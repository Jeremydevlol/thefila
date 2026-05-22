import SwiftUI

// MARK: - ChoosePrayerIntentionView

struct ChoosePrayerIntentionView: View {
    /// Flujo en pasos para que la acción principal no quede fuera de pantalla.
    private enum WizardStep: Int, CaseIterable {
        case intention
        case location
        case summary
    }

    @Environment(\.dismiss) private var dismiss

    @State private var step: WizardStep = .intention
    @State private var selectedIntention: PrayerIntention? = nil
    @State private var selectedLocation: SacredLocation = .kotel
    @State private var goToForm = false

    private let intentions = MockIntentions.all
    private let goldAccent = Color(red: 236/255, green: 196/255, blue: 95/255)
    private let goldMid    = Color(red: 219/255, green: 175/255, blue: 75/255)
    private let goldDeep   = Color(red: 172/255, green: 128/255, blue: 44/255)
    private let navyInk    = Color(red: 42/255, green: 58/255, blue: 98/255)

    private let columns = [
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10),
    ]

    var body: some View {
        ZStack {
            // Fondo celestial
            Image("TefilaHomeBackground")
                .resizable()
                .scaledToFill()
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                .clipped()
                .ignoresSafeArea()
                .accessibilityIgnoresInvertColors(true)
            Color.white.opacity(0.18).ignoresSafeArea().allowsHitTesting(false)

            VStack(spacing: 0) {
                stepIndicator
                    .padding(.horizontal, 18)
                    .padding(.top, 8)
                    .padding(.bottom, 12)

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 0) {
                        switch step {
                        case .intention:
                            intentionStepContent
                        case .location:
                            locationStepContent
                        case .summary:
                            summaryStepContent
                        }
                    }
                    .padding(.bottom, 8)
                }
            }
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            wizardBottomBar
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button { dismiss() } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left").font(.system(size: 14, weight: .semibold))
                    }
                    .foregroundStyle(goldAccent)
                    .frame(width: 36, height: 36)
                    .background {
                        Circle().fill(.white.opacity(0.82))
                            .shadow(color: .black.opacity(0.08), radius: 6, x: 0, y: 2)
                    }
                }
            }
        }
        .toolbarBackground(.hidden, for: .navigationBar)
        .environment(\.colorScheme, .light)
        .preferredColorScheme(.light)
        .navigationDestination(isPresented: $goToForm) {
            if let intention = selectedIntention {
                PrayerRequestFormView(
                    intention: intention,
                    location: selectedLocation
                )
            }
        }
    }

    // MARK: - Paso 1 · Intenciones

    @ViewBuilder
    private var intentionStepContent: some View {
        intentionHeader(title: "Elige la intención\nde tu tefilá", subtitle: "Cada oración es recitada por rabinos\ny estudiosos en lugares sagrados.")
            .padding(.bottom, 20)

        LazyVGrid(columns: columns, spacing: 10) {
            ForEach(intentions) { intention in
                IntentionGridCell(
                    intention: intention,
                    isSelected: selectedIntention?.id == intention.id,
                    goldAccent: goldAccent,
                    goldMid: goldMid,
                    navyInk: navyInk
                )
                .onTapGesture {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                        selectedIntention = intention
                    }
                }
            }
        }
        .padding(.horizontal, 18)
    }

    // MARK: - Paso 2 · Lugar (lista en pantalla, sin sheet)

    @ViewBuilder
    private var locationStepContent: some View {
        intentionHeader(title: "Elige el lugar\nsagrado", subtitle: "Donde será elevada tu tefilá.")
            .padding(.bottom, 18)

        VStack(spacing: 10) {
            ForEach(SacredLocation.allCases) { loc in
                SacredLocationSelectableRow(
                    location: loc,
                    isSelected: selectedLocation == loc,
                    navyInk: navyInk,
                    goldMid: goldMid,
                    goldAccent: goldAccent
                ) {
                    withAnimation(.spring(response: 0.28, dampingFraction: 0.82)) {
                        selectedLocation = loc
                    }
                }
            }
        }
        .padding(.horizontal, 18)
        .padding(.bottom, 8)
    }

    // MARK: - Paso 3 · Resumen y confiar

    @ViewBuilder
    private var summaryStepContent: some View {
        intentionHeader(title: "Listo para\ncontinuar", subtitle: "Revisa tu elección. Después podrás personalizar nombres y petición.")
            .padding(.bottom, 16)

        if let intention = selectedIntention {
            summaryRecapCard(intention: intention)
                .padding(.horizontal, 18)
                .padding(.bottom, 14)
        }

        personalizationInfo
            .padding(.horizontal, 18)
            .padding(.bottom, 14)

        trustBadges
            .padding(.horizontal, 18)
            .padding(.bottom, 8)
    }

    private func summaryRecapCard(intention: PrayerIntention) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Image(systemName: intention.sfSymbol)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(LinearGradient(colors: [goldAccent, goldDeep], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 44, height: 44)
                    .background(Circle().fill(goldAccent.opacity(0.12)))

                VStack(alignment: .leading, spacing: 4) {
                    Text(TefilaCopy.choose("Tu intención", "Your intention", "הכוונה שלך"))
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(navyInk.opacity(0.5))
                        .textCase(.uppercase)
                    Text(intention.title)
                        .font(.system(size: 17, weight: .bold, design: .serif))
                        .foregroundStyle(navyInk)
                }
                Spacer(minLength: 0)
            }

            Divider().opacity(0.2)

            HStack(spacing: 10) {
                Image(systemName: "location.fill")
                    .foregroundStyle(goldMid)
                VStack(alignment: .leading, spacing: 2) {
                    Text(TefilaCopy.choose("Lugar", "Sacred site", "מקום"))
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(navyInk.opacity(0.45))
                        .textCase(.uppercase)
                    Text(selectedLocation.displayName)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(navyInk.opacity(0.85))
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer(minLength: 0)
            }
        }
        .padding(18)
        .background {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.white.opacity(0.92))
                .overlay {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.75), lineWidth: 1)
                }
                .shadow(color: .black.opacity(0.06), radius: 10, x: 0, y: 4)
        }
    }

    // MARK: - Indicador de pasos

    private var stepIndicator: some View {
        VStack(spacing: 10) {
            HStack(spacing: 6) {
                ForEach(WizardStep.allCases.indices, id: \.self) { idx in
                    let active = idx <= step.rawValue
                    Capsule()
                        .fill(active
                              ? LinearGradient(colors: [goldAccent, goldMid], startPoint: .leading, endPoint: .trailing)
                              : LinearGradient(colors: [Color.gray.opacity(0.18), Color.gray.opacity(0.12)], startPoint: .leading, endPoint: .trailing))
                        .frame(height: 5)
                        .frame(maxWidth: .infinity)
                }
            }

            Text(stepIndicatorCaption)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(navyInk.opacity(0.55))
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
        }
    }

    private var stepIndicatorCaption: String {
        switch step {
        case .intention:
            return TefilaCopy.choose("Paso 1 de 3 · Elige tu intención", "Step 1 of 3 · Choose your intention", "שלב 1 מתוך 3 · כוונה")
        case .location:
            return TefilaCopy.choose("Paso 2 de 3 · Elige el lugar sagrado", "Step 2 of 3 · Choose the sacred site", "שלב 2 מתוך 3 · מקום קדוש")
        case .summary:
            return TefilaCopy.choose("Paso 3 de 3 · Confirma y continúa", "Step 3 of 3 · Confirm and continue", "שלב 3 מתוך 3 · אישור והמשך")
        }
    }

    // MARK: - Barra inferior fija

    private var wizardBottomBar: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(Color.black.opacity(0.06))
                .frame(height: 1)

            VStack(spacing: 12) {
                switch step {
                case .intention:
                    wizardPrimaryButton(
                        title: TefilaCopy.choose("Siguiente", "Next", "הבא"),
                        systemImage: "chevron.right",
                        isEnabled: selectedIntention != nil
                    ) {
                        guard selectedIntention != nil else { return }
                        withAnimation(.easeInOut(duration: 0.25)) { step = .location }
                    }

                case .location:
                    HStack(spacing: 12) {
                        wizardSecondaryButton(title: TefilaCopy.choose("Atrás", "Back", "חזרה")) {
                            withAnimation(.easeInOut(duration: 0.25)) { step = .intention }
                        }

                        wizardPrimaryButton(
                            title: TefilaCopy.choose("Siguiente", "Next", "הבא"),
                            systemImage: "chevron.right",
                            isEnabled: true
                        ) {
                            withAnimation(.easeInOut(duration: 0.25)) { step = .summary }
                        }
                    }

                case .summary:
                    HStack(spacing: 12) {
                        wizardSecondaryButton(title: TefilaCopy.choose("Atrás", "Back", "חזרה")) {
                            withAnimation(.easeInOut(duration: 0.25)) { step = .location }
                        }

                        wizardPrimaryButton(
                            title: "Continuar",
                            systemImage: "star.of.david.fill",
                            isEnabled: selectedIntention != nil,
                            trailingIcon: false
                        ) {
                            if selectedIntention != nil { goToForm = true }
                        }
                    }
                }
            }
            .padding(.horizontal, 18)
            .padding(.top, 14)
            .padding(.bottom, 10)
            .background {
                Rectangle()
                    .fill(.regularMaterial)
                    .environment(\.colorScheme, .light)
                    .ignoresSafeArea(edges: .bottom)
            }
        }
    }

    private func wizardPrimaryButton(
        title: String,
        systemImage: String,
        isEnabled: Bool,
        trailingIcon: Bool = true,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Group {
                if trailingIcon {
                    HStack(spacing: 8) {
                        Text(title).font(.system(size: 16, weight: .bold))
                        Image(systemName: systemImage).font(.system(size: 14, weight: .bold))
                    }
                } else {
                    HStack(spacing: 8) {
                        Image(systemName: systemImage).font(.system(size: 14, weight: .bold))
                        Text(title).font(.system(size: 16, weight: .bold))
                    }
                }
            }
            .foregroundStyle(isEnabled ? navyInk : navyInk.opacity(0.35))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 15)
            .background {
                Capsule(style: .continuous)
                    .fill(
                        isEnabled
                        ? LinearGradient(
                            stops: [
                                .init(color: Color(red: 1, green: 0.93, blue: 0.72), location: 0),
                                .init(color: goldAccent, location: 0.45),
                                .init(color: goldMid, location: 1),
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        : LinearGradient(colors: [Color.gray.opacity(0.2), Color.gray.opacity(0.15)], startPoint: .leading, endPoint: .trailing)
                    )
                    .shadow(color: isEnabled ? goldDeep.opacity(0.4) : .clear, radius: 10, x: 0, y: 5)
            }
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
    }

    private func wizardSecondaryButton(title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(navyInk.opacity(0.85))
                .frame(minWidth: 96)
                .padding(.vertical, 15)
                .padding(.horizontal, 8)
                .background {
                    Capsule(style: .continuous)
                        .fill(Color.white.opacity(0.92))
                        .overlay {
                            Capsule(style: .continuous).strokeBorder(navyInk.opacity(0.12), lineWidth: 1)
                        }
                }
        }
        .buttonStyle(.plain)
    }

    // MARK: - Header

    @ViewBuilder
    private func intentionHeader(title: String, subtitle: String) -> some View {
        VStack(spacing: 10) {
            // Logo Tefila
            Group {
                if let _ = UIImage(named: "TefilaLogo") {
                    Image("TefilaLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 40)
                } else {
                    Image(systemName: "music.note")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(goldAccent)
                }
            }
            .padding(.top, 6)

            Text(title)
                .font(.system(size: 24, weight: .bold, design: .serif))
                .foregroundStyle(navyInk)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)

            Text(subtitle)
                .font(.system(size: 13.5, weight: .medium))
                .foregroundStyle(navyInk.opacity(0.62))
                .multilineTextAlignment(.center)

            // Separador dorado
            HStack(spacing: 8) {
                Capsule().fill(goldMid.opacity(0.5)).frame(width: 36, height: 1.5)
                Image(systemName: "star.of.david.fill")
                    .font(.system(size: 9))
                    .foregroundStyle(goldMid)
                Capsule().fill(goldMid.opacity(0.5)).frame(width: 36, height: 1.5)
            }
        }
        .padding(.horizontal, 20)
    }

    // MARK: - Info personalización

    private var personalizationInfo: some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: "sparkles")
                .font(.system(size: 20))
                .foregroundStyle(goldMid)

            VStack(alignment: .leading, spacing: 3) {
                Text("Puedes personalizar tu oración con el nombre hebreo de la persona y una petición especial.")
                    .font(.system(size: 13.5, weight: .medium))
                    .foregroundStyle(navyInk.opacity(0.75))
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)

            Image(systemName: "square.and.pencil")
                .font(.system(size: 26))
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(goldMid.opacity(0.7))
        }
        .padding(16)
        .background {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(goldAccent.opacity(0.08))
                .overlay {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .strokeBorder(goldAccent.opacity(0.28), lineWidth: 1)
                }
        }
    }

    // MARK: - Trust badges

    private var trustBadges: some View {
        HStack(spacing: 0) {
            TrustBadgeItem(icon: "checkmark.shield.fill", title: "Seguro y\nPrivado",   subtitle: "Tu información\nestá protegida.", color: goldMid)
            Divider().frame(height: 44).opacity(0.2)
            TrustBadgeItem(icon: "scroll.fill",            title: "Recitado\nauténtico", subtitle: "Por rabinos y\nestudiosos.",       color: goldMid)
            Divider().frame(height: 44).opacity(0.2)
            TrustBadgeItem(icon: "building.columns.fill",  title: "100%\nTefilá",       subtitle: "Tu oración es\nnuestra prioridad.", color: goldMid)
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 10)
        .background {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(.white.opacity(0.88))
                .overlay {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.7), lineWidth: 1)
                }
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
        }
    }
}

