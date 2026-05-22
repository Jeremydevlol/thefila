import Foundation
import SwiftUI

/// Oración personalizada lista para reproducir de nuevo (persistida en dispositivo).
struct SavedTefilaPrayer: Codable, Identifiable, Hashable {
    let id: UUID
    let createdAt: Date
    let prayerText: String
    let intentionId: String
    let intentionTitle: String
    let intentionSubtitle: String
    let sfSymbol: String
    let hebrewKeyword: String
    let locationRawValue: String
    let audioLanguageRaw: String
    let hebrewName: String

    func resolvedIntention() -> PrayerIntention {
        if let match = MockIntentions.all.first(where: { $0.id == intentionId }) {
            return match
        }
        let gold = Color(red: 236 / 255, green: 196 / 255, blue: 95 / 255)
        return PrayerIntention(
            id: intentionId,
            title: intentionTitle,
            subtitle: intentionSubtitle,
            sfSymbol: sfSymbol,
            hebrewKeyword: hebrewKeyword,
            accentColor: gold
        )
    }

    func resolvedLocation() -> SacredLocation {
        SacredLocation(rawValue: locationRawValue) ?? .kotel
    }

    func resolvedAudioLanguage() -> PrayerLanguage {
        PrayerLanguage(rawValue: audioLanguageRaw) ?? .spanish
    }
}
