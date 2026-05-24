import SwiftUI
import UIKit

// MARK: - PrayerAudioView (reproductor con síntesis de voz)

struct PrayerAudioView: View {
    let intention: PrayerIntention
    let location: SacredLocation
    let hebrewName: String
    let prayerText: String
    let audioLanguage: PrayerLanguage

    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var savedPrayers: SavedPrayersStore
    @EnvironmentObject private var speech: PrayerSpeechPlaybackController
    @State private var didAutoSaveFavorite = false

    private let goldAccent = Color(red: 236/255, green: 196/255, blue: 95/255)
    private let goldMid    = Color(red: 219/255, green: 175/255, blue: 75/255)
    private let goldDeep   = Color(red: 172/255, green: 128/255, blue: 44/255)
    private let navyInk = Color(red: 42/255, green: 58/255, blue: 98/255)
    /// Lavanda editorial (Pasajes/checkout); nombre explícito evita errores si `purple` no resuelve en el SDK.
    private let tefilaPurpleAccent = Color(red: 0.48, green: 0.35, blue: 0.74)

    private var elapsedSeconds: Double {
        speech.estimatedDurationSeconds * speech.progress
    }

    private var remainingSeconds: Double {
        max(0, speech.estimatedDurationSeconds - elapsedSeconds)
    }

