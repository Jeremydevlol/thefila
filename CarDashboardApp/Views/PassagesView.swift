import SwiftUI

// MARK: - PassagesView (Pasajes del Tanaj)

struct PassagesView: View {
    @EnvironmentObject private var auth: AuthViewModel
    @EnvironmentObject private var shell: AppShellRouter

    @State private var passages: [TanajPassage] = MockPassages.all
    @State private var searchText: String = ""
    @State private var selectedTag: PassageTag? = nil
    @State private var selectedPassage: TanajPassage? = nil

    private let goldAccent = Color(red: 236/255, green: 196/255, blue: 95/255)
    private let goldMid    = Color(red: 219/255, green: 175/255, blue: 75/255)
    private let goldDeep   = Color(red: 172/255, green: 128/255, blue: 44/255)
    private let navyInk    = Color(red: 42/255, green: 58/255, blue: 98/255)

    private var filtered: [TanajPassage] {
        passages.filter { p in
            let matchesSearch = searchText.isEmpty ||
                p.title.localizedCaseInsensitiveContains(searchText) ||
                p.reference.localizedCaseInsensitiveContains(searchText) ||
                p.spanishText.localizedCaseInsensitiveContains(searchText)
            let matchesTag = selectedTag == nil || p.tag == selectedTag
            return matchesSearch && matchesTag
        }
    }

    var body: some View {
        ZStack {
            // Fondo celestial (mismo tratamiento que Inicio: recorte + safe area).
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
                // Cabecera: misma posición que Inicio (barra de navegación nativa oculta + padding app chrome).
                DashboardHomeTopBar(
                    initials: auth.userInitials,
                    profileImage: auth.profileAvatarImage,
                    searchText: $searchText,
                    showsSearchField: true,
                    onNotifications: { shell.openHomeSheet(.notifications) }
                )
                .appChromeHeaderOuterPadding()

                // Tag filter pills
                tagFilterRow
                    .padding(.horizontal, AppChromeHeaderMetrics.horizontalPadding)
                    .padding(.bottom, 10)

                // List
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 12) {
                        ForEach(filtered) { passage in
                            PassageCardRow(
                                passage: passage,
                                goldAccent: goldAccent,
                                goldMid: goldMid,
                                goldDeep: goldDeep,
                                navyInk: navyInk,
                                onFavorite: { toggle(passage) }
                            )
                            .onTapGesture { selectedPassage = passage }
                        }

                        if filtered.isEmpty {
                            emptyState
                        }
                    }
                    .padding(.horizontal, 18)
                    .padding(.bottom, 40)
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
        .navigationDestination(item: $selectedPassage) { passage in
            PassageDetailView(passage: binding(for: passage))
        }
    }

    // MARK: - Tag filter

    private var tagFilterRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                tagPill(label: "Todos", tag: nil)
                ForEach(PassageTag.allCases, id: \.rawValue) { tag in
                    tagPill(label: tag.rawValue, tag: tag)
                }
            }
            .padding(.horizontal, 2)
            .padding(.vertical, 4)
        }
    }

    private func tagPill(label: String, tag: PassageTag?) -> some View {
        let isOn = selectedTag == tag
        return Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                selectedTag = tag
            }
        } label: {
            Text(label)
                .font(.system(size: 12.5, weight: .semibold))
                .foregroundStyle(isOn ? .white : navyInk.opacity(0.7))
                .padding(.horizontal, 14)
                .padding(.vertical, 7)
                .background {
                    Capsule(style: .continuous)
                        .fill(isOn ? goldMid : Color.white.opacity(0.7))
                        .shadow(color: isOn ? goldDeep.opacity(0.35) : .clear, radius: 5, x: 0, y: 2)
                }
        }
        .buttonStyle(.plain)
    }

    // MARK: - Empty state

    private var emptyState: some View {
        VStack(spacing: 14) {
            Image(systemName: "scroll.fill")
                .font(.system(size: 36))
                .foregroundStyle(goldAccent.opacity(0.6))
            Text("No se encontraron pasajes")
                .font(.system(size: 16, weight: .semibold, design: .serif))
                .foregroundStyle(navyInk.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 60)
    }

    // MARK: - Helpers

    private func toggle(_ passage: TanajPassage) {
        if let i = passages.firstIndex(where: { $0.id == passage.id }) {
            passages[i].isFavorite.toggle()
        }
    }

    private func binding(for passage: TanajPassage) -> Binding<TanajPassage> {
        guard let i = passages.firstIndex(where: { $0.id == passage.id }) else {
            return .constant(passage)
        }
        return $passages[i]
    }
}

