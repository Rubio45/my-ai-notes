import SwiftUI

struct ContentView: View {
    @Environment(AppViewModel.self) private var appViewModel

    var body: some View {
        Group {
            if !appViewModel.isOnboarded {
                OnboardingView()
                    .transition(.opacity)
            } else if !appViewModel.isLoggedIn {
                AuthContainerView()
                    .transition(.opacity)
            } else {
                NotesListView()
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.35), value: appViewModel.isOnboarded)
        .animation(.easeInOut(duration: 0.35), value: appViewModel.isLoggedIn)
    }
}

#Preview {
    ContentView()
        .environment(AppViewModel())
}
