//
//  myAINotesApp.swift
//  myAINotes
//
//  Created by Alex Diaz on 26/3/26.
//

import SwiftUI
import SwiftData

@main
struct myAINotesApp: App {
    var body: some Scene {
        WindowGroup {
            Root()
        }
        .modelContainer(for: [Note.self])
    }
}

private struct Root: View {
    @Environment(\.modelContext) private var modelContext
    @State private var container: AppContainer?

    var body: some View {
        Group {
            if let container {
                ContentView()
                    .environment(container)
            } else {
                ProgressView()
                    .task {
                        // Construimos el contenedor con el ModelContext real
                        let repo = SwiftDataNotesRepository(context: modelContext)
                        let sync = MockSyncService(context: modelContext)
                        let ai = MockAIChatService()
                        container = AppContainer(notesRepository: repo, syncService: sync, aiService: ai)
                    }
            }
        }
    }
}