// MARK: - Tarjeta de pasaje (fila)

struct PassageCardRow: View {
    let passage: TanajPassage
    let goldAccent: Color
    let goldMid: Color
    let goldDeep: Color
    let navyInk: Color
    let onFavorite: () -> Void

    var body: some View {
        ZStack(alignment: .topLeading) {
            // Cinta / flag con Maguén
            passageRibbon

            // Contenido
            HStack(alignment: .top, spacing: 0) {
                Color.clear.frame(width: 36) // espacio para la cinta

                VStack(alignment: .leading, spacing: 6) {
                    // Tag pill + favorito
                    HStack {
                        Text(passage.tag.rawValue)
                            .font(.system(size: 10.5, weight: .bold))
                            .tracking(0.5)
                            .foregroundStyle(passage.tag.color)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(passage.tag.background, in: Capsule())

                        Spacer()

                        Button(action: onFavorite) {
                            Image(systemName: passage.isFavorite ? "heart.fill" : "heart")
                                .font(.system(size: 17, weight: .medium))
                                .foregroundStyle(passage.isFavorite ? Color(red: 0.82, green: 0.28, blue: 0.38) : navyInk.opacity(0.35))
                        }
                        .buttonStyle(.plain)
                    }

                    // Título
                    Text(passage.title)
                        .font(.system(size: 17, weight: .bold, design: .serif))
                        .foregroundStyle(navyInk)
                        .lineLimit(2)

                    // Referencia
                    Text(passage.reference)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(goldMid)

                    // Texto español (preview)
                    Text(passage.spanishText)
                        .font(.system(size: 13.5, weight: .medium))
                        .foregroundStyle(navyInk.opacity(0.62))
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)

                    // Botón ver pasaje
                    HStack(spacing: 6) {
                        Image(systemName: "eye")
                            .font(.system(size: 12, weight: .semibold))
                        Text("Ver pasaje")
                            .font(.system(size: 13, weight: .semibold))
                    }
                    .foregroundStyle(goldMid)
                    .padding(.top, 2)
                }
                .padding(.vertical, 14)
                .padding(.trailing, 14)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .background {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(.white.opacity(0.90))
                    .overlay {
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .strokeBorder(Color.white.opacity(0.75), lineWidth: 1)
                    }
                    .shadow(color: .black.opacity(0.07), radius: 10, x: 0, y: 5)
            }
        }
    }

    // MARK: - Cinta de pasaje

    private var passageRibbon: some View {
        ZStack {
            // Flag shape (cinta con punta)
            PassageRibbonShape()
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.48, green: 0.35, blue: 0.74),
                            Color(red: 0.35, green: 0.25, blue: 0.60)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .overlay {
                    PassageRibbonShape()
                        .stroke(Color.white.opacity(0.35), lineWidth: 0.75)
                }
                .shadow(color: Color(red: 0.35, green: 0.25, blue: 0.60).opacity(0.4), radius: 4, x: 0, y: 2)

            // Maguén David dorado
            Image(systemName: "star.of.david.fill")
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(
                    LinearGradient(colors: [goldAccent, goldDeep], startPoint: .top, endPoint: .bottom)
                )
                .offset(y: -6)
        }
        .frame(width: 28, height: 62)
        .offset(x: 10, y: -4)
        .zIndex(1)
    }
}

// MARK: - Forma de la cinta

struct PassageRibbonShape: Shape {
    func path(in rect: CGRect) -> Path {
        let w = rect.width, h = rect.height
        let tipY = h - 14
        var p = Path()
        p.move(to: CGPoint(x: 4, y: 0))
        p.addLine(to: CGPoint(x: w - 4, y: 0))
        p.addQuadCurve(to: CGPoint(x: w, y: 4), control: CGPoint(x: w, y: 0))
        p.addLine(to: CGPoint(x: w, y: tipY))
        p.addLine(to: CGPoint(x: w/2, y: h))
        p.addLine(to: CGPoint(x: 0, y: tipY))
        p.addLine(to: CGPoint(x: 0, y: 4))
        p.addQuadCurve(to: CGPoint(x: 4, y: 0), control: CGPoint(x: 0, y: 0))
        p.closeSubpath()
        return p
    }
}

