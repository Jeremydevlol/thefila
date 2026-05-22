import SwiftUI

// MARK: - Revolut-style auth (bienvenida + inicio / registro)

private enum AuthPhase {
    case welcome
    case signIn
    case signUp
}

private let authLinkBlue = PremiumAccent.tabActive
/// Botón principal de la bienvenida (referencia pantalla inicial).
private let welcomePrimaryBlue = Color(red: 26 / 255, green: 102 / 255, blue: 1)

struct LoginView: View {
    @ObservedObject var auth: AuthViewModel

    @State private var phase: AuthPhase = .welcome
    @State private var email = ""
    @State private var password = ""
    @State private var isBusy = false
    @State private var showResetSheet = false
    @State private var resetEmail = ""
    @State private var resetInfo: String?
    @State private var showHelpAlert = false

    private var canSubmit: Bool {
        email.contains("@") && email.contains(".") && password.count >= 6
    }

    var body: some View {
        ZStack {
            switch phase {
            case .welcome:
                welcomeLayer
            case .signIn, .signUp:
                innerAuthLayer
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .preferredColorScheme(.light)
        .animation(.easeInOut(duration: 0.25), value: phase)
        .sheet(isPresented: $showResetSheet) {
            resetPasswordSheet
        }
        .alert("Ayuda", isPresented: $showHelpAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Próximamente podrás obtener ayuda desde aquí.")
        }
        .onAppear {
            phase = .welcome
        }
    }

    // MARK: - Bienvenida (arte + branding)

    private var welcomeLayer: some View {
        ZStack {
            TefilaFondoMiOracionBackground(lightVeilOpacity: 0.28)

            VStack(spacing: 0) {
                Image("LogoBlanco")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 280)
                    .shadow(color: .black.opacity(0.28), radius: 8, x: 0, y: 3)
                    .accessibilityLabel("Tefila")
                    .frame(maxWidth: .infinity)
                    .padding(.top, 96)

                Spacer(minLength: 0)

                welcomeBottomChrome
                    .environment(\.colorScheme, .light)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var welcomeBottomChrome: some View {
        VStack(spacing: 14) {
            Button {
                phase = .signIn
                auth.lastErrorMessage = nil
            } label: {
                Text("Iniciar sesión")
                    .font(.system(size: 17, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .foregroundStyle(.white)
                    .background(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(welcomePrimaryBlue)
                    )
                    .shadow(color: welcomePrimaryBlue.opacity(0.35), radius: 12, x: 0, y: 5)
            }
            .buttonStyle(.plain)

            Button {
                phase = .signUp
                auth.lastErrorMessage = nil
            } label: {
                Text("Crear cuenta")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(welcomePrimaryBlue)
                    .padding(.vertical, 6)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 24)
        .padding(.top, 26)
        .padding(.bottom, 24)
        .frame(maxWidth: .infinity)
        .background(
            UnevenRoundedRectangle(topLeadingRadius: 28, bottomLeadingRadius: 0, bottomTrailingRadius: 0, topTrailingRadius: 28, style: .continuous)
                .fill(Color.white)
                .ignoresSafeArea(edges: .bottom)
        )
    }

    // MARK: Inner (inicio de sesión / registro — difuminado azul, blanco y dorado)

    private var innerAuthLayer: some View {
        ZStack {
            TefilaFondoMiOracionBackground(lightVeilOpacity: 0.5)

            VStack(spacing: 0) {
                HStack {
                    circleNavButton(systemName: "chevron.left") {
                        phase = .welcome
                        auth.lastErrorMessage = nil
                    }
                    Spacer()
                    circleNavButton(systemName: "questionmark") {
                        showHelpAlert = true
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 18) {
                        if phase == .signIn {
                            SectionHeader(
                                title: "Nos alegra verte de nuevo · ברוכים הבאים",
                                subtitle: "Introduce el correo y la contraseña de tu cuenta Tefila.",
                                inkOnVideoBackdrop: true
                            )
                        } else {
                            SectionHeader(
                                title: "Crea tu cuenta",
                                subtitle: "Usa tu correo para registrar Tefila y sincronizar preferencias cuando actives tu cuenta.",
                                inkOnVideoBackdrop: true
                            )
                        }

                        authPillField {
                            TextField(
                                "",
                                text: $email,
                                prompt: Text("Correo electrónico").foregroundStyle(Color.black.opacity(0.38))
                            )
                            .textContentType(.emailAddress)
                            .keyboardType(.emailAddress)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .foregroundStyle(Color.black.opacity(0.9))
                        }

                        authPillField {
                            SecureField(
                                "",
                                text: $password,
                                prompt: Text("Contraseña").foregroundStyle(Color.black.opacity(0.38))
                            )
                            .textContentType(phase == .signUp ? .newPassword : .password)
                            .foregroundStyle(Color.black.opacity(0.9))
                        }

                        if let msg = auth.lastErrorMessage {
                            Text(msg)
                                .font(.system(size: 13, weight: .medium))
                                .foregroundStyle(.red.opacity(0.9))
                                .fixedSize(horizontal: false, vertical: true)
                        }

                        if phase == .signIn {
                            Button("¿Olvidaste la contraseña?") {
                                resetEmail = email
                                showResetSheet = true
                            }
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(authLinkBlue)

                            Button("¿No tienes cuenta? Crear cuenta") {
                                phase = .signUp
                                auth.lastErrorMessage = nil
                            }
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(authLinkBlue)
                        } else {
                            Button("¿Ya tienes cuenta? Iniciar sesión") {
                                phase = .signIn
                                auth.lastErrorMessage = nil
                            }
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(authLinkBlue)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 24)
                }

                Button {
                    Task {
                        isBusy = true
                        defer { isBusy = false }
                        if phase == .signUp {
                            await auth.signUp(email: email, password: password)
                        } else {
                            await auth.signIn(email: email, password: password)
                        }
                    }
                } label: {
                    HStack(spacing: 8) {
                        if isBusy {
                            ProgressView()
                                .tint(canSubmit ? .white : Color.black.opacity(0.35))
                        }
                        Text("Continuar")
                            .font(.system(size: 17, weight: .semibold))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .foregroundStyle(canSubmit && !isBusy ? Color.white : Color.black.opacity(0.38))
                    .background(
                        Capsule()
                            .fill(canSubmit && !isBusy ? PremiumAccent.tabActive : Color.black.opacity(0.08))
                    )
                    .shadow(color: canSubmit && !isBusy ? PremiumAccent.tabActive.opacity(0.3) : .clear, radius: 12, y: 5)
                }
                .disabled(!canSubmit || isBusy)
                .buttonStyle(.plain)
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 28)
            }
        }
    }

    private func circleNavButton(systemName: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(Color.black.opacity(0.82))
                .frame(width: 44, height: 44)
                .background {
                    TranslucentWhiteCircleChrome(size: 44)
                }
        }
        .buttonStyle(.plain)
    }

    private func authPillField<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background {
                TranslucentWhiteRoundedChrome(cornerRadius: 18)
            }
    }

    private var resetPasswordSheet: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Correo", text: $resetEmail)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                }
                if let resetInfo {
                    Section {
                        Text(resetInfo)
                            .font(.footnote)
                    }
                }
            }
            .navigationTitle("Recuperar acceso")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cerrar") {
                        showResetSheet = false
                        resetInfo = nil
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Enviar") {
                        Task {
                            resetInfo = await auth.resetPassword(email: resetEmail)
                        }
                    }
                }
            }
        }
        .presentationDetents([.medium])
    }
}

#Preview {
    LoginView(auth: AuthViewModel())
}
