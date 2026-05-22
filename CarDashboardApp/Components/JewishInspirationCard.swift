import SwiftUI

/// Tarjeta «Frase del Tanaj» en la app principal (idioma espiritual judío contemporáneo).
struct JewishInspirationCard: View {
    let phrase: JewishInspirationPhrase
    /// Índice 0‑based opcional para el badge derecho (“día”).
    var badgeCount: Int? = nil

    private var cardBackdropShape: RoundedRectangle {
        RoundedRectangle(cornerRadius: 22, style: .continuous)
    }

    var body: some View {
        ZStack {
            ZStack {
                Image("Palabra", bundle: .main)
                    .renderingMode(.original)
                    .resizable()
                    .scaledToFill()
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                    .blur(radius: 2.75)
                    .overlay(
                        Color.white
                            .opacity(0.085)
                            .allowsHitTesting(false)
                    )
                Rectangle()
                    .fill(Color.black.opacity(0.42))
                    .allowsHitTesting(false)
                Rectangle()
                    .fill(Color.black.opacity(0.06))
                    .allowsHitTesting(false)
            }

            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Image(systemName: "menorah.fill")
                        .foregroundStyle(Color(red: 1, green: 0.92, blue: 0.62))
                        .font(.footnote.weight(.semibold))
                        .shadow(color: Color.black.opacity(0.45), radius: 2)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(TefilaCopy.inspirationCardTitle)
                            .font(.footnote.weight(.semibold))
                            .foregroundStyle(Color.white.opacity(0.94))
                            .shadow(color: Color.black.opacity(0.55), radius: 2)
                        Text(TefilaCopy.inspirationCardTorahAccent)
                            .font(.system(size: 10, weight: .medium))
                            .foregroundStyle(Color.white.opacity(0.55))
                            .shadow(color: Color.black.opacity(0.45), radius: 1)
                    }
                    Spacer(minLength: 0)
                    if let badgeCount {
                        HStack(spacing: 6) {
                            Image(systemName: "sparkle")
                                .font(.caption.weight(.semibold))
                            Text("\(badgeCount)")
                                .font(.caption.monospacedDigit().weight(.medium))
                                .foregroundStyle(Color.white.opacity(0.94))
                                .shadow(color: Color.black.opacity(0.65), radius: 2)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 7)
                        .background(
                            RoundedRectangle(cornerRadius: 17, style: .continuous)
                                .strokeBorder(
                                    Color(red: 0.96, green: 0.84, blue: 0.48).opacity(0.9),
                                    lineWidth: 1.25
                                )
                                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 17, style: .continuous))
                                .overlay(
                                    Color.white.opacity(0.06)
                                        .clipShape(RoundedRectangle(cornerRadius: 17, style: .continuous))
                                )
                        )
                    }
                }
                .padding(.bottom, 16)

                Spacer(minLength: 0)

                Text("“\(phrase.text)”")
                    .font(.system(size: 18, weight: .semibold, design: .serif))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Color.white.opacity(0.94))
                    .shadow(color: Color.black.opacity(0.55), radius: 2)
                    .minimumScaleFactor(0.76)
                    .frame(maxWidth: .infinity)

                if !phrase.attribution.isEmpty {
                    Text(phrase.attribution.uppercased())
                        .font(.caption.weight(.medium))
                        .foregroundStyle(Color.white.opacity(0.78))
                        .multilineTextAlignment(.center)
                        .padding(.top, 10)
                        .shadow(color: Color.black.opacity(0.5), radius: 2)
                        .minimumScaleFactor(0.76)
                        .frame(maxWidth: .infinity)
                }

                Spacer(minLength: 0)
            }
            .padding(18)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 188)
        .clipShape(cardBackdropShape)
        .overlay(
            cardBackdropShape
                .strokeBorder(Color.white.opacity(0.52), lineWidth: 3)
                .blendMode(.screen)
        )
    }
}

#if DEBUG
#Preview("Inspiration card") {
    JewishInspirationCard(
        phrase: JewishPhraseLibrary.phrase(),
        badgeCount: JewishPhraseLibrary.dayOrdinal()
    )
    .padding()
    .background(Color.gray.opacity(0.3))
}
#endif
