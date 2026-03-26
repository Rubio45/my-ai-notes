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
        // Fallback para previews
        let container = try! ModelContainer(for: Note.self, configurations: .init(isStoredInMemoryOnly: true))
        let context = ModelContext(container)
        return AppContainer(
            notesRepository: SwiftDataNotesRepository(context: context),
            syncService: MockSyncService(context: context),
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
    static var preview: AppContainer {
        let container = try! ModelContainer(for: Note.self, configurations: .init(isStoredInMemoryOnly: true))
        let context = ModelContext(container)
        return AppContainer(
            notesRepository: SwiftDataNotesRepository(context: context),
            syncService: MockSyncService(context: context),
            aiService: MockAIChatService()
        )
    }
}
