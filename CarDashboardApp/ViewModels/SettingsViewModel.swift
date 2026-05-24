import Foundation
import SwiftUI
import WidgetKit

@MainActor
final class SettingsViewModel: ObservableObject {
    let appVersion = "1.0.0"
    let buildNumber = "2025.03"

    /// Incrementa al cambiar idioma para forzar reconstrucción de vistas que leen `LocaleTriple` / `TefilaCopy`.
    @Published private(set) var languageRevision = 0

    @Published var appLanguage: TefilaAppLanguage {
        didSet {
            guard oldValue != appLanguage else { return }
            UserDefaults.standard.set(appLanguage.rawValue, forKey: TefilaAppLanguage.persistenceKey)
            languageRevision += 1
            WidgetCenter.shared.reloadAllTimelines()
        }
    }

    var effectiveLocale: Locale {
        switch appLanguage {
        case .spanish:
            return Locale(identifier: "es_ES")
        case .english:
            return Locale(identifier: "en_US")
        case .hebrew:
            return Locale(identifier: "he_IL")
        }
    }

    init() {
        if let raw = UserDefaults.standard.string(forKey: TefilaAppLanguage.persistenceKey),
           let lang = TefilaAppLanguage(rawValue: raw) {
            appLanguage = lang
        } else {
            let inferred = TefilaAppLanguage.inferredFromSystemLocale()
            UserDefaults.standard.set(inferred.rawValue, forKey: TefilaAppLanguage.persistenceKey)
            appLanguage = inferred
        }
    }
}
