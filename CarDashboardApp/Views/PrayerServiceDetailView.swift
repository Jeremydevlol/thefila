import SwiftUI
import UIKit

// MARK: - PrayerServiceDetailView (pantalla de detalle de servicio)

struct PrayerServiceDetailView: View {
    let service: PrayerService
    let category: SpiritualCategoryID

    @Environment(\.dismiss) private var dismiss
    @State private var selectedTier: PrayerTier = .standard
    @State private var goToIntention: Bool = false
    @State private var showPreviewSheet: Bool = false
    @State private var savedToFavoritesPulse: Bool = false

    private let goldAccent = Color(red: 236/255, green: 196/255, blue: 95/255)
    private let goldMid    = Color(red: 219/255, green: 175/255, blue: 75/255)
    private let goldDeep   = Color(red: 172/255, green: 128/255, blue: 44/255)
    private let navyInk    = Color(red: 42/255, green: 58/255, blue: 98/255)

    var body: some View {
        ZStack {
            TefilaSpiritualFondoBackdrop(lightVeilOpacity: 0.22)

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 16) {
                    serviceHeaderCard
                    descriptionCard
                    tierPicker
                    certificateInfo
                    fundsInfo

                    Color.clear.frame(height: 12)
                }
                .padding(.horizontal, 18)
                .padding(.top, 14)
                .padding(.bottom, 40)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button { dismiss() } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left").font(.system(size: 14, weight: .semibold))
                        Text("Categoría").font(.system(size: 16, weight: .medium))
                    }
                    .foregroundStyle(goldAccent)
                }
            }
            ToolbarItem(placement: .principal) {
                Text(service.title)
                    .font(.system(size: 16, weight: .bold, design: .serif))
                    .foregroundStyle(navyInk)
                    .lineLimit(2)
                    .minimumScaleFactor(0.78)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 220)
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    toggleFavoriteHaptic()
                } label: {
                    ZStack {
                        TranslucentWhiteCircleChrome(size: 38)
                        Image(systemName: savedToFavoritesPulse ? "heart.fill" : "heart")
                            .font(.system(size: 17))
                            .foregroundStyle(savedToFavoritesPulse ? Color(red: 0.82, green: 0.28, blue: 0.38) : navyInk.opacity(0.55))
                    }
                    .shadow(color: .black.opacity(0.06), radius: 4, x: 0, y: 2)
                }
                .accessibilityLabel(savedToFavoritesPulse ? "Quitar de favoritos" : "Guardar en favoritos")
            }
            .sharedBackgroundVisibility(.hidden)
        }
        .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
        .toolbarColorScheme(.light, for: .navigationBar)
        .environment(\.colorScheme, .light)
        .preferredColorScheme(.light)
        .safeAreaInset(edge: .bottom, spacing: 0) {
            stickyRequestBar
        }
        .sheet(isPresented: $showPreviewSheet) {
            servicePreviewSheet
        }
        .navigationDestination(isPresented: $goToIntention) {
            ChoosePrayerIntentionView()
        }
    }

    private func toggleFavoriteHaptic() {
        let gen = UIImpactFeedbackGenerator(style: .medium)
        gen.prepare()
        withAnimation(.spring(response: 0.32, dampingFraction: 0.72)) {
            savedToFavoritesPulse.toggle()
        }
        gen.impactOccurred(intensity: 0.95)
    }

    // MARK: - Header card

    private var serviceHeaderCard: some View {
        VStack(spacing: 0) {
            HStack(alignment: .top, spacing: 14) {
                TefilaBanderaMark(width: 38, height: 74)

                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 8) {
                        Image(systemName: service.iconSystemName)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(service.iconColor)
                        Text(service.eyebrow.uppercased())
                            .font(.system(size: 10.5, weight: .bold))
                            .tracking(0.8)
                            .foregroundStyle(service.iconColor)
                    }

                    Text(service.title)
                        .font(.system(size: 21, weight: .bold, design: .serif))
                        .foregroundStyle(navyInk)
                        .lineLimit(4)
                        .fixedSize(horizontal: false, vertical: true)

                    if !service.hebrewTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        Text(service.hebrewTitle)
                            .font(.system(size: 15, weight: .medium))
                            .foregroundStyle(navyInk.opacity(0.55))
                            .lineLimit(2)
                    }
                }
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 18)
            .padding(.top, 18)
            .padding(.bottom, 14)

            // Separador dorado
            HStack(spacing: 8) {
                Capsule().fill(goldMid.opacity(0.4)).frame(height: 1)
                Image(systemName: "sparkles").font(.system(size: 9)).foregroundStyle(goldMid)
                Capsule().fill(goldMid.opacity(0.4)).frame(height: 1)
            }
            .padding(.horizontal, 18)
            .padding(.bottom, 14)

            // Preview + duración
            HStack(spacing: 14) {
                Button {
                    showPreviewSheet = true
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "eye.fill")
                            .font(.system(size: 13))
                        Text(TefilaCopy.choose("Vista previa", "Preview", "תצוגה מקדימה"))
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .foregroundStyle(goldMid)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 9)
                    .background {
                        Capsule(style: .continuous)
                            .stroke(goldMid.opacity(0.6), lineWidth: 1.2)
                    }
                }
                .buttonStyle(.plain)
                .accessibilityHint("Muestra el texto y la bendición antes de solicitar.")

                Spacer()

                HStack(spacing: 5) {
                    Image(systemName: "clock")
                        .font(.system(size: 13))
                        .foregroundStyle(navyInk.opacity(0.55))
                    Text(service.durationLabel)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(navyInk.opacity(0.55))
                }
            }
            .padding(.horizontal, 18)
            .padding(.bottom, 18)
        }
        .background {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(.white.opacity(0.95))
                .overlay {
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.8), lineWidth: 1)
                }
                .shadow(color: .black.opacity(0.08), radius: 14, x: 0, y: 7)
        }
    }

    // MARK: - Description card

    private var descriptionCard: some View {
        HStack(alignment: .top, spacing: 14) {
            VStack(alignment: .leading, spacing: 8) {
                Text(service.longDescription)
                    .font(.system(size: 14.5, weight: .medium))
                    .foregroundStyle(navyInk.opacity(0.8))
                    .fixedSize(horizontal: false, vertical: true)
                    .lineSpacing(3)

                // Cita espiritual
                VStack(alignment: .leading, spacing: 4) {
                    Text(service.spiritualNote)
                        .font(.system(size: 13, weight: .medium, design: .serif))
                        .foregroundStyle(navyInk.opacity(0.62))
                        .italic()
                        .fixedSize(horizontal: false, vertical: true)
                    Text(service.rabbiSource)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(goldMid)
                }
                .padding(12)
                .background {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(goldAccent.opacity(0.07))
                        .overlay {
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .strokeBorder(goldAccent.opacity(0.25), lineWidth: 1)
                        }
                }
            }

            VStack(spacing: 10) {
                Image(systemName: "book.closed.fill")
                    .font(.system(size: 44))
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(service.iconColor.opacity(0.7))
                    .padding(14)
                    .background {
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(Color.white.opacity(0.72))
                            .overlay {
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .strokeBorder(Color.white.opacity(0.95), lineWidth: 1)
                            }
                            .shadow(color: .black.opacity(0.06), radius: 6, x: 0, y: 3)
                    }

                Image(systemName: "waveform.circle.fill")
                    .font(.system(size: 22))
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(goldMid.opacity(0.85))
                    .accessibilityLabel(TefilaCopy.choose("Audio al continuar el flujo", "Audio continues in flow", "השמעה בהמשך"))
            }
            .frame(width: 84)
        }
        .padding(18)
        .background {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.white.opacity(0.92))
                .overlay {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.75), lineWidth: 1)
                }
                .shadow(color: .black.opacity(0.06), radius: 10, x: 0, y: 5)
        }
    }

    // MARK: - Tier picker (Estándar / Premium)

    private var tierPicker: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Capsule().fill(goldMid.opacity(0.4)).frame(height: 1)
                Text(TefilaCopy.choose(
                    "Elige una opción",
                    "Choose an option",
                    "בחר אפשרות"
                ))
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(navyInk.opacity(0.65))
                    .fixedSize()
                Capsule().fill(goldMid.opacity(0.4)).frame(height: 1)
            }

            HStack(spacing: 10) {
                ForEach(PrayerTier.allCases) { tier in
                    TierOptionButton(
                        tier: tier,
                        isSelected: selectedTier == tier,
                        goldAccent: goldAccent,
                        goldMid: goldMid,
                        navyInk: navyInk
                    ) {
                        let gen = UIImpactFeedbackGenerator(style: .light)
                        gen.prepare()
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.82)) {
                            selectedTier = tier
                        }
                        gen.impactOccurred(intensity: 0.85)
                    }
                }
            }
        }
        .padding(18)
        .background {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color(red: 0.94, green: 0.96, blue: 1.0).opacity(0.88))
                .overlay {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.7), lineWidth: 1)
                }
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
        }
    }

    // MARK: - Certificate info

    private var certificateInfo: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "checkmark.shield.fill")
                .font(.system(size: 22))
                .foregroundStyle(navyInk.opacity(0.55))
            VStack(alignment: .leading, spacing: 3) {
                Text("El recital de oración es ")
                    .font(.system(size: 13.5, weight: .medium))
                    .foregroundStyle(navyInk.opacity(0.7))
                + Text("confirmado")
                    .font(.system(size: 13.5, weight: .bold))
                    .foregroundStyle(navyInk.opacity(0.85))
                + Text(" con un Certificado de finalización enviado por correo electrónico o SMS")
                    .font(.system(size: 13.5, weight: .medium))
                    .foregroundStyle(navyInk.opacity(0.7))
            }
            .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .background {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.white.opacity(0.88))
                .overlay {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.7), lineWidth: 1)
                }
                .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 3)
        }
    }

    // MARK: - Funds info

    private var fundsInfo: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "info.circle")
                .font(.system(size: 16))
                .foregroundStyle(navyInk.opacity(0.4))
            Text("*Los fondos se utilizan para apoyar al Proveedor de Oración y para el mantenimiento de la plataforma.")
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(navyInk.opacity(0.45))
                .italic()
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, 4)
    }

    // MARK: - Barra inferior fija + CTA

    private var stickyRequestBar: some View {
        VStack(spacing: 0) {
            primaryRequestButton
                .padding(.horizontal, 18)
                .padding(.top, 10)
                .padding(.bottom, 10)
        }
        .frame(maxWidth: .infinity)
        .background(.regularMaterial)
        .overlay(alignment: .top) {
            Divider().opacity(0.35)
        }
    }

    private var primaryRequestButton: some View {
        Button {
            let gen = UIImpactFeedbackGenerator(style: .medium)
            gen.prepare()
            gen.impactOccurred(intensity: 0.9)
            goToIntention = true
        } label: {
            HStack(spacing: 12) {
                TefilaBanderaMark(width: 26, height: 48)
                Text(TefilaCopy.choose(
                    "Solicitar esta tefilá · $9.00",
                    "Request this tefilah · $9.00",
                    "לבקש תפלה זו · ‎$9‎"
                ))
                    .font(.system(size: 17, weight: .bold))
            }
            .foregroundStyle(navyInk)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 15)
            .background {
                Capsule(style: .continuous)
                    .fill(
                        LinearGradient(
                            stops: [
                                .init(color: Color(red: 1, green: 0.93, blue: 0.72), location: 0),
                                .init(color: goldAccent, location: 0.45),
                                .init(color: goldMid, location: 1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: goldDeep.opacity(0.42), radius: 12, x: 0, y: 5)
                    .overlay {
                        Capsule(style: .continuous)
                            .strokeBorder(
                                LinearGradient(
                                    colors: [.white.opacity(0.92), .white.opacity(0.22)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1.2
                            )
                    }
            }
        }
        .buttonStyle(.plain)
        .accessibilityHint(TefilaCopy.choose(
            "Continúa para elegir intención y lugar sagrado",
            "Continue to choose intention and sacred site",
            "ממשיכים לבחירת כוונה ומקום קדוש"
        ))
    }

    // MARK: - Vista previa (sheet)

    private var servicePreviewSheet: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 18) {
                    HStack(alignment: .top, spacing: 12) {
                        TefilaBanderaMark(width: 34, height: 72)
                        VStack(alignment: .leading, spacing: 6) {
                            Text(service.title)
                                .font(.system(size: 20, weight: .bold, design: .serif))
                                .foregroundStyle(navyInk)
                            if !service.hebrewTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                Text(service.hebrewTitle)
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundStyle(navyInk.opacity(0.52))
                            }
                        }
                        Spacer(minLength: 0)
                    }

                    HStack(spacing: 10) {
                        Image(systemName: "clock.fill")
                            .foregroundStyle(goldMid)
                        Text(service.durationLabel)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(navyInk.opacity(0.7))
                        Spacer()
                    }

                    Divider().opacity(0.25)

                    Text(service.description)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(navyInk.opacity(0.88))
                        .lineSpacing(3)

                    Text(service.longDescription)
                        .font(.system(size: 14.5, weight: .medium))
                        .foregroundStyle(navyInk.opacity(0.78))
                        .lineSpacing(4)

                    VStack(alignment: .leading, spacing: 6) {
                        Text(service.spiritualNote)
                            .font(.system(size: 14, weight: .medium, design: .serif))
                            .italic()
                            .foregroundStyle(navyInk.opacity(0.68))
                            .fixedSize(horizontal: false, vertical: true)
                        Text(service.rabbiSource)
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(goldMid)
                    }
                    .padding(14)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background {
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(goldAccent.opacity(0.08))
                            .overlay {
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .strokeBorder(goldAccent.opacity(0.22), lineWidth: 1)
                            }
                    }
                }
                .padding(.horizontal, 22)
                .padding(.bottom, 28)
                .padding(.top, 8)
            }
            .navigationTitle(LocalizedStringKey(tefilaDynamic: TefilaCopy.choose("Vista previa", "Preview", "תצוגה מקדימה")))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showPreviewSheet = false
                    } label: {
                        Text(TefilaCopy.choose("Listo", "Done", "סיום"))
                            .fontWeight(.semibold)
                    }
                }
                .sharedBackgroundVisibility(.hidden)
            }
            .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        .presentationCornerRadius(22)
        .preferredColorScheme(.light)
        .environment(\.colorScheme, .light)
    }
}

