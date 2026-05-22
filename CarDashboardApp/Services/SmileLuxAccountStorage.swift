import Foundation
import Supabase

/// Aísla datos SMILELUX (simulaciones, informes, última copia) por cuenta de Supabase; sin sesión usa `anonymous`.
enum SmileLuxAccountStorage {
    private static let userDefaultsKey = "SmileLuxActiveAccountStorageId"

    static var activeAccountId: String {
        UserDefaults.standard.string(forKey: userDefaultsKey) ?? "anonymous"
    }

    /// Llamar cuando cambie la sesión (login, logout, refresh).
    static func syncFromSession(_ session: Session?) {
        let id: String
        if let u = session?.user.id {
            id = u.uuidString.lowercased()
        } else {
            id = "anonymous"
        }
        if UserDefaults.standard.string(forKey: userDefaultsKey) != id {
            UserDefaults.standard.set(id, forKey: userDefaultsKey)
        }
    }
}
