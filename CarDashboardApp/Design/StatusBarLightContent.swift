import SwiftUI
import UIKit

/// Controlador invisible que fuerza texto e íconos de la barra de estado en **blanco** (`.lightContent`).
/// SwiftUI suele usar iconos oscuros si la ventana está en modo claro (p. ej. `.preferredColorScheme(.light)`);
/// esta pieza permite seguir usando modo claro en la interfaz pero con status bar visible sobre fondos oscuros.
final class StatusBarLightContentViewController: UIViewController {

    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
    }

    override func didMove(toParent parent: UIViewController?) {
        super.didMove(toParent: parent)
        parent?.setNeedsStatusBarAppearanceUpdate()
        setNeedsStatusBarAppearanceUpdate()
    }
}

struct StatusBarLightContentHostingView: UIViewControllerRepresentable {

    func makeUIViewController(context: Context) -> StatusBarLightContentViewController {
        StatusBarLightContentViewController()
    }

    func updateUIViewController(_ uiViewController: StatusBarLightContentViewController, context: Context) {
        uiViewController.setNeedsStatusBarAppearanceUpdate()
        uiViewController.parent?.setNeedsStatusBarAppearanceUpdate()
    }
}

extension View {
    /// Hora, señal, Wi‑Fi y batería en blanco sobre la pantalla bloqueante de la barra de estado.
    func statusBarIconsLightContent() -> some View {
        background(
            StatusBarLightContentHostingView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .allowsHitTesting(false)
        )
    }
}
