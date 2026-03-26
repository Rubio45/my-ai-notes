//
//  AIChatView.swift
//  myAINotes
//
//  Created by Alex Diaz on 26/3/26.
//

import SwiftUI

@MainActor
struct AIChatView: View {
    @Environment(\.appContainer) private var container

    @State private var messages: [AIMessage] = [
        AIMessage(role: .assistant, text: "Hola 👋 Soy tu asistente de estudio. Puedo ayudarte a mejorar tus notas, resumir y organizar ideas. ¿En qué te ayudo hoy?")
    ]
    @State private var input: String = ""
    @State private var isSending: Bool = false
    @FocusState private var inputFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(messages) { msg in
                            MessageBubble(message: msg, onAction: { action in
                                handleAction(action, for: msg)
                            })
                            .id(msg.id)
                            .padding(.horizontal)
                        }
                    }
                    .padding(.vertical, 12)
                }
                .onChange(of: messages.count) { _ in
                    withAnimation(.easeInOut) {
                        if let last = messages.last {
                            proxy.scrollTo(last.id, anchor: .bottom)
                        }
                    }
                }
            }

            Divider()

            inputBar
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(.bar)
        }
        .navigationTitle("Chat con IA")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if isSending {
                ProgressView()
            }
        }
    }

    private var inputBar: some View {
        HStack(spacing: 8) {
            TextField("Escribe tu mensaje...", text: $input, axis: .vertical)
                .lineLimit(1...4)
                .textFieldStyle(.roundedBorder)
                .focused($inputFocused)
                .onSubmit { send() }

            Button {
                send()
            } label: {
                Image(systemName: "paperplane.fill")
                    .imageScale(.medium)
                    .padding(8)
            }
            .buttonStyle(.borderedProminent)
            .disabled(input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isSending)
        }
    }

    private func send() {
        let trimmed = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        input = ""
        inputFocused = false

        let userMessage = AIMessage(role: .user, text: trimmed)
        messages.append(userMessage)

        isSending = true
        Task { @MainActor in
            defer { isSending = false }
            do {
                let reply = try await container.aiService.send(message: trimmed, context: messages)
                messages.append(reply)
            } catch {
                let errorMsg = AIMessage(role: .assistant, text: "Lo siento, hubo un error procesando tu mensaje.")
                messages.append(errorMsg)
            }
        }
    }

    private enum QuickAction {
        case saveAsNote
        case addToExisting
        case copyText
        case summarizeMore
    }

    private func handleAction(_ action: QuickAction, for message: AIMessage) {
        switch action {
        case .saveAsNote:
            do {
                let title = makeTitle(from: message.text)
                let note = try container.notesRepository.create(title: title, content: message.text)
                container.syncService.enqueueSync(note: note)
            } catch {
                print("Error guardando como nota: \(error)")
            }
        case .addToExisting:
            // En la siguiente iteración: presentar un sheet para elegir nota existente y anexar texto.
            print("Añadir a existente (pendiente de UI de selección)")
        case .copyText:
            UIPasteboard.general.string = message.text
        case .summarizeMore:
            Task { @MainActor in
                do {
                    let summary = try await container.aiService.summarize(text: message.text)
                    messages.append(AIMessage(role: .assistant, text: summary))
                } catch {
                    print("Error resumiendo más: \(error)")
                }
            }
        }
    }

    private func makeTitle(from text: String) -> String {
        let firstLine = text.split(separator: "\n").first.map(String.init) ?? text
        return String(firstLine.prefix(60))
    }
}

private struct MessageBubble: View {
    let message: AIMessage
    var onAction: (AIChatView.QuickAction) -> Void

    var isUser: Bool { message.role == .user }

    var body: some View {
        HStack(alignment: .bottom) {
            if isUser { Spacer(minLength: 40) }

            VStack(alignment: .leading, spacing: 8) {
                Text(message.text)
                    .font(.body)
                    .foregroundStyle(isUser ? .white : .primary)
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(isUser ? Color.accentColor.gradient : Color(.secondarySystemBackground))
                    )
                if !isUser {
                    actionRow
                }
            }

            if !isUser { Spacer(minLength: 40) }
        }
        .transition(.move(edge: isUser ? .trailing : .leading).combined(with: .opacity))
    }

    private var actionRow: some View {
        HStack(spacing: 8) {
            Button {
                onAction(.saveAsNote)
            } label: {
                Label("Guardar", systemImage: "square.and.arrow.down")
            }
            .buttonStyle(.bordered)

            Button {
                onAction(.addToExisting)
            } label: {
                Label("Añadir", systemImage: "text.badge.plus")
            }
            .buttonStyle(.bordered)

            Button {
                onAction(.copyText)
            } label: {
                Image(systemName: "doc.on.doc")
            }
            .buttonStyle(.bordered)

            Button {
                onAction(.summarizeMore)
            } label: {
                Image(systemName: "text.line.first.and.arrowtriangle.forward")
            }
            .buttonStyle(.bordered)
        }
        .font(.caption)
        .foregroundStyle(.secondary)
    }
}
