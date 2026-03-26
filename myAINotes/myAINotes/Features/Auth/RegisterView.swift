import SwiftUI

struct RegisterView: View {
    @Environment(AppViewModel.self) private var appViewModel
    @State private var authViewModel = AuthViewModel()
    @Binding var showRegister: Bool
    @State private var username = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @FocusState private var focusedField: Field?

    private enum Field { case username, password, confirm }

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
                Image(systemName: "person.badge.plus.fill")
                    .font(.system(size: 38))
                    .foregroundStyle(Color.accentColor)
                    .symbolRenderingMode(.hierarchical)
            }
            Text("Crea tu cuenta").font(.title2.bold())
            Text("Únete para empezar a tomar notas").font(.subheadline).foregroundStyle(.secondary)
        }
    }

    private var fields: some View {
        VStack(spacing: 16) {
            AuthTextField(systemImage: "person.fill", placeholder: "Nombre de usuario", text: $username, isSecure: false)
                .focused($focusedField, equals: .username).submitLabel(.next).onSubmit { focusedField = .password }

            AuthTextField(systemImage: "lock.fill", placeholder: "Contraseña", text: $password, isSecure: true)
                .focused($focusedField, equals: .password).submitLabel(.next).onSubmit { focusedField = .confirm }

            AuthTextField(systemImage: "lock.rotation", placeholder: "Confirmar contraseña", text: $confirmPassword, isSecure: true)
                .focused($focusedField, equals: .confirm).submitLabel(.go).onSubmit { attemptRegister() }

            if let error = authViewModel.errorMessage {
                ErrorBanner(message: error)
            }
        }
    }

    private var actionArea: some View {
        VStack(spacing: 20) {
            Button(action: attemptRegister) {
                Group {
                    if authViewModel.isLoading {
                        ProgressView().tint(.white)
                    } else {
                        Label("Crear cuenta", systemImage: "person.crop.circle.badge.checkmark").font(.headline)
                    }
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(Color.accentColor, in: RoundedRectangle(cornerRadius: 16))
            }
            .disabled(authViewModel.isLoading)

            Button { withAnimation(.easeInOut) { showRegister = false } } label: {
                HStack(spacing: 4) {
                    Text("¿Ya tienes cuenta?").foregroundStyle(.secondary)
                    Text("Inicia sesión").foregroundStyle(Color.accentColor).fontWeight(.semibold)
                }
                .font(.subheadline)
            }
        }
    }

    private func attemptRegister() {
        guard password == confirmPassword else {
            authViewModel.errorMessage = "Las contraseñas no coinciden."
            return
        }
        Task { await authViewModel.register(username: username, password: password, appViewModel: appViewModel) }
    }
}
