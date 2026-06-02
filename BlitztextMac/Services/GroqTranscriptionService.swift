import Foundation

enum GroqTranscriptionError: LocalizedError {
    case noFile
    case notConfigured
    case networkError(String)
    case apiError(String)
    case invalidAPIKey
    case rateLimitExceeded
    case fileTooLarge
    case serviceUnavailable

    var errorDescription: String? {
        switch self {
        case .noFile:
            return "Keine Audiodatei gefunden."
        case .notConfigured:
            return "Groq API Key fehlt. Bitte in den Einstellungen hinterlegen."
        case .networkError(let msg):
            return "Netzwerkfehler: \(msg)"
        case .apiError(let msg):
            return "Groq-Fehler: \(msg)"
        case .invalidAPIKey:
            return "Groq API Key ungültig. Bitte prüfen."
        case .rateLimitExceeded:
            return "Groq Rate Limit erreicht. Kurz warten und erneut versuchen."
        case .fileTooLarge:
            return "Audiodatei zu groß für Groq."
        case .serviceUnavailable:
            return "Groq ist gerade nicht erreichbar. Bitte erneut versuchen."
        }
    }
}

private struct GroqTranscriptionErrorResponse: Decodable {
    struct APIError: Decodable {
        let message: String?
    }
    let error: APIError?
}

enum GroqTranscriptionService {
    private static let transcriptionsURL = URL(string: "https://api.groq.com/openai/v1/audio/transcriptions")!

    private static let session: URLSession = {
        let config = URLSessionConfiguration.ephemeral
        config.waitsForConnectivity = false
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        config.timeoutIntervalForRequest = 60
        config.timeoutIntervalForResource = 60
        return URLSession(configuration: config)
    }()

    static func transcribe(
        audioURL: URL,
        customTerms: [String] = [],
        language: String? = nil,
        model: String = GroqTranscriptionModel.defaultModel.rawValue
    ) async throws -> String {
        guard let apiKey = KeychainService.load(key: .groqAPIKey) else {
            throw GroqTranscriptionError.notConfigured
        }

        return try await Task.detached(priority: .userInitiated) {
            defer {
                try? FileManager.default.removeItem(at: audioURL)
            }

            let boundary = UUID().uuidString
            var request = URLRequest(url: transcriptionsURL)
            request.httpMethod = "POST"
            request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
            request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
            request.setValue("text/plain, application/json", forHTTPHeaderField: "Accept")
            request.timeoutInterval = 60
            request.cachePolicy = .reloadIgnoringLocalCacheData

            let audioData = try Data(contentsOf: audioURL, options: [.mappedIfSafe])

            var body = Data()
            body.appendString("--\(boundary)\r\n")
            body.appendString("Content-Disposition: form-data; name=\"file\"; filename=\"audio.m4a\"\r\n")
            body.appendString("Content-Type: audio/m4a\r\n\r\n")
            body.append(audioData)
            body.appendString("\r\n")

            body.appendString("--\(boundary)\r\n")
            body.appendString("Content-Disposition: form-data; name=\"model\"\r\n\r\n")
            body.appendString(model)
            body.appendString("\r\n")

            body.appendString("--\(boundary)\r\n")
            body.appendString("Content-Disposition: form-data; name=\"response_format\"\r\n\r\n")
            body.appendString("text")
            body.appendString("\r\n")

            if !customTerms.isEmpty {
                let prompt = "Eigennamen und Begriffe: \(customTerms.joined(separator: ", "))"
                body.appendString("--\(boundary)\r\n")
                body.appendString("Content-Disposition: form-data; name=\"prompt\"\r\n\r\n")
                body.appendString(prompt)
                body.appendString("\r\n")
            }

            if let language, !language.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                body.appendString("--\(boundary)\r\n")
                body.appendString("Content-Disposition: form-data; name=\"language\"\r\n\r\n")
                body.appendString(language.trimmingCharacters(in: .whitespacesAndNewlines))
                body.appendString("\r\n")
            }

            body.appendString("--\(boundary)--\r\n")
            request.httpBody = body

            let (data, response) = try await session.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw GroqTranscriptionError.networkError("Ungültige Antwort")
            }

            switch httpResponse.statusCode {
            case 200: break
            case 401: throw GroqTranscriptionError.invalidAPIKey
            case 413: throw GroqTranscriptionError.fileTooLarge
            case 429: throw GroqTranscriptionError.rateLimitExceeded
            case 503: throw GroqTranscriptionError.serviceUnavailable
            default:
                throw GroqTranscriptionError.apiError(
                    groqErrorMessage(from: data) ?? "Status \(httpResponse.statusCode)"
                )
            }

            guard let text = String(data: data, encoding: .utf8)?
                .trimmingCharacters(in: .whitespacesAndNewlines),
                  !text.isEmpty else {
                throw GroqTranscriptionError.apiError("Transkription fehlgeschlagen.")
            }

            return text
        }.value
    }

    private static func groqErrorMessage(from data: Data) -> String? {
        (try? JSONDecoder().decode(GroqTranscriptionErrorResponse.self, from: data))?.error?.message
    }
}

private extension Data {
    mutating func appendString(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}
