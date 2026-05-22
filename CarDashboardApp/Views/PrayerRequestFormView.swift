import SwiftUI

// MARK: - PrayerRequestFormView

struct PrayerRequestFormView: View {
    let intention: PrayerIntention
    let location: SacredLocation

    @Environment(\.dismiss) private var dismiss
    @FocusState private var focusedField: FormField?

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
                .resizable().scaledToFill().ignoresSafeArea()
                .accessibilityIgnoresInvertColors(true)
            Color.white.opacity(0.22).ignoresSafeArea().allowsHitTesting(false)

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 18) {
                    formHeader
                    intentionSummaryCard
                    hebrewNameSection
                    personalNoteSection
                    languageSection

                    if !generatedText.isEmpty {
                        generatedPrayerCard
                    }

                    generateButton
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
                        Text("Intención").font(.system(size: 16, weight: .medium))
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
                durationLabel: "30 minutos"
            )
        }
    }

    // MARK: - Header

    private var formHeader: some View {
        VStack(spacing: 8) {
            Text("Personaliza tu tefilá")
                .font(.system(size: 24, weight: .bold, design: .serif))
                .foregroundStyle(navyInk)

            Text("Cada detalle hace tu oración más poderosa y personal.")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(navyInk.opacity(0.6))
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
                    .font(.system(size: 12.5, weight: .medium))
                    .foregroundStyle(navyInk.opacity(0.55))
                    .lineLimit(1)
            }
            Spacer()
            Text(intention.hebrewKeyword)
                .font(.system(size: 18, weight: .bold, design: .serif))
                .foregroundStyle(goldMid)
                .environment(\.layoutDirection, .rightToLeft)
        }
        .padding(16)
        .background(whiteCard)
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
        .background(whiteCard)
    }

    // MARK: - Petición personal

    private var personalNoteSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionLabel(icon: "text.quote", text: "Petición personal")

            ZStack(alignment: .topLeading) {
                if personalNote.isEmpty {
                    Text("Ej: Por sanación, paz y fortaleza espiritual...")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(navyInk.opacity(0.35))
                        .padding(.top, 12)
                        .padding(.leading, 4)
                        .allowsHitTesting(false)
                }
                TextEditor(text: $personalNote)
                    .font(.system(size: 14.5, weight: .medium))
                    .foregroundStyle(navyInk)
                    .frame(minHeight: 90)
                    .scrollContentBackground(.hidden)
                    .background(Color.clear)
                    .focused($focusedField, equals: .personalNote)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(navyInk.opacity(0.04))
                    .overlay {
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .strokeBorder(focusedField == .personalNote ? goldMid.opacity(0.7) : navyInk.opacity(0.12), lineWidth: 1)
                    }
            }

            Text("IMPORTANTE: Usamos lenguaje judío — Hashem, tefilá, berajá, emuná, Torá.")
                .font(.system(size: 10.5, weight: .medium))
                .foregroundStyle(navyInk.opacity(0.4))
                .italic()
        }
        .padding(18)
        .background(whiteCard)
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
        .background(whiteCard)
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
                .foregroundStyle(isOn ? .white : navyInk.opacity(0.65))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background {
                    Capsule(style: .continuous)
                        .fill(isOn
                              ? LinearGradient(colors: [goldAccent, goldMid], startPoint: .leading, endPoint: .trailing)
                              : LinearGradient(colors: [Color.white.opacity(0.8), Color.white.opacity(0.6)], startPoint: .leading, endPoint: .trailing))
                        .shadow(color: isOn ? goldDeep.opacity(0.3) : .clear, radius: 6, x: 0, y: 3)
                }
        }
        .buttonStyle(.plain)
    }

    // MARK: - Tefilá generada

    private var generatedPrayerCard: some View {
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
                .foregroundStyle(navyInk.opacity(0.82))
                .fixedSize(horizontal: false, vertical: true)
                .lineSpacing(4)

            // Continuar a checkout
            Button {
                goToCheckout = true
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "star.of.david.fill")
                        .font(.system(size: 14, weight: .bold))
                    Text("Finalizar mi tefilá · $9.00")
                        .font(.system(size: 16, weight: .bold))
                }
                .foregroundStyle(navyInk)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 15)
                .background {
                    Capsule(style: .continuous)
                        .fill(LinearGradient(
                            stops: [
                                .init(color: Color(red: 1, green: 0.93, blue: 0.72), location: 0),
                                .init(color: goldAccent, location: 0.45),
                                .init(color: goldMid, location: 1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                        .shadow(color: goldDeep.opacity(0.45), radius: 12, x: 0, y: 6)
                }
            }
            .buttonStyle(.plain)
            .padding(.top, 4)
        }
        .padding(18)
        .background {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(purple.opacity(0.06))
                .overlay {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .strokeBorder(purple.opacity(0.25), lineWidth: 1.5)
                }
                .shadow(color: purple.opacity(0.08), radius: 10, x: 0, y: 5)
        }
    }

    // MARK: - Generar button

    private var generateButton: some View {
        Button {
            generatePrayer()
        } label: {
            HStack(spacing: 8) {
                if isGenerating {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .tint(navyInk)
                        .scaleEffect(0.85)
                } else {
                    Image(systemName: "wand.and.stars")
                        .font(.system(size: 15, weight: .semibold))
                }
                Text(isGenerating ? "Creando tu tefilá..." : "Crear mi tefilá")
                    .font(.system(size: 17, weight: .bold))
            }
            .foregroundStyle(navyInk)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background {
                Capsule(style: .continuous)
                    .fill(LinearGradient(
                        stops: [
                            .init(color: Color(red: 1, green: 0.93, blue: 0.72), location: 0),
                            .init(color: goldAccent, location: 0.45),
                            .init(color: goldMid, location: 1)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .shadow(color: goldDeep.opacity(0.4), radius: 12, x: 0, y: 6)
            }
        }
        .buttonStyle(.plain)
        .disabled(isGenerating)
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

    private var whiteCard: some ShapeStyle { .clear }

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
                        .fill(navyInk.opacity(0.04))
                        .overlay {
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .strokeBorder(focusedField == field ? goldMid.opacity(0.7) : navyInk.opacity(0.12), lineWidth: 1)
                        }
                }
                .focused($focusedField, equals: field)

            Text(hint)
                .font(.system(size: 10.5, weight: .medium))
                .foregroundStyle(navyInk.opacity(0.38))
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
