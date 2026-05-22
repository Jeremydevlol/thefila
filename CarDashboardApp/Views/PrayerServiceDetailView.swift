import SwiftUI

// MARK: - PrayerServiceDetailView (pantalla de detalle de servicio)

struct PrayerServiceDetailView: View {
    let service: PrayerService
    let category: SpiritualCategoryID

    @Environment(\.dismiss) private var dismiss
    @State private var selectedTier: PrayerTier = .standard
    @State private var goToIntention: Bool = false

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
                VStack(spacing: 16) {
                    serviceHeaderCard
                    descriptionCard
                    tierPicker
                    certificateInfo
                    fundsInfo
                    requestButton
                }
                .padding(.horizontal, 18)
                .padding(.bottom, 40)
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
                        Text("Categoría").font(.system(size: 16, weight: .medium))
                    }
                    .foregroundStyle(goldAccent)
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {} label: {
                    Image(systemName: "heart")
                        .font(.system(size: 18))
                        .foregroundStyle(navyInk.opacity(0.5))
                        .frame(width: 36, height: 36)
                        .background(Circle().fill(.white.opacity(0.75)))
                }
            }
        }
        .toolbarBackground(.hidden, for: .navigationBar)
        .environment(\.colorScheme, .light)
        .preferredColorScheme(.light)
        .navigationDestination(isPresented: $goToIntention) {
            ChoosePrayerIntentionView()
        }
    }

    // MARK: - Header card

    private var serviceHeaderCard: some View {
        VStack(spacing: 0) {
            HStack(alignment: .center, spacing: 16) {
                // Ícono
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [goldAccent, goldDeep],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 62, height: 62)
                        .shadow(color: goldDeep.opacity(0.4), radius: 8, x: 0, y: 4)
                    Image(systemName: service.iconSystemName)
                        .font(.system(size: 26, weight: .bold))
                        .foregroundStyle(.white)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(service.eyebrow.uppercased())
                        .font(.system(size: 10.5, weight: .bold))
                        .tracking(0.8)
                        .foregroundStyle(service.iconColor)
                    Text(service.title)
                        .font(.system(size: 20, weight: .bold, design: .serif))
                        .foregroundStyle(navyInk)
                        .lineLimit(3)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer()
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
                // Preview button
                Button {} label: {
                    HStack(spacing: 6) {
                        Image(systemName: "eye.fill")
                            .font(.system(size: 13))
                        Text("Preview")
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

            // Imagen del libro de Tehilim (SF Symbol fallback)
            Image(systemName: "book.closed.fill")
                .font(.system(size: 52))
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(service.iconColor.opacity(0.65))
                .frame(width: 70)
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
                Text("Elija una opción")
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
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            selectedTier = tier
                        }
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

    // MARK: - Request button

    private var requestButton: some View {
        Button {
            goToIntention = true
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "star.of.david.fill")
                    .font(.system(size: 15, weight: .bold))
                Text("Solicitar esta tefilá · $9.00")
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
                    .shadow(color: goldDeep.opacity(0.45), radius: 12, x: 0, y: 6)
                    .overlay {
                        Capsule(style: .continuous)
                            .strokeBorder(
                                LinearGradient(colors: [.white.opacity(0.9), .white.opacity(0.25)], startPoint: .topLeading, endPoint: .bottomTrailing),
                                lineWidth: 1.2
                            )
                    }
            }
        }
        .buttonStyle(.plain)
        .padding(.bottom, 8)
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
