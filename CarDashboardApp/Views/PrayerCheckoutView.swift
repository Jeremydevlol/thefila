import SwiftUI

// MARK: - PrayerCheckoutView

struct PrayerCheckoutView: View {
    let intention: PrayerIntention
    let location: SacredLocation
    let hebrewName: String
    let mothersName: String
    let prayerText: String
    let durationLabel: String

    @Environment(\.dismiss) private var dismiss
    @State private var goToAudio: Bool = false

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
            Color.white.opacity(0.20).ignoresSafeArea().allowsHitTesting(false)

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 18) {
                    checkoutHeader
                    summaryCard
                    paymentMethodsCard
                    securityRow
                    trustBadges
                    termsRow
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
                        Text("Mis oraciones").font(.system(size: 16, weight: .medium))
                    }
                    .foregroundStyle(goldAccent)
                }
            }
        }
        .toolbarBackground(.hidden, for: .navigationBar)
        .environment(\.colorScheme, .light)
        .preferredColorScheme(.light)
        .navigationDestination(isPresented: $goToAudio) {
            PrayerAudioView(
                intention: intention,
                location: location,
                hebrewName: hebrewName,
                prayerText: prayerText
            )
        }
    }

    // MARK: - Header

    private var checkoutHeader: some View {
        VStack(spacing: 10) {
            // Logo
            Group {
                if let _ = UIImage(named: "TefilaLogo") {
                    Image("TefilaLogo").resizable().scaledToFit().frame(height: 40)
                } else {
                    Image(systemName: "music.note").font(.system(size: 28, weight: .bold)).foregroundStyle(goldAccent)
                }
            }
            .padding(.top, 14)

            Text("Finalizar tefilá")
                .font(.system(size: 26, weight: .bold, design: .serif))
                .foregroundStyle(navyInk)

            Text("Tu oración será recitada\nen un lugar sagrado.")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(navyInk.opacity(0.62))
                .multilineTextAlignment(.center)

            // Separador dorado
            HStack(spacing: 8) {
                Capsule().fill(goldMid.opacity(0.5)).frame(width: 36, height: 1.5)
                Image(systemName: "star.of.david.fill").font(.system(size: 9)).foregroundStyle(goldMid)
                Capsule().fill(goldMid.opacity(0.5)).frame(width: 36, height: 1.5)
            }
        }
    }

    // MARK: - Summary card

    private var summaryCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Cabecera de la card con cinta
            HStack(alignment: .center, spacing: 14) {
                // Cinta morada con Maguén
                ZStack {
                    PassageRibbonShape()
                        .fill(LinearGradient(colors: [purple, purple.opacity(0.75)], startPoint: .top, endPoint: .bottom))
                        .overlay { PassageRibbonShape().stroke(Color.white.opacity(0.35), lineWidth: 0.75) }
                        .shadow(color: purple.opacity(0.4), radius: 4, x: 0, y: 2)
                    Image(systemName: "star.of.david.fill")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(LinearGradient(colors: [goldAccent, goldDeep], startPoint: .top, endPoint: .bottom))
                        .offset(y: -6)
                }
                .frame(width: 32, height: 68)

                VStack(alignment: .leading, spacing: 4) {
                    Text(intention.title)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(goldMid)
                    Text(prayerText.isEmpty ? "Tefilá personalizada" : intention.title)
                        .font(.system(size: 20, weight: .bold, design: .serif))
                        .foregroundStyle(navyInk)
                        .lineLimit(2)
                }
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 12)

            Divider().padding(.horizontal, 16).opacity(0.15)

            // Chips: location / duration / name
            HStack(spacing: 0) {
                CheckoutChip(icon: location.systemIcon, label: location.displayName.components(separatedBy: " ").prefix(2).joined(separator: " "), color: location.accentColor)
                Divider().frame(height: 36).opacity(0.2)
                CheckoutChip(icon: "clock", label: durationLabel, color: goldMid)
                Divider().frame(height: 36).opacity(0.2)
                CheckoutChip(icon: "person", label: hebrewName.isEmpty ? "Tu nombre" : String(hebrewName.prefix(16)), color: navyInk.opacity(0.65))
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 4)

            Divider().padding(.horizontal, 16).opacity(0.15)

            // Resumen
            VStack(alignment: .leading, spacing: 0) {
                Text("Resumen")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(navyInk)
                    .padding(.bottom, 12)

                summaryRow(label: "Tefilá seleccionada", value: intention.title)
                summaryRow(label: "Lugar de recitado", value: location.displayName.components(separatedBy: "·").first?.trimmingCharacters(in: .whitespaces) ?? location.displayName)
                summaryRow(label: "Duración estimada", value: durationLabel)

                Divider().padding(.vertical, 10).opacity(0.2)

                HStack {
                    Text("Total")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(navyInk)
                    Spacer()
                    Text("$9.00")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundStyle(goldMid)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 14)
            .padding(.bottom, 18)
        }
        .background {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(.white.opacity(0.94))
                .overlay {
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.8), lineWidth: 1)
                }
                .shadow(color: .black.opacity(0.08), radius: 14, x: 0, y: 7)
        }
    }

    private func summaryRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 13.5, weight: .medium))
                .foregroundStyle(navyInk.opacity(0.55))
            Spacer()
            Text(value)
                .font(.system(size: 13.5, weight: .semibold))
                .foregroundStyle(navyInk)
                .multilineTextAlignment(.trailing)
                .lineLimit(1)
        }
        .padding(.vertical, 4)
    }

    // MARK: - Payment methods

    private var paymentMethodsCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Método de pago")
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(navyInk)

            // Apple Pay (mock — navega a audio)
            Button { goToAudio = true } label: {
                HStack {
                    Image(systemName: "applelogo")
                        .font(.system(size: 16, weight: .semibold))
                    Text("Pay")
                        .font(.system(size: 18, weight: .semibold))
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .opacity(0.6)
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .background {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color.black)
                }
            }
            .buttonStyle(.plain)

            // Credit card (mock)
            Button { goToAudio = true } label: {
                paymentRow(icon: "creditcard.fill", label: "Tarjeta de crédito o débito", dark: false)
            }
            .buttonStyle(.plain)
        }
        .padding(18)
        .background(whiteCard)
    }

    private func paymentRow(icon: String, label: String, dark: Bool) -> some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(dark ? .white : navyInk.opacity(0.7))
            Text(label)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(dark ? .white : navyInk)
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(dark ? .white.opacity(0.6) : navyInk.opacity(0.35))
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 15)
        .background {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(dark ? Color.black : Color.white)
                .overlay {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .strokeBorder(dark ? Color.clear : Color.black.opacity(0.12), lineWidth: 1)
                }
        }
    }

    // MARK: - Security

    private var securityRow: some View {
        HStack(spacing: 6) {
            Image(systemName: "lock.fill")
                .font(.system(size: 12))
                .foregroundStyle(goldMid)
            Text("Pago 100% seguro y encriptado")
                .font(.system(size: 12.5, weight: .medium))
                .foregroundStyle(navyInk.opacity(0.55))
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Trust badges

    private var trustBadges: some View {
        HStack(spacing: 0) {
            CheckoutTrustBadge(icon: "checkmark.shield.fill", title: "Privacidad", subtitle: "Tu nombre hebreo\nestá protegido.", color: goldMid)
            CheckoutTrustBadge(icon: "scroll.fill",           title: "Tefilá auténtica", subtitle: "Recitado por rabinos\ny estudiosos reales.", color: goldMid)
            CheckoutTrustBadge(icon: "building.columns.fill", title: "Lugares sagrados", subtitle: "Kotel, Tzfat, Uman\ny más.", color: goldMid)
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 8)
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

    // MARK: - Terms

    private var termsRow: some View {
        HStack(spacing: 6) {
            Image(systemName: "person.fill.checkmark")
                .font(.system(size: 11))
                .foregroundStyle(navyInk.opacity(0.4))
            Group {
                Text("Al continuar, aceptas nuestros ")
                    .foregroundStyle(navyInk.opacity(0.5))
                + Text("Términos y Condiciones")
                    .foregroundStyle(goldMid)
            }
            .font(.system(size: 11.5, weight: .medium))
        }
        .frame(maxWidth: .infinity)
        .multilineTextAlignment(.center)
    }

    private var whiteCard: some ShapeStyle { .clear }
}

// MARK: - Checkout chip

private struct CheckoutChip: View {
    let icon: String
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(color)
            Text(label)
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(Color(red: 42/255, green: 58/255, blue: 98/255).opacity(0.65))
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
    }
}

// MARK: - Checkout trust badge

private struct CheckoutTrustBadge: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color

    var body: some View {
        VStack(spacing: 5) {
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
        PrayerCheckoutView(
            intention: MockIntentions.all[0],
            location: .kotel,
            hebrewName: "Yosef ben Sarah",
            mothersName: "Sarah",
            prayerText: "Que Hashem escuche...",
            durationLabel: "30 minutos"
        )
    }
}
