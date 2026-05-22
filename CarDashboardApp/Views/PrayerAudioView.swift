import SwiftUI

// MARK: - PrayerAudioView (reproductor mock)

struct PrayerAudioView: View {
    let intention: PrayerIntention
    let location: SacredLocation
    let hebrewName: String
    let prayerText: String

    @Environment(\.dismiss) private var dismiss
    @State private var isPlaying: Bool = false
    @State private var progress: Double = 0.287     // 08:42 de 30:00
    @State private var timer: Timer? = nil

    private let totalSeconds: Double = 30 * 60      // 30:00
    private let goldAccent = Color(red: 236/255, green: 196/255, blue: 95/255)
    private let goldMid    = Color(red: 219/255, green: 175/255, blue: 75/255)
    private let goldDeep   = Color(red: 172/255, green: 128/255, blue: 44/255)
    private let navyInk    = Color(red: 42/255, green: 58/255, blue: 98/255)
    private let purple     = Color(red: 0.48, green: 0.35, blue: 0.74)

    private var currentSeconds: Double { progress * totalSeconds }
    private var currentTime: String { formatTime(currentSeconds) }
    private var remainingTime: String { formatTime(totalSeconds) }

    var body: some View {
        ZStack {
            Image("TefilaHomeBackground")
                .resizable().scaledToFill().ignoresSafeArea()
                .accessibilityIgnoresInvertColors(true)
            Color.white.opacity(0.18).ignoresSafeArea().allowsHitTesting(false)

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
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button("Compartir tefilá", systemImage: "square.and.arrow.up") { }
                    Button("Guardar en favoritos", systemImage: "heart") { }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .font(.system(size: 18))
                        .foregroundStyle(navyInk.opacity(0.6))
                }
            }
        }
        .toolbarBackground(.hidden, for: .navigationBar)
        .environment(\.colorScheme, .light)
        .preferredColorScheme(.light)
        .onDisappear { stopTimer() }
    }

    // MARK: - Page header (celestial background area)

    private var pageHeader: some View {
        VStack(spacing: 8) {
            Group {
                if let _ = UIImage(named: "TefilaLogo") {
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
            // Header de la card
            HStack(alignment: .center, spacing: 14) {
                // Cinta morada
                ZStack {
                    PassageRibbonShape()
                        .fill(LinearGradient(colors: [purple, purple.opacity(0.75)], startPoint: .top, endPoint: .bottom))
                        .overlay { PassageRibbonShape().stroke(Color.white.opacity(0.35), lineWidth: 0.75) }
                        .shadow(color: purple.opacity(0.45), radius: 4, x: 0, y: 2)
                    Image(systemName: "star.of.david.fill")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(LinearGradient(colors: [goldAccent, goldDeep], startPoint: .top, endPoint: .bottom))
                        .offset(y: -6)
                }
                .frame(width: 32, height: 66)

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

            // Progress bar
            VStack(spacing: 6) {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(navyInk.opacity(0.10))
                            .frame(height: 5)
                        Capsule()
                            .fill(LinearGradient(colors: [goldAccent, goldMid], startPoint: .leading, endPoint: .trailing))
                            .frame(width: geo.size.width * progress, height: 5)
                    }
                }
                .frame(height: 5)
                .padding(.horizontal, 16)

                HStack {
                    Text(currentTime)
                    Spacer()
                    Text(remainingTime)
                }
                .font(.system(size: 12, weight: .semibold, design: .monospaced))
                .foregroundStyle(navyInk.opacity(0.5))
                .padding(.horizontal, 16)
            }

            // Controls
            HStack(spacing: 0) {
                // -15s
                controlButton(icon: "gobackward.15") {
                    progress = max(0, progress - 15/totalSeconds)
                }

                // Back
                controlButton(icon: "backward.end.fill") {
                    progress = 0
                }

                // Play / Pause (grande)
                Button {
                    togglePlay()
                } label: {
                    ZStack {
                        Circle()
                            .fill(LinearGradient(colors: [goldAccent, goldMid], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(width: 62, height: 62)
                            .shadow(color: goldDeep.opacity(0.45), radius: 12, x: 0, y: 6)
                        Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundStyle(navyInk)
                            .offset(x: isPlaying ? 0 : 2)
                    }
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 14)

                // Forward
                controlButton(icon: "forward.end.fill") {
                    progress = min(1, progress + 0.05)
                }

                // +15s
                controlButton(icon: "goforward.15") {
                    progress = min(1, progress + 15/totalSeconds)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 8)
            .padding(.bottom, 18)

            // "Audio generado" label
            Text("Audio generado con voz profesional · Vista de prueba")
                .font(.system(size: 10.5, weight: .medium))
                .foregroundStyle(navyInk.opacity(0.35))
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

    // MARK: - Inspiration quote

    private var inspirationCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Text("❝")
                    .font(.system(size: 22, weight: .heavy))
                    .foregroundStyle(goldMid)
                Text("Frase que te inspira")
                    .font(.system(size: 13.5, weight: .bold))
                    .foregroundStyle(goldMid)
            }

            Text(inspirationQuote)
                .font(.system(size: 17, weight: .medium, design: .serif))
                .foregroundStyle(navyInk)
                .fixedSize(horizontal: false, vertical: true)
                .lineSpacing(3)

            Text(inspirationReference)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(goldMid)
        }
        .padding(18)
        .background {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color(red: 1, green: 0.97, blue: 0.88).opacity(0.95))
                .overlay {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .strokeBorder(goldAccent.opacity(0.3), lineWidth: 1)
                }
                .shadow(color: goldDeep.opacity(0.12), radius: 8, x: 0, y: 4)
        }
    }

    // MARK: - Inteligencia espiritual

    private var spiritualIntelligenceCard: some View {
        HStack(alignment: .top, spacing: 14) {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 6) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 13))
                        .foregroundStyle(purple)
                    Text("Inteligencia espiritual")
                        .font(.system(size: 13.5, weight: .bold))
                        .foregroundStyle(purple)
                }
                Text(spiritualReflection)
                    .font(.system(size: 13.5, weight: .medium))
                    .foregroundStyle(navyInk.opacity(0.75))
                    .fixedSize(horizontal: false, vertical: true)
                    .lineSpacing(3)
            }

            Image(systemName: "brain.fill")
                .font(.system(size: 42))
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(purple.opacity(0.65))
        }
        .padding(18)
        .background {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(purple.opacity(0.07))
                .overlay {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .strokeBorder(purple.opacity(0.18), lineWidth: 1)
                }
        }
    }

    // MARK: - Info row (ubicación + tiempo)

    private var infoRow: some View {
        HStack(spacing: 12) {
            // Ubicación
            HStack(alignment: .bottom, spacing: 0) {
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 5) {
                        Image(systemName: "location.fill")
                            .font(.system(size: 12))
                            .foregroundStyle(purple)
                        Text("Ubicación")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(purple)
                    }
                    Text(location.displayName.components(separatedBy: "·").first?.trimmingCharacters(in: .whitespaces) ?? location.displayName)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(navyInk)
                        .lineLimit(2)
                }
                Spacer()
                // Silhouette / city icon
                Image(systemName: "building.columns.fill")
                    .font(.system(size: 28))
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(purple.opacity(0.3))
            }
            .padding(14)
            .frame(maxWidth: .infinity)
            .background {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(.white.opacity(0.88))
                    .overlay {
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .strokeBorder(Color.white.opacity(0.7), lineWidth: 1)
                    }
                    .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 4)
            }

            // Tiempo de escucha
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 5) {
                    Image(systemName: "clock.fill")
                        .font(.system(size: 12))
                        .foregroundStyle(goldMid)
                    Text("Tiempo de escucha")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(goldMid)
                }
                Text(currentTime)
                    .font(.system(size: 22, weight: .bold, design: .monospaced))
                    .foregroundStyle(navyInk)
                Text("de \(remainingTime)")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(navyInk.opacity(0.5))
                // Bars
                HStack(spacing: 3) {
                    ForEach(0..<5) { i in
                        Capsule()
                            .fill(Double(i)/4.0 <= progress ? goldMid : navyInk.opacity(0.15))
                            .frame(width: 5, height: CGFloat(8 + i * 4))
                    }
                }
            }
            .padding(14)
            .frame(maxWidth: .infinity)
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
    }

    // MARK: - Prayer text card

    private var prayerTextCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                // Mini ribbon
                ZStack {
                    PassageRibbonShape()
                        .fill(LinearGradient(colors: [purple, purple.opacity(0.75)], startPoint: .top, endPoint: .bottom))
                    Image(systemName: "star.of.david.fill")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(LinearGradient(colors: [goldAccent, goldDeep], startPoint: .top, endPoint: .bottom))
                        .offset(y: -4)
                }
                .frame(width: 24, height: 50)

                VStack(alignment: .leading, spacing: 2) {
                    Text(intention.title)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(goldMid)
                    Text(isPlaying ? "Reproduciendo..." : "En pausa")
                        .font(.system(size: 11.5, weight: .medium))
                        .foregroundStyle(navyInk.opacity(0.5))
                }
                Spacer()
                Button { togglePlay() } label: {
                    Image(systemName: isPlaying ? "pause.fill" : "play.fill")
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

    // MARK: - Control button

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

    // MARK: - Timer logic

    private func togglePlay() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
            isPlaying.toggle()
        }
        if isPlaying {
            startTimer()
        } else {
            stopTimer()
        }
    }

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
            if progress >= 1 {
                stopTimer()
                isPlaying = false
            } else {
                progress += 0.5 / totalSeconds
            }
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    private func pauseAndDismiss() {
        stopTimer()
        dismiss()
    }

    // MARK: - Computed content

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

    // MARK: - Format time

    private func formatTime(_ seconds: Double) -> String {
        let s = Int(seconds)
        return String(format: "%02d:%02d", s / 60, s % 60)
    }
}

#Preview {
    NavigationStack {
        PrayerAudioView(
            intention: MockIntentions.all[0],
            location: .kotel,
            hebrewName: "Yosef ben Sarah",
            prayerText: "Que Hashem escuche esta tefilá..."
        )
    }
}
