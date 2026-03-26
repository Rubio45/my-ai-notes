import Foundation
import Observation

@Observable
final class AppViewModel {
    var isOnboarded: Bool
    var isLoggedIn: Bool

    private let onboardingKey = "hasSeenOnboarding"

    init() {
        self.isOnboarded = UserDefaults.standard.bool(forKey: "hasSeenOnboarding")
        self.isLoggedIn  = KeychainManager.shared.loadToken() != nil
    }

    func completeOnboarding() {
        UserDefaults.standard.set(true, forKey: onboardingKey)
        isOnboarded = true
    }

    func logOut() {
        KeychainManager.shared.deleteToken()
        isLoggedIn = false
    }
}
