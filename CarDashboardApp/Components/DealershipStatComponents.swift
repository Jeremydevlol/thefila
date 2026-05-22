import SwiftUI
import UIKit

enum DealershipGridMetrics {
    /// Altura mínima de la tarjeta con foto; crece si la fila es más alta (p. ej. KPI con subtítulo).
    static let imageStatMinHeight: CGFloat = 128
}

// MARK: - KPI estándar (Liquid Glass vía `GlassCard`)

struct DealershipStatCard: View {
    let icon: String
    let iconBackground: Color
    let title: String
    let value: String
    var titleUppercase: Bool = true
    var badge: String?
    var badgePositive: Bool = false
    var subtitle: String?

    var body: some View {
        GlassCard(cornerRadius: 20, padding: 12) {
            VStack(alignment: .leading, spacing: 6) {
                HStack(alignment: .top) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 11, style: .continuous)
                            .fill(Color.black.opacity(0.06))
                            .frame(width: 38, height: 38)
                            .overlay {
                                RoundedRectangle(cornerRadius: 11, style: .continuous)
                                    .strokeBorder(Color.black.opacity(0.08), lineWidth: 0.5)
                            }

                        Image(systemName: icon)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(iconBackground)
                    }

                    Spacer(minLength: 0)

                    if let badge {
                        GlassCapsuleBadge(text: badge, isPositive: badgePositive)
                    }
                }

                Text(titleUppercase ? title.uppercased() : title)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)

                Text(value)
                    .font(.system(size: 21, weight: .bold, design: .rounded))
                    .foregroundStyle(PremiumAccent.ink)
                    .minimumScaleFactor(0.75)
                    .lineLimit(1)

                if let subtitle {
                    Text(subtitle)
                        .font(.system(size: 9, weight: .medium))
                        .foregroundStyle(.secondary)
                        .lineLimit(3)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

// MARK: - Imagen remota (dashboard)

struct DashboardRemoteFillImage: View {
    let url: URL
    @State private var uiImage: UIImage?
    @State private var loadFailed = false

    var body: some View {
        Group {
            if let uiImage {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                    .clipped()
            } else if loadFailed {
                Color(white: 0.92)
                    .overlay {
                        Image(systemName: "photo")
                            .font(.title2)
                            .foregroundStyle(.tertiary)
                    }
            } else {
                Color.white.opacity(0.5)
                    .overlay { ProgressView() }
            }
        }
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
        .clipped()
        .task(id: url) {
            await load()
        }
    }

    private func load() async {
        do {
            var request = URLRequest(url: url)
            request.cachePolicy = .returnCacheDataElseLoad
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let http = response as? HTTPURLResponse,
                  (200 ... 299).contains(http.statusCode),
                  let img = UIImage(data: data)
            else {
                await MainActor.run { loadFailed = true }
                return
            }
            await MainActor.run { uiImage = img }
        } catch {
            await MainActor.run { loadFailed = true }
        }
    }
}

// MARK: - Tarjeta con imagen (marco glass + foto contenida)

struct DealershipImageStatCard: View {
    let title: String
    let value: String
    let changePercent: Int
    var imageURL: URL = RemoteAssets.clinicHeroImageURL
    private let cornerRadius: CGFloat = 20

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            DashboardRemoteFillImage(url: imageURL)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .clipped()

            LinearGradient(
                colors: [
                    Color.black.opacity(0.42),
                    Color.black.opacity(0.18),
                    Color.black.opacity(0.02),
                    .clear
                ],
                startPoint: .bottom,
                endPoint: .top
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .allowsHitTesting(false)

            VStack(alignment: .leading, spacing: 5) {
                HStack(alignment: .top) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(.ultraThinMaterial)
                            .environment(\.colorScheme, .light)
                            .frame(width: 34, height: 34)
                            .overlay {
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .strokeBorder(Color.white.opacity(0.75), lineWidth: 0.5)
                            }

                        Image("AppLogo")
                            .renderingMode(.original)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 22, height: 22)
                    }

                    Spacer(minLength: 0)

                    GlassPhotoBadge(text: "+ \(changePercent)%")
                }

                Text(title)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.white)

                Text(value)
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
            }
            .padding(12)
        }
        .frame(
            maxWidth: .infinity,
            minHeight: DealershipGridMetrics.imageStatMinHeight,
            maxHeight: .infinity
        )
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .strokeBorder(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.65),
                            Color.white.opacity(0.2),
                            Color.gray.opacity(0.1)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 0.75
                )
        }
        .compositingGroup()
        .shadow(color: .black.opacity(0.06), radius: 10, x: 0, y: 5)
    }
}

// MARK: - Franja total (glass ancho)

struct DealershipWideStatCard: View {
    let icon: String
    let iconBackground: Color
    let title: String
    let value: String
    var subtitle: String?

