import Foundation

final class OpenAIClient {
    static let shared = OpenAIClient()
    private init() {}

    let apiKey = ProcessInfo.processInfo.environment["OPENAI_API_KEY"] ?? ""
    private let endpoint = URL(string: "https://api.openai.com/v1/chat/completions")!

    private let systemPrompt = """
        Eres un asistente inteligente integrado en una app de notas. \
        Eres conciso, útil y amigable. Respondes en el mismo idioma en el que el usuario escribe.
        """

    /// Sends the current conversation history and streams the assistant reply token by token.
    /// `onToken` is called on the main actor for each new piece of text received.
    func streamCompletion(
        messages: [ChatMessage],
        onToken: @escaping @MainActor (String) -> Void,
        onFinish: @escaping @MainActor () -> Void,
        onError: @escaping @MainActor (Error) -> Void
    ) {
        let openAIMessages: [OpenAIMessage] = buildMessages(from: messages)
        let body = OpenAIChatRequest(messages: openAIMessages, stream: true)

        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("application/json",     forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)",      forHTTPHeaderField: "Authorization")
        request.timeoutInterval = 60

        do {
            request.httpBody = try JSONEncoder().encode(body)
        } catch {
            Task { @MainActor in onError(error) }
            return
        }

        Task {
            do {
                let (asyncBytes, response) = try await URLSession.shared.bytes(for: request)

                guard let http = response as? HTTPURLResponse else {
                    throw OpenAIError.badResponse
                }
                guard (200...299).contains(http.statusCode) else {
                    throw OpenAIError.httpError(http.statusCode)
                }

                for try await line in asyncBytes.lines {
                    guard line.hasPrefix("data: ") else { continue }
                    let payload = String(line.dropFirst(6))
                    if payload == "[DONE]" { break }

                    guard let data = payload.data(using: .utf8),
                          let chunk = try? JSONDecoder().decode(OpenAIStreamChunk.self, from: data),
                          let text  = chunk.choices.first?.delta.content
                    else { continue }

                    await MainActor.run { onToken(text) }
                }

                await MainActor.run { onFinish() }
            } catch {
                await MainActor.run { onError(error) }
            }
        }
    }

    // MARK: - Private helpers

    private func buildMessages(from history: [ChatMessage]) -> [OpenAIMessage] {
        var result = [OpenAIMessage(role: "system", content: systemPrompt)]
        result += history.map { OpenAIMessage(role: $0.role.rawValue, content: $0.content) }
        return result
    }
}

// MARK: - Errors

enum OpenAIError: LocalizedError {
    case badResponse
    case httpError(Int)

    var errorDescription: String? {
        switch self {
        case .badResponse:        return "Respuesta inválida del servidor."
        case .httpError(let code): return "Error del servidor: \(code)."
        }
    }
}
