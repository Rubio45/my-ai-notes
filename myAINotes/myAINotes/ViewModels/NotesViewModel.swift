import Foundation
import Observation

@Observable
final class NotesViewModel {
    var notes: [NoteInDb] = []
    var isLoading = false
    var errorMessage: String?

    func loadNotes() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            notes = try await APIClient.shared.request(.getNotes)
        } catch {
            errorMessage = (error as? NetworkError)?.errorDescription ?? error.localizedDescription
        }
    }

    func createNote(title: String, content: String) async {
        guard !title.isEmpty else { return }
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            let body = CreateNoteRequest(title: title, content: content)
            let note: NoteInDb = try await APIClient.shared.request(.createNote, body: body)
            notes.insert(note, at: 0)
        } catch {
            errorMessage = (error as? NetworkError)?.errorDescription ?? error.localizedDescription
        }
    }

    func updateNote(id: String, title: String, content: String) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            let body = UpdateNoteRequest(title: title, content: content)
            let updated: NoteInDb = try await APIClient.shared.request(.updateNote(id: id), body: body)
            if let idx = notes.firstIndex(where: { $0.id == id }) {
                notes[idx] = updated
            }
        } catch {
            errorMessage = (error as? NetworkError)?.errorDescription ?? error.localizedDescription
        }
    }

    func deleteNote(id: String) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            try await APIClient.shared.requestVoid(.deleteNote(id: id))
            notes.removeAll { $0.id == id }
        } catch {
            errorMessage = (error as? NetworkError)?.errorDescription ?? error.localizedDescription
        }
    }
}
