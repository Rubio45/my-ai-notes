//
//  NoteEditorView.swift
//  myAINotes
//
//  Created by Alex Diaz on 26/3/26.
//

import SwiftUI

@MainActor
struct NoteEditorView: View {
    @Environment(\.appContainer) private var container

    @State private var title: String
    @State private var content: String
    @State private var isSaving: Bool = false
    @State private var lastSaveDate: Date = .now
    @State private var aiWorking: Bool = false

    private let note: Note

    init(note: Note) {
        self.note = note
        _title = State(initialValue: note.title)
        _content = State(initialValue: note.content)
    }

    var body: some View {
        VStack(spacing: 0) {
            Form {
                Section {
                    TextField("Título", text: $title)
                        .font(.title3.weight(.semibold))
                }
                Section {
                    TextEditor(text: $content)
                        .frame(minHeight: 240)
                        .font(.body)
                } footer: {
                    HStack(spacing: 8) {
                        if isSaving {
                            ProgressView()
                                .scaleEffect(0.8)
                        }
                        Text("Último guardado: \(lastSaveDate.formatted(date: .abbreviated, time: .shortened))")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }

                Section("IA") {
                    HStack {
                        Button {
                            runAI { try await container.aiService.improve(text: content) }
                        } label: {
                            Label("Mejorar", systemImage: "wand.and.stars")
                        }
                        .buttonStyle(.bordered)
                        .disabled(aiWorking)

                        Button {
                            runAI { try await container.aiService.summarize(text: content) }
                        } label: {
                            Label("Resumir", systemImage: "text.justify.trailing")
                        }
                        .buttonStyle(.bordered)
                        .disabled(aiWorking)
                    }
                    HStack {
                        Button {
                            runAI { try await container.aiService.outline(text: content) }
                        } label: {
                            Label("Esquema", systemImage: "list.bullet.rectangle.portrait")
                        }
                        .buttonStyle(.bordered)
                        .disabled(aiWorking)

                        Button {
                            runAI { try await container.aiService.correctSpelling(text: content) }
                        } label: {
                            Label("Ortografía", systemImage: "checkmark.seal")
                        }
                        .buttonStyle(.bordered)
                        .disabled(aiWorking)
                    }
                    Button {
                        runAI { try await container.aiService.studyVersion(text: content) }
                    } label: {
                        Label("Versión estudio", systemImage: "graduationcap")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(aiWorking)
                }
            }
        }
        .navigationTitle("Editar nota")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                if aiWorking {
                    ProgressView()
                }
            }
        }
        .onChange(of: title) { _ in scheduleSave() }
        .onChange(of: content) { _ in scheduleSave() }
        .onDisappear { saveNow() }
    }

    // MARK: - Guardado automático (debounce)

    @State private var saveTask: Task<Void, Never>?

    private func scheduleSave() {
        saveTask?.cancel()
        saveTask = Task { @MainActor in
            try? await Task.sleep(nanoseconds: 600_000_000)
            await saveNow()
        }
    }

    @discardableResult
    private func saveNow() -> Bool {
        saveTask?.cancel()
        isSaving = true
        defer { isSaving = false }
        do {
            try container.notesRepository.update(note: note, title: title, content: content)
            lastSaveDate = .now
            // Si estaba sincronizada, update() ya marca .pending; encolamos sync
            container.syncService.enqueueSync(note: note)
            return true
        } catch {
            print("Error guardando nota: \(error)")
            return false
        }
    }

    // MARK: - IA helpers

    private func runAI(_ op: @escaping () async throws -> String) {
        Task { @MainActor in
            aiWorking = true
            defer { aiWorking = false }
            do {
                let result = try await op()
                content = result
            } catch {
                print("Error IA: \(error)")
            }
        }
    }
}
