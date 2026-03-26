import Foundation

final class APIClient {
    static let shared = APIClient()
    private init() {}

    private let session: URLSession = {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        return URLSession(configuration: config)
    }()

    func request<T: Decodable>(_ endpoint: APIEndpoint) async throws -> T {
        try await execute(endpoint, body: Optional<String>.none)
    }

    func request<T: Decodable, B: Encodable>(_ endpoint: APIEndpoint, body: B) async throws -> T {
        try await execute(endpoint, body: body)
    }

    func requestVoid(_ endpoint: APIEndpoint) async throws {
        _ = try await performRequest(endpoint, body: Optional<String>.none)
    }

    private func execute<T: Decodable, B: Encodable>(_ endpoint: APIEndpoint, body: B?) async throws -> T {
        let data = try await performRequest(endpoint, body: body)
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw NetworkError.decodingFailed(error)
        }
    }

    private func performRequest<B: Encodable>(_ endpoint: APIEndpoint, body: B?) async throws -> Data {
        guard let url = endpoint.url else { throw NetworkError.invalidURL }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = endpoint.method.rawValue
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let token = KeychainManager.shared.loadToken() {
            urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        if let body {
            urlRequest.httpBody = try JSONEncoder().encode(body)
        }

        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await session.data(for: urlRequest)
        } catch let urlError as URLError where urlError.code == .notConnectedToInternet {
            throw NetworkError.noInternetConnection
        } catch {
            throw NetworkError.unknown(error)
        }

        guard let http = response as? HTTPURLResponse else {
            throw NetworkError.unknown(URLError(.badServerResponse))
        }

        switch http.statusCode {
        case 200...299: return data
        case 401: throw NetworkError.unauthorized
        case 404: throw NetworkError.notFound
        case 409: throw NetworkError.conflict
        default:  throw NetworkError.serverError(http.statusCode)
        }
    }
}
