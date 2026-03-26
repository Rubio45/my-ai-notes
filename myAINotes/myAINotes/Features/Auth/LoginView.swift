import SwiftUI

struct LoginView: View {
    @Environment(AppViewModel.self) private var appViewModel
    @State private var authViewModel = AuthViewModel()
    @Binding var showRegister: Bool
    @State private var username = ""
    @State private var password = ""
    @FocusState private var focusedField: Field?

    private enum Field { case username, password }

    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                header
                fields
                actionArea
            }
            .padding(.horizontal, 28)
            .padding(.top, 48)
            .padding(.bottom, 32)
        }
        .scrollBounceBehavior(.basedOnSize)
    }

    private var header: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle().fill(Color.accentColor.opacity(0.12)).frame(width: 80, height: 80)
                Image(systemName: "person.crop.circle.fill")
                    .font(.system(size: 38))
                    .foregroundStyle(Color.accentColor)
                    .symbolRenderingMode(.hierarchical)
            }
            Text("Bienvenido de nuevo").font(.title2.bold())
            Text("Inicia sesión para continuar").font(.subheadline).foregroundStyle(.secondary)
        }
    }

    private var fields: some View {
        VStack(spacing: 16) {
            AuthTextField(systemImage: "person.fill", placeholder: "Nombre de usuario", text: $username, isSecure: false)
                .focused($focusedField, equals: .username)
                .submitLabel(.next)
                .onSubmit { focusedField = .password }

            AuthTextField(systemImage: "lock.fill", placeholder: "Contraseña", text: $password, isSecure: true)
                .focused($focusedField, equals: .password)
                .submitLabel(.go)
                .onSubmit {
                    Task { await authViewModel.login(username: username, password: password, appViewModel: appViewModel) }
                }

            if let error = authViewModel.errorMessage {
                ErrorBanner(message: error)
            }
        }
    }

    private var actionArea: some View {
        VStack(spacing: 20) {
            Button {
                Task { await authViewModel.login(username: username, password: password, appViewModel: appViewModel) }
            } label: {
                Group {
                    if authViewModel.isLoading {
                        ProgressView().tint(.white)
                    } else {
                        Label("Iniciar sesión", systemImage: "arrow.right.circle.fill").font(.headline)
                    }
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(Color.accentColor, in: RoundedRectangle(cornerRadius: 16))
            }
            .disabled(authViewModel.isLoading)

            Button { withAnimation(.easeInOut) { showRegister = true } } label: {
                HStack(spacing: 4) {
                    Text("¿No tienes cuenta?").foregroundStyle(.secondary)
                    Text("Regístrate").foregroundStyle(Color.accentColor).fontWeight(.semibold)
                }
                .font(.subheadline)
            }
        }
    }
}
