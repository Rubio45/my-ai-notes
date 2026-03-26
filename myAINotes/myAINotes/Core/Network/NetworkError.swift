import Foundation

enum NetworkError: LocalizedError {
    case invalidURL
    case unauthorized
    case notFound
    case conflict
    case serverError(Int)
    case decodingFailed(Error)
    case noInternetConnection
    case unknown(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL:           return "URL inválida."
        case .unauthorized:         return "Credenciales incorrectas o sesión expirada."
        case .notFound:             return "Recurso no encontrado."
        case .conflict:             return "El usuario ya existe."
        case .serverError(let c):   return "Error del servidor (\(c))."
        case .decodingFailed(let e):return "Error al procesar la respuesta: \(e.localizedDescription)"
        case .noInternetConnection: return "Sin conexión a internet."
        case .unknown(let e):       return e.localizedDescription
        }
    }
}
