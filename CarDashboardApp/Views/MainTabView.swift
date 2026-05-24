import SwiftUI

// MARK: - Pestañas (TabView nativo + router de acciones)

struct MainTabView: View {
    @StateObject private var shell = AppShellRouter()
    @StateObject private var prayerSpeechPlayback = PrayerSpeechPlaybackController()
    @State private var chatSearchText = ""
    @EnvironmentObject private var chatInbox: ChatInboxStore
    @EnvironmentObject private var savedPrayers: SavedPrayersStore
    @EnvironmentObject private var auth: AuthViewModel
    @EnvironmentObject private var settingsVM: SettingsViewModel

    var body: some View {
        TabView(selection: $shell.selectedTab) {
            Tab(TefilaCopy.tabHome, systemImage: "house.fill", value: AppShellRouter.Tab.home) {
                NavigationStack {
                    DashboardView()
                }
            }

            Tab(TefilaCopy.tabPassages, systemImage: "book.closed.fill", value: AppShellRouter.Tab.favorites) {
                NavigationStack {
                    PassagesView()
                }
            }

            Tab(TefilaCopy.tabTefila, systemImage: TefilaCopy.tabTefilaSystemImage, value: AppShellRouter.Tab.prayers) {
                NavigationStack {
                    MyPrayersView()
                }
            }

            Tab(TefilaCopy.tabProfile, systemImage: "person.circle.fill", value: AppShellRouter.Tab.chat) {
                NavigationStack {
                    SettingsView()
                }
            }
        }
        .tint(PremiumAccent.tabActive)
        .environmentObject(chatInbox)
        .environmentObject(savedPrayers)
        .environmentObject(prayerSpeechPlayback)
        .environmentObject(shell)
        .sheet(item: $shell.homeSheet) { item in
            Group {
                switch item {
                case .reports:
                    ClinicReportsSheetView()
                case .billing:
                    ClinicBillingSheetView()
                case .more:
                    ClinicMoreSheetView()
                case .notifications:
                    ClinicNotificationsSheetView()
                        .environmentObject(chatInbox)
                }
            }
            .environmentObject(shell)
        }
        .sheet(isPresented: $shell.showLeadsBrowser) {
            NavigationStack {
                LeadsListView()
            }
            .environmentObject(shell)
        }
        .sheet(isPresented: $shell.showPatientRecordsBrowser) {
            NavigationStack {
                PatientRecordsBrowseView()
            }
            .environmentObject(shell)
        }
        .sheet(isPresented: $shell.showSettingsSheet) {
            NavigationStack {
                SettingsView()
            }
            .environmentObject(shell)
            .environmentObject(auth)
            .environmentObject(settingsVM)
        }
        // Evita que, al hacer scroll en listas largas (p. ej. Mis oraciones), la tab bar minimizada deje pill/círculos vítreos flotantes.
        .tabBarMinimizeBehavior(.never)
        .onChange(of: shell.selectedTab) { _, newTab in
            UserDefaults.standard.set(newTab.rawValue, forKey: "TefilaLastSelectedTab")
        }
    }
}

#Preview {
    MainTabView()
        .environmentObject(ChatInboxStore())
        .environmentObject(SavedPrayersStore())
        .environmentObject(PatientsRegistryViewModel())
        .environmentObject(SettingsViewModel())
        .environmentObject(AuthViewModel())
}
