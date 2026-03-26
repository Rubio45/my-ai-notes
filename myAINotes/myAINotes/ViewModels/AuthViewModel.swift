import Foundation
import Observation

@Observable
final class AuthViewModel {
    var isLoading = false
    var errorMessage: String?

    func login(username: String, password: String, appViewModel: AppViewModel) async {
        guard !username.isEmpty, !password.isEmpty else {
            errorMessage = "Completa todos los campos."
            return
        }
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let body = LoginRequest(username: username, password: password)
            let token: TokenResponse = try await APIClient.shared.request(.login, body: body)
            KeychainManager.shared.saveToken(token.accessToken)
            appViewModel.isLoggedIn = true
        } catch {
            errorMessage = (error as? NetworkError)?.errorDescription ?? error.localizedDescription
        }
    }

    func register(username: String, password: String, appViewModel: AppViewModel) async {
        guard !username.isEmpty, !password.isEmpty else {
            errorMessage = "Completa todos los campos."
            return
        }
        guard password.count >= 6 else {
            errorMessage = "La contraseña debe tener al menos 6 caracteres."
            return
        }
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let body = RegisterRequest(username: username, password: password)
            let _: UserInDb = try await APIClient.shared.request(.register, body: body)
            await login(username: username, password: password, appViewModel: appViewModel)
        } catch {
            errorMessage = (error as? NetworkError)?.errorDescription ?? error.localizedDescription
        }
    }
}