    var body: some View {
        GlassCard(cornerRadius: 22, padding: 16) {
            HStack(alignment: .center, spacing: 14) {
                    ZStack {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color.black.opacity(0.06))
                        .frame(width: 46, height: 46)
                        .overlay {
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .strokeBorder(Color.black.opacity(0.08), lineWidth: 0.5)
                        }

                    Image(systemName: icon)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(iconBackground)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.primary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)

                    Text(value)
                        .font(.system(size: 26, weight: .bold, design: .rounded))
                        .foregroundStyle(PremiumAccent.ink)

                    if let subtitle {
                        Text(subtitle)
                            .font(.system(size: 10, weight: .medium))
                            .foregroundStyle(.secondary)
                    }
                }
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
            }
            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Dashboard (Liquid Glass + fotos hero)

private let dashboardTileCorner: CGFloat = 26

// MARK: - Cabecera unificada (misma geometría en Inicio y Chat)

/// Avatar → hoja de cuenta y ajustes (`AppShellRouter.openSettingsSheet`), salvo `onProfileTap` explícito.
struct AppChromeAvatarProfileButton: View {
    @EnvironmentObject private var shell: AppShellRouter
    let initials: String
    var profileImage: UIImage? = nil
    /// Si es `nil`, se abre la hoja de ajustes. En **Ajustes** pasa `{ }` para desactivar el toque.
    var onProfileTap: (() -> Void)? = nil

