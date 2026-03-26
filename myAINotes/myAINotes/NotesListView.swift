//
//  NotesListView.swift
//  myAINotes
//
//  Created by Alex Diaz on 26/3/26.
//

import SwiftUI
import SwiftData

@MainActor
struct NotesListView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.appContainer) private var container

    @State private var searchText: String = ""
    @State private var notes: [Note] = []
    @State private var isPresentingNewNote: Bool = false

    var body: some View {
        NavigationStack {
            Group {
                if notes.isEmpty {
                    emptyState
                } else {
                    list
                }
            }
            .navigationTitle("AI Notes")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isPresentingNewNote = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .symbolRenderingMode(.hierarchical)
                            .imageScale(.large)
                    }
                    .accessibilityLabel("Crear nota")
                }
            }
            .searchable(text: $searchText, prompt: "Buscar notas")
            .onChange(of: searchText) { _ in load() }
            .onAppear { bootstrapIfNeeded(); load() }
            .sheet(isPresented: $isPresentingNewNote) {
                NewNoteSheet { title, content in
                    do {
                        let note = try container.notesRepository.create(title: title, content: content)
                        // Encolamos la sincronización
                        Task { await container.syncService.enqueueSync(note: note) }
                        load()
                    } catch {
                        // En una app real, mostraríamos un alert
                        print("Error creando nota: \(error)")
                    }
                }
                .presentationDetents([.medium, .large])
            }
        }
    }

    private var list: some View {
        List {
            ForEach(notes, id: \.id) { note in
                HStack(alignment: .top, spacing: 12) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(note.title.isEmpty ? "Sin título" : note.title)
                            .font(.headline)
                            .lineLimit(1)
                        Text(note.content)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                        Text(note.updatedAt, style: .date)
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
                    Spacer()
                    syncBadge(for: note.syncState)
                }
                .padding(.vertical, 6)
                .contentShape(Rectangle())
                // Navegación a detalle/editor llegará en el siguiente paso
            }
            .onDelete(perform: delete)
        }
        .listStyle(.insetGrouped)
        .animation(.easeInOut, value: notes)
    }

    private func syncBadge(for state: SyncState) -> some View {
        let (text, color, symbol): (String, Color, String) = {
            switch state {
            case .localOnly:   return ("Local", .gray, "internaldrive")
            case .pending:     return ("Pendiente", .orange, "arrow.triangle.2.circlepath")
            case .synced:      return ("Sincronizada", .green, "checkmark.seal.fill")
            case .error:       return ("Error", .red, "exclamationmark.triangle.fill")
            }
        }()
        return Label {
            Text(text).font(.caption2)
        } icon: {
            Image(systemName: symbol)
        }
        .labelStyle(.iconOnly)
        .foregroundStyle(color)
        .padding(6)
        .background(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(color.opacity(0.12))
        )
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "square.and.pencil.circle.fill")
                .symbolRenderingMode(.hierarchical)
                .font(.system(size: 64))
                .foregroundStyle(.secondary)
            Text("Crea tu primera nota")
                .font(.title3.weight(.semibold))
            Text("Escribe ideas rápidas y mejora tu contenido con IA. Funciona sin conexión.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal)
            Button {
                isPresentingNewNote = true
            } label: {
                Label("Nueva nota", systemImage: "plus.circle.fill")
                    .font(.headline)
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }

    private func delete(at offsets: IndexSet) {
        for index in offsets {
            let note = notes[index]
            do {
                try container.notesRepository.delete(note: note)
            } catch {
                print("Error eliminando nota: \(error)")
            }
        }
        load()
    }

    private func load() {
        do {
            notes = try container.notesRepository.fetchAll(search: searchText)
        } catch {
            print("Error cargando notas: \(error)")
        }
    }

    private func bootstrapIfNeeded() {
        // Reconstruye el container live con el ModelContext real del entorno.
        // Esto asegura que AppContainer.live use el mismo context del Scene.
        if container.notesRepository is SwiftDataNotesRepository == false {
            let repo = SwiftDataNotesRepository(context: modelContext)
            let sync = MockSyncService(context: modelContext)
            let ai = MockAIChatService()
            let newContainer = AppContainer(notesRepository: repo, syncService: sync, aiService: ai)
            // Inyectamos al Environment.
            // Nota: No podemos mutar Environment directamente aquí, pero el .environment(container)
            // se establece en myAINotesApp. Para simplificar el paso 1, asumimos que ya llega un container válido.
            // Si quisieras, podemos ajustar myAINotesApp para construir el container con modelContext.
        }
    }
}

private struct NewNoteSheet: View {
    var onCreate: (String, String) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var title: String = ""
    @State private var content: String = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Título") {
                    TextField("Escribe un título", text: $title)
                }
                Section("Contenido") {
                    TextEditor(text: $content)
                        .frame(minHeight: 160)
                }
            }
            .navigationTitle("Nueva nota")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") {
                        onCreate(title, content)
                        dismiss()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
                              content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}
