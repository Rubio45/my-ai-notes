import SwiftUI

struct NoteDetailView: View {
    @Environment(NotesViewModel.self) private var notesViewModel
    @Environment(\.dismiss) private var dismiss

    let note: NoteInDb
    @State private var currentNote: NoteInDb
    @State private var showEditor = false
    @State private var showDeleteAlert = false

    init(note: NoteInDb) {
        self.note = note
        _currentNote = State(initialValue: note)
    }

    var body: some View {
        ZStack(alignment: .top) {
            // Colored background tint
            note.accentColor
                .opacity(0.07)
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    coloredHeader
                    contentBody
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(note.accentColor.opacity(0.07), for: .navigationBar)
        .toolbar { toolbarContent }
        .sheet(isPresented: $showEditor) {
            NoteEditorView(noteToEdit: currentNote)
                .environment(notesViewModel)
        }
        .alert("Eliminar nota", isPresented: $showDeleteAlert) {
            Button("Cancelar", role: .cancel) {}
            Button("Eliminar", role: .destructive) {
                Task {
                    await notesViewModel.deleteNote(id: note.id)
                    dismiss()
                }
            }
        } message: {
            Text("Esta acción no se puede deshacer.")
        }
        .onReceive(
            NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)
        ) { _ in
            if let updated = notesViewModel.notes.first(where: { $0.id == note.id }) {
                currentNote = updated
            }
        }
        .onChange(of: notesViewModel.notes) { _, newNotes in
            if let updated = newNotes.first(where: { $0.id == note.id }) {
                currentNote = updated
            }
        }
    }

    // MARK: - Header

    private var coloredHeader: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Color accent bar
            RoundedRectangle(cornerRadius: 3)
                .fill(note.accentColor)
                .frame(width: 48, height: 5)

            Text(currentNote.title)
                .font(.largeTitle.bold())
                .fixedSize(horizontal: false, vertical: true)

            metadataRow
        }
        .padding(.horizontal, 24)
        .padding(.top, 20)
        .padding(.bottom, 20)
    }

    private var metadataRow: some View {
        VStack(alignment: .leading, spacing: 6) {
            Label {
                Text(currentNote.createdDate.formatted(date: .long, time: .shortened))
                    .foregroundStyle(.secondary)
            } icon: {
                Image(systemName: "calendar")
                    .foregroundStyle(note.accentColor)
            }

            if currentNote.updatedAt != currentNote.createdAt {
                Label {
                    Text("Editada ")
                        .foregroundStyle(.secondary)
                    + Text(currentNote.updatedDate, style: .relative)
                        .foregroundStyle(.secondary)
                } icon: {
                    Image(systemName: "pencil.and.outline")
                        .foregroundStyle(note.accentColor)
                }
            }

            Label {
                let words = currentNote.content.split(separator: " ").count
                Text("\(words) palabra\(words == 1 ? "" : "s")")
                    .foregroundStyle(.secondary)
            } icon: {
                Image(systemName: "character.cursor.ibeam")
                    .foregroundStyle(note.accentColor)
            }
        }
        .font(.subheadline)
    }

    // MARK: - Content

    private var contentBody: some View {
        VStack(alignment: .leading, spacing: 0) {
            Divider()
                .padding(.horizontal, 24)
                .padding(.bottom, 24)

            if currentNote.content.isEmpty {
                HStack {
                    Spacer()
                    VStack(spacing: 12) {
                        Image(systemName: "text.alignleft")
                            .font(.system(size: 36))
                            .foregroundStyle(note.accentColor.opacity(0.4))
                        Text("Sin contenido")
                            .font(.subheadline)
                            .foregroundStyle(.tertiary)
                    }
                    Spacer()
                }
                .padding(.top, 48)
            } else {
                Text(currentNote.content)
                    .font(.body)
                    .lineSpacing(8)
                    .tracking(0.2)
                    .foregroundStyle(.primary)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 48)
            }
        }
    }

    // MARK: - Toolbar

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .primaryAction) {
            Menu {
                Button {
                    showEditor = true
                } label: {
                    Label("Editar nota", systemImage: "pencil")
                }

                Divider()

                Button(role: .destructive) {
                    showDeleteAlert = true
                } label: {
                    Label("Eliminar nota", systemImage: "trash")
                }
            } label: {
                Image(systemName: "ellipsis.circle.fill")
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(note.accentColor)
            }
        }
    }
}
