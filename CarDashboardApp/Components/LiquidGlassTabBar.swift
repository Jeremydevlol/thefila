import SwiftUI

private enum LiquidGlassTabBarCopy {
    static let home = "Inicio"
    static let passages = "Pasajes"
    static let prayers = "Mis oraciones"
    static let chat = "Guía"
}

enum TabItem: Int, CaseIterable, Identifiable {
    case home = 0
    case favorites = 1
    case prayers = 2
    case chat = 3

    var id: Int { rawValue }

    var title: String {
        switch self {
        case .home: return LiquidGlassTabBarCopy.home
        case .favorites: return LiquidGlassTabBarCopy.passages
        case .prayers: return LiquidGlassTabBarCopy.prayers
        case .chat: return LiquidGlassTabBarCopy.chat
        }
    }

    var icon: String {
        switch self {
        case .home: return "house.fill"
        case .favorites: return "star.fill"
        case .prayers: return TefilaCopy.tabTefilaSystemImage
        case .chat: return "bubble.left.and.bubble.right.fill"
        }
    }
}

/// Barra flotante estilo referencia: **cápsula glass** con tabs (icono + título).
/// Nota: la app usa `TabView` nativo; esto sirve sobre todo para vistas previas o futuros skins.
struct LiquidGlassTabBar: View {
    @Binding var selectedTab: TabItem

    @Namespace private var tabNamespace

    private let selectionDiameter: CGFloat = 50

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            mainCapsule
        }
        .padding(.horizontal, 20)
        .padding(.top, 6)
        .padding(.bottom, 12)
    }

    private var mainCapsule: some View {
        HStack(spacing: 0) {
            ForEach(TabItem.allCases) { tab in
                tabPillButton(for: tab)
            }
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 8)
        .background {
            floatingGlassCapsule
        }
    }

    private var floatingGlassCapsule: some View {
        Capsule(style: .continuous)
            .fill(.ultraThinMaterial)
            .background {
                Capsule(style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.62),
                                Color.white.opacity(0.18),
                                Color.white.opacity(0.05)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            .overlay {
                Capsule(style: .continuous)
                    .strokeBorder(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.95),
                                Color.white.opacity(0.3),
                                Color.gray.opacity(0.12)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 0.75
                    )
            }
            .shadow(color: .black.opacity(0.08), radius: 24, x: 0, y: 12)
            .shadow(color: .black.opacity(0.04), radius: 4, x: 0, y: 2)
    }

    private func tabPillButton(for tab: TabItem) -> some View {
        let isSelected = selectedTab == tab

        return Button {
            withAnimation(.spring(response: 0.42, dampingFraction: 0.76)) {
                selectedTab = tab
            }
        } label: {
            ZStack {
                if isSelected {
                    Circle()
                        .fill(.thinMaterial)
                        .background {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color.white.opacity(0.92),
                                            PremiumAccent.tabActive.opacity(0.32),
                                            Color.white.opacity(0.35)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        }
                        .overlay {
                            Circle()
                                .strokeBorder(
                                    LinearGradient(
                                        colors: [
                                            Color.white.opacity(0.98),
                                            Color.white.opacity(0.35)
                                        ],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    ),
                                    lineWidth: 0.65
                                )
                        }
                        .shadow(color: .black.opacity(0.07), radius: 10, x: 0, y: 5)
                        .frame(width: selectionDiameter, height: selectionDiameter)
                        .matchedGeometryEffect(id: "activeTabHighlight", in: tabNamespace)
                }

                VStack(spacing: 3) {
                    Image(systemName: tab.icon)
                        .font(.system(size: 18, weight: isSelected ? .semibold : .medium))
                        .symbolEffect(.bounce, value: isSelected)

                    Text(tab.title)
                        .font(.system(size: 9, weight: .semibold))
                        .lineLimit(1)
                        .minimumScaleFactor(0.85)
                }
                .foregroundStyle(
                    isSelected ? PremiumAccent.tabActive : Color.primary.opacity(0.38)
                )
            }
            .frame(maxWidth: .infinity)
            .frame(height: selectionDiameter)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ZStack {
        Color.white.ignoresSafeArea()
        VStack {
            Spacer()
            LiquidGlassTabBar(selectedTab: .constant(.home))
        }
    }
}
