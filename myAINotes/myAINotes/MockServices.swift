//
//  MockServices.swift
//  myAINotes
//
//  Created by Alex Diaz on 26/3/26.
//

import Foundation
import SwiftData

actor MockSyncService: SyncService {
    private weak var context: ModelContext?
    private var pending: [UUID] = []

    init(context: ModelContext?) {
        self.context = context
    }

    func enqueueSync(note: Note) {
        pending.append(note.id)
        note.syncState = .pending
        try? context?.save()
        Task { await syncPending() }
    }

    func syncPending() async {
        guard let context else { return }
        // Simula latencia y resultado
        try? await Task.sleep(nanoseconds: 700_000_000)
        do {
            let all = try context.fetch(FetchDescriptor<Note>())
            for note in all where pending.contains(note.id) {
                // 80% éxito, 20% error para probar estados
                if Bool.random() || Bool.random() {
                    note.syncState = .synced
                } else {
                    note.syncState = .error
                }
            }
            pending.removeAll()
            try context.save()
        } catch {
            // si falla el fetch/save, dejamos los estados como están
        }
    }
}

struct MockAIChatService: AIChatService {
    func send(message: String, context: [AIMessage]) async throws -> AIMessage {
        // Respuesta determinística simple
        let reply = """
        ✨ Idea mejorada:
        \(message.trimmingCharacters(in: .whitespacesAndNewlines))
        
        • Resumen breve
        • Puntos clave
        • Próximos pasos
        """
        try await Task.sleep(nanoseconds: 300_000_000)
        return AIMessage(role: .assistant, text: reply)
    }

    func improve(text: String) async throws -> String {
        "Mejora: \(text)"
    }

    func summarize(text: String) async throws -> String {
        "Resumen: \(text)"
    }

    func outline(text: String) async throws -> String {
        "Esquema:\n- Punto 1\n- Punto 2\n- Punto 3\n\nBasado en: \(text)"
    }

    func correctSpelling(text: String) async throws -> String {
        "Corrección ortográfica: \(text)"
    }

    func studyVersion(text: String) async throws -> String {
        "Versión para estudiar:\n• Concepto clave\n• Definición\n• Ejemplo\n\nBasado en: \(text)"
    }
}
