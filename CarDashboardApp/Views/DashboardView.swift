import SwiftUI

private enum DashboardHomeScrollID {
    static let homeTop = "tefila_home_top"
}

// MARK: - Inicio (Tefila)

struct DashboardView: View {
    @EnvironmentObject private var auth: AuthViewModel
    @EnvironmentObject private var shell: AppShellRouter

    @State private var selectedCategory: SpiritualCategoryID? = nil
    @State private var goToIntention: Bool = false

    private static let tefilaMoments: [TefilaMoment] = spiritualIntentGrid()

    private static func spiritualIntentGrid() -> [TefilaMoment] {
        SpiritualCategoryID.allCases.map { cat in
            let b = backdropSpec(for: cat)
            return TefilaMoment(
                id: cat.rawValue,
                backdropAssetName: b.asset,
                headline: cat.headline,
                subtitle: cat.subtitle,
                gradient: b.gradient
            )
        }
    }

    /// Una imagen de catálogo distinta por intención (sin repetir en la rejilla de 6).
    private static func backdropSpec(for category: SpiritualCategoryID) -> (asset: String, gradient: [Color]) {
        switch category {
        case .parnassa:
            return ("Shajarit", [
                Color(red: 1.0, green: 0.94, blue: 0.78),
                Color(red: 0.98, green: 0.82, blue: 0.52),
            ])
        case .shalomBayit:
            return ("Tefila", [
                Color(red: 0.82, green: 0.95, blue: 0.90),
                Color(red: 0.72, green: 0.88, blue: 0.84),
            ])
        case .refua:
            return ("fortelza", [
                Color(red: 0.88, green: 0.78, blue: 0.96),
                Color(red: 0.94, green: 0.72, blue: 0.88),
            ])
        case .zeraBeracha:
            return ("Minja", [
                Color(red: 1.0, green: 0.88, blue: 0.78),
                Color(red: 0.94, green: 0.70, blue: 0.80),
            ])
        case .shemira:
            return ("Arvit", [
                Color(red: 0.42, green: 0.45, blue: 0.72),
                Color(red: 0.26, green: 0.22, blue: 0.48),
            ])
        case .hazlacha:
            return ("Palabra", [
                Color(red: 0.72, green: 0.82, blue: 0.94),
                Color(red: 0.52, green: 0.62, blue: 0.86),
            ])
        }
    }

    /// Dorado suave (acento Torah / Yerushalayim).
    private let goldAccent = Color(red: 236 / 255, green: 196 / 255, blue: 95 / 255)
    private let goldMid = Color(red: 219 / 255, green: 175 / 255, blue: 75 / 255)
    private let goldDeep = Color(red: 186 / 255, green: 142 / 255, blue: 48 / 255)
    /// Azul texto solemne.
    private let navyInk = Color(red: 42 / 255, green: 58 / 255, blue: 98 / 255)

    private let homeCardCornerRadius: CGFloat = 22
    /// Sombras tipo “elevación” sobre fondo luminoso del inicio.
    private let elevatedShadowAmbient = Color(red: 32 / 255, green: 48 / 255, blue: 86 / 255)