    var body: some View {
        Button {
            if let onProfileTap {
                onProfileTap()
            } else {
                shell.openSettingsSheet()
            }
        } label: {
            ZStack(alignment: .topTrailing) {
                ZStack {
                    if let profileImage {
                        Image(uiImage: profileImage)
                            .resizable()
                            .scaledToFill()
                    } else {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        PremiumAccent.ice.opacity(0.9),
                                        PremiumAccent.tabActive.opacity(0.72),
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                        Text(initials)
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                    }
                }
                .frame(width: AppChromeHeaderMetrics.avatarSize, height: AppChromeHeaderMetrics.avatarSize)
                .clipShape(Circle())
                .overlay {
                    Circle()
                        .strokeBorder(
                            LinearGradient(
                                colors: [Color.white.opacity(0.55), Color.white.opacity(0.12)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 0.75
                        )
                }

                Circle()
                    .fill(Color.red.opacity(0.92))
                    .frame(width: 9, height: 9)
                    .overlay {
                        Circle()
                            .strokeBorder(Color.white.opacity(0.95), lineWidth: 1.5)
                    }
                    .offset(x: 3, y: -3)
            }
            .frame(width: AppChromeHeaderMetrics.avatarSize, height: AppChromeHeaderMetrics.avatarSize)
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Perfil, cuenta y ajustes")
    }
}

/// Pastilla de búsqueda: ocupa el espacio flexible entre avatar y botones (igual ancho relativo que Inicio).
struct AppChromeSearchCapsuleField: View {
    @Binding var text: String
    var prompt: Text
    var showsClearButton: Bool
    @FocusState.Binding var isSearchFocused: Bool

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(Color.black.opacity(DashboardChromeSearchFieldStyle.iconOpacity))

            TextField("", text: $text, prompt: prompt)
                .focused($isSearchFocused)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .submitLabel(.search)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(Color.black)
                .tint(PremiumAccent.tabActive)

            if showsClearButton, !text.isEmpty {
                Button {
                    text = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(Color.black.opacity(DashboardChromeSearchFieldStyle.iconClearOpacity))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 11)
        .background {
            DashboardChromeSearchCapsuleBackground()
        }
        .frame(minWidth: 0, maxWidth: .infinity)
    }
}

struct AppChromeHeaderCircleIconButton: View {
    private enum IconSource {
        case sfSymbol(String)
        case assetCatalog(String)
    }

    private let source: IconSource
    var accessibilityLabel: LocalizedStringKey
    var action: () -> Void

    init(systemName: String, accessibilityLabel: LocalizedStringKey, action: @escaping () -> Void) {
        source = .sfSymbol(systemName)
        self.accessibilityLabel = accessibilityLabel
        self.action = action
    }

    /// Icono vectorial desde `Assets.xcassets` (p. ej. SVG).
    init(catalogAssetName: String, accessibilityLabel: LocalizedStringKey, action: @escaping () -> Void) {
        source = .assetCatalog(catalogAssetName)
        self.accessibilityLabel = accessibilityLabel
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            ZStack {
                DashboardChromeHeaderCircleBackground()
                switch source {
                case .sfSymbol(let name):
                    Image(systemName: name)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Color.black.opacity(0.88))
                case .assetCatalog(let name):
                    Image(name)
                        .renderingMode(.original)
                        .resizable()
                        .interpolation(.high)
                        .scaledToFit()
                        .frame(width: 21, height: 21)
                }
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(accessibilityLabel)
    }
}

/// Fila: [avatar 48] [buscador flexible] [trailing]. `trailing` debe ocupar el mismo ancho que 2× círculo + spacing (Inicio).
struct AppChromeHeaderRow<Trailing: View>: View {
    let initials: String
    var profileImage: UIImage? = nil
    var onProfileTap: (() -> Void)? = nil
    @Binding var searchText: String
    var prompt: Text
    var showsSearchClearButton: Bool
    @FocusState.Binding var searchFieldFocused: Bool
    @ViewBuilder var trailing: () -> Trailing

    var body: some View {
        HStack(alignment: .center, spacing: AppChromeHeaderMetrics.hStackSpacing) {
            AppChromeAvatarProfileButton(initials: initials, profileImage: profileImage, onProfileTap: onProfileTap)
            AppChromeSearchCapsuleField(
                text: $searchText,
                prompt: prompt,
                showsClearButton: showsSearchClearButton,
                isSearchFocused: $searchFieldFocused
            )
            trailing()
        }
    }
}

/// Disco circular con Maguén David (gris relleno + contorno oscuro), referencia Pasajes / listas.
struct PassagesMagenDavidAccentDisk: View {
    enum DiskFillStyle {
        /// Relleno opaco suave (cabecera, chips en fila).
        case solid
        /// Cristal claro + tinte azul (cintas / banderas Pasajes).
        case frostedLight
    }

    var diameter: CGFloat
    var symbolSize: CGFloat
    var fillStyle: DiskFillStyle = .solid
    var showsShadow: Bool = true

    private let diskTint = Color(red: 0.90, green: 0.934, blue: 0.972)

    var body: some View {
        ZStack {
            switch fillStyle {
            case .solid:
                Circle()
                    .fill(diskTint)
            case .frostedLight:
                Circle()
                    .fill(.ultraThinMaterial)
                    .environment(\.colorScheme, .light)
                Circle()
                    .fill(diskTint.opacity(0.38))
            }
            Circle()
                .strokeBorder(Color.white.opacity(0.95), lineWidth: 1.15)
        }
        .frame(width: diameter, height: diameter)
        /// El glifo debe quedar fuera del apilado «material», para evitar círculos vítreos sin estrella visible.
        .overlay {
            ZStack {
                Image(systemName: "star.of.david.fill")
                    .font(.system(size: symbolSize, weight: .medium))
                    .foregroundStyle(Color(red: 0.54, green: 0.55, blue: 0.58))
                Image(systemName: "star.of.david")
                    .font(.system(size: symbolSize, weight: .semibold))
                    .foregroundStyle(Color.black.opacity(0.88))
            }
            .allowsHitTesting(false)
        }
        .shadow(color: Color.black.opacity(showsShadow ? 0.055 : 0), radius: showsShadow ? 3.5 : 0, x: 0, y: showsShadow ? 1 : 0)
    }
}

/// Botón derecho cabecera **Pasajes** (mismo aspecto que el disco anterior).
struct PassagesMagenDavidAccentCircleButton: View {
    var diameter: CGFloat = AppChromeHeaderMetrics.circleButtonSize
    var symbolSize: CGFloat = 20
    var action: () -> Void = {}

    var body: some View {
        Button(action: action) {
            PassagesMagenDavidAccentDisk(diameter: diameter, symbolSize: symbolSize)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Pasajes, Tanaj y favoritos")
    }
}

/// Cabecera inicio / listados: búsqueda **o** centro vacío (sin pastilla ni logo en barra).
struct DashboardHomeTopBar: View {
    let initials: String
    var profileImage: UIImage? = nil
    var onProfileTap: (() -> Void)? = nil
    @Binding var searchText: String
    /// Cuando es `false`, oculta «Buscar» y deja espacio flexible (p. ej. Inicio con título más abajo en el contenido).
    var showsSearchField: Bool = true
    /// Derecha: icono espiritual (Pasajes) en lugar de la campana de notificaciones.
    var passagesAccentTrailing: Bool = false
    var passagesAccentAction: () -> Void = {}
    @FocusState private var searchFieldFocused: Bool
    var onNotifications: () -> Void = {}

    private var trailingControls: some View {
        HStack(spacing: AppChromeHeaderMetrics.hStackSpacing) {
            Color.clear
                .frame(width: AppChromeHeaderMetrics.circleButtonSize, height: AppChromeHeaderMetrics.circleButtonSize)
                .accessibilityHidden(true)
            if passagesAccentTrailing {
                PassagesMagenDavidAccentCircleButton(action: passagesAccentAction)
            } else {
                AppChromeHeaderCircleIconButton(
                    catalogAssetName: "TefilaNotificationsIcon",
                    accessibilityLabel: "Notificaciones",
                    action: onNotifications
                )
            }
        }
    }

    var body: some View {
        Group {
            if showsSearchField {
                AppChromeHeaderRow(
                    initials: initials,
                    profileImage: profileImage,
                    onProfileTap: onProfileTap,
                    searchText: $searchText,
                    prompt: Text("Buscar")
                        .foregroundStyle(Color.black.opacity(DashboardChromeSearchFieldStyle.promptOpacity)),
                    showsSearchClearButton: true,
                    searchFieldFocused: $searchFieldFocused
                ) {
                    trailingControls
                }
            } else {
                HStack(alignment: .center, spacing: AppChromeHeaderMetrics.hStackSpacing) {
                    AppChromeAvatarProfileButton(initials: initials, profileImage: profileImage, onProfileTap: onProfileTap)

                    Spacer(minLength: 0)

                    trailingControls
                }
            }
        }
    }
}

/// Tarjeta KPI a pantalla con foto, texto blanco abajo y sombra suave (sin borde duro).
struct DashboardPhotoStatTile: View {
    let imageURL: URL
    let title: String
    let value: String
    let iconName: String
    var iconForeground: Color = Color.black.opacity(0.88)
    /// Réplica referencia: número junto al icono (p. ej. stock).
    var showsValueNextToIcon: Bool = false
    var topRightBadge: String?
    var footnote: String?

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            DashboardRemoteFillImage(url: imageURL)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .clipped()

            LinearGradient(
                colors: [
                    .black.opacity(0.55),
                    .black.opacity(0.22),
                    .black.opacity(0.05),
                    .clear,
                ],
                startPoint: .bottom,
                endPoint: .top
            )
            .allowsHitTesting(false)

            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .center) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(.ultraThinMaterial)
                            .environment(\.colorScheme, .light)
                            .frame(width: 36, height: 36)
                            .overlay {
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .strokeBorder(Color.white.opacity(0.75), lineWidth: 0.5)
                            }

                        Image(systemName: iconName)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(iconForeground)
                    }

                    if showsValueNextToIcon {
                        Text(value)
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                            .padding(.leading, 6)
                    }

                    Spacer(minLength: 0)

                    if let topRightBadge {
                        Text(topRightBadge)
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(.white.opacity(0.95))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(.black.opacity(0.35), in: Capsule())
                    }
                }

                Spacer(minLength: 10)

                Text(title)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.92))

