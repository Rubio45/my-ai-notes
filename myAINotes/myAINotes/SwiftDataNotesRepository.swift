//
//  SwiftDataNotesRepository.swift
//  myAINotes
//
//  Created by Alex Diaz on 26/3/26.
//

import Foundation
import SwiftData

struct SwiftDataNotesRepository: NotesRepository {
    let context: ModelContext

    func fetchAll(search: String?) throws -> [Note] {
        var descriptor = FetchDescriptor<Note>(
            sortBy: [SortDescriptor(\.updatedAt, order: .reverse)]
        )
        if let search, !search.isEmpty {
            descriptor.predicate = #Predicate<Note> { note in
                note.title.localizedStandardContains(search) ||
                note.content.localizedStandardContains(search)
            }
        }
        return try context.fetch(descriptor)
    }

    func create(title: String, content: String) throws -> Note {
        let note = Note(title: title, content: content, syncState: .localOnly)
        context.insert(note)
        try context.save()
        return note
    }

    func update(note: Note, title: String, content: String) throws {
        note.title = title
        note.content = content
        note.updatedAt = .now
        if note.syncState == .synced {
            note.syncState = .pending
        }
        try context.save()
    }

    func delete(note: Note) throws {
        context.delete(note)
        try context.save()
    }
}