    var body: some View {
        ZStack {
            TefilaSpiritualFondoBackdrop(lightVeilOpacity: 0.18)

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 18) {
                    pageHeader
                    playerCard
                    inspirationCard
                    spiritualIntelligenceCard
                    infoRow
                    prayerTextCard
                }
                .padding(.horizontal, 18)
                .padding(.bottom, 40)
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button { pauseAndDismiss() } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left").font(.system(size: 14, weight: .semibold))
                        Text("Mis oraciones").font(.system(size: 16, weight: .medium))
                    }
                    .foregroundStyle(goldAccent)
                }
            }
            .sharedBackgroundVisibility(.hidden)
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button("Compartir tefilá", systemImage: "square.and.arrow.up") { }
                    Button("Guardar en favoritos", systemImage: "heart") {
                        persistFavoriteToStore()
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .font(.system(size: 18))
                        .foregroundStyle(navyInk.opacity(0.6))
                }
            }
            .sharedBackgroundVisibility(.hidden)
        }
        .toolbarBackground(.hidden, for: .navigationBar)
        .environment(\.colorScheme, .light)
        .preferredColorScheme(.light)
        .onAppear {
            if !didAutoSaveFavorite {
                didAutoSaveFavorite = true
                persistFavoriteToStore()
            }
            speech.preparePrayerPlaybackIfNeeded(
                signature: playbackSignatureValue,
                prayerText: prayerText,
                language: audioLanguage,
                titles: prayerNowPlayingTitles
            )
        }
    }

    // MARK: - Page header (celestial background area)

    private var pageHeader: some View {
        VStack(spacing: 8) {
            Group {
                if UIImage(named: "TefilaLogo") != nil {
                    Image("TefilaLogo").resizable().scaledToFit().frame(height: 38)
                } else {
                    Image(systemName: "music.note").font(.system(size: 26, weight: .bold)).foregroundStyle(goldAccent)
                }
            }
            .padding(.top, 12)

            Text("TEFILA")
                .font(.system(size: 10, weight: .bold))
                .tracking(2.5)
                .foregroundStyle(goldMid)
        }
    }

    // MARK: - Player card (principal)

    private var playerCard: some View {
        VStack(spacing: 0) {
            HStack(alignment: .center, spacing: 14) {
                TefilaBanderaMark(width: 36, height: 72)

                VStack(alignment: .leading, spacing: 4) {
                    Text(intention.title)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(goldMid)
                    Text(prayerText.isEmpty ? "Salmos del día recomendados" : intention.title)
                        .font(.system(size: 20, weight: .bold, design: .serif))
                        .foregroundStyle(navyInk)
                        .lineLimit(2)
                }
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 14)

            VStack(spacing: 6) {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(navyInk.opacity(0.10))
                            .frame(height: 5)
                        Capsule()
                            .fill(LinearGradient(colors: [goldAccent, goldMid], startPoint: .leading, endPoint: .trailing))
                            .frame(width: max(8, geo.size.width * CGFloat(speech.progress)), height: 5)
                    }
                }
                .frame(height: 5)
                .padding(.horizontal, 16)

                HStack {
                    Text(formatTime(elapsedSeconds))
                    Spacer()
                    Text("-\(formatTime(remainingSeconds))")
                }
                .font(.system(size: 12, weight: .semibold, design: .monospaced))
                .foregroundStyle(navyInk.opacity(0.5))
                .padding(.horizontal, 16)
            }

            HStack(spacing: 0) {
                controlButton(icon: "gobackward.15") {
                    speech.skip(seconds: -15)
                }

                controlButton(icon: "backward.end.fill") {
                    speech.seekToBeginning()
                }

                Button {
                    speech.togglePlayPause()
                } label: {
                    ZStack {
                        Circle()
                            .fill(LinearGradient(colors: [goldAccent, goldMid], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(width: 62, height: 62)
                            .shadow(color: goldDeep.opacity(0.45), radius: 12, x: 0, y: 6)
                        if speech.isGeneratingCloudVoice {
                            ProgressView()
                                .tint(navyInk)
                        } else {
                            Image(systemName: speech.isSpeaking ? "pause.fill" : "play.fill")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundStyle(navyInk)
                                .offset(x: speech.isSpeaking ? 0 : 2)
                        }
                    }
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 14)

                controlButton(icon: "forward.end.fill") {
                    speech.skip(seconds: speech.estimatedDurationSeconds * 0.06)
                }

                controlButton(icon: "goforward.15") {
                    speech.skip(seconds: 15)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 8)
            .padding(.bottom, 18)

            Text(
                speech.isGeneratingCloudVoice
                    ? TefilaCopy.choose(
                        "Generando narración con tu voz en la nube…",
                        "Preparing narration with cloud voice…",
                        "מייצרים דיבור מהענן…"
                      )
                    : TefilaCopy.choose(
                        "VIERA IA (voz en la nube) si hay clave API; si no, voz del sistema.",
                        "VIERA IA cloud voice when API key present; otherwise system voice.",
                        "VIERA IA אם קיימת מפתח; אחרת קול המערכת."
                      )
            )
            .font(.system(size: 10.5, weight: .medium))
            .foregroundStyle(navyInk.opacity(0.5))
            .multilineTextAlignment(.center)
            .padding(.horizontal, 10)
            .padding(.bottom, 14)
        }
        .background {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(.white.opacity(0.94))
                .overlay {
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.8), lineWidth: 1)
                }
                .shadow(color: .black.opacity(0.09), radius: 16, x: 0, y: 8)
        }
    }

    // MARK: - Inspiration quote — fondo de contenedor `Salmo`

    private var inspirationCard: some View {
        ZStack(alignment: .topLeading) {
            prayerAudioCardBackdropLayer(
                assetName: "Salmo",
                fallbackColor: Color(red: 1, green: 0.97, blue: 0.88),
                washColor: Color(red: 1, green: 0.97, blue: 0.88),
                washOpacity: 0.74
            )

            HStack(alignment: .top, spacing: 14) {
                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 6) {
                        Text("❝")
                            .font(.system(size: 22, weight: .heavy))
                            .foregroundStyle(goldMid)
                            .shadow(color: .black.opacity(0.12), radius: 0, x: 0, y: 0.8)
                        Text("Frase que te inspira")
                            .font(.system(size: 13.5, weight: .bold))
                            .foregroundStyle(goldMid)
                    }

                    Text(inspirationQuote)
                        .font(.system(size: 17, weight: .medium, design: .serif))
                        .foregroundStyle(navyInk)
                        .shadow(color: .white.opacity(0.35), radius: 0.5, x: 0, y: 0)
                        .fixedSize(horizontal: false, vertical: true)
                        .lineSpacing(3)

                    Text(inspirationReference)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(goldMid)
                }
                Spacer(minLength: 0)
            }
            .padding(18)
        }
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .strokeBorder(goldAccent.opacity(0.32), lineWidth: 1)
        }
        .shadow(color: goldDeep.opacity(0.14), radius: 8, x: 0, y: 4)
    }

    // MARK: - Inteligencia espiritual — fondo de contenedor `Tefila`

    private var spiritualIntelligenceCard: some View {
        ZStack(alignment: .topLeading) {
            prayerAudioCardBackdropLayer(
                assetName: "Tefila",
                fallbackColor: tefilaPurpleAccent.opacity(0.08),
                washColor: .white,
                washOpacity: 0.62,
                secondaryWash: Color(red: 0.52, green: 0.40, blue: 0.78),
                secondaryWashOpacity: 0.12
            )

            HStack(alignment: .top, spacing: 14) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 6) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 13))
                            .foregroundStyle(tefilaPurpleAccent)
                            .shadow(color: .white.opacity(0.55), radius: 0, x: 0, y: 0.5)
                        Text("Inteligencia espiritual")
                            .font(.system(size: 13.5, weight: .bold))
                            .foregroundStyle(tefilaPurpleAccent)
                    }
                    Text(spiritualReflection)
                        .font(.system(size: 13.5, weight: .medium))
                        .foregroundStyle(navyInk.opacity(0.82))
                        .shadow(color: .white.opacity(0.42), radius: 0.5, x: 0, y: 0)
                        .fixedSize(horizontal: false, vertical: true)
                        .lineSpacing(3)
                }
                Spacer(minLength: 0)
            }
            .padding(18)
        }
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .strokeBorder(tefilaPurpleAccent.opacity(0.22), lineWidth: 1)
        }
        .shadow(color: tefilaPurpleAccent.opacity(0.12), radius: 8, x: 0, y: 3)
    }

    private var infoRow: some View {
        let headline = prayerAudioLocationHeadline
        let subtitleText = prayerAudioLocationSubtitle

        return HStack(alignment: .center, spacing: 14) {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 5) {
                    Image(systemName: "location.fill")
                        .font(.system(size: 13))
                        .foregroundStyle(tefilaPurpleAccent)
                    Text("Ubicación")
                        .font(.system(size: 12.5, weight: .bold))
                        .foregroundStyle(tefilaPurpleAccent)
                }
                Text(headline)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(navyInk)
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.leading)

                if let detail = subtitleText, !detail.isEmpty {
                    Text(detail)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(navyInk.opacity(0.55))
                        .fixedSize(horizontal: false, vertical: true)
                        .multilineTextAlignment(.leading)
                }
            }

            Image(systemName: "building.columns.fill")
                .font(.system(size: 36))
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(tefilaPurpleAccent.opacity(0.28))
                .padding(.leading, 4)
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(.white.opacity(0.88))
                .overlay {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.7), lineWidth: 1)
                }
                .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 4)
        }
    }

    private var prayerAudioLocationHeadline: String {
        let segs = location.displayName.components(separatedBy: "·").map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
        return segs.first ?? location.displayName.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var prayerAudioLocationSubtitle: String? {
        let segs = location.displayName.components(separatedBy: "·").map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
        guard segs.count > 1 else { return nil }
        return segs.dropFirst().joined(separator: " · ")
    }

    private var prayerTextCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                TefilaBanderaMark(width: 26, height: 54)

                VStack(alignment: .leading, spacing: 2) {
                    Text(intention.title)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(goldMid)
                    Text(speech.isSpeaking ? TefilaCopy.choose("Reproduciendo…", "Playing…", "משמיע…") : TefilaCopy.choose("En pausa", "Paused", "מושהה"))
                        .font(.system(size: 11.5, weight: .medium))
                        .foregroundStyle(navyInk.opacity(0.5))
                }
                Spacer()
                Button { speech.togglePlayPause() } label: {
                    Image(systemName: speech.isSpeaking ? "pause.fill" : "play.fill")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(goldMid)
                        .frame(width: 36, height: 36)
                        .background(goldAccent.opacity(0.15), in: Circle())
                }
                .buttonStyle(.plain)
            }

            if !prayerText.isEmpty {
                Divider().opacity(0.15)
                Text(prayerText)
                    .font(.system(size: 13.5, weight: .medium))
                    .foregroundStyle(navyInk.opacity(0.75))
                    .fixedSize(horizontal: false, vertical: true)
                    .lineSpacing(4)
            }
        }
        .padding(16)
        .background {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.white.opacity(0.92))
                .overlay {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.75), lineWidth: 1)
                }
                .shadow(color: .black.opacity(0.07), radius: 10, x: 0, y: 5)
        }
    }

    private func controlButton(icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .medium))
                .foregroundStyle(navyInk.opacity(0.65))
                .frame(width: 44, height: 44)
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity)
    }

    private func pauseAndDismiss() {
        speech.endLocalPlayerSession()
        dismiss()
    }

    /// Firma estable en memoria por intención + idioma + texto (no persiste entre ejecuciones).
    private var playbackSignatureValue: Int {
        var hasher = Hasher()
        hasher.combine(intention.id)
        hasher.combine(audioLanguage.rawValue)
        hasher.combine(prayerText)
        return hasher.finalize()
    }

    private var prayerNowPlayingTitles: PrayerSpeechNowPlayingTitles {
        let trimmedName = hebrewName.trimmingCharacters(in: .whitespacesAndNewlines)
        let artist: String =
            trimmedName.isEmpty
            ? TefilaCopy.choose("Tefila", "Tefila", "תפלה")
            : TefilaCopy.choose(
                "Tefila — \(trimmedName)",
                "Tefila — \(trimmedName)",
                "תפלה — \(trimmedName)"
            )
        let locationShort =
            location.displayName.components(separatedBy: "·").first?.trimmingCharacters(in: .whitespaces)
            ?? location.displayName
        let album = locationShort.isEmpty ? TefilaCopy.choose("Tehilá", "Prayer", "תפלה") : locationShort

        return PrayerSpeechNowPlayingTitles(
            title: intention.title,
            artist: artist,
            album: album
        )
    }

    /// Persiste texto + intención + idioma de audio para reabrir desde Favoritos (deduplica en el store).
    private func persistFavoriteToStore() {
        guard !prayerText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        savedPrayers.addPrayer(
            prayerText: prayerText,
            intention: intention,
            location: location,
            audioLanguage: audioLanguage,
            hebrewName: hebrewName
        )
    }

    private var inspirationQuote: String {
        switch intention.id {
        case "salud":
            return "«Porque Hashem es bueno; para siempre es su misericordia, y su fidelidad por todas las generaciones.»"
        case "exito":
            return "«Encomienda a Hashem tus obras y tus planes se consolidarán.»"
        case "paz_casa":
            return "«Tu mujer será como vid fructífera en los lados de tu casa.»"
        default:
            return "«Confía en Hashem con todo tu corazón y Él enderezará tus sendas.»"
        }
    }

    private var inspirationReference: String {
        switch intention.id {
        case "salud":   return "— Tehilim 100:5"
        case "exito":   return "— Mishlé 16:3"
        case "paz_casa":return "— Tehilim 128:3"
        default:        return "— Mishlé 3:5-6"
        }
    }

    private var spiritualReflection: String {
        "Este pasaje nos recuerda que la bondad de Hashem no depende de nuestras circunstancias. Su rachamim es constante y eterna. Confía, agradece y descansa en Él hoy. Cada tefilá que sube al Cielo lleva consigo la luz de la Torá y la esperanza del pueblo de Israel."
    }

    /// Fondo de tarjeta: imagen **`Salmo` / `Tefila`** a pantalla + velos (mismo PNG que en `Assets`, p. ej. `ChatBackdropBase` duplicados).
    @ViewBuilder
    private func prayerAudioCardBackdropLayer(
        assetName: String,
        fallbackColor: Color,
        washColor: Color,
        washOpacity: CGFloat,
        secondaryWash: Color = .clear,
        secondaryWashOpacity: CGFloat = 0
    ) -> some View {
        ZStack {
            if UIImage(named: assetName) != nil {
                Image(assetName)
                    .resizable()
                    .scaledToFill()
            } else {
                fallbackColor
            }

            washColor.opacity(washOpacity)

            if secondaryWashOpacity > 0 {
                secondaryWash.opacity(secondaryWashOpacity)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }

    private func formatTime(_ seconds: Double) -> String {
        let s = Int(seconds.rounded())
        return String(format: "%02d:%02d", s / 60, s % 60)
    }
}

#Preview {
    NavigationStack {
        PrayerAudioView(
            intention: MockIntentions.all[0],
            location: .kotel,
            hebrewName: "Yosef ben Sarah",
            prayerText: "Que Hashem escuche esta tefilá...",
            audioLanguage: .spanish
        )
        .environmentObject(SavedPrayersStore())
        .environmentObject(PrayerSpeechPlaybackController())
    }
}
