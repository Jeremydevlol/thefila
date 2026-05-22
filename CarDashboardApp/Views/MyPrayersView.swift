import SwiftUI

// MARK: - Mis oraciones (referencia editorial: filtros superior + cintas con Maguén + tarjetas vítreas)

private enum PrayerShelfTab: String, CaseIterable, Identifiable {
    case tehilim
    case classicServices
    case torahStudy
    case favorites

    var id: String { rawValue }

    var title: String {
        switch self {
        case .tehilim:
            return TefilaCopy.choose("Tehilim", "Tehillim", "תהילים")
        case .classicServices:
            return TefilaCopy.choose(
                "Tefilot clásicas",
                "Classic prayer",
                "תפילות קלאסיות"
            )
        case .torahStudy:
            return TefilaCopy.choose(
                "Estudio corto",
                "Brief study",
                "לימוד קצר"
            )
        case .favorites:
            return TefilaCopy.choose("Favoritos", "Saved", "מועדפים")
        }
    }

    var systemImage: String {
        switch self {
        case .tehilim: return "book.closed.fill"
        case .classicServices: return "harp.fill"
        case .torahStudy: return "books.vertical.fill"
        case .favorites: return "heart.fill"
        }
    }
}

/// Cinta vertical con punta inferior (banderín / bookmark).
private struct PrayerRibbonFlagShape: Shape {
    var cornerRadius: CGFloat = 5
    var tipDepth: CGFloat = 14

    func path(in rect: CGRect) -> Path {
        let w = rect.width
        let h = rect.height
        let r = min(cornerRadius, w / 4, tipDepth / 2)
        let tipBaseY = max(rect.minY, h - tipDepth)

        var p = Path()
        p.move(to: CGPoint(x: r, y: rect.minY))
        p.addLine(to: CGPoint(x: w - r, y: rect.minY))
        p.addQuadCurve(
            to: CGPoint(x: w, y: rect.minY + r),
            control: CGPoint(x: w, y: rect.minY)
        )
        p.addLine(to: CGPoint(x: w, y: tipBaseY))
        p.addLine(to: CGPoint(x: w / 2, y: h))
        p.addLine(to: CGPoint(x: rect.minX, y: tipBaseY))
        p.addLine(to: CGPoint(x: rect.minX, y: rect.minY + r))
        p.addQuadCurve(
            to: CGPoint(x: r, y: rect.minY),
            control: CGPoint(x: rect.minX, y: rect.minY)
        )
        p.closeSubpath()
        return p
    }
}

/// Cinta compacta coloreada + Maguén dorada (referencia UI).
private struct PrayerGoldDavidRibbon: View {
    let ribbonColor: Color

    private let goldTop = Color(red: 236 / 255, green: 196 / 255, blue: 95 / 255)
    private let goldDeep = Color(red: 172 / 255, green: 128 / 255, blue: 44 / 255)

    private let flagW: CGFloat = 29
    private let flagH: CGFloat = 66