                Text(value)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .minimumScaleFactor(0.65)
                    .lineLimit(2)

                if let footnote {
                    Text(footnote)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(.white.opacity(0.82))
                        .lineLimit(3)
                        .padding(.top, 4)
                }
            }
            .padding(14)
        }
        .frame(maxWidth: .infinity)
        .aspectRatio(0.88, contentMode: .fit)
        .clipShape(RoundedRectangle(cornerRadius: dashboardTileCorner, style: .continuous))
        .shadow(color: .black.opacity(0.1), radius: 18, x: 0, y: 10)
        .shadow(color: .black.opacity(0.04), radius: 4, x: 0, y: 2)
    }
}

/// Franja inferior ancha: total concesionario (glass claro).
struct DashboardWideLiquidEarningsCard: View {
    let title: String
    let value: String
    let subtitle: String?

    var body: some View {
        HStack(alignment: .center, spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                PremiumAccent.mint.opacity(0.35),
                                PremiumAccent.mint.opacity(0.12),
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 52, height: 52)
                    .overlay {
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .strokeBorder(Color.white.opacity(0.55), lineWidth: 0.6)
                    }

                Image(systemName: "sparkles")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(PremiumAccent.mint)
            }

            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.secondary)

                Text(value)
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .foregroundStyle(PremiumAccent.ink)

                if let subtitle {
                    Text(subtitle)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(.tertiary)
                }
            }
            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
        }
        .padding(18)
        .background {
            RoundedRectangle(cornerRadius: dashboardTileCorner, style: .continuous)
                .fill(.ultraThinMaterial)
                .background {
                    RoundedRectangle(cornerRadius: dashboardTileCorner, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.88),
                                    Color.white.opacity(0.32),
                                    Color.white.opacity(0.08),
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
                .overlay {
                    RoundedRectangle(cornerRadius: dashboardTileCorner, style: .continuous)
                        .strokeBorder(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.9),
                                    Color.white.opacity(0.28),
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 0.7
                        )
                }
                .shadow(color: .black.opacity(0.07), radius: 16, x: 0, y: 8)
                .shadow(color: .black.opacity(0.03), radius: 2, x: 0, y: 1)
        }
    }
}

