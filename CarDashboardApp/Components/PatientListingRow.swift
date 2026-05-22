import SwiftUI

/// Fila de ficha de paciente (cristal elevado, sin imágenes de vehículos).
struct PatientListingRow: View {
    let patient: PatientRecord
    var isSelected: Bool
    var onTap: () -> Void

    private var avatarImage: UIImage? {
        PatientAvatarStore.image(for: patient.id)
    }

    var body: some View {
        Button(action: onTap) {
            HStack(alignment: .center, spacing: 14) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    PremiumAccent.tabActive.opacity(0.35),
                                    PremiumAccent.ice.opacity(0.45),
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 48, height: 48)

                    if let avatarImage {
                        Image(uiImage: avatarImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 48, height: 48)
                            .clipShape(Circle())
                    } else {
                        Text(String(patient.displayName.prefix(1)).uppercased())
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.black.opacity(0.75))
                    }
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(patient.displayName)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Color.black.opacity(0.92))
                        .lineLimit(1)
                    if !patient.email.trimmingCharacters(in: .whitespaces).isEmpty {
                        Text(patient.email)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(Color.black.opacity(0.45))
                            .lineLimit(1)
                    }
                    if !patient.phone.trimmingCharacters(in: .whitespaces).isEmpty {
                        Text(patient.phone)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(Color.black.opacity(0.45))
                            .lineLimit(1)
                    }
                    Text(patient.subtitle)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(Color.black.opacity(0.48))
                        .lineLimit(1)
                    Text(patient.detailLine)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(Color.black.opacity(0.42))
                        .lineLimit(1)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color.black.opacity(0.28))
            }
            .padding(14)
            .background {
                WhiteElevatedCardBackground(cornerRadius: 20)
            }
            .overlay {
                if isSelected {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .strokeBorder(PremiumAccent.tabActive.opacity(0.55), lineWidth: 2)
                }
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    PatientListingRow(
        patient: PatientRecord.samples[0],
        isSelected: true,
        onTap: {}
    )
    .padding()
    .background(Color(white: 0.94))
}
