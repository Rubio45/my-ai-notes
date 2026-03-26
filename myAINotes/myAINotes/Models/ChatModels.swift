import Foundation

// MARK: - Domain model

struct ChatMessage: Identifiable, Equatable {
    let id: UUID
    let role: Role
    var content: String
    let createdAt: Date

    enum Role: String {
        case user      = "user"
        case assistant = "assistant"
        case system    = "system"
    }

    init(id: UUID = UUID(), role: Role, content: String, createdAt: Date = .now) {
        self.id        = id
        self.role      = role
        self.content   = content
        self.createdAt = createdAt
    }
}

// MARK: - OpenAI request / response

struct OpenAIChatRequest: Encodable {
    let model: String
    let messages: [OpenAIMessage]
    let stream: Bool

    init(model: String = "gpt-4o-mini", messages: [OpenAIMessage], stream: Bool = true) {
        self.model    = model
        self.messages = messages
        self.stream   = stream
    }
}

struct OpenAIMessage: Encodable {
    let role: String
    let content: String
}

// MARK: - Streaming delta

struct OpenAIStreamChunk: Decodable {
    let choices: [StreamChoice]

    struct StreamChoice: Decodable {
        let delta: Delta
        let finishReason: String?

        enum CodingKeys: String, CodingKey {
            case delta
            case finishReason = "finish_reason"
        }
    }

    struct Delta: Decodable {
        let content: String?
    }
}
