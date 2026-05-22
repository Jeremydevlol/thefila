import SwiftUI

// MARK: - PrayerRequestFormView

struct PrayerRequestFormView: View {
    let intention: PrayerIntention
    let location: SacredLocation

    /// Divide el formulario para que quepa bien y los botones sean siempre accesibles.
    private enum CustomizeStep {
        /// Nombres y petición (scroll corto).
        case personalDetails
        /// Idioma, crear tefilá y vista previa.
        case audioAndCreate
    }

    @Environment(\.dismiss) private var dismiss
    @FocusState private var focusedField: FormField?

    @State private var step: CustomizeStep = .personalDetails
    @State private var hebrewName: String = ""
    @State private var mothersName: String = ""
    @State private var personalNote: String = ""
    @State private var selectedLanguage: PrayerLanguage = .spanish
    @State private var generatedText: String = ""
    @State private var isGenerating: Bool = false
    @State private var goToCheckout: Bool = false

    private enum FormField { case hebrewName, mothersName, personalNote }
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
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                .clipped()
                .ignoresSafeArea()
                .accessibilityIgnoresInvertColors(true)
            Color.white.opacity(0.32).ignoresSafeArea().allowsHitTesting(false)

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 18) {
                    switch step {
                    case .personalDetails:
                        stepIndicatorDots
                        formHeader
                        intentionSummaryCard
                        hebrewNameSection
                        personalNoteSection
                    case .audioAndCreate:
                        stepIndicatorDots
                        compactSummaryForStepTwo
                        languageSection

                        if !generatedText.isEmpty {
                            generatedPrayerPreviewCard
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 6)
                .padding(.bottom, 20)
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            bottomBar
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    switch step {
                    case .personalDetails:
                        dismiss()
                    case .audioAndCreate:
                        withAnimation(.easeInOut(duration: 0.22)) {
                            step = .personalDetails
                            focusedField = nil
                        }
                    }
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left").font(.system(size: 14, weight: .semibold))
                        Text(step == .personalDetails ? "Intención" : "Datos").font(.system(size: 16, weight: .medium))
                    }
                    .foregroundStyle(goldAccent)
                }
            }
        }
        .toolbarBackground(.hidden, for: .navigationBar)
        .environment(\.colorScheme, .light)
        .preferredColorScheme(.light)
        .navigationDestination(isPresented: $goToCheckout) {
            PrayerCheckoutView(
                intention: intention,
                location: location,
                hebrewName: hebrewName.isEmpty ? "Tu nombre" : hebrewName,
                mothersName: mothersName,
                prayerText: generatedText,
                durationLabel: "30 minutos",
                audioLanguage: selectedLanguage
            )
        }
    }

    // MARK: - Indicador de pasos

    private var stepIndicatorDots: some View {
        let activeIndex = step == .personalDetails ? 0 : 1
        return VStack(spacing: 8) {
            HStack(spacing: 8) {
                ForEach(0 ..< 2, id: \.self) { i in
                    let on = i <= activeIndex
                    Capsule()
                        .fill(on
                              ? LinearGradient(colors: [goldAccent, goldMid], startPoint: .leading, endPoint: .trailing)
                              : LinearGradient(colors: [Color.gray.opacity(0.2), Color.gray.opacity(0.12)], startPoint: .leading, endPoint: .trailing))
                        .frame(height: 5)
                        .frame(maxWidth: .infinity)
                }
            }
            Text(step == .personalDetails
                 ? TefilaCopy.choose("Paso 1 de 2 · Tus datos", "Step 1 of 2 · Your details", "שלב 1 מתוך 2 · פרטים")
                 : TefilaCopy.choose("Paso 2 de 2 · Idioma y crear", "Step 2 of 2 · Language & create", "שלב 2 מתוך 2 · שפה ויצירה"))
                .font(.system(size: 12.5, weight: .semibold))
                .foregroundStyle(navyInk.opacity(0.62))
                .frame(maxWidth: .infinity)
        }
        .padding(.bottom, 4)
    }

    /// Resumen compacto en el segundo paso (sin repetir el bloque largo).
    private var compactSummaryForStepTwo: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(goldAccent.opacity(0.18))
                    .frame(width: 44, height: 44)
                Image(systemName: intention.sfSymbol)
                    .font(.system(size: 19, weight: .semibold))
                    .foregroundStyle(LinearGradient(colors: [goldAccent, goldDeep], startPoint: .topLeading, endPoint: .bottomTrailing))
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(intention.title)
                    .font(.system(size: 15, weight: .bold, design: .serif))
                    .foregroundStyle(navyInk)
                Text(location.displayName)
                    .font(.system(size: 12.5, weight: .semibold))
                    .foregroundStyle(navyInk.opacity(0.68))
                    .lineLimit(2)
            }
            Spacer(minLength: 6)
            Text(intention.hebrewKeyword)
                .font(.system(size: 16, weight: .bold, design: .serif))
                .foregroundStyle(goldMid)
                .environment(\.layoutDirection, .rightToLeft)
        }
        .padding(16)
        .background { formGlassCard() }
    }

    // MARK: - Barra inferior fija

    private var bottomBar: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(Color.black.opacity(0.06))
                .frame(height: 1)

            VStack(spacing: 10) {
                switch step {
                case .personalDetails:
                    insetPrimaryButton(title: TefilaCopy.choose("Siguiente", "Next", "הבא"), subtitle: nil, showProgress: false, systemImage: "chevron.right", iconTrailing: true) {
                        focusedField = nil
                        withAnimation(.easeInOut(duration: 0.22)) {
                            step = .audioAndCreate
                        }
                    }

                case .audioAndCreate:
                    if generatedText.isEmpty {
                        insetPrimaryButton(
                            title: isGenerating ? TefilaCopy.choose("Creando tu tefilá…", "Creating your prayer…", "יוצרים תפילה…") : TefilaCopy.choose("Crear mi tefilá", "Create my prayer", "צור את התפילה שלי"),
                            subtitle: TefilaCopy.choose("Primero elige el idioma del audio.", "Pick the audio language first.", "בחר תחילה את שפת השמע."),
                            showProgress: isGenerating,
                            systemImage: "wand.and.stars",
                            iconTrailing: false
                        ) {
                            generatePrayer()
                        }
                        .disabled(isGenerating)
                    } else {
                        insetPrimaryButton(
                            title: TefilaCopy.choose("Finalizar mi tefilá · $9.00", "Finish my prayer · $9.00", "לסיים · ‎$9‎"),
                            subtitle: TefilaCopy.choose("Continúas al siguiente paso de pago.", "Continue to checkout.", "המשך לתשלום."),
                            showProgress: false,
                            systemImage: "star.of.david.fill",
                            iconTrailing: false
                        ) {
                            goToCheckout = true
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
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

    private func insetPrimaryButton(
        title: String,
        subtitle: String?,
        showProgress: Bool,
        systemImage: String,
        iconTrailing: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            VStack(spacing: 6) {
                HStack(spacing: 8) {
                    if showProgress {
                        ProgressView()
                            .progressViewStyle(.circular)
                            .tint(navyInk)
                            .scaleEffect(0.9)
                    }
                    if !showProgress && !iconTrailing {
                        Image(systemName: systemImage)
                            .font(.system(size: 15, weight: .bold))
                    }
                    Text(title)
                        .font(.system(size: 16, weight: .bold))
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .minimumScaleFactor(0.88)
                    if !showProgress && iconTrailing {
                        Image(systemName: systemImage)
                            .font(.system(size: 14, weight: .bold))
                    }
                }
                if let subtitle, !subtitle.isEmpty {
                    Text(subtitle)
                        .font(.system(size: 11.5, weight: .semibold))
                        .foregroundStyle(navyInk.opacity(0.58))
                        .multilineTextAlignment(.center)
                }
            }
            .foregroundStyle(navyInk)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
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
                    .shadow(color: goldDeep.opacity(0.42), radius: 12, x: 0, y: 5)
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: - Header

    private var formHeader: some View {
        VStack(spacing: 8) {
            Text("Personaliza tu tefilá")
                .font(.system(size: 24, weight: .bold, design: .serif))
                .foregroundStyle(navyInk)

            Text("Cada detalle hace tu oración más poderosa y personal.")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(navyInk.opacity(0.76))
                .multilineTextAlignment(.center)
        }
        .padding(.top, 10)
        .multilineTextAlignment(.center)
    }

    // MARK: - Resumen de intención

    private var intentionSummaryCard: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(goldAccent.opacity(0.15))
                    .frame(width: 46, height: 46)
                Image(systemName: intention.sfSymbol)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(LinearGradient(colors: [goldAccent, goldDeep], startPoint: .topLeading, endPoint: .bottomTrailing))
            }
            VStack(alignment: .leading, spacing: 3) {
                Text(intention.title)
                    .font(.system(size: 16, weight: .bold, design: .serif))
                    .foregroundStyle(navyInk)
                Text(location.displayName)
                    .font(.system(size: 12.5, weight: .semibold))
                    .foregroundStyle(navyInk.opacity(0.72))
                    .lineLimit(2)
            }
            Spacer()
            Text(intention.hebrewKeyword)
                .font(.system(size: 18, weight: .bold, design: .serif))
                .foregroundStyle(goldMid)
                .environment(\.layoutDirection, .rightToLeft)
        }
        .padding(16)
        .background { formGlassCard() }
    }

    // MARK: - Nombres

    private var hebrewNameSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionLabel(icon: "person.fill", text: "Nombre hebreo")

            formField(
                placeholder: "Ej: Yosef ben Sarah",
                hint: "Nombre hebreo · ben/bat · nombre de la madre",
                text: $hebrewName,
                field: .hebrewName
            )

            formField(
                placeholder: "Nombre de la madre (opcional)",
                hint: "Ejemplo: Sarah, Rivka, Leah",
                text: $mothersName,
                field: .mothersName
            )
        }
        .padding(18)
        .background { formGlassCard() }
    }

    // MARK: - Petición personal

    private var personalNoteSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionLabel(icon: "text.quote", text: "Petición personal")

            ZStack(alignment: .topLeading) {
                if personalNote.isEmpty {
                    Text("Ej: Por sanación, paz y fortaleza espiritual...")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(navyInk.opacity(0.5))
                        .padding(.top, 12)
                        .padding(.leading, 4)
                        .allowsHitTesting(false)
                }
                TextEditor(text: $personalNote)
                    .font(.system(size: 14.5, weight: .medium))
                    .foregroundStyle(navyInk)
                    .frame(minHeight: 100)
                    .scrollContentBackground(.hidden)
                    .background(Color.clear)
                    .focused($focusedField, equals: .personalNote)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color.white.opacity(0.97))
                    .overlay {
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .strokeBorder(focusedField == .personalNote ? goldMid.opacity(0.85) : navyInk.opacity(0.16), lineWidth: 1)
                    }
            }

            Text("IMPORTANTE: Usamos lenguaje judío — Hashem, tefilá, berajá, emuná, Torá.")
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(navyInk.opacity(0.74))
        }
        .padding(18)
        .background { formGlassCard() }
    }

    // MARK: - Idioma

    private var languageSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionLabel(icon: "globe", text: "Idioma del audio")

            HStack(spacing: 10) {
                ForEach(PrayerLanguage.allCases, id: \.self) { lang in
                    languagePill(lang)
                }
            }
        }
        .padding(18)
        .background { formGlassCard() }
    }

    private func languagePill(_ lang: PrayerLanguage) -> some View {
        let isOn = selectedLanguage == lang
        return Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                selectedLanguage = lang
            }
        } label: {
            Text(lang.label)
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(isOn ? .white : navyInk.opacity(0.92))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background {
                    Capsule(style: .continuous)
                        .fill(isOn
                              ? LinearGradient(colors: [goldAccent, goldMid], startPoint: .leading, endPoint: .trailing)
                              : LinearGradient(colors: [Color.white.opacity(0.98), Color.white.opacity(0.92)], startPoint: .top, endPoint: .bottom))
                        .shadow(color: isOn ? goldDeep.opacity(0.32) : .black.opacity(0.06), radius: isOn ? 6 : 4, x: 0, y: 3)
                        .overlay {
                            if !isOn {
                                Capsule(style: .continuous)
                                    .strokeBorder(navyInk.opacity(0.15), lineWidth: 1)
                            }
                        }
                }
        }
        .buttonStyle(.plain)
    }

    // MARK: - Tefilá generada (solo lectura; el CTA está en la barra inferior)

    private var generatedPrayerPreviewCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "sparkles")
                    .font(.system(size: 14))
                    .foregroundStyle(purple)
                Text("Tu tefilá personalizada")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(purple)
            }

            Text(generatedText)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(navyInk.opacity(0.9))
                .fixedSize(horizontal: false, vertical: true)
                .lineSpacing(5)

            Text(TefilaCopy.choose(
                "Revisa el texto. Para seguir, usa el botón dorado de abajo.",
                "Review the text. Use the gold button below to continue.",
                "עיין בטקסט. המשך בלחיצה על הכפתור הזהוב למטה."
            ))
            .font(.system(size: 12, weight: .semibold))
            .foregroundStyle(navyInk.opacity(0.68))
            .fixedSize(horizontal: false, vertical: true)
        }
        .padding(18)
        .background {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.white.opacity(0.96))
                .overlay {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .strokeBorder(
                            LinearGradient(colors: [purple.opacity(0.45), goldMid.opacity(0.35)], startPoint: .topLeading, endPoint: .bottomTrailing),
                            lineWidth: 1.5
                        )
                }
                .shadow(color: purple.opacity(0.1), radius: 12, x: 0, y: 6)
        }
    }

    // MARK: - Generate mock prayer

    private func generatePrayer() {
        focusedField = nil
        isGenerating = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) {
            generatedText = TefilaMockGenerator.generate(
                hebrewName: hebrewName,
                mothersName: mothersName,
                intention: intention,
                location: location,
                personalNote: personalNote
            )
            isGenerating = false
        }
    }

    // MARK: - Helpers

    /// Fondo de tarjeta legible sobre el cielo del asset (antes era `.clear` y no se veía nada).
    private func formGlassCard() -> some View {
        RoundedRectangle(cornerRadius: 20, style: .continuous)
            .fill(Color.white.opacity(0.94))
            .overlay {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.55), lineWidth: 1)
            }
            .shadow(color: Color.black.opacity(0.09), radius: 16, x: 0, y: 6)
    }

    private func sectionLabel(icon: String, text: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(goldMid)
            Text(text)
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(navyInk)
        }
    }

    private func formField(placeholder: String, hint: String, text: Binding<String>, field: FormField) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            TextField(placeholder, text: text)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(navyInk)
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color.white.opacity(0.98))
                        .overlay {
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .strokeBorder(focusedField == field ? goldMid.opacity(0.85) : navyInk.opacity(0.16), lineWidth: 1)
                        }
                }
                .focused($focusedField, equals: field)

            Text(hint)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(navyInk.opacity(0.68))
                .padding(.leading, 4)
        }
    }
}

// MARK: - Prayer language

enum PrayerLanguage: String, CaseIterable {
    case spanish = "español"
    case english = "english"
    case hebrew  = "עברית"

    var label: String {
        switch self {
        case .spanish: return "Español"
        case .english: return "English"
        case .hebrew:  return "עברית"
        }
    }
}

#Preview {
    NavigationStack {
        PrayerRequestFormView(
            intention: MockIntentions.all[0],
            location: .kotel
        )
    }
}
