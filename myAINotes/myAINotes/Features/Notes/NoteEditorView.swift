import SwiftUI

struct NoteEditorView: View {
    @Environment(NotesViewModel.self) private var notesViewModel
    @Environment(\.dismiss) private var dismiss

    let noteToEdit: NoteInDb?

    @State private var title: String
    @State private var content: String
    @FocusState private var focusedField: Field?

    private enum Field { case title, content }

    init(noteToEdit: NoteInDb? = nil) {
        self.noteToEdit = noteToEdit
        _title   = State(initialValue: noteToEdit?.title ?? "")
        _content = State(initialValue: noteToEdit?.content ?? "")
    }

    private var isEditing: Bool { noteToEdit != nil }

    private var wordCount: Int {
        content.split(whereSeparator: { $0.isWhitespace }).count
    }

    private var charCount: Int { content.count }

    private var canSave: Bool { !title.trimmingCharacters(in: .whitespaces).isEmpty }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                titleField
                divider
                contentField
            }
            .background(Color(.systemBackground))
            .navigationTitle(isEditing ? "Editar nota" : "Nueva nota")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { toolbarContent }
            .onAppear {
                focusedField = isEditing ? .title : .content
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    focusedField = isEditing ? nil : .content
                }
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
    }

    // MARK: - Fields

    private var titleField: some View {
        TextField("Título de la nota", text: $title, axis: .vertical)
            .font(.title2.bold())
            .lineLimit(1...3)
            .focused($focusedField, equals: .title)
            .submitLabel(.next)
            .onSubmit { focusedField = .content }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 14)
    }

    private var divider: some View {
        HStack(spacing: 0) {
            Rectangle()
                .fill(Color.accentColor)
                .frame(width: 3, height: 20)
                .clipShape(Capsule())
            Rectangle()
                .fill(Color(.separator))
                .frame(height: 0.5)
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 4)
    }

    private var contentField: some View {
        TextEditor(text: $content)
            .font(.body)
            .lineSpacing(6)
            .focused($focusedField, equals: .content)
            .scrollContentBackground(.hidden)
            .padding(.horizontal, 16)
            .overlay(alignment: .topLeading) {
                if content.isEmpty {
                    Text("Escribe aquí...")
                        .foregroundStyle(.tertiary)
                        .font(.body)
                        .padding(.horizontal, 20)
                        .padding(.top, 8)
                        .allowsHitTesting(false)
                }
            }
    }

    // MARK: - Toolbar

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button("Cancelar") { dismiss() }
                .foregroundStyle(.secondary)
        }
        ToolbarItem(placement: .confirmationAction) {
            Button {
                Task {
                    if let note = noteToEdit {
                        await notesViewModel.updateNote(id: note.id, title: title, content: content)
                    } else {
                        await notesViewModel.createNote(title: title, content: content)
                    }
                    dismiss()
                }
            } label: {
                if notesViewModel.isLoading {
                    ProgressView().tint(Color.accentColor)
                } else {
                    Text("Guardar")
                        .fontWeight(.semibold)
                }
            }
            .disabled(!canSave || notesViewModel.isLoading)
        }
    }
}
