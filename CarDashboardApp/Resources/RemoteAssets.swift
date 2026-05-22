import Foundation

enum RemoteAssets {
    /// Imagen hero tipo clínica / bienestar (sustituye el antiguo showroom de coches).
    static let clinicHeroImageURL = URL(string: "https://images.unsplash.com/photo-1576091160399-112ba8d25d1d?w=800&h=640&fit=crop")!

    static var dashboardHeroStock: URL { clinicHeroImageURL }
    static let dashboardHeroValue = URL(string: "https://picsum.photos/seed/doctorfly_value/800/640")!
    static let dashboardHeroCaptured = URL(string: "https://picsum.photos/seed/doctorfly_patients/800/640")!
    static let dashboardHeroCommission = URL(string: "https://picsum.photos/seed/doctorfly_team/800/640")!

    /// Retratos estables para avatares de demo en el listado de chat.
    static func chatThreadPortrait(_ seed: Int) -> URL {
        URL(string: "https://picsum.photos/seed/doctorfly_chat\(seed)/400/400")!
    }
}
