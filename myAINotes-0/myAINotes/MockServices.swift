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
        // #region agent log
        let _mt = Thread.isMainThread
        { var r = URLRequest(url: URL(string: "http://127.0.0.1:7291/ingest/b5960aac-798e-4289-9938-2fac66bcef41")!); r.httpMethod = "POST"; r.setValue("application/json", forHTTPHeaderField: "Content-Type"); r.setValue("3c0e57", forHTTPHeaderField: "X-Debug-Session-Id"); r.httpBody = "{\"sessionId\":\"3c0e57\",\"timestamp\":\(Int(Date().timeIntervalSince1970*1000)),\"location\":\"MockServices:enqueueSync\",\"message\":\"enqueueSync called\",\"data\":{\"isMainThread\":\(_mt),\"pendingBefore\":\(pending.count)},\"hypothesisId\":\"B\"}".data(using: .utf8); URLSession.shared.dataTask(with: r).resume() }()
        // #endregion
        pending.append(note.id)
        note.syncState = .pending
        try? context?.save()
        Task { await syncPending() }
    }

    func syncPending() async {
        guard let context else {
            // #region agent log
            { var r = URLRequest(url: URL(string: "http://127.0.0.1:7291/ingest/b5960aac-798e-4289-9938-2fac66bcef41")!); r.httpMethod = "POST"; r.setValue("application/json", forHTTPHeaderField: "Content-Type"); r.setValue("3c0e57", forHTTPHeaderField: "X-Debug-Session-Id"); r.httpBody = "{\"sessionId\":\"3c0e57\",\"timestamp\":\(Int(Date().timeIntervalSince1970*1000)),\"location\":\"MockServices:syncPending\",\"message\":\"context nil - aborted\",\"data\":{\"isMainThread\":\(Thread.isMainThread)},\"hypothesisId\":\"B\"}".data(using: .utf8); URLSession.shared.dataTask(with: r).resume() }()
            // #endregion
            return
        }
        try? await Task.sleep(nanoseconds: 700_000_000)
        do {
            // #region agent log
            let _pc = pending.count; let _mt2 = Thread.isMainThread
            { var r = URLRequest(url: URL(string: "http://127.0.0.1:7291/ingest/b5960aac-798e-4289-9938-2fac66bcef41")!); r.httpMethod = "POST"; r.setValue("application/json", forHTTPHeaderField: "Content-Type"); r.setValue("3c0e57", forHTTPHeaderField: "X-Debug-Session-Id"); r.httpBody = "{\"sessionId\":\"3c0e57\",\"timestamp\":\(Int(Date().timeIntervalSince1970*1000)),\"location\":\"MockServices:syncPending\",\"message\":\"syncing notes\",\"data\":{\"pendingCount\":\(_pc),\"isMainThread\":\(_mt2)},\"hypothesisId\":\"B\"}".data(using: .utf8); URLSession.shared.dataTask(with: r).resume() }()
            // #endregion
            let all = try context.fetch(FetchDescriptor<Note>())
            for note in all where pending.contains(note.id) {
                // 80% éxito aprox.
                if Bool.random() || Bool.random() {
                    note.syncState = .synced
                } else {
                    note.syncState = .error
                }
            }
            pending.removeAll()
            try context.save()
        } catch {
            // Silenciar por mock
        }
    }
}

struct MockAIChatService: AIChatService {
    func send(message: String, context: [AIMessage]) async throws -> AIMessage {
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
