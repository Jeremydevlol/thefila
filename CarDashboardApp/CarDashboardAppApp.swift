import SwiftUI

@main
struct CarDashboardAppApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var authVM = AuthViewModel()
    @StateObject private var patientsRegistryVM = PatientsRegistryViewModel()
    @StateObject private var settingsVM = SettingsViewModel()

    var body: some Scene {
        WindowGroup {
            AppShellRoot(authVM: authVM)
                .environmentObject(patientsRegistryVM)
                .environmentObject(settingsVM)
                .preferredColorScheme(.light)
                .statusBarIconsLightContent()
        }
    }
}

private struct AppShellRoot: View {
    @ObservedObject var authVM: AuthViewModel
    @EnvironmentObject var patientsRegistryVM: PatientsRegistryViewModel
    @EnvironmentObject var settingsVM: SettingsViewModel
    @State private var launchVideoFinished = false

    var body: some View {
        Group {
            if launchVideoFinished {
                AuthRootView(auth: authVM)
                    .environmentObject(patientsRegistryVM)
                    .environmentObject(settingsVM)
            } else {
                AppLaunchSplashView {
                    launchVideoFinished = true
                }
            }
        }
    }
}