    var body: some View {
        ZStack {
            PrayerRibbonFlagShape(cornerRadius: 5, tipDepth: 13)
                .fill(
                    LinearGradient(
                        colors: [ribbonColor, ribbonColor.opacity(0.78)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .overlay {
                    PrayerRibbonFlagShape(cornerRadius: 5, tipDepth: 13)
                        .stroke(Color.white.opacity(0.38), lineWidth: 0.85)
                }
                .shadow(color: ribbonColor.opacity(0.35), radius: 4, x: 0, y: 2)

            Image(systemName: "star.of.david.fill")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(
                    LinearGradient(colors: [goldTop, goldDeep], startPoint: .top, endPoint: .bottom)
                )
                .shadow(color: .black.opacity(0.18), radius: 0.5, x: 0, y: 0.8)
        }
        .frame(width: flagW, height: flagH)
        .padding(.top, -5)
        .padding(.leading, -1)
        .accessibilityHidden(true)
    }
}

private struct CompactPrayerShelfTabButton: View {
    let tab: PrayerShelfTab
    let selected: PrayerShelfTab
    let action: () -> Void

    private let accentPurple = Color(red: 0.48, green: 0.35, blue: 0.74)

    var body: some View {
        let isOn = tab == selected

        Button(action: action) {
            VStack(spacing: 4) {
                tabLeadingIcon(for: tab)
                    .frame(height: 16)

                Text(tab.title)
                    .font(.system(size: 8.5, weight: .bold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.65)

                Capsule()
                    .fill(isOn ? accentPurple : Color.clear)
                    .frame(width: isOn ? 26 : 0, height: 2.5)
                    .frame(height: 2.5)
            }
            .foregroundStyle(isOn ? accentPurple : Color.primary.opacity(0.42))
            .padding(.horizontal, 9)
            .padding(.vertical, 7)
            .background {
                if isOn {
                    Capsule(style: .continuous)
                        .fill(Color.white.opacity(0.72))
                        .shadow(color: accentPurple.opacity(0.28), radius: 8, x: 0, y: 2)
                        .blendMode(.plusLighter)
                }
            }
        }
        .buttonStyle(.plain)
    }

    /// Tehilim: libro + estrella diminuta centrada sobre la tapa (mock).
    @ViewBuilder
    private func tabLeadingIcon(for tab: PrayerShelfTab) -> some View {
        switch tab {
        case .tehilim:
            ZStack {
                Image(systemName: "book.closed.fill")
                    .font(.system(size: 15, weight: .semibold))
                Image(systemName: "star.fill")
                    .font(.system(size: 5.2, weight: .black))
                    .offset(y: -3)
            }
            .foregroundStyle(tab == selected ? accentPurple : Color.primary.opacity(0.42))

        default:
            Image(systemName: tab.systemImage)
                .font(.system(size: 15, weight: .semibold))
        }
    }
}

/// Tehilim · tefilot · estudio — layout tipo mock con filtros superior.
struct MyPrayersView: View {
    @EnvironmentObject private var shell: AppShellRouter
    @State private var shelfTab: PrayerShelfTab = .tehilim
    @State private var goToIntention: Bool = false
    @State private var selectedPrayerService: PrayerService? = nil

    private struct ScriptureRow: Identifiable {
        let id: String
        let eyebrow: String
        let title: String
        let detail: String
        let minutes: String
        let ribbonColor: Color
        let backdropAsset: String
    }

    private let tehilimSection: [ScriptureRow] = [
        ScriptureRow(
            id: "daily_psalms",
            eyebrow: "Tehilim",
            title: TefilaCopy.choose("Salmos del día recomendados", "Recommended Psalms today", "תהילים למצב הרוח הנוכחי"),
            detail: TefilaCopy.choose(
                "Rotación estable según día hebreo — Tehilim 20, 22, 23, 121…",
                "Cadence keyed to Hebrew days — Books I–VI.",
                "מחזור יומי — קטעים מובחרים מתהילים."
            ),
            minutes: "~12'",
            ribbonColor: Color(red: 0.52, green: 0.36, blue: 0.78),
            backdropAsset: "Salmo"
        ),
        ScriptureRow(
            id: "tikkun_klali",
            eyebrow: "Tikkun HaKlali",
            title: TefilaCopy.choose("Tikkún HaKlali (R. Najmán)", "Ten Psalms restoration", "תיקון הכללי"),
            detail: TefilaCopy.choose(
                "Tradición báalshem · antes de grandes peticiones.",
                "Restorative pairs with repentance.",
                "מסורת ברסלב · לימוד ובקשה."
            ),
            minutes: "~25'",
            ribbonColor: Color(red: 0.32, green: 0.48, blue: 0.92),
            backdropAsset: "Minja"
        ),
        ScriptureRow(
            id: "shir_hashirim",
            eyebrow: "Shir HaShirim",
            title: TefilaCopy.choose("Shir HaShirim · Shabat", "Song of Songs (Shabbat)", "שיר השירים · שבת"),
            detail: TefilaCopy.choose(
                "Leído cerca del Shabbat — amor pacto Shamáim.",
                "Often read erev Shabbat — covenant tenderness.",
                "נקרא לקראת שבת · קשר עדין עם בורא."
            ),
            minutes: "~14'",
            ribbonColor: Color(red: 0.38, green: 0.70, blue: 0.52),
            backdropAsset: "Palabra"
        ),
    ]

    private let serviceRows: [ScriptureRow] = [
        ScriptureRow(
            id: "shacharit",
            eyebrow: "Shajarit",
            title: "Pesukei Dezimrá",
            detail: TefilaCopy.choose(
                "Versos hasta la Amidá — alabanza interior.",
                "Psalms bridging dawn to Amidah.",
                "פסוקי זמרא · גשר אל העמידה."
            ),
            minutes: "~30'",
            ribbonColor: Color(red: 0.90, green: 0.68, blue: 0.28),
            backdropAsset: "Shajarit"
        ),
        ScriptureRow(
            id: "mincha_shell",
            eyebrow: "Minjá",
            title: "Amidá",
            detail: TefilaCopy.choose(
                "Después del mediodía · tehilim personales pueden sumarse.",
                "Afternoon hinge — add Psalms as you wish.",
                "צהריים · אפשר לצרף פרקים."
            ),
            minutes: "~10'",
            ribbonColor: Color(red: 0.28, green: 0.58, blue: 0.72),
            backdropAsset: "Minja"
        ),
        ScriptureRow(
            id: "maariv",
            eyebrow: "Arvit",
            title: "Shijrénu",
            detail: TefilaCopy.choose(
                "Cierre del día · Shema y descanso con seguridad.",
                "Night hymns toward rest.",
                "שיר ידידות לפני שינה."
            ),
            minutes: "~18'",
            ribbonColor: Color(red: 0.42, green: 0.38, blue: 0.72),
            backdropAsset: "Arvit"
        ),
    ]

    private let torahRows: [ScriptureRow] = [
        ScriptureRow(
            id: "parasha_primer",
            eyebrow: TefilaCopy.choose("Torá", "Torah", "תורה"),
            title: TefilaCopy.choose("Aliyá de la sedrá", "Weekly sedra synopsis", "עלייה בסדר השבוע"),
            detail: TefilaCopy.choose(
                "Pasajes destacados para el día.",
                "Key verses focused for commuters.",
                "פסוקים מובחרים בסימן הגשה מהירה."
            ),
            minutes: "~15'",
            ribbonColor: Color(red: 0.58, green: 0.34, blue: 0.68),
            backdropAsset: "fortelza"
        ),
        ScriptureRow(
            id: "mishna_avot",
            eyebrow: TefilaCopy.choose("Sabiduría", "Ethics layer", "הגות"),
            title: "Pirqé Abot",
            detail: TefilaCopy.choose(
                "Máximas después de Minjá — tono práctico.",
                "Pirkei trimmed for commuters.",
                "אבות — ציטוטים מתומצתים למחשבה יומית."
            ),
            minutes: "~9'",
            ribbonColor: Color(red: 0.72, green: 0.48, blue: 0.30),
            backdropAsset: "Tefila"
        ),
    ]

    private var activeRows: [ScriptureRow] {
        switch shelfTab {
        case .tehilim: return tehilimSection
        case .classicServices: return serviceRows
        case .torahStudy: return torahRows
        case .favorites: return []
        }
    }

    var body: some View {
        ZStack {
            TefilaFondoMiOracionBackground(lightVeilOpacity: 0.38)

            VStack(alignment: .leading, spacing: 0) {
                shelfTabScroller
                    .padding(.horizontal, 14)
                    .padding(.top, 6)
                    .padding(.bottom, 10)

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 11) {
                        if shelfTab == .favorites {
                            favoritesShelfEmpty
                        } else {
                            ForEach(activeRows) { row in
                                prayerHeroGlassCard(row)
                            }

                            footerHint
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 28)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .environment(\.colorScheme, .light)
        .preferredColorScheme(.light)
        .navigationTitle(TefilaCopy.prayersNavTitle)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.thinMaterial, for: .navigationBar)
        .toolbarColorScheme(.light, for: .navigationBar)
        .navigationDestination(isPresented: $goToIntention) {
            ChoosePrayerIntentionView()
        }
        .navigationDestination(item: $selectedPrayerService) { svc in
            PrayerServiceDetailView(service: svc, category: .hazlacha)
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    goToIntention = true
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 17))
                        Text("Solicitar")
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .foregroundStyle(PremiumAccent.tabActive)
                }
            }
        }
    }

    private var shelfTabScroller: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 2) {
                ForEach(PrayerShelfTab.allCases) { tab in
                    CompactPrayerShelfTabButton(tab: tab, selected: shelfTab) {
                        withAnimation(.spring(response: 0.34, dampingFraction: 0.84)) {
                            shelfTab = tab
                        }
                    }
                }
            }
            .padding(.horizontal, 6)
            .padding(.vertical, 5)
        }
        .background {
            Capsule(style: .continuous)
                .fill(Color.white.opacity(0.58))
                .background {
                    Capsule(style: .continuous)
                        .fill(.ultraThinMaterial)
                        .environment(\.colorScheme, .light)
                }
                .overlay {
                    Capsule(style: .continuous)
                        .strokeBorder(Color.white.opacity(0.62), lineWidth: 1)
                }
                .shadow(color: Color.black.opacity(0.055), radius: 12, x: 0, y: 5)
        }
    }

    private var favoritesShelfEmpty: some View {
        let accent = Color(red: 0.48, green: 0.35, blue: 0.74)

        return VStack(spacing: 18) {
            Image(systemName: "heart.circle.fill")
                .font(.system(size: 44))
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(accent.opacity(0.85))

            Text(TefilaCopy.choose(
                "Aquí están tus Pasajes guardados",
                "Open your saved passages",
                "השמורים שלך בעמוד «שמורים»"
            ))
                .font(.system(size: 17, weight: .semibold, design: .serif))
                .multilineTextAlignment(.center)
                .foregroundStyle(PremiumAccent.ink)

            Text(TefilaCopy.choose(
                "Abre la pestaña Pasajes para ver destacados y lecturas archivadas con el mismo estilo editorial.",
                "Jump to Passages for featured text and bookmarks.",
                "עבור אל «שמורים» לקטעים מוצגים ושמורים."
            ))
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(PremiumAccent.ink.opacity(0.54))
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)

            Button {
                shell.selectedTab = .favorites
            } label: {
                Text(TefilaCopy.choose("Ir a Pasajes guardados", "Go to Saved passages", "לפתיחת השמורים"))
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background {
                        Capsule(style: .continuous).fill(accent)
                    }
            }
            .buttonStyle(.plain)
            .padding(.top, 8)
        }
        .padding(28)
        .frame(maxWidth: .infinity)
        .background {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(.ultraThinMaterial)
                .environment(\.colorScheme, .light)
                .overlay {
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.62), lineWidth: 1)
                }
                .shadow(color: .black.opacity(0.07), radius: 16, x: 0, y: 8)
        }
    }

    private func prayerHeroGlassCard(_ row: ScriptureRow) -> some View {
        let ink = PremiumAccent.ink
        let cardCorner: CGFloat = 20
        let cardFillHeight: CGFloat = 132

        return ZStack(alignment: .leading) {
            ZStack {
                Image(row.backdropAsset)
                    .resizable()
                    .scaledToFill()
                    .frame(height: cardFillHeight + 28)
                    .frame(maxWidth: .infinity)
                    .clipped()
                    .blur(radius: 3)

                LinearGradient(
                    colors: [
                        Color.white.opacity(0.88),
                        Color.white.opacity(0.58),
                        row.ribbonColor.opacity(0.14),
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )

                Rectangle()
                    .fill(.thinMaterial)
                    .environment(\.colorScheme, .light)
                    .opacity(0.52)
                    .blendMode(.plusLighter)
            }
            .frame(height: cardFillHeight)
            .frame(maxWidth: .infinity)
            .allowsHitTesting(false)

            HStack(alignment: .center, spacing: 9) {
                PrayerGoldDavidRibbon(ribbonColor: row.ribbonColor)

                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Text(row.eyebrow.uppercased())
                            .font(.system(size: 10.2, weight: .bold))
                            .tracking(0.82)
                            .foregroundStyle(row.ribbonColor.opacity(0.94))
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                        Spacer(minLength: 6)
                        HStack(spacing: 3) {
                            Image(systemName: "clock")
                                .font(.system(size: 10.8, weight: .semibold))
                            Text(row.minutes)
                                .font(.system(size: 12, weight: .semibold, design: .rounded))
                        }
                        .foregroundStyle(ink.opacity(0.76))
                    }

                    Text(row.title)
                        .font(.system(size: 17, weight: .bold, design: .serif))
                        .foregroundStyle(ink)
                        .fixedSize(horizontal: false, vertical: true)
                        .lineLimit(2)

                    Text(row.detail)
                        .font(.system(size: 12.3, weight: .medium))
                        .foregroundStyle(ink.opacity(0.52))
                        .fixedSize(horizontal: false, vertical: true)
                        .lineLimit(2)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Button {
                    if let svc = PrayerServiceCatalog.service(id: row.id) {
                        selectedPrayerService = svc
                    } else {
                        goToIntention = true
                    }
                } label: {
                    Circle()
                        .fill(Color.white.opacity(0.72))
                        .frame(width: 33, height: 33)
                        .overlay {
                            Circle()
                                .strokeBorder(Color.white.opacity(0.95), lineWidth: 1)
                        }
                        .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 2)
                        .overlay {
                            Image(systemName: "chevron.right")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundStyle(ink.opacity(0.58))
                        }
                }
                .buttonStyle(.plain)
            }
            .padding(.leading, 8)
            .padding(.trailing, 12)
            .padding(.vertical, 11)
            .allowsHitTesting(true)
        }
        .frame(height: cardFillHeight)
        .clipShape(RoundedRectangle(cornerRadius: cardCorner, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: cardCorner, style: .continuous)
                .strokeBorder(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.82),
                            row.ribbonColor.opacity(0.32),
                            Color.white.opacity(0.42),
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 0.92
                )
                .blendMode(.plusLighter)
        }
        .shadow(color: row.ribbonColor.opacity(0.1), radius: 11, x: 0, y: 7)
        .shadow(color: .black.opacity(0.054), radius: 10, x: 0, y: 6)
    }

    private var footerHint: some View {
        GlassCard(cornerRadius: 20, padding: 16) {
            VStack(alignment: .leading, spacing: 6) {
                Text(TefilaCopy.choose(
                    "¿Necesitas petición dirigida?",
                    "Need routed petitions?",
                    "צריך עריכת ברכות ושמות?"
                ))
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Color.black.opacity(0.92))
                Text(TefilaCopy.choose(
                    "Desde las categorías espirituales del Inicio o la pestaña «Guía», un rabino revisará tus nombres hebreos y la causa elegida.",
                    "From Home categories or Guide, clergy align Hebrew names & sacred intents.",
                    "מהבית ובמסך ההדרכה · רבנים מתאימים שמות לפי הערות ומקום מקושר רוחנית."
                ))
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Color.black.opacity(0.48))
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

#Preview {
    NavigationStack {
        MyPrayersView()
    }
    .environmentObject(AppShellRouter())
}
