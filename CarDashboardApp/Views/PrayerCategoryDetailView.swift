import SwiftUI

// MARK: - Vista de detalle de categoría espiritual (ej. "ÉXITO")

struct PrayerCategoryDetailView: View {
    let category: SpiritualCategoryID

    @Environment(\.dismiss) private var dismiss

    private let goldAccent  = Color(red: 236 / 255, green: 196 / 255, blue: 95 / 255)
    private let goldMid     = Color(red: 219 / 255, green: 175 / 255, blue: 75 / 255)
    private let navyInk     = Color(red: 42 / 255, green: 58 / 255, blue: 98 / 255)

    private var services: [PrayerService] {
        PrayerServiceCatalog.services(for: category.rawValue)
    }

    var body: some View {
        ZStack {
            TefilaSpiritualFondoBackdrop(lightVeilOpacity: 0.30)

            VStack(spacing: 0) {
                // ── Encabezado ──────────────────────────────────────────────
                categoryHeader

                // ── Lista de servicios ───────────────────────────────────────
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 12) {
                        ForEach(services) { service in
                            NavigationLink {
                                PrayerServiceDetailView(service: service, category: category)
                            } label: {
                                ServiceRowCard(service: service)
                            }
                            .buttonStyle(.plain)
                        }

                        if services.isEmpty {
                            emptyState
                        }
                    }
                    .padding(.horizontal, 18)
                    .padding(.top, 16)
                    .padding(.bottom, 40)
                }
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 14, weight: .semibold))
                        Text(TefilaCopy.choose("Inicio", "Home", "בית"))
                            .font(.system(size: 16, weight: .medium))
                    }
                    .foregroundStyle(goldAccent)
                }
            }
            .sharedBackgroundVisibility(.hidden)
        }
        .toolbarBackground(.hidden, for: .navigationBar)
        .environment(\.colorScheme, .light)
        .preferredColorScheme(.light)
    }

    // MARK: - Encabezado de categoría

    private var categoryHeader: some View {
        VStack(spacing: 8) {
            // Ícono Tefila (símbolo musical dorado)
            Image("TefilaLogo")
                .resizable()
                .scaledToFit()
                .frame(height: 48)
                .padding(.top, 12)

            // Nombre de la categoría en mayúsculas tipo "ÉXITO"
            Text(category.headline.uppercased())
                .font(.system(size: 28, weight: .bold, design: .serif))
                .foregroundStyle(navyInk)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)

            // Separador dorado
            HStack(spacing: 8) {
                Capsule()
                    .fill(goldMid.opacity(0.6))
                    .frame(width: 40, height: 1.5)
                Image(systemName: "sparkle")
                    .font(.system(size: 10))
                    .foregroundStyle(goldMid)
                Capsule()
                    .fill(goldMid.opacity(0.6))
                    .frame(width: 40, height: 1.5)
            }
            .padding(.bottom, 8)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 4)
    }

    // MARK: - Estado vacío

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "book.closed.fill")
                .font(.system(size: 38))
                .foregroundStyle(goldAccent.opacity(0.7))
            Text(TefilaCopy.choose(
                "Próximamente nuevos servicios",
                "New services coming soon",
                "שירותים חדשים בקרוב"
            ))
            .font(.system(size: 16, weight: .semibold, design: .serif))
            .foregroundStyle(navyInk.opacity(0.7))
            .multilineTextAlignment(.center)
        }
        .padding(.top, 60)
    }
}

// MARK: - Tarjeta de fila de servicio (estilo screenshots)

private struct ServiceRowCard: View {
    let service: PrayerService

    private let navyInk   = Color(red: 42 / 255, green: 58 / 255, blue: 98 / 255)
    private let goldTop   = Color(red: 236 / 255, green: 196 / 255, blue: 95 / 255)
    private let goldDeep  = Color(red: 172 / 255, green: 128 / 255, blue: 44 / 255)

    var body: some View {
        HStack(spacing: 14) {
            // ── Ícono izquierdo (círculo con fondo) ──────────────────────────
            ZStack {
                Circle()
                    .fill(service.iconColor.opacity(0.12))
                    .frame(width: 52, height: 52)
                    .overlay {
                        Circle()
                            .strokeBorder(service.iconColor.opacity(0.25), lineWidth: 1)
                    }
                Image(systemName: service.iconSystemName)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(service.iconColor)
            }

            // ── Texto central ─────────────────────────────────────────────────
            VStack(alignment: .leading, spacing: 4) {
                Text(service.title)
                    .font(.system(size: 15.5, weight: .bold, design: .serif))
                    .foregroundStyle(navyInk)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)

                Text(service.description)
                    .font(.system(size: 12.5, weight: .medium))
                    .foregroundStyle(navyInk.opacity(0.54))
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            // ── Badge dorado + chevron ────────────────────────────────────────
            VStack(spacing: 6) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [goldTop, goldDeep],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 40, height: 40)
                        .shadow(color: goldDeep.opacity(0.4), radius: 6, x: 0, y: 3)

                    Image(systemName: "leaf.fill")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.white.opacity(0.92))
                }

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(navyInk.opacity(0.35))
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 14)
        .background {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(.white.opacity(0.88))
                .overlay {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.7), lineWidth: 1)
                }
                .shadow(color: Color.black.opacity(0.07), radius: 10, x: 0, y: 5)
        }
    }
}

#Preview {
    NavigationStack {
        PrayerCategoryDetailView(category: .hazlacha)
    }
}
