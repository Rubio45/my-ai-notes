//
//  Domain.swift
//  myAINotes
//
//  Created by Alex Diaz on 26/3/26.
//

import Foundation
import SwiftData

enum SyncState: String, Codable, CaseIterable, Sendable {
    case localOnly
    case pending
    case synced
    case error
}

@Model
final class Note {
    @Attribute(.unique) var id: UUID
    var title: String
    var content: String
    var createdAt: Date
    var updatedAt: Date
    var syncStateRaw: String

    var syncState: SyncState {
        get { SyncState(rawValue: syncStateRaw) ?? .localOnly }
        set { syncStateRaw = newValue.rawValue }
    }

    init(
        id: UUID = UUID(),
        title: String,
        content: String,
        createdAt: Date = .now,
        updatedAt: Date = .now,
        syncState: SyncState = .localOnly
    ) {
        self.id = id
        self.title = title
        self.content = content
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.syncStateRaw = syncState.rawValue
    }
}
