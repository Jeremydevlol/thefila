import Combine
import Foundation
import Supabase
import UIKit

@MainActor
final class AuthViewModel: ObservableObject {
    private let client: SupabaseClient

    /// Tras **Cerrar sesión**: mostrar `LoginView` hasta que inicien sesión de nuevo.
    private static let expectsLoginAfterSignOutKey = "TefilaExpectsLoginAfterSignOut"

    @Published private(set) var session: Session?
    @Published private(set) var isRestoringSession = true
    /// Persistido: si es `true` y no hay sesión, la app muestra pantalla de acceso (`LoginView`).
    @Published private(set) var expectsLoginAfterSignOut: Bool
    @Published var lastErrorMessage: String?
    /// Foto de perfil del usuario con sesión iniciada (`profiles.avatar_url` o metadatos OAuth).
    @Published private(set) var profileAvatarImage: UIImage?

    private var authStateTask: Task<Void, Never>?
    private var profileAvatarTask: Task<Void, Never>?

    init(client: SupabaseClient = SupabaseClientProvider.shared) {
        self.client = client
        expectsLoginAfterSignOut = UserDefaults.standard.bool(forKey: Self.expectsLoginAfterSignOutKey)
        session = client.auth.currentSession
        SmileLuxAccountStorage.syncFromSession(session)
        isRestoringSession = session == nil
        startAuthStateListener()
        Task { await refreshSessionIfNeeded() }
        scheduleProfileAvatarLoad()
    }

    deinit {
        authStateTask?.cancel()
    }

    var isAuthenticated: Bool {
        session != nil
    }

    private func persistExpectsLoginAfterSignOut(_ value: Bool) {
        expectsLoginAfterSignOut = value
        UserDefaults.standard.set(value, forKey: Self.expectsLoginAfterSignOutKey)
    }

    var userEmail: String? {
        session?.user.email
    }

    var userDisplayName: String {
        if let email = userEmail, !email.isEmpty {
            return email
        }
        return "Invitado"
    }

    /// Nombre corto para saludo (parte local del correo, legible).
    var shortGreetingName: String {
        guard let email = userEmail, !email.isEmpty else { return "Invitado" }
        guard let at = email.firstIndex(of: "@") else { return email }
        let local = String(email[..<at])
        let parts = local.split { $0 == "." || $0 == "_" || $0 == "-" }
        let words = parts.map { String($0).capitalized }.filter { !$0.isEmpty }
        if words.isEmpty { return "Invitado" }
        return words.joined(separator: " ")
    }

    var userInitials: String {
        let name = shortGreetingName
        let parts = name.split(separator: " ")
        if parts.count >= 2, let a = parts[0].first, let b = parts[1].first {
            return "\(a)\(b)".uppercased()
        }
        if let f = name.first { return String(f).uppercased() }
        return "?"
    }

    private func startAuthStateListener() {
        authStateTask?.cancel()
        authStateTask = Task { [client] in
            for await (_, newSession) in client.auth.authStateChanges {
                await MainActor.run {
                    self.session = newSession
                    if newSession != nil {
                        self.persistExpectsLoginAfterSignOut(false)
                    }
                    SmileLuxAccountStorage.syncFromSession(newSession)
                    self.isRestoringSession = false
                    self.scheduleProfileAvatarLoad()
                }
            }
        }
    }

    private func refreshSessionIfNeeded() async {
        defer { isRestoringSession = false }
        do {
            let s = try await client.auth.session
            await MainActor.run {
                self.session = s
                self.persistExpectsLoginAfterSignOut(false)
                SmileLuxAccountStorage.syncFromSession(s)
                self.scheduleProfileAvatarLoad()
            }
        } catch {
            await MainActor.run {
                self.session = client.auth.currentSession
                if self.session != nil {
                    self.persistExpectsLoginAfterSignOut(false)
                }
                SmileLuxAccountStorage.syncFromSession(self.session)
                self.scheduleProfileAvatarLoad()
            }
        }
    }

    private func scheduleProfileAvatarLoad() {
        profileAvatarTask?.cancel()
        guard let session else {
            profileAvatarImage = nil
            return
        }

        let user = session.user
        let userId = user.id
        let token = session.accessToken

        profileAvatarTask = Task { [client] in
            let ref = await UserProfileService.resolveAvatarRef(user: user, client: client)
            guard !Task.isCancelled else { return }
            let image = await UserProfileService.loadProfileAvatarImage(
                avatarRef: ref,
                userId: userId,
                client: client,
                accessToken: token
            )
            guard !Task.isCancelled else { return }
            await MainActor.run {
                guard self.session?.user.id == userId else { return }
                self.profileAvatarImage = image
            }
        }
    }

    func signIn(email: String, password: String) async {
        lastErrorMessage = nil
        let trimmed = email.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, !password.isEmpty else {
            lastErrorMessage = "Introduce correo y contraseña."
            return
        }
        do {
            let s = try await client.auth.signIn(email: trimmed, password: password)
            session = s
            SmileLuxAccountStorage.syncFromSession(s)
            persistExpectsLoginAfterSignOut(false)
            scheduleProfileAvatarLoad()
        } catch {
            lastErrorMessage = error.localizedDescription
        }
    }

    func signUp(email: String, password: String) async {
        lastErrorMessage = nil
        let trimmed = email.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, !password.isEmpty else {
            lastErrorMessage = "Introduce correo y contraseña."
            return
        }
        do {
            let response = try await client.auth.signUp(email: trimmed, password: password)
            if let s = response.session {
                session = s
                SmileLuxAccountStorage.syncFromSession(s)
                persistExpectsLoginAfterSignOut(false)
                scheduleProfileAvatarLoad()
            } else {
                lastErrorMessage =
                    "Cuenta creada. Si el proyecto exige confirmar el correo, revisa tu bandeja de entrada."
            }
        } catch {
            lastErrorMessage = error.localizedDescription
        }
    }

    func signOut() async {
        lastErrorMessage = nil
        profileAvatarTask?.cancel()
        profileAvatarImage = nil
        do {
            try await client.auth.signOut()
        } catch {
            lastErrorMessage = error.localizedDescription
        }
        session = nil
        SmileLuxAccountStorage.syncFromSession(nil)
        persistExpectsLoginAfterSignOut(true)
    }

    func resetPassword(email: String) async -> String? {
        lastErrorMessage = nil
        let trimmed = email.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            lastErrorMessage = "Introduce tu correo."
            return nil
        }
        do {
            try await client.auth.resetPasswordForEmail(trimmed)
            return "Si existe una cuenta con ese correo, recibirás un enlace para restablecer la contraseña."
        } catch {
            lastErrorMessage = error.localizedDescription
            return nil
        }
    }
}
