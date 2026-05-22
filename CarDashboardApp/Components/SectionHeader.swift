import SwiftUI

struct SectionHeader: View {
    let title: String
    var subtitle: String? = nil
    /// Texto claro sobre fondo muy oscuro (legado).
    var lightOnDark: Bool = false
    /// Tinta oscura legible sobre vídeo / cristal (mismo criterio que Inicio).
    var inkOnVideoBackdrop: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(titleColor)

            if let subtitle {
                Text(subtitle)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(subtitleColor)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var titleColor: Color {
        if inkOnVideoBackdrop { return Color.black.opacity(0.9) }
        return lightOnDark ? Color.white : Color.primary
    }

    private var subtitleColor: Color {
        if inkOnVideoBackdrop { return Color.black.opacity(0.52) }
        return lightOnDark ? Color.white.opacity(0.55) : Color.secondary
    }
}

#Preview {
    ZStack {
        Color.white.ignoresSafeArea()
        SectionHeader(title: "Dashboard", subtitle: "Datos en tiempo real")
            .padding()
    }
}
