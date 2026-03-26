import SwiftUI

struct NotesListView: View {
    @Environment(AppViewModel.self) private var appViewModel
    @State private var notesViewModel = NotesViewModel()
    @State private var showEditor    = false
    @State private var noteToEdit: NoteInDb? = nil
    @State private var showChat      = false
    @State private var searchText    = ""

    private var filteredNotes: [NoteInDb] {
        guard !searchText.isEmpty else { return notesViewModel.notes }
        return notesViewModel.notes.filter {
            $0.title.localizedCaseInsensitiveContains(searchText) ||
            $0.content.localizedCaseInsensitiveContains(searchText)
        }
    }

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        NavigationStack {
            Group {
                if notesViewModel.isLoading && notesViewModel.notes.isEmpty {
                    loadingView
                } else if filteredNotes.isEmpty {
                    emptyState
                } else {
                    notesGrid
                }
            }
            .navigationTitle("Mis notas")
            .navigationBarTitleDisplayMode(.large)
            .searchable(text: $searchText, prompt: "Buscar notas")
            .toolbar { toolbarContent }
            .task { await notesViewModel.loadNotes() }
            .refreshable { await notesViewModel.loadNotes() }
            .safeAreaInset(edge: .bottom) { fabButton }
            .sheet(isPresented: $showEditor) {
                NoteEditorView(noteToEdit: noteToEdit)
                    .environment(notesViewModel)
            }
            .sheet(isPresented: $showChat) {
                ChatView()
            }
            .overlay(alignment: .bottom) {
                if let error = notesViewModel.errorMessage {
                    ErrorToast(message: error)
                        .padding(.bottom, 100)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
        }
        .environment(notesViewModel)
    }

    // MARK: - Grid

    private var notesGrid: some View {
        ScrollView {
            noteCountHeader
                .padding(.horizontal, 16)
                .padding(.top, 4)

            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(filteredNotes) { note in
                    NavigationLink(destination: NoteDetailView(note: note)) {
                        NoteCardView(note: note) {
                            noteToEdit = note
                            showEditor = true
                        } onDelete: {
                            Task { await notesViewModel.deleteNote(id: note.id) }
                        }
                    }
                    .buttonStyle(NoteCardButtonStyle())
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 100)
        }
    }

    private var noteCountHeader: some View {
        HStack {
            Text(countLabel)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Spacer()
        }
    }

    private var countLabel: String {
        let count = filteredNotes.count
        if !searchText.isEmpty { return "\(count) resultado\(count == 1 ? "" : "s")" }
        return "\(count) nota\(count == 1 ? "" : "s")"
    }

    // MARK: - States

    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.4)
                .tint(Color.accentColor)
            Text("Cargando notas...")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var emptyState: some View {
        VStack(spacing: 24) {
            ZStack {
                Circle()
                    .fill(Color.accentColor.opacity(0.1))
                    .frame(width: 100, height: 100)
                Image(systemName: searchText.isEmpty ? "note.text.badge.plus" : "magnifyingglass")
                    .font(.system(size: 44))
                    .foregroundStyle(Color.accentColor)
                    .symbolRenderingMode(.hierarchical)
            }
            VStack(spacing: 8) {
                Text(searchText.isEmpty ? "Sin notas aún" : "Sin resultados")
                    .font(.title3.bold())
                Text(searchText.isEmpty
                     ? "Toca el botón + para crear\ntu primera nota."
                     : "Prueba con otra búsqueda.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(40)
    }

    // MARK: - FAB & Toolbar

    private var fabButton: some View {
        HStack {
            Spacer()
            Button {
                noteToEdit = nil
                showEditor = true
            } label: {
                Image(systemName: "plus")
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(.white)
                    .frame(width: 58, height: 58)
                    .background(Color.accentColor, in: Circle())
                    .shadow(color: Color.accentColor.opacity(0.45), radius: 14, y: 6)
            }
            .padding(.trailing, 24)
            .padding(.bottom, 24)
        }
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Button {
                showChat = true
            } label: {
                Image(systemName: "wand.and.stars")
                    .foregroundStyle(Color.accentColor)
            }
        }
        ToolbarItem(placement: .primaryAction) {
            Button {
                appViewModel.logOut()
            } label: {
                Image(systemName: "rectangle.portrait.and.arrow.right")
                    .foregroundStyle(.secondary)
            }
        }
    }
}

// MARK: - NoteCardView

private struct NoteCardView: View {
    let note: NoteInDb
    let onEdit: () -> Void
    let onDelete: () -> Void

    @State private var showDeleteAlert = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            colorStripe
            cardContent
        }
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(note.accentColor.opacity(0.12))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .strokeBorder(note.accentColor.opacity(0.2), lineWidth: 1)
        )
        .contextMenu {
            Button {
                onEdit()
            } label: {
                Label("Editar", systemImage: "pencil")
            }

            Divider()

            Button(role: .destructive) {
                showDeleteAlert = true
            } label: {
                Label("Eliminar", systemImage: "trash")
            }
        }
        .alert("Eliminar nota", isPresented: $showDeleteAlert) {
            Button("Cancelar", role: .cancel) {}
            Button("Eliminar", role: .destructive) { onDelete() }
        } message: {
            Text("«\(note.title)» se eliminará de forma permanente.")
        }
    }

    private var colorStripe: some View {
        RoundedRectangle(cornerRadius: 4)
            .fill(note.accentColor)
            .frame(height: 4)
            .padding(.horizontal, 14)
            .padding(.top, 14)
    }

    private var cardContent: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(note.title)
                .font(.subheadline.bold())
                .lineLimit(2)
                .foregroundStyle(.primary)

            if !note.content.isEmpty {
                Text(note.content)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(4)
            }

            Spacer(minLength: 8)

            HStack {
                Image(systemName: "clock")
                    .font(.caption2)
                Text(note.updatedDate, style: .relative)
                    .font(.caption2)
            }
            .foregroundStyle(note.accentColor.opacity(0.8))
        }
        .padding(14)
    }
}

// MARK: - Card Button Style

private struct NoteCardButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .animation(.spring(response: 0.25, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

// MARK: - Error Toast

private struct ErrorToast: View {
    let message: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "exclamationmark.triangle.fill")
            Text(message).font(.subheadline)
        }
        .foregroundStyle(.white)
        .padding(.horizontal, 18)
        .padding(.vertical, 12)
        .background(Color.red.opacity(0.9), in: Capsule())
        .shadow(radius: 8, y: 4)
    }
}
