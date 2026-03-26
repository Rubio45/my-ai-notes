import SwiftUI

struct ChatView: View {
    @State private var viewModel = ChatViewModel()
    @FocusState private var inputFocused: Bool

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                messageList
                Divider()
                inputBar
            }
            .navigationTitle("Asistente IA")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    if !viewModel.messages.isEmpty {
                        Button(role: .destructive) {
                            viewModel.clearHistory()
                        } label: {
                            Image(systemName: "trash")
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Message list

    private var messageList: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 12) {
                    if viewModel.messages.isEmpty {
                        emptySuggestions
                    } else {
                        ForEach(viewModel.messages) { message in
                            ChatBubbleView(message: message)
                                .id(message.id)
                        }

                        if let error = viewModel.errorMessage {
                            errorBanner(error)
                        }
                    }
                    Color.clear.frame(height: 8).id("bottom")
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
            }
            .onChange(of: viewModel.messages.count) { _, _ in
                withAnimation(.easeOut(duration: 0.2)) {
                    proxy.scrollTo("bottom", anchor: .bottom)
                }
            }
            .onChange(of: viewModel.messages.last?.content) { _, _ in
                proxy.scrollTo("bottom", anchor: .bottom)
            }
        }
    }

    // MARK: - Empty state suggestions

    private var emptySuggestions: some View {
        VStack(spacing: 24) {
            Spacer(minLength: 60)

            Image(systemName: "sparkles")
                .font(.system(size: 52))
                .foregroundStyle(Color.accentColor.opacity(0.8))
                .symbolRenderingMode(.hierarchical)

            Text("¿En qué puedo ayudarte?")
                .font(.title3.bold())

            VStack(spacing: 10) {
                ForEach(suggestions, id: \.self) { text in
                    Button {
                        viewModel.inputText = text
                        viewModel.send()
                    } label: {
                        Text(text)
                            .font(.subheadline)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 14))
                            .foregroundStyle(.primary)
                    }
                }
            }

            Spacer()
        }
        .frame(maxWidth: .infinity)
    }

    private let suggestions = [
        "Ayúdame a organizar mis ideas",
        "¿Cómo puedo mejorar mis notas?",
        "Resume el tema de inteligencia artificial",
        "Dame consejos para estudiar mejor"
    ]

    // MARK: - Input bar

    private var inputBar: some View {
        HStack(alignment: .bottom, spacing: 10) {
            TextField("Escribe un mensaje...", text: $viewModel.inputText, axis: .vertical)
                .lineLimit(1...5)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 20))
                .focused($inputFocused)
                .onSubmit {
                    if !viewModel.isStreaming {
                        viewModel.send()
                    }
                }
                .submitLabel(.send)

            sendButton
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(.bar)
    }

    private var sendButton: some View {
        Button {
            viewModel.send()
            inputFocused = false
        } label: {
            Group {
                if viewModel.isStreaming {
                    ProgressView()
                        .tint(.white)
                        .scaleEffect(0.9)
                } else {
                    Image(systemName: "arrow.up")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.white)
                }
            }
            .frame(width: 36, height: 36)
            .background(
                viewModel.inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || viewModel.isStreaming
                    ? Color.secondary.opacity(0.4)
                    : Color.accentColor,
                in: Circle()
            )
        }
        .disabled(viewModel.inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || viewModel.isStreaming)
        .animation(.easeInOut(duration: 0.15), value: viewModel.isStreaming)
    }

    // MARK: - Error banner

    private func errorBanner(_ message: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: "exclamationmark.triangle.fill")
            Text(message).font(.footnote)
        }
        .foregroundStyle(.white)
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(Color.red.opacity(0.85), in: RoundedRectangle(cornerRadius: 12))
        .padding(.top, 4)
    }
}

// MARK: - Chat bubble

private struct ChatBubbleView: View {
    let message: ChatMessage

    private var isUser: Bool { message.role == .user }

    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            if isUser { Spacer(minLength: 50) }

