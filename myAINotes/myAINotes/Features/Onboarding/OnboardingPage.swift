import Foundation

struct OnboardingPage: Identifiable {
    let id = UUID()
    let systemImage: String
    let title: String
    let description: String
    let accentColor: String
}

extension OnboardingPage {
    static let pages: [OnboardingPage] = [
        OnboardingPage(
            systemImage: "pencil.and.list.clipboard",
            title: "Captura tus ideas",
            description: "Escribe notas rápidas en cualquier momento. Nunca pierdas una idea importante.",
            accentColor: "AccentColor"
        ),
        OnboardingPage(
            systemImage: "brain.head.profile",
            title: "Organiza con inteligencia",
            description: "Tu asistente de IA organiza y enriquece tus notas para que siempre encuentres lo que necesitas.",
            accentColor: "AccentColor"
        ),
        OnboardingPage(
            systemImage: "lock.shield.fill",
            title: "Seguras y privadas",
            description: "Tus notas están cifradas y protegidas. Solo tú tienes acceso a tu contenido.",
            accentColor: "AccentColor"
        )
    ]
}
