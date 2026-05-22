import SwiftUI

// MARK: - Pasajes · tarjeta destacada + lista (estilo editorial / glass)

private struct PassageAccent {
    let gold = PremiumAccent.tabActive
    /// Púrpura suave tipo cinta en el mock.
    let ribbon = Color(red: 0.42, green: 0.32, blue: 0.62)
    let ribbonTeal = Color(red: 0.24, green: 0.52, blue: 0.52)
    let ink = PremiumAccent.ink
}

private enum PassageTagKind {
    case torah
    case tefila
    case tehilim
}

private extension PassageTagKind {
    var title: String {
        switch self {
        case .torah: return TefilaCopy.choose("Torá", "Torah", "תורה")
        case .tefila: return TefilaCopy.choose("Tefilá", "Prayer", "תפילה")
        case .tehilim: return TefilaCopy.choose("Tehilim", "Psalms", "תהילים")
        }
    }

    var tagBackground: Color {
        switch self {
        case .torah: return Color(red: 1.0, green: 0.88, blue: 0.72)
        case .tefila: return Color(red: 0.78, green: 0.92, blue: 0.90)
        case .tehilim: return Color(red: 0.82, green: 0.90, blue: 0.98)
        }
    }

    var tagForeground: Color {
        switch self {
        case .torah: return Color(red: 0.55, green: 0.32, blue: 0.12)
        case .tefila: return Color(red: 0.12, green: 0.42, blue: 0.40)
        case .tehilim: return Color(red: 0.18, green: 0.35, blue: 0.62)
        }
    }
}

private struct SavedPassageRow: Identifiable {
    let id: String
    let title: String
    let subtitle: String
    let tag: PassageTagKind
    let ribbonTeal: Bool
}

/// Pasajes guardados y lectura editorial.
struct FavoritesView: View {
    @EnvironmentObject private var auth: AuthViewModel
    @EnvironmentObject private var shell: AppShellRouter

    private let accent = PassageAccent()

    private var featuredHebrew: String {
        "שְׁמַע יִשְׂרָאֵל יְהוָה אֱלֹהֵינוּ יְהוָה אֶחָד"
    }

    private var featuredTranslation: String {
        TefilaCopy.choose(
            "«Escucha, Israel: Adonai es nuestro Dios, Adonai es uno.»",
            "“Hear, O Israel: the Lord is our God, the Lord is one.”",
            "שמע ישראל יהוה אלקינו יהוה אחד."
        )
    }

    private var featuredReferencePill: String {
        TefilaCopy.choose(
            "guardado desde Tefilá",
            "saved from Tefila",
            "נשמר מתפילה"
        )
    }

    private var savedRows: [SavedPassageRow] {
        [
            SavedPassageRow(
                id: "shema",
                title: TefilaCopy.choose("Shemá Israel", "Shema Israel", "שמע ישראל"),
                subtitle: TefilaCopy.choose(
                    "Devarim 6:4 · lectura diaria",
                    "Deuteronomy 6:4 · daily read",
                    "דברים ו׳ ד׳ · קריאה יומית"
                ),
                tag: .torah,
                ribbonTeal: false
            ),
            SavedPassageRow(
                id: "aleinu",
                title: TefilaCopy.choose("Aleinu les habeiach", "Aleinu", "עלינו לשבח"),
                subtitle: TefilaCopy.choose(
                    "Liturgia de kedushá · cierre solemne",
                    "Kedushah closure · solemn close",
                    "קדושה אחרונה · סיום נשיא"
                ),
                tag: .tefila,
                ribbonTeal: true
            ),
            SavedPassageRow(
                id: "tehilim121",
                title: TefilaCopy.choose("Tehilim 121 · Yerushalayim", "Psalm 121 · Jerusalem", "תהילים קכ״א · ירושלים"),
                subtitle: TefilaCopy.choose(
                    "Elevación en la subida a los montes",
                    "Uplift on the pilgrim ascent",
                    "שיר למעלות · שומר ישראל"
                ),
                tag: .tehilim,
                ribbonTeal: false
            ),
        ]
    }