// MARK: - Tier option button

private struct TierOptionButton: View {
    let tier: PrayerTier
    let isSelected: Bool
    let goldAccent: Color
    let goldMid: Color
    let navyInk: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                // Icon
                ZStack {
                    Circle()
                        .fill(isSelected ? .white.opacity(0.25) : tier.accentColor.opacity(0.12))
                        .frame(width: 30, height: 30)
                    Image(systemName: tier.systemIcon)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(isSelected ? .white : tier.accentColor)
                }
                Text(tier.label)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(isSelected ? .white : navyInk)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background {
                Capsule(style: .continuous)
                    .fill(isSelected
                          ? LinearGradient(colors: [tier.accentColor, tier.accentColor.opacity(0.75)], startPoint: .topLeading, endPoint: .bottomTrailing)
                          : LinearGradient(colors: [.white.opacity(0.85), .white.opacity(0.65)], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .overlay {
                        Capsule(style: .continuous)
                            .strokeBorder(isSelected ? .white.opacity(0.35) : Color.black.opacity(0.1), lineWidth: 1)
                    }
                    .shadow(color: isSelected ? tier.accentColor.opacity(0.35) : .black.opacity(0.06), radius: 6, x: 0, y: 3)
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(tier.label)")
        .accessibilityAddTraits(isSelected ? [.isSelected, .isButton] : [.isButton])
    }
}

#Preview {
    NavigationStack {
        PrayerServiceDetailView(
            service: PrayerServiceCatalog.allServices[0],
            category: .hazlacha
        )
    }
}
