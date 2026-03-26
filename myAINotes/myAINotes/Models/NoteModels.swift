import Foundation
import SwiftUI

struct NoteInDb: Decodable, Identifiable, Equatable {
    let id: String
    let userId: String
    let title: String
    let content: String
    let createdAt: Int
    let updatedAt: Int

    enum CodingKeys: String, CodingKey {
        case id
        case userId    = "user_id"
        case title
        case content
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }

    var createdDate: Date {
        Date(timeIntervalSince1970: Double(createdAt) / 1000)
    }

    var updatedDate: Date {
        Date(timeIntervalSince1970: Double(updatedAt) / 1000)
    }

    var accentColor: Color {
        let palette: [Color] = [.yellow, .blue, .green, .pink, .orange, .purple]
        let index = abs(id.hashValue) % palette.count
        return palette[index]
    }
}

struct CreateNoteRequest: Encodable {
    let title: String
    let content: String
}

struct UpdateNoteRequest: Encodable {
    let title: String?
    let content: String?
}
