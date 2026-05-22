import SwiftUI

/// Contenedor blanco elevado (misma familia que cabeceras y fichas).
struct GlassCard<Content: View>: View {
    var cornerRadius: CGFloat
    var padding: CGFloat
    @ViewBuilder let content: () -> Content

    init(
        cornerRadius: CGFloat = 20,
        padding: CGFloat = 16,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.cornerRadius = cornerRadius
        self.padding = padding
        self.content = content
    }

    var body: some View {
        content()
            .padding(padding)
            .background {
                WhiteElevatedCardBackground(cornerRadius: cornerRadius)
            }
    }
}

#Preview {
    ZStack {
        Color.white.ignoresSafeArea()
        GlassCard {
            Text("Liquid Glass")
                .font(.headline)
                .foregroundStyle(.primary)
        }
        .padding()
    }
}
