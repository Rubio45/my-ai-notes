import Foundation

enum HTTPMethod: String {
    case GET, POST, PATCH, DELETE
}

enum APIEndpoint {
    case register
    case login
    case createNote
    case getNotes
    case getNote(id: String)
    case updateNote(id: String)
    case deleteNote(id: String)

    private static let baseURL = "http://localhost:8000/api/v1"

    var url: URL? {
        URL(string: path)
    }

    var path: String {
        switch self {
        case .register:              return "\(Self.baseURL)/auth/register"
        case .login:                 return "\(Self.baseURL)/auth/login"
        case .createNote:            return "\(Self.baseURL)/notes"
        case .getNotes:              return "\(Self.baseURL)/notes"
        case .getNote(let id):       return "\(Self.baseURL)/notes/\(id)"
        case .updateNote(let id):    return "\(Self.baseURL)/notes/\(id)"
        case .deleteNote(let id):    return "\(Self.baseURL)/notes/\(id)"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .register, .login, .createNote: return .POST
        case .getNotes, .getNote:            return .GET
        case .updateNote:                    return .PATCH
        case .deleteNote:                    return .DELETE
        }
    }
}
