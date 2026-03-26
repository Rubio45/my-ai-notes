//
//  AppContainer.swift
//  myAINotes
//
//  Created by Alex Diaz on 26/3/26.
//

import Foundation
import SwiftUI
import SwiftData

@Observable
final class AppContainer {
    let notesRepository: NotesRepository
    let syncService: SyncService
    let aiService: AIChatService

    init(notesRepository: NotesRepository, syncService: SyncService, aiService: AIChatService) {
        self.notesRepository = notesRepository
        self.syncService = syncService
        self.aiService = aiService
    }
}

private struct AppContainerKey: EnvironmentKey {
    static var defaultValue: AppContainer = {
        // Fallback para previews sin ModelContext (no debería usarse en runtime)
        AppContainer(
            notesRepository: SwiftDataNotesRepository(context: .init(container: try! ModelContainer(for: Note.self))),
            syncService: MockSyncService(context: nil),
            aiService: MockAIChatService()
        )
    }()
}

extension EnvironmentValues {
    var appContainer: AppContainer {
        get { self[AppContainerKey.self] }
        set { self[AppContainerKey.self] = newValue }
    }
}

extension View {
    func environment(_ container: AppContainer) -> some View {
        environment(\.appContainer, container)
    }
}

extension AppContainer {
    // .live construye con el ModelContext del entorno en runtime (inyectado en myAINotesApp)
    static var live: AppContainer {
        // Se completará en runtime desde myAINotesApp usando el ModelContext del Scene.
        // Como no tenemos acceso directo aquí, devolvemos un contenedor vacío que será
        // reemplazado en myAINotesApp con el context real.
        AppContainer(
            notesRepository: SwiftDataNotesRepository(context: .init(container: try! ModelContainer(for: Note.self))),
            syncService: MockSyncService(context: nil),
            aiService: MockAIChatService()
        )
    }

    static var preview: AppContainer {
        let container = try! ModelContainer(for: Note.self, configurations: .init(isStoredInMemoryOnly: true))
        let context = ModelContext(container)
        let repo = SwiftDataNotesRepository(context: context)
        let sync = MockSyncService(context: context)
        let ai = MockAIChatService()
        return AppContainer(notesRepository: repo, syncService: sync, aiService: ai)
    }
}