    private let tefilaGridColumns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16),
    ]

    var body: some View {
        ZStack {
            Image("TefilaHomeBackground")
                .resizable()
                .scaledToFill()
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                .clipped()
                .accessibilityIgnoresInvertColors(true)
                .ignoresSafeArea()

            /// Capa blanca semitransparente encima del fondo de Inicio.
            Color.white.opacity(0.38)
                .ignoresSafeArea()
                .allowsHitTesting(false)

            /// Cabecera fija (perfil / notificación): fuera del `ScrollView` para que siga comportándose como header mientras rollear el contenido debajo (frase del día y rejilla).
            VStack(spacing: 0) {
                DashboardHomeTopBar(
                    initials: auth.userInitials,
                    profileImage: auth.profileAvatarImage,
                    searchText: .constant(""),
                    showsSearchField: false,
                    onNotifications: {
                        shell.openHomeSheet(.notifications)
                    }
                )
                .appChromeHeaderOuterPadding()

                ScrollViewReader { proxy in
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 0) {
                            Color.clear
                                .frame(height: 1)
                                .id(DashboardHomeScrollID.homeTop)

                            footerQuoteCard
                                .padding(.horizontal, AppChromeHeaderMetrics.horizontalPadding)
                                .padding(.top, 18)
                                .padding(.bottom, 20)

                            primaryPrayerButton
                                .padding(.horizontal, AppChromeHeaderMetrics.horizontalPadding)
                                .padding(.top, 0)

                            chooseMomentSection
                                .padding(.horizontal, AppChromeHeaderMetrics.horizontalPadding)
                                .padding(.top, 28)
                                .padding(.bottom, 12)

                            LazyVGrid(columns: tefilaGridColumns, spacing: 17) {
                                ForEach(Self.tefilaMoments) { moment in
                                    TefilaMomentTileView(
                                        backdropAssetName: moment.backdropAssetName,
                                        headline: moment.headline,
                                        subtitle: moment.subtitle,
                                        gradientColors: moment.gradient,
                                        foregroundLight: moment.needsLightForeground
                                    ) {
                                        selectedCategory = SpiritualCategoryID(rawValue: moment.id)
                                    }
                                    .frame(maxWidth: .infinity, minHeight: 120)
                                }
                            }
                            .padding(.horizontal, AppChromeHeaderMetrics.horizontalPadding)
                            .padding(.bottom, 46)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .scrollContentBackground(.hidden)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .onChange(of: shell.scrollHomeToKPI) { _, go in
                        guard go else { return }
                        withAnimation(.easeInOut(duration: 0.35)) {
                            proxy.scrollTo(DashboardHomeScrollID.homeTop, anchor: .top)
                        }
                        DispatchQueue.main.async {
                            shell.scrollHomeToKPI = false
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .environment(\.colorScheme, .light)
        .preferredColorScheme(.light)
        .toolbar(.hidden, for: .navigationBar)
        .navigationDestination(item: $selectedCategory) { cat in
            PrayerCategoryDetailView(category: cat)
        }
        .navigationDestination(isPresented: $goToIntention) {
            ChoosePrayerIntentionView()
        }
    }

    private var primaryPrayerButton: some View {
        NavigationLink(destination: ChoosePrayerIntentionView()) {
            HStack(spacing: 8) {
                Image(systemName: "menorah.fill")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(navyInk)

                Text(TefilaCopy.homePrimaryCTA)
                    .font(.system(size: 15.5, weight: .bold))
                    .foregroundStyle(navyInk)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 15)
            .background {
                Capsule(style: .continuous)
                    .fill(
                        LinearGradient(
                            stops: [
                                .init(color: Color(red: 1, green: 0.93, blue: 0.72), location: 0),
                                .init(color: goldAccent, location: 0.45),
                                .init(color: goldMid, location: 1),
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay {
                        Capsule(style: .continuous)
                            .strokeBorder(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.95),
                                        Color.white.opacity(0.32),
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1.35
                            )
                    }
            }
            .shadow(color: .black.opacity(0.12), radius: 3.5, x: 0, y: 2)
            .shadow(color: goldDeep.opacity(0.48), radius: 18, x: 0, y: 9)
            .shadow(color: elevatedShadowAmbient.opacity(0.26), radius: 34, x: 0, y: 18)
        }
        .buttonStyle(.plain)
    }

    private var chooseMomentSection: some View {
        VStack(spacing: 14) {
            HStack(spacing: 12) {
                flourishSparks
                    .opacity(0.85)

                Text(TefilaCopy.homeCategoryHeading)
                    .font(.system(size: 13.5, weight: .semibold, design: .serif))
                    .foregroundStyle(navyInk)
                    .minimumScaleFactor(0.92)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)

                flourishSparks
                    .opacity(0.85)
                    .rotationEffect(.degrees(180))
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 10)
        }
    }

    private var flourishSparks: some View {
        HStack(spacing: 3) {
            Image(systemName: "sparkles")
                .font(.caption.weight(.medium))
                .foregroundStyle(goldMid)
            Capsule().fill(goldAccent.opacity(0.45)).frame(width: 22, height: 2)
        }
    }

    private var footerQuoteCard: some View {
        JewishInspirationCard(
            phrase: JewishPhraseLibrary.phrase(),
            badgeCount: JewishPhraseLibrary.dayOrdinal()
        )
        .padding(.vertical, 4)
    }

}

// MARK: - Modelo rejilla · intenciones espirituales (Inicio)

private struct TefilaMoment: Identifiable {
    let id: String
    /// Nombre del recurso en `Assets.xcassets` (rejilla de momentos).
    let backdropAssetName: String
    let headline: String
    let subtitle: String
    let gradient: [Color]

    /// Texto blanco sobre la foto + velo (mejor lectura sobre imágenes variadas).
    var needsLightForeground: Bool {
        true
    }
}

// MARK: - Tarjeta de momento (rejilla)

private struct TefilaMomentTileView: View {
    /// Radio alineado con la tarjeta de cita del inicio.
    private let cornerRadius: CGFloat = 20
    /// Sombra en coherencia con el resto del home.
    private let cardShadowTint = Color(red: 28 / 255, green: 42 / 255, blue: 78 / 255)

    let backdropAssetName: String
    let headline: String
    let subtitle: String
    let gradientColors: [Color]
    /// Texto oscuro vs claro según velo sobre la foto.
    var foregroundLight: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                cardBackdrop

                GeometryReader { geo in
                    HStack(alignment: .center, spacing: 0) {
                        Spacer(minLength: 0)
                        VStack(alignment: .trailing, spacing: 10) {
                            Text(headline)
                                .font(.system(size: 18.2, weight: .bold))
                                .foregroundStyle(primaryTextOpacity)
                                .shadow(color: .black.opacity(0.42), radius: 3, x: 0, y: 1)
                                .multilineTextAlignment(.trailing)
                                .fixedSize(horizontal: false, vertical: true)

                            Text(subtitle)
                                .font(.system(size: 14.1, weight: .medium))
                                .foregroundStyle(secondaryTextOpacity)
                                .shadow(color: .black.opacity(0.35), radius: 2, x: 0, y: 1)
                                .fixedSize(horizontal: false, vertical: true)
                                .multilineTextAlignment(.trailing)
                        }
                        /// Como mínimo la mitad del ancho del tile, pegado al borde derecho.
                        .frame(minWidth: geo.size.width * 0.5, maxWidth: .infinity, alignment: .trailing)
                        .minimumScaleFactor(0.88)
                    }
                    // Aire igual arriba/abajo y a los costados para que el bloque respire dentro del rounded rect.
                    .padding(.horizontal, 13)
                    .padding(.vertical, 12)
                }
            }
            .frame(maxWidth: .infinity, minHeight: 120)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.72),
                                Color.white.opacity(0.22),
                                Color.white.opacity(0.06),
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.2
                    )
            )
            .accessibilityIgnoresInvertColors(true)
        }
        .buttonStyle(.plain)
        .allowsHitTesting(true)
        .shadow(color: .black.opacity(0.12), radius: 4, x: 0, y: 2.5)
        .shadow(color: cardShadowTint.opacity(0.3), radius: 16, x: 0, y: 9)
        .shadow(color: .black.opacity(0.07), radius: 32, x: 0, y: 18)
    }

    /// Foto del catálogo + velo muy suave para coherencia cromática + viñeta inferior para legibilidad.
    /// Antes el gradiente pastel a ~0.52 opacidad cubría casi por completo la imagen (“no se veían”).
    @ViewBuilder
    private var cardBackdrop: some View {
        ZStack {
            Image(backdropAssetName, bundle: .main)
                .renderingMode(.original)
                .resizable()
                .interpolation(.high)
                .scaledToFill()
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)

            LinearGradient(
                colors: gradientColors.map { $0.opacity(foregroundLight ? 0.20 : 0.14) },
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            LinearGradient(
                stops: [
                    .init(color: .clear, location: 0),
                    .init(color: foregroundLight ? .black.opacity(0.38) : .black.opacity(0.26), location: 0.72),
                    .init(color: foregroundLight ? .black.opacity(0.56) : .black.opacity(0.38), location: 1),
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        }
        .allowsHitTesting(false)
    }

    private var primaryTextOpacity: Color {
        foregroundLight ? .white.opacity(0.96) : Color.black.opacity(0.88)
    }

    private var secondaryTextOpacity: Color {
        foregroundLight ? Color.white.opacity(0.78) : Color.black.opacity(0.58)
    }
}

#Preview {
    DashboardView()
        .environmentObject(AuthViewModel())
        .environmentObject(AppShellRouter())
}
