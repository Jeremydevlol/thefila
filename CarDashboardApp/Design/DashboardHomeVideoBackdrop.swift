import AVFoundation
import SwiftUI
import UIKit

// MARK: - Inicio (solo vídeo)

/// Vídeo de fondo **solo en la pestaña Inicio**: `Fondo.mp4`, bucle y sin audio.
struct DashboardHomeVideoBackdrop: View {
    var body: some View {
        ZStack {
            if let url = Bundle.main.url(forResource: "Fondo", withExtension: "mp4") {
                MutedLoopingVideoFillRepresentable(url: url)
                DashboardHomeVideoAtmosphereOverlay()
            } else {
                DashboardHomeStaticBackdropBase()
                DashboardHomeVideoAtmosphereOverlay()
            }
        }
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
        .clipped()
        .ignoresSafeArea()
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}

// MARK: - Resto de secciones (sin vídeo)

/// Fondo Perfil/Ajustes (y cromados Revolut): imagen celestial unificada, **sin** el vídeo de Inicio.
struct DashboardHomeBackdropImage: View {
    var body: some View {
        TefilaSpiritualFondoBackdrop(lightVeilOpacity: 0.32)
    }
}

// MARK: - Fondo unificado “Mis oraciones” (`FondoMisOraciones1`) — **todas menos Inicio**

/// Imagen celestial unificada: `FondoMisOraciones1` → fallback `FondoMiOracion` → `TefilaHomeBackground`.
/// Inicio (`DashboardView`) sigue usando su propio fondo/vídeo.
struct TefilaSpiritualFondoBackdrop: View {
    /// Velo blanco sobre la imagen para legibilidad.
    var lightVeilOpacity: CGFloat = 0.38

    var body: some View {
        ZStack {
            Group {
                if UIImage(named: "FondoMisOraciones1") != nil {
                    Image("FondoMisOraciones1")
                        .resizable()
                        .scaledToFill()
                } else if UIImage(named: "FondoMiOracion") != nil {
                    Image("FondoMiOracion")
                        .resizable()
                        .scaledToFill()
                } else {
                    Image("TefilaHomeBackground")
                        .resizable()
                        .scaledToFill()
                }
            }
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
            .clipped()
            .accessibilityIgnoresInvertColors(true)

            Color.white.opacity(lightVeilOpacity)
                .allowsHitTesting(false)
        }
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
        .clipped()
        .ignoresSafeArea()
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}

// MARK: - Login (`login.mp4`)

/// Fondo para login/registro: bucle **`login.mp4`** (silenciado). Si falta el archivo, mismo fondo que `TefilaSpiritualFondoBackdrop`.
struct LoginAuthVideoBackdrop: View {
    /// Velo cuando el recurso es vídeo (legibilidad del formulario).
    var videoWhiteVeilOpacity: CGFloat = 0.18
    /// Velo del fallback cuando no existe `login.mp4`.
    var fallbackSpiritualVeilOpacity: CGFloat = 0.38

    var body: some View {
        ZStack {
            if let url = Bundle.main.url(forResource: "login", withExtension: "mp4") {
                MutedLoopingVideoFillRepresentable(url: url)
                Color.white.opacity(videoWhiteVeilOpacity)
                    .allowsHitTesting(false)
            } else {
                TefilaSpiritualFondoBackdrop(lightVeilOpacity: fallbackSpiritualVeilOpacity)
            }
        }
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
        .clipped()
        .ignoresSafeArea()
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}

// MARK: - Mis oraciones + autenticación (nombre histórico)

/// Alias sobre `TefilaSpiritualFondoBackdrop` — mismo arte que el resto de pantallas fuera de Inicio.
struct TefilaFondoMiOracionBackground: View {
    var lightVeilOpacity: CGFloat = 0.38

    var body: some View {
        TefilaSpiritualFondoBackdrop(lightVeilOpacity: lightVeilOpacity)
    }
}

/// Base suave que evoca el inicio sin `AVPlayer` (ahorro de batería y CPU fuera de Inicio).
private struct DashboardHomeStaticBackdropBase: View {
    var body: some View {
        LinearGradient(
            colors: [
                Color(red: 0.78, green: 0.70, blue: 0.94),
                Color.white.opacity(0.96),
                Color(red: 0.82, green: 0.91, blue: 0.99),
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}

/// Degradado diagonal tipo referencia: lavanda / azul cielo; la franja central es blanco **muy transparente** para que el vídeo traspase.
private struct DashboardHomeVideoAtmosphereOverlay: View {
    var body: some View {
        LinearGradient(
            stops: [
                .init(color: Color(red: 0.74, green: 0.64, blue: 0.93).opacity(0.42), location: 0.0),
                .init(color: Color(red: 0.82, green: 0.76, blue: 0.96).opacity(0.22), location: 0.32),
                .init(color: Color.white.opacity(0.14), location: 0.42),
                .init(color: Color.white.opacity(0.03), location: 0.5),
                .init(color: Color.white.opacity(0.12), location: 0.58),
                .init(color: Color(red: 0.58, green: 0.84, blue: 0.98).opacity(0.26), location: 0.78),
                .init(color: Color(red: 0.48, green: 0.76, blue: 0.96).opacity(0.48), location: 1.0),
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}

// MARK: - Vídeo silenciado en bucle (Inicio + login)

/// Vídeo de fondo: **bucle normal hacia adelante**, silenciado, `resizeAspectFill`.
struct MutedLoopingVideoFillRepresentable: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> MutedLoopingVideoBackingView {
        let v = MutedLoopingVideoBackingView()
        v.start(url: url)
        return v
    }

    func updateUIView(_ uiView: MutedLoopingVideoBackingView, context: Context) {}

    static func dismantleUIView(_ uiView: MutedLoopingVideoBackingView, coordinator: Void) {
        uiView.stop()
    }
}

final class MutedLoopingVideoBackingView: UIView {
    override static var layerClass: AnyClass { AVPlayerLayer.self }

    private var playerLayer: AVPlayerLayer { layer as! AVPlayerLayer }
    private var queuePlayer: AVQueuePlayer?
    private var looper: AVPlayerLooper?

    func start(url: URL) {
        stop()

        let item = AVPlayerItem(url: url)
        let queue = AVQueuePlayer()
        looper = AVPlayerLooper(player: queue, templateItem: item)
        queuePlayer = queue
        queue.isMuted = true
        queue.volume = 0
        queue.automaticallyWaitsToMinimizeStalling = false
        if #available(iOS 15.0, *) {
            queue.audiovisualBackgroundPlaybackPolicy = .continuesIfPossible
        }
        playerLayer.videoGravity = .resizeAspectFill
        playerLayer.player = queue
        queue.play()
    }

    func stop() {
        queuePlayer?.pause()
        looper?.disableLooping()
        looper = nil
        queuePlayer = nil
        playerLayer.player = nil
    }
}
