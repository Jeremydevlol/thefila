import SwiftUI

/// Raíz después del splash: restauración Supabase → `LoginView` o contenido principal.
struct AuthRootView: View {
    @ObservedObject var auth: AuthViewModel
    @EnvironmentObject var patientsRegistryVM: PatientsRegistryViewModel
    @EnvironmentObject var settingsVM: SettingsViewModel
    @StateObject private var chatInbox = ChatInboxStore()

    var body: some View {
        Group {
            if auth.isRestoringSession {
                ZStack {
                    Color(.systemGroupedBackground)
                        .ignoresSafeArea()
                    ProgressView("Conectando…")
                }
            } else if !auth.isAuthenticated {
                LoginView(auth: auth)
            } else {
                MainTabView()
                    .environmentObject(chatInbox)
            }
        }
        .environmentObject(auth)
        .onOpenURL { url in
            SupabaseClientProvider.shared.auth.handle(url)
        }
    }
}

#Preview {
    AuthRootView(auth: AuthViewModel())
        .environmentObject(PatientsRegistryViewModel())
        .environmentObject(SettingsViewModel())
}