            if !isUser {
                assistantAvatar
            }

            bubbleContent
                .frame(maxWidth: UIScreen.main.bounds.width * 0.75, alignment: isUser ? .trailing : .leading)

            if !isUser { Spacer(minLength: 50) }
        }
        .frame(maxWidth: .infinity, alignment: isUser ? .trailing : .leading)
    }

    private var assistantAvatar: some View {
        ZStack {
            Circle()
                .fill(Color.accentColor)
                .frame(width: 30, height: 30)
            Image(systemName: "sparkles")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.white)
        }
        .padding(.bottom, 2)
    }

    @ViewBuilder
    private var bubbleContent: some View {
        if message.content.isEmpty && message.role == .assistant {
            typingIndicator
        } else {
            Text(message.content)
                .textSelection(.enabled)
                .font(.body)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(isUser ? Color.accentColor : Color(.secondarySystemBackground),
                            in: BubbleShape(isUser: isUser))
                .foregroundStyle(isUser ? .white : .primary)
        }
    }

    private var typingIndicator: some View {
        HStack(spacing: 4) {
            ForEach(0..<3, id: \.self) { i in
                Circle()
                    .fill(Color.secondary.opacity(0.5))
                    .frame(width: 7, height: 7)
                    .offset(y: typingOffset(for: i))
                    .animation(
                        .easeInOut(duration: 0.5)
                        .repeatForever()
                        .delay(Double(i) * 0.15),
                        value: UUID()
                    )
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(Color(.secondarySystemBackground), in: BubbleShape(isUser: false))
    }

    private func typingOffset(for index: Int) -> CGFloat { 0 }
}

// MARK: - Bubble shape

private struct BubbleShape: Shape {
    let isUser: Bool

    func path(in rect: CGRect) -> Path {
        let radius: CGFloat = 16
        let tailSize: CGFloat = 6
        var path = Path()

        let tl = CGPoint(x: rect.minX, y: rect.minY)
        let tr = CGPoint(x: rect.maxX, y: rect.minY)
        let bl = CGPoint(x: rect.minX, y: rect.maxY)
        let br = CGPoint(x: rect.maxX, y: rect.maxY)

        if isUser {
            path.move(to: CGPoint(x: tl.x + radius, y: tl.y))
            path.addLine(to: CGPoint(x: tr.x - radius, y: tr.y))
            path.addQuadCurve(to: CGPoint(x: tr.x, y: tr.y + radius), control: tr)
            path.addLine(to: CGPoint(x: br.x, y: br.y - radius - tailSize))
            path.addQuadCurve(to: CGPoint(x: br.x - radius, y: br.y), control: br)
            path.addLine(to: CGPoint(x: bl.x + radius, y: bl.y))
            path.addQuadCurve(to: CGPoint(x: bl.x, y: bl.y - radius), control: bl)
            path.addLine(to: CGPoint(x: tl.x, y: tl.y + radius))
            path.addQuadCurve(to: CGPoint(x: tl.x + radius, y: tl.y), control: tl)
        } else {
            path.move(to: CGPoint(x: tl.x + radius, y: tl.y))
            path.addLine(to: CGPoint(x: tr.x - radius, y: tr.y))
            path.addQuadCurve(to: CGPoint(x: tr.x, y: tr.y + radius), control: tr)
            path.addLine(to: CGPoint(x: br.x, y: br.y - radius))
            path.addQuadCurve(to: CGPoint(x: br.x - radius, y: br.y), control: br)
            path.addLine(to: CGPoint(x: bl.x + radius, y: bl.y))
            path.addQuadCurve(to: CGPoint(x: bl.x, y: bl.y - radius - tailSize), control: bl)
            path.addLine(to: CGPoint(x: tl.x, y: tl.y + radius))
            path.addQuadCurve(to: CGPoint(x: tl.x + radius, y: tl.y), control: tl)
        }

        path.closeSubpath()
        return path
    }
}

#Preview {
    ChatView()
}
