import Foundation

enum GroqLLMError: LocalizedError {
    case notConfigured
    case networkError(String)
    case apiError(String)
    case noContent
    case invalidAPIKey
    case rateLimitExceeded
    case serviceUnavailable

    var errorDescription: String? {
        switch self {
        case .notConfigured:
            return "Groq API Key fehlt. Bitte in den Einstellungen hinterlegen."
        case .networkError(let msg):
            return "Verbindungsproblem: \(msg)"
        case .apiError(let msg):
            return "Groq-Fehler: \(msg)"
        case .noContent:
            return "Keine Antwort erhalten. Bitte nochmal versuchen."
        case .invalidAPIKey:
            return "Groq API Key ungültig. Bitte prüfen."
        case .rateLimitExceeded:
            return "Groq Rate Limit erreicht. Kurz warten und erneut versuchen."
        case .serviceUnavailable:
            return "Groq ist gerade nicht erreichbar. Bitte erneut versuchen."
        }
    }
}

private struct GroqChatResponse: Decodable {
    struct Choice: Decodable {
        struct Message: Decodable {
            let content: String?
        }
        let message: Message?
    }
    let choices: [Choice]?
}

private struct GroqErrorResponse: Decodable {
    struct APIError: Decodable {
        let message: String?
    }
    let error: APIError?
}

enum GroqLLMService {
    private static let chatCompletionsURL = URL(string: "https://api.groq.com/openai/v1/chat/completions")!

    private static let session: URLSession = {
        let config = URLSessionConfiguration.ephemeral
        config.waitsForConnectivity = false
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        config.timeoutIntervalForRequest = 45
        config.timeoutIntervalForResource = 45
        return URLSession(configuration: config)
    }()

    static func improve(
        text: String,
        settings: TextImprovementSettings,
        model: String = GroqChatModel.defaultModel.rawValue
    ) async throws -> String {
        try await complete(
            text: text,
            systemPrompt: buildSystemPrompt(settings: settings),
            model: model,
            temperature: 0.3
        )
    }

    static func dampfAblassen(
        text: String,
        systemPrompt: String,
        model: String = GroqChatModel.defaultModel.rawValue
    ) async throws -> String {
        try await complete(
            text: text,
            systemPrompt: systemPrompt,
            model: model,
            temperature: 0.4
        )
    }

    static func addEmojis(
        text: String,
        settings: EmojiTextSettings,
        model: String = GroqChatModel.defaultModel.rawValue
    ) async throws -> String {
        try await complete(
            text: text,
            systemPrompt: buildEmojiSystemPrompt(density: settings.emojiDensity),
            model: model,
            temperature: 0.3
        )
    }

    // Used by the API test button in Settings (Phase 3).
    static func testConnection(model: String = GroqChatModel.defaultModel.rawValue) async throws {
        _ = try await complete(
            text: "hi",
            systemPrompt: "Reply with one word.",
            model: model,
            temperature: 0,
            maxTokens: 1
        )
    }

    private static func complete(
        text: String,
        systemPrompt: String,
        model: String,
        temperature: Double,
        maxTokens: Int? = nil
    ) async throws -> String {
        guard let apiKey = KeychainService.load(key: .groqAPIKey) else {
            throw GroqLLMError.notConfigured
        }

        var bodyDict: [String: Any] = [
            "model": model,
            "messages": [
                ["role": "system", "content": systemPrompt],
                ["role": "user",   "content": text]
            ],
            "temperature": temperature
        ]
        if let maxTokens {
            bodyDict["max_tokens"] = maxTokens
        }

        var request = URLRequest(url: chatCompletionsURL)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 45
        request.httpBody = try JSONSerialization.data(withJSONObject: bodyDict)

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw GroqLLMError.networkError("Keine gültige Antwort")
        }

        switch httpResponse.statusCode {
        case 200: break
        case 401: throw GroqLLMError.invalidAPIKey
        case 429: throw GroqLLMError.rateLimitExceeded
        case 503: throw GroqLLMError.serviceUnavailable
        default:
            throw GroqLLMError.apiError(
                groqErrorMessage(from: data) ?? "Status \(httpResponse.statusCode)"
            )
        }

        let result = try JSONDecoder().decode(GroqChatResponse.self, from: data)
        guard let content = result.choices?.first?.message?.content,
              !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw GroqLLMError.noContent
        }

        return content.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private static func groqErrorMessage(from data: Data) -> String? {
        (try? JSONDecoder().decode(GroqErrorResponse.self, from: data))?.error?.message
    }

    private static func buildEmojiSystemPrompt(density: EmojiTextSettings.EmojiDensity) -> String {
        let densityInstruction: String
        switch density {
        case .wenig:
            densityInstruction = "Setze nur vereinzelt Emojis ein, maximal 1-2 pro Absatz."
        case .mittel:
            densityInstruction = "Setze regelmaessig passende Emojis ein, etwa alle 1-2 Saetze."
        case .viel:
            densityInstruction = "Setze grosszuegig Emojis ein, gerne mehrere pro Satz."
        }
        return "Du erhaeltst ein gesprochenes Transkript. Gib den Text moeglichst originalgetreu zurueck, aber fuege passende Emojis ein. \(densityInstruction) Korrigiere offensichtliche Sprach- und Grammatikfehler. Behalte den Stil und die Bedeutung bei. Gib NUR den Text mit Emojis zurueck, keine Erklaerungen."
    }

    private static func buildSystemPrompt(settings: TextImprovementSettings) -> String {
        if !settings.systemPrompt.isEmpty {
            var prompt = settings.systemPrompt
            if !settings.customTerms.isEmpty {
                prompt += "\n\nWichtig: Diese Eigennamen und Fachbegriffe muessen exakt so geschrieben werden: \(settings.customTerms.joined(separator: ", "))"
            }
            return prompt
        }

        var prompt = """
        Du bist ein Lektor und Schreibassistent. Verbessere den folgenden Text:
        - Korrigiere Rechtschreibung und Grammatik
        - Verbessere die Formulierung und den Lesefluss
        - Behalte die urspruengliche Bedeutung bei
        - Gib NUR den verbesserten Text zurueck, keine Erklaerungen
        """

        switch settings.tone {
        case .formal:
            prompt += "\n- Verwende einen formellen, professionellen Ton"
        case .neutral:
            prompt += "\n- Verwende einen neutralen, klaren Ton"
        case .casual:
            prompt += "\n- Verwende einen lockeren, natuerlichen Ton"
        }

        if !settings.customTerms.isEmpty {
            prompt += "\n\nWichtig: Diese Eigennamen und Fachbegriffe muessen exakt so geschrieben werden: \(settings.customTerms.joined(separator: ", "))"
        }

        if !settings.context.isEmpty {
            prompt += "\n\nKontext: \(settings.context)"
        }

        return prompt
    }
}
