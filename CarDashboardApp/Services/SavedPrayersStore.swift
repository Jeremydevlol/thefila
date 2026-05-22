import Foundation

/// Almacena las tefilot creadas localmente para escucharlas otra vez desde Favoritos.
@MainActor
final class SavedPrayersStore: ObservableObject {
    private static let defaultsKey = "SavedTefilaPrayers.v1"

    @Published private(set) var prayers: [SavedTefilaPrayer] = []

    init() {
        load()
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: Self.defaultsKey) else {
            prayers = []
            return
        }
        let dec = JSONDecoder()
        dec.dateDecodingStrategy = .iso8601
        if let decoded = try? dec.decode([SavedTefilaPrayer].self, from: data) {
            prayers = decoded.sorted { $0.createdAt > $1.createdAt }
        }
    }

    private func persist() {
        let enc = JSONEncoder()
        enc.dateEncodingStrategy = .iso8601
        enc.outputFormatting = [.sortedKeys]
        if let data = try? enc.encode(prayers) {
            UserDefaults.standard.set(data, forKey: Self.defaultsKey)
        }
    }

    /// Añade una oración (p. ej. al abrir el reproductor después del flujo de creación).
    func addPrayer(
        prayerText: String,
        intention: PrayerIntention,
        location: SacredLocation,
        audioLanguage: PrayerLanguage,
        hebrewName: String
    ) {
        let trimmed = prayerText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        let isDup = prayers.contains {
            $0.prayerText == trimmed
                && $0.intentionId == intention.id
                && $0.locationRawValue == location.rawValue
                && $0.audioLanguageRaw == audioLanguage.rawValue
        }
        guard !isDup else { return }

        let entry = SavedTefilaPrayer(
            id: UUID(),
            createdAt: Date(),
            prayerText: trimmed,
            intentionId: intention.id,
            intentionTitle: intention.title,
            intentionSubtitle: intention.subtitle,
            sfSymbol: intention.sfSymbol,
            hebrewKeyword: intention.hebrewKeyword,
            locationRawValue: location.rawValue,
            audioLanguageRaw: audioLanguage.rawValue,
            hebrewName: hebrewName.trimmingCharacters(in: .whitespacesAndNewlines)
        )
        prayers.insert(entry, at: 0)
        persist()
    }

    func remove(id: UUID) {
        prayers.removeAll { $0.id == id }
        persist()
    }
}