// MARK: - PassageDetailView

struct PassageDetailView: View {
    @Binding var passage: TanajPassage
    @Environment(\.dismiss) private var dismiss

    private let goldAccent = Color(red: 236/255, green: 196/255, blue: 95/255)
    private let goldMid    = Color(red: 219/255, green: 175/255, blue: 75/255)
    private let goldDeep   = Color(red: 172/255, green: 128/255, blue: 44/255)
    private let navyInk    = Color(red: 42/255, green: 58/255, blue: 98/255)
    private let purple     = Color(red: 0.48, green: 0.35, blue: 0.74)

    var body: some View {
        ZStack {
            Image("TefilaHomeBackground")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
                .accessibilityIgnoresInvertColors(true)
            Color.white.opacity(0.22).ignoresSafeArea().allowsHitTesting(false)

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 20) {
                    // Hero header
                    VStack(spacing: 10) {
                        // Cinta grande
                        ZStack {
                            PassageRibbonShape()
                                .fill(LinearGradient(colors: [purple, purple.opacity(0.75)], startPoint: .top, endPoint: .bottom))
                                .overlay { PassageRibbonShape().stroke(Color.white.opacity(0.4), lineWidth: 1) }
                                .shadow(color: purple.opacity(0.45), radius: 8, x: 0, y: 4)
                            Image(systemName: "star.of.david.fill")
                                .font(.system(size: 22, weight: .bold))
                                .foregroundStyle(LinearGradient(colors: [goldAccent, goldDeep], startPoint: .top, endPoint: .bottom))
                                .offset(y: -8)
                        }
                        .frame(width: 48, height: 98)
                        .padding(.top, 20)

                        Text(passage.title)
                            .font(.system(size: 26, weight: .bold, design: .serif))
                            .foregroundStyle(navyInk)
                            .multilineTextAlignment(.center)

                        Text(passage.reference)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(goldMid)

                        // Tag
                        Text(passage.tag.rawValue)
                            .font(.system(size: 11, weight: .bold))
                            .tracking(0.6)
                            .foregroundStyle(passage.tag.color)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 5)
                            .background(passage.tag.background, in: Capsule())
                    }
                    .frame(maxWidth: .infinity)

                    // Texto hebreo
                    hebrewCard

                    // Texto español
                    spanishCard

                    // Reflexión espiritual
                    reflectionCard

                    // Botón favorito
                    favoriteButton
                        .padding(.bottom, 40)
                }
                .padding(.horizontal, 20)
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button { dismiss() } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left").font(.system(size: 14, weight: .semibold))
                        Text("Pasajes").font(.system(size: 16, weight: .medium))
                    }
                    .foregroundStyle(goldAccent)
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { passage.isFavorite.toggle() }) {
                    Image(systemName: passage.isFavorite ? "heart.fill" : "heart")
                        .font(.system(size: 17))
                        .foregroundStyle(passage.isFavorite ? Color(red: 0.82, green: 0.28, blue: 0.38) : navyInk.opacity(0.5))
                }
            }
        }
        .toolbarBackground(.hidden, for: .navigationBar)
        .environment(\.colorScheme, .light)
        .preferredColorScheme(.light)
    }

    // MARK: - Cards

    private var hebrewCard: some View {
        VStack(alignment: .trailing, spacing: 10) {
            HStack {
                Spacer()
                Text("עברית")
                    .font(.system(size: 11, weight: .bold))
                    .tracking(0.5)
                    .foregroundStyle(goldMid)
            }
            Text(passage.hebrewText)
                .font(.system(size: 22, weight: .medium, design: .serif))
                .foregroundStyle(navyInk)
                .multilineTextAlignment(.trailing)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .environment(\.layoutDirection, .rightToLeft)
        }
        .padding(20)
        .background {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color(red: 1, green: 0.97, blue: 0.88).opacity(0.95))
                .overlay {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .strokeBorder(goldAccent.opacity(0.35), lineWidth: 1)
                }
                .shadow(color: goldDeep.opacity(0.15), radius: 8, x: 0, y: 4)
        }
    }

    private var spanishCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("«")
                    .font(.system(size: 28, weight: .heavy, design: .serif))
                    .foregroundStyle(goldMid)
                Spacer()
            }
            .padding(.bottom, -8)

            Text(passage.spanishText)
                .font(.system(size: 18, weight: .medium, design: .serif))
                .foregroundStyle(navyInk)
                .fixedSize(horizontal: false, vertical: true)
                .multilineTextAlignment(.leading)

            HStack {
                Spacer()
                Text("— \(passage.reference)")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(goldMid)
            }
        }
        .padding(20)
        .background {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.white.opacity(0.92))
                .overlay {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.8), lineWidth: 1)
                }
                .shadow(color: .black.opacity(0.06), radius: 10, x: 0, y: 5)
        }
    }

    private var reflectionCard: some View {
        HStack(alignment: .top, spacing: 14) {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 6) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 13))
                        .foregroundStyle(purple)
                    Text("Reflexión espiritual")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(purple)
                }
                Text(reflectionText)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(navyInk.opacity(0.75))
                    .fixedSize(horizontal: false, vertical: true)
            }
            Image(systemName: "brain.fill")
                .font(.system(size: 38))
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(purple.opacity(0.7))
        }
        .padding(18)
        .background {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(purple.opacity(0.08))
                .overlay {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .strokeBorder(purple.opacity(0.18), lineWidth: 1)
                }
        }
    }

    private var reflectionText: String {
        switch passage.tag {
        case .tehilim:
            return "Este pasaje del Tehilim nos invita a elevar nuestra mirada hacia Hashem en cada momento de dificultad o gratitud. La sabiduría del Rey David trasciende el tiempo y sigue resonando en cada neshamá que busca conexión espiritual."
        case .torah:
            return "Este pasaje de la Torá es la base de la vida judía. Cada palabra fue dada en Sinaí con un propósito eterno. Al leerlo y meditarlo, conectamos con la tradición de miles de años de fe y kedushá."
        case .mishle:
            return "La sabiduría de Mishlé, compilada por el Rey Shlomo, es una guía práctica para vivir con emuná e integridad. Este pasaje nos enseña cómo aplicar la sabiduría de la Torá en nuestra vida cotidiana."
        case .shir:
            return "Shir HaShirim — el más sagrado de los textos — representa el amor eterno entre el Am Israel y el Creador. Rabbi Akiva enseñó que es el Kodesh Kedoshim de toda la Torá."
        case .nevi:
            return "Los profetas de Israel transmitieron palabras de Hashem en momentos cruciales de la historia del pueblo. Este pasaje contiene un mensaje eterno de esperanza, teshuva y renovación espiritual."
        }
    }

    private var favoriteButton: some View {
        Button {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                passage.isFavorite.toggle()
            }
        } label: {
            HStack(spacing: 10) {
                Image(systemName: passage.isFavorite ? "heart.fill" : "heart")
                    .font(.system(size: 16, weight: .semibold))
                Text(passage.isFavorite ? "Guardado en favoritos" : "Guardar en favoritos")
                    .font(.system(size: 16, weight: .bold))
            }
            .foregroundStyle(passage.isFavorite ? .white : navyInk)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 15)
            .background {
                Capsule(style: .continuous)
                    .fill(passage.isFavorite
                          ? LinearGradient(colors: [Color(red: 0.82, green: 0.28, blue: 0.38), Color(red: 0.65, green: 0.18, blue: 0.28)], startPoint: .leading, endPoint: .trailing)
                          : LinearGradient(colors: [goldAccent, goldMid], startPoint: .leading, endPoint: .trailing))
                    .shadow(color: (passage.isFavorite ? Color(red: 0.65, green: 0.18, blue: 0.28) : goldDeep).opacity(0.4), radius: 12, x: 0, y: 6)
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationStack {
        PassagesView()
            .environmentObject(AuthViewModel())
            .environmentObject(AppShellRouter())
    }
}
