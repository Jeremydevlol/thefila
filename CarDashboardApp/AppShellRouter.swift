import SwiftUI

// MARK: - Hojas modales desde Inicio / cabeceras

enum ClinicHomeSheet: Identifiable {
    case reports
    case billing
    case more
    case notifications

    var id: String {
        switch self {
        case .reports: return "reports"
        case .billing: return "billing"
        case .more: return "more"
        case .notifications: return "notifications"
        }
    }
}

/// Coordina pestañas, hojas de informes / facturación y accesos rápidos a fichas.
@MainActor
final class AppShellRouter: ObservableObject {
    enum Tab: String, Hashable, CaseIterable {
        case home
        case favorites
        case prayers
        case chat
    }

    private static let lastTabKey = "TefilaLastSelectedTab"

    @Published var selectedTab: Tab = .home
    @Published var homeSheet: ClinicHomeSheet?
    /// Cuenta y cierre de sesión (antes pestaña Ajustes).
    @Published var showSettingsSheet: Bool = false
    /// Presenta el listado de fichas (antes en la pestaña Consultorio).
    @Published var showPatientRecordsBrowser: Bool = false
    /// Tras cambiar a Inicio, el carrusel KPI hace scroll al ancla.
    @Published var scrollHomeToKPI: Bool = false
    @Published var showLeadsBrowser: Bool = false

    init() {
        if let raw = UserDefaults.standard.string(forKey: Self.lastTabKey),
           let restored = Tab(rawValue: raw) {
            selectedTab = restored
        }
    }

    func openPatientRecordsBrowser() {
        showPatientRecordsBrowser = true
    }

    /// Cambia a Inicio y pide scroll al bloque de estadísticas (KPI).
    func goHomeAndFocusKPI() {
        selectedTab = .home
        scrollHomeToKPI = true
    }

    func openHomeSheet(_ sheet: ClinicHomeSheet) {
        homeSheet = sheet
    }

    func openSettingsSheet() {
        showSettingsSheet = true
    }
}
