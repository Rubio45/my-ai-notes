import Foundation
import Observation

@Observable
final class ChatViewModel {
    private(set) var messages: [ChatMessage] = []
    private(set) var isStreaming = false
    private(set) var errorMessage: String?

    /// Streaming assistant message currently being built.
    private var streamingMessageID: UUID?

    var inputText = ""

    // MARK: - Public API

    func send() {
        let text = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty, !isStreaming else { return }
        inputText = ""
        errorMessage = nil

        let userMessage = ChatMessage(role: .user, content: text)
        messages.append(userMessage)

        startStreaming()
    }

    func clearHistory() {
        guard !isStreaming else { return }
        messages.removeAll()
    }

    // MARK: - Private

    private func startStreaming() {
        isStreaming = true

        let placeholderID = UUID()
        streamingMessageID = placeholderID
        let placeholder = ChatMessage(id: placeholderID, role: .assistant, content: "")
        messages.append(placeholder)

        OpenAIClient.shared.streamCompletion(
            messages: messages.dropLast(),   // exclude empty placeholder
            onToken: { [weak self] token in
                self?.appendToken(token, to: placeholderID)
            },
            onFinish: { [weak self] in
                self?.isStreaming       = false
                self?.streamingMessageID = nil
            },
            onError: { [weak self] error in
                self?.handleStreamError(error, placeholderID: placeholderID)
            }
        )
    }

    private func appendToken(_ token: String, to id: UUID) {
        guard let idx = messages.firstIndex(where: { $0.id == id }) else { return }
        messages[idx] = ChatMessage(
            id: messages[idx].id,
            role: messages[idx].role,
            content: messages[idx].content + token,
            createdAt: messages[idx].createdAt
        )
    }

    private func handleStreamError(_ error: Error, placeholderID: UUID) {
        messages.removeAll { $0.id == placeholderID }
        errorMessage  = error.localizedDescription
        isStreaming   = false
        streamingMessageID = nil
    }
}
