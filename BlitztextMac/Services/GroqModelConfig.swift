import Foundation

enum GroqTranscriptionModel: String, CaseIterable, Identifiable, Codable {
    case turbo = "whisper-large-v3-turbo"
    case large = "whisper-large-v3"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .turbo: return "Whisper Large V3 Turbo (schnell)"
        case .large: return "Whisper Large V3 (genauer)"
        }
    }

    static let defaultModel = GroqTranscriptionModel.turbo
}

enum GroqChatModel: String, CaseIterable, Identifiable, Codable {
    case llama70b = "llama-3.3-70b-versatile"
    case llama8b  = "llama-3.1-8b-instant"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .llama70b: return "Llama 3.3 70B (empfohlen)"
        case .llama8b:  return "Llama 3.1 8B (schnell)"
        }
    }

    static let defaultModel = GroqChatModel.llama70b
}
