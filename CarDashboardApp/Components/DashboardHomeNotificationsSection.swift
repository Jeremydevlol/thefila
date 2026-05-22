import SwiftUI

/// Resumen en Inicio (Tefila): tarjeta blanca elevada, tipografía oscura.
struct DashboardHomeClinicInsightSection: View {
    @ObservedObject var stats: DealershipStatsViewModel
    /// Pulsación en la tarjeta (p. ej. abrir informes).
    var onTap: (() -> Void)? = nil

    private let corner: CGFloat = 22

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .center, spacing: 14) {
                ZStack {
                    TranslucentWhiteRoundedChrome(cornerRadius: 16)
                        .frame(width: 72, height: 88)

                    Image("AppLogo")
                        .renderingMode(.original)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 52, height: 52)
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text("Tefila")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Color.black.opacity(0.45))

                    Text("Pulso de tu clínica")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(Color.black)

                    Text("Ingresos estimados · \(stats.periodDisplayLabel)")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(Color.black.opacity(0.52))
                        .lineLimit(2)

                    HStack(alignment: .lastTextBaseline, spacing: 8) {
                        Text(stats.totalStockValue)
                            .font(.system(size: 26, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.black)

                        Spacer(minLength: 8)

                        ClinicInsightTrendPill(text: stats.totalStockBadge.trimmingCharacters(in: .whitespaces), positive: true)
                    }
                    .padding(.top, 2)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(16)
            .background {
                DashboardChromeCardBackground(cornerRadius: corner)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(Rectangle())
        .onTapGesture {
            onTap?()
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Tefila, pulso de tu clínica, ingresos estimados \(stats.totalStockValue)")
        .accessibilityAddTraits(onTap != nil ? .isButton : [])
    }
}

// MARK: - Pastilla tendencia (blanco elevado)

private struct ClinicInsightTrendPill: View {
    let text: String
    let positive: Bool

    var body: some View {
        HStack(spacing: 5) {
            Text(text.isEmpty ? "· estable" : text)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Color.black.opacity(0.72))

            Image(systemName: positive ? "arrow.up.right.circle.fill" : "minus.circle.fill")
                .font(.system(size: 20))
                .foregroundStyle(positive ? PremiumAccent.mint : Color.black.opacity(0.35))
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 7)
        .background {
            TranslucentWhitePillChrome()
        }
    }
}

#Preview {
    ScrollView {
        DashboardHomeClinicInsightSection(stats: DealershipStatsViewModel())
            .padding()
    }
    .background(Color(white: 0.92))
}
