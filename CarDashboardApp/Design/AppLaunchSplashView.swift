import AVFoundation
import SwiftUI
import UIKit

// MARK: - Video de bienvenida (una sola vez al abrir la app)

/// Reproduce `video-inicio.mp4` a pantalla completa una vez y llama `onFinished` cuando termina.
struct AppLaunchSplashView: View {
    let onFinished: () -> Void

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            if let url = Bundle.main.url(forResource: "video-inicio", withExtension: "mp4") {
                OneShotLaunchVideoFillRepresentable(url: url, onFinished: onFinished)
                    .ignoresSafeArea()
            } else {
                Color(red: 0.12, green: 0.1, blue: 0.14).ignoresSafeArea()
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            onFinished()
                        }
                    }
            }
        }
    }
}

private struct OneShotLaunchVideoFillRepresentable: UIViewRepresentable {
    let url: URL
    let onFinished: () -> Void

    func makeUIView(context: Context) -> LaunchVideoUIView {
        let v = LaunchVideoUIView()
        v.onPlaybackEnded = {
            DispatchQueue.main.async {
                onFinished()
            }
        }
        v.play(url: url)
        return v
    }

    func updateUIView(_ uiView: LaunchVideoUIView, context: Context) {}

    static func dismantleUIView(_ uiView: LaunchVideoUIView, coordinator: Void) {
        uiView.cleanup()
    }
}

private final class LaunchVideoUIView: UIView {
    override static var layerClass: AnyClass { AVPlayerLayer.self }

    private var playerLayer: AVPlayerLayer { layer as! AVPlayerLayer }

    private var player: AVPlayer?
    private var endObserver: NSObjectProtocol?

    var onPlaybackEnded: (() -> Void)?

    func play(url: URL) {
        cleanup()
        playerLayer.videoGravity = .resizeAspectFill
        let item = AVPlayerItem(url: url)
        let p = AVPlayer(playerItem: item)
        p.actionAtItemEnd = .pause
        endObserver = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: item,
            queue: .main
        ) { [weak self] _ in
            self?.onPlaybackEnded?()
        }
        playerLayer.player = p
        player = p
        p.play()
    }

    func cleanup() {
        if let endObserver {
            NotificationCenter.default.removeObserver(endObserver)
            self.endObserver = nil
        }
        player?.pause()
        player?.replaceCurrentItem(with: nil)
        player = nil
        playerLayer.player = nil
    }

    deinit {
        cleanup()
    }
}

#Preview {
    AppLaunchSplashView(onFinished: {})
}