// MARK: - Fila lugar sagrado (paso 2)

private struct SacredLocationSelectableRow: View {
    let location: SacredLocation
    let isSelected: Bool
    let navyInk: Color
    let goldMid: Color
    let goldAccent: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(location.accentColor.opacity(isSelected ? 0.22 : 0.12))
                        .frame(width: 44, height: 44)
                    Image(systemName: location.systemIcon)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(location.accentColor)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(location.displayName)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(navyInk)
                        .multilineTextAlignment(.leading)
                    Text(location.subtitle)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(navyInk.opacity(0.55))
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 8)

                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(isSelected ? goldMid : navyInk.opacity(0.25))
                    .symbolRenderingMode(.hierarchical)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(isSelected ? goldAccent.opacity(0.07) : .white.opacity(0.9))
                    .overlay {
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .strokeBorder(isSelected ? goldMid.opacity(0.85) : Color.white.opacity(0.75), lineWidth: isSelected ? 1.5 : 1)
                    }
                    .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 3)
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Celda de intención

private struct IntentionGridCell: View {
    let intention: PrayerIntention
    let isSelected: Bool
    let goldAccent: Color
    let goldMid: Color
    let navyInk: Color

    var body: some View {
        VStack(spacing: 8) {
            // Ícono dorado
            ZStack {
                Circle()
                    .fill(goldAccent.opacity(isSelected ? 0.25 : 0.10))
                    .frame(width: 50, height: 50)
                    .overlay {
                        Circle()
                            .strokeBorder(goldMid.opacity(isSelected ? 0.6 : 0.3), lineWidth: isSelected ? 1.5 : 1)
                    }
                Image(systemName: intention.sfSymbol)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(
                        LinearGradient(colors: [goldAccent, Color(red: 172/255, green: 128/255, blue: 44/255)], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
            }

            Text(intention.title)
                .font(.system(size: 11.5, weight: .bold))
                .foregroundStyle(navyInk)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.85)

            Text(intention.subtitle)
                .font(.system(size: 9.5, weight: .medium))
                .foregroundStyle(navyInk.opacity(0.52))
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.85)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 6)
        .frame(maxWidth: .infinity)
        .background {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(isSelected ? goldAccent.opacity(0.08) : .white.opacity(0.88))
                .overlay {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .strokeBorder(isSelected ? goldMid.opacity(0.8) : Color.white.opacity(0.7), lineWidth: isSelected ? 1.5 : 1)
                }
                .shadow(color: isSelected ? goldMid.opacity(0.2) : .black.opacity(0.05), radius: 6, x: 0, y: 3)
        }
        .overlay(alignment: .topTrailing) {
            if isSelected {
                ZStack {
                    Circle()
                        .fill(goldMid)
                        .frame(width: 20, height: 20)
                    Image(systemName: "checkmark")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(.white)
                }
                .offset(x: 4, y: -4)
            }
        }
    }
}

// MARK: - Trust badge item

private struct TrustBadgeItem: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(color)
            Text(title)
                .font(.system(size: 10.5, weight: .bold))
                .foregroundStyle(color)
                .multilineTextAlignment(.center)
            Text(subtitle)
                .font(.system(size: 9, weight: .medium))
                .foregroundStyle(Color.black.opacity(0.45))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    NavigationStack {
        ChoosePrayerIntentionView()
    }
}