    var body: some View {
        ZStack {
            Image("TefilaHomeBackground")
                .resizable()
                .scaledToFill()
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                .clipped()
                .accessibilityIgnoresInvertColors(true)
                .ignoresSafeArea()

            Color.white.opacity(0.38)
                .ignoresSafeArea()
                .allowsHitTesting(false)

            VStack(spacing: 0) {
                DashboardHomeTopBar(
                    initials: auth.userInitials,
                    profileImage: auth.profileAvatarImage,
                    searchText: .constant(""),
                    showsSearchField: false,
                    passagesAccentTrailing: true,
                    passagesAccentAction: {},
                    onNotifications: {
                        shell.openHomeSheet(.notifications)
                    }
                )
                .appChromeHeaderOuterPadding()

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 22) {
                        featuredPassageCard
                        savedPassagesSection
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 4)
                    .padding(.bottom, 32)
                }
                .scrollContentBackground(.hidden)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .environment(\.colorScheme, .light)
        .preferredColorScheme(.light)
        .toolbar(.hidden, for: .navigationBar)
    }

    // MARK: - Destacado

    private var featuredPassageCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top, spacing: 12) {
                ribbonBookMark()
                VStack(alignment: .leading, spacing: 6) {
                    Text(TefilaCopy.choose("PASAJE DESTACADO", "FEATURED PASSAGE", "קטע מובלט"))
                        .font(.system(size: 10, weight: .bold))
                        .kerning(1.1)
                        .foregroundStyle(accent.gold)
                    Text(TefilaCopy.choose("Shemá Israel", "Shema Israel", "שמע ישראל"))
                        .font(.system(size: 24, weight: .bold, design: .serif))
                        .foregroundStyle(accent.ink)
                }
                Spacer(minLength: 0)
            }

            HStack(alignment: .center, spacing: 8) {
                Text("Devarim 6:4")
                    .font(.system(size: 14, weight: .semibold, design: .serif))
                    .foregroundStyle(accent.ink.opacity(0.85))
                Text(featuredReferencePill)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(Color(red: 0.48, green: 0.30, blue: 0.14))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(
                        Capsule(style: .continuous)
                            .fill(Color(red: 1.0, green: 0.92, blue: 0.82))
                    )
            }

            Text(featuredHebrew)
                .font(.system(size: 22, weight: .medium, design: .serif))
                .foregroundStyle(accent.ink)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .environment(\.layoutDirection, .rightToLeft)
                .padding(.vertical, 6)

            diamondDivider

            Text(featuredTranslation)
                .font(.system(size: 15, weight: .regular, design: .serif))
                .italic()
                .foregroundStyle(accent.ink.opacity(0.78))
                .fixedSize(horizontal: false, vertical: true)

            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(accent.gold)
                    Text("142")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(accent.ink.opacity(0.75))
                }
                Spacer()
                Button {
                    // Placeholder: futura navegación al lector
                } label: {
                    HStack(spacing: 6) {
                        Text(TefilaCopy.choose("Ver pasaje", "View passage", "צפה בקטע"))
                            .font(.system(size: 14, weight: .semibold))
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .bold))
                    }
                    .foregroundStyle(accent.ink)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(
                        Capsule(style: .continuous)
                            .fill(Color.white.opacity(0.55))
                    )
                    .overlay {
                        Capsule(style: .continuous)
                            .strokeBorder(accent.gold.opacity(0.95), lineWidth: 1.25)
                    }
                    .shadow(color: accent.gold.opacity(0.35), radius: 10, x: 0, y: 4)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(18)
        .background {
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(.ultraThinMaterial)
                .background {
                    RoundedRectangle(cornerRadius: 26, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.72),
                                    Color.white.opacity(0.38),
                                    accent.gold.opacity(0.06),
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
                .overlay {
                    RoundedRectangle(cornerRadius: 26, style: .continuous)
                        .strokeBorder(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.95),
                                    accent.gold.opacity(0.55),
                                    Color.white.opacity(0.35),
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.1
                        )
                }
                .shadow(color: accent.gold.opacity(0.12), radius: 18, x: 0, y: 8)
                .shadow(color: .black.opacity(0.06), radius: 16, x: 0, y: 10)
        }
    }

    private var diamondDivider: some View {
        HStack(spacing: 10) {
            Rectangle()
                .fill(accent.ink.opacity(0.12))
                .frame(height: 1)
            Image(systemName: "diamond.fill")
                .font(.system(size: 6))
                .foregroundStyle(accent.gold.opacity(0.8))
            Rectangle()
                .fill(accent.ink.opacity(0.12))
                .frame(height: 1)
        }
        .padding(.vertical, 4)
    }

    // MARK: - Lista

    private var savedPassagesSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .firstTextBaseline) {
                Text(TefilaCopy.choose("Tus pasajes guardados", "Your saved passages", "שמורים שלך"))
                    .font(.system(size: 20, weight: .bold, design: .serif))
                    .foregroundStyle(accent.ink)
                Spacer()
                Menu {
                    Button(TefilaCopy.choose("Más recientes", "Most recent", "העדכניים ביותר"), action: {})
                    Button(TefilaCopy.choose("Por libro", "By book", "לפי ספר"), action: {})
                } label: {
                    HStack(spacing: 4) {
                        Text(TefilaCopy.choose("Más recientes", "Most recent", "העדכניים ביותר"))
                            .font(.system(size: 13, weight: .semibold))
                        Image(systemName: "chevron.down")
                            .font(.system(size: 11, weight: .bold))
                    }
                    .foregroundStyle(accent.ink.opacity(0.72))
                }
            }

            ForEach(savedRows) { row in
                savedPassageRowCard(row)
            }
        }
    }

    private func savedPassageRowCard(_ row: SavedPassageRow) -> some View {
        GlassCard(cornerRadius: 20, padding: 14) {
            HStack(alignment: .center, spacing: 14) {
                ribbonBookMark(tealVariant: row.ribbonTeal, compact: true)

                VStack(alignment: .leading, spacing: 6) {
                    Text(row.title)
                        .font(.system(size: 17, weight: .semibold, design: .serif))
                        .foregroundStyle(accent.ink)
                    Text(row.subtitle)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(accent.ink.opacity(0.48))
                        .fixedSize(horizontal: false, vertical: true)
                    Text(row.tag.title)
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(row.tag.tagForeground)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(
                            Capsule(style: .continuous).fill(row.tag.tagBackground)
                        )
                }

                Spacer(minLength: 0)

                VStack(spacing: 12) {
                    PassagesMagenDavidAccentDisk(diameter: 32, symbolSize: 13)
                        .accessibilityHidden(true)
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(accent.ink.opacity(0.35))
                }
            }
        }
    }

    private func ribbonBookMark(
        tealVariant: Bool = false,
        compact: Bool = false
    ) -> some View {
        let base = tealVariant ? accent.ribbonTeal : accent.ribbon
        let h: CGFloat = compact ? 62 : 78
        let w: CGFloat = compact ? 32 : 38
        let diskDiameter: CGFloat = compact ? 26 : 30
        let symbolSize: CGFloat = compact ? 11 : 13

        return ZStack {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            base,
                            base.opacity(0.78),
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: w, height: h)
                .overlay {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.35), lineWidth: 0.8)
                }
                .shadow(color: .black.opacity(0.12), radius: 5, x: 0, y: 3)

            PassagesMagenDavidAccentDisk(
                diameter: diskDiameter,
                symbolSize: symbolSize,
                fillStyle: .frostedLight,
                showsShadow: false
            )
            .accessibilityHidden(true)
        }
    }
}

#Preview {
    NavigationStack {
        FavoritesView()
    }
    .environmentObject(AuthViewModel())
    .environmentObject(AppShellRouter())
}
