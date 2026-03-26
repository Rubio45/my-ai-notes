//
//  Protocols.swift
//  myAINotes
//
//  Created by Alex Diaz on 26/3/26.
//

import Foundation
import SwiftData

protocol NotesRepository {
    func fetchAll(search: String?) throws -> [Note]
    func create(title: String, content: String) throws -> Note
    func update(note: Note, title: String, content: String) throws
    func delete(note: Note) throws
}

protocol SyncService {
    func enqueueSync(note: Note)
    func syncPending() async
}

struct AIMessage: Identifiable, Equatable, Sendable {
    enum Role: String, Sendable { case user, assistant }
    let id: UUID
    let role: Role
    let text: String
    init(id: UUID = UUID(), role: Role, text: String) {
        self.id = id
        self.role = role
        self.text = text
    }
}

protocol AIChatService {
    func send(message: String, context: [AIMessage]) async throws -> AIMessage
    func improve(text: String) async throws -> String
    func summarize(text: String) async throws -> String
    func outline(text: String) async throws -> String
    func correctSpelling(text: String) async throws -> String
    func studyVersion(text: String) async throws -> String
}
