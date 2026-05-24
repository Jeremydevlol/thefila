import SwiftUI

// MARK: - Mis oraciones (referencia editorial: filtros superior + cintas con Maguén + tarjetas vítreas)

private enum PrayerShelfTab: String, CaseIterable, Identifiable {
    case tehilim
    case torahStudy
    case favorites

    var id: String { rawValue }

    var title: String {
        switch self {
        case .tehilim:
            return TefilaCopy.choose("Tehilim", "Tehillim", "תהילים")
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
        case .torahStudy: return "books.vertical.fill"
        case .favorites: return "heart.fill"
        }
    }
}

/// Banderín de catálogo `bandera` (misma pieza visual en todas las filas Tehilim).
private struct PrayerGoldDavidRibbon: View {
    private let flagW: CGFloat = 29
    private let flagH: CGFloat = 66

    var body: some View {
        TefilaBanderaMark(width: flagW, height: flagH)
            .padding(.top, -5)
            .padding(.leading, -1)
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
    @EnvironmentObject private var savedPrayers: SavedPrayersStore
    @State private var shelfTab: PrayerShelfTab = .tehilim
    @State private var goToIntention: Bool = false
    @State private var selectedPrayerService: PrayerService? = nil
    @State private var replayPrayer: SavedTefilaPrayer?

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

                Group {
                    if shelfTab == .favorites, !savedPrayers.prayers.isEmpty {
                        favoritesWithSavedPrayersList
                    } else {
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
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .environment(\.colorScheme, .light)
        .preferredColorScheme(.light)
        .navigationTitle(LocalizedStringKey(tefilaDynamic: TefilaCopy.prayersNavTitle))
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.thinMaterial, for: .navigationBar)
        .toolbarColorScheme(.light, for: .navigationBar)
        .navigationDestination(isPresented: $goToIntention) {
            ChoosePrayerIntentionView()
        }
        .navigationDestination(item: $selectedPrayerService) { svc in
            PrayerServiceDetailView(service: svc, category: .hazlacha)
        }
        .navigationDestination(item: $replayPrayer) { saved in
            PrayerAudioView(
                intention: saved.resolvedIntention(),
                location: saved.resolvedLocation(),
                hebrewName: resolvedHebrewDisplay(for: saved.hebrewName),
                prayerText: saved.prayerText,
                audioLanguage: saved.resolvedAudioLanguage()
            )
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
            .sharedBackgroundVisibility(.hidden)
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

    private var favoritesWithSavedPrayersList: some View {
        VStack(spacing: 11) {
            List {
                ForEach(savedPrayers.prayers) { prayer in
                    Button {
                        replayPrayer = prayer
                    } label: {
                        favoritePrayerGlassCard(saved: prayer)
                    }
                    .buttonStyle(.plain)
                    .listRowInsets(EdgeInsets(top: 5, leading: 16, bottom: 5, trailing: 16))
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            savedPrayers.remove(id: prayer.id)
                        } label: {
                            Label(TefilaCopy.choose("Eliminar", "Delete", "מחק"), systemImage: "trash")
                        }
                    }
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)

            footerHint
                .padding(.horizontal, 16)
        }
        .padding(.bottom, 20)
    }

    private var favoritesShelfEmpty: some View {
        let accent = Color(red: 0.48, green: 0.35, blue: 0.74)

        return VStack(spacing: 18) {
            Image(systemName: "heart.circle.fill")
                .font(.system(size: 44))
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(accent.opacity(0.85))

            Text(TefilaCopy.choose(
                "Tus oraciones solicitadas aparecerán aquí",
                "Your requested prayers appear here",
                "הבקשות האישיות שלך מופיעות כאן"
            ))
                .font(.system(size: 17, weight: .semibold, design: .serif))
                .multilineTextAlignment(.center)
                .foregroundStyle(PremiumAccent.ink)

            Text(TefilaCopy.choose(
                "Cuando crees una tefilá y escuches el audio, se guarda para volver a oírla. También tienes Pasajes en su propia pestaña.",
                "When you generate a prayer and open the listener, we save it to replay anytime. Saved passages stay under the Passages tab.",
                "לאחר שנוצר תפילה ושנפתח ההשמעה — נשמר אצלך. קטעים נשמרים במסך הנפרד של «שמורים»."
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

    private func favoritePrayerGlassCard(saved prayer: SavedTefilaPrayer) -> some View {
        let intention = prayer.resolvedIntention()
        let location = prayer.resolvedLocation()
        let lang = prayer.resolvedAudioLanguage()
        let locShort =
            location.displayName.components(separatedBy: "·").first?.trimmingCharacters(in: .whitespaces)
            ?? location.displayName

        let dateLine = prayer.createdAt.formatted(date: .abbreviated, time: .shortened)
        let eyebrow = TefilaCopy.choose(
            "GUARDADA · \(dateLine.uppercased())",
            "SAVED · \(dateLine.uppercased())",
            "נשמר · \(dateLine)"
        )

        let detail = compactPrayerTextSnippet(prayer.prayerText)
            + "\n"
            + "\(locShort) · \(lang.label)"

        let row = ScriptureRow(
            id: prayer.id.uuidString,
            eyebrow: eyebrow,
            title: intention.title,
            detail: detail,
            minutes: TefilaCopy.choose("AUDIO", "PLAY", "השמעה"),
            ribbonColor: intention.accentColor,
            backdropAsset: "Tefila"
        )

        return prayerHeroGlassCard(row, favoriteReplay: true)
    }

    /// Nombre visible en el reproductor al reabrir desde favoritos.
    private func resolvedHebrewDisplay(for stored: String) -> String {
        let t = stored.trimmingCharacters(in: .whitespacesAndNewlines)
        guard t.isEmpty else { return t }
        return TefilaCopy.choose("Tu nombre hebreo", "Your Hebrew name", "השם העברי")
    }

    private func compactPrayerTextSnippet(_ text: String, limit: Int = 100) -> String {
        let t = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard t.count > limit else { return t }
        return String(t.prefix(limit)).trimmingCharacters(in: .whitespacesAndNewlines) + "…"
    }

    private func prayerHeroGlassCard(_ row: ScriptureRow, favoriteReplay: Bool = false) -> some View {
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
                PrayerGoldDavidRibbon()

                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Text(row.eyebrow.uppercased())
                            .font(.system(size: 10.2, weight: .bold))
                            .tracking(0.82)
                            .foregroundStyle(row.ribbonColor.opacity(0.94))
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                        Spacer(minLength: 6)
                        if !favoriteReplay {
                            HStack(spacing: 3) {
                                Image(systemName: "clock")
                                    .font(.system(size: 10.8, weight: .semibold))
                                Text(row.minutes)
                                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                            }
                            .foregroundStyle(ink.opacity(0.76))
                        }
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

                Group {
                    if favoriteReplay {
                        Image(systemName: "play.circle.fill")
                            .font(.system(size: 28))
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(ink.opacity(0.45))
                    } else {
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
                }
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
    .environmentObject(SavedPrayersStore())
}
