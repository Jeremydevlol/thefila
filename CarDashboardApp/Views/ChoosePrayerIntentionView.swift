import SwiftUI

// MARK: - ChoosePrayerIntentionView

struct ChoosePrayerIntentionView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var selectedIntention: PrayerIntention? = nil
    @State private var selectedLocation: SacredLocation = .kotel
    @State private var showLocationPicker = false
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
                .ignoresSafeArea()
                .accessibilityIgnoresInvertColors(true)
            Color.white.opacity(0.18).ignoresSafeArea().allowsHitTesting(false)

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 0) {
                    // Header
                    intentionHeader
                        .padding(.bottom, 22)

                    // Grid de intenciones
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

                    // Separador
                    HStack {
                        Capsule().fill(goldMid.opacity(0.3)).frame(height: 1)
                    }
                    .padding(.horizontal, 18)
                    .padding(.vertical, 20)

                    // Elegir lugar
                    locationRow
                        .padding(.horizontal, 18)
                        .padding(.bottom, 12)

                    // Info personalización
                    personalizationInfo
                        .padding(.horizontal, 18)
                        .padding(.bottom, 18)

                    // Trust badges
                    trustBadges
                        .padding(.horizontal, 18)
                        .padding(.bottom, 22)

                    // Botón continuar
                    continueButton
                        .padding(.horizontal, 18)
                        .padding(.bottom, 40)
                }
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
        .sheet(isPresented: $showLocationPicker) {
            LocationPickerSheet(selected: $selectedLocation)
        }
        .navigationDestination(isPresented: $goToForm) {
            if let intention = selectedIntention {
                PrayerRequestFormView(
                    intention: intention,
                    location: selectedLocation
                )
            }
        }
    }

    // MARK: - Header

    private var intentionHeader: some View {
        VStack(spacing: 10) {
            // Logo Tefila
            Group {
                if let _ = UIImage(named: "TefilaLogo") {
                    Image("TefilaLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 44)
                } else {
                    Image(systemName: "music.note")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundStyle(goldAccent)
                }
            }
            .padding(.top, 16)

            Text("Elige la intención\nde tu tefilá")
                .font(.system(size: 28, weight: .bold, design: .serif))
                .foregroundStyle(navyInk)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)

            Text("Cada oración es recitada por rabinos\ny estudiosos en lugares sagrados.")
                .font(.system(size: 14, weight: .medium))
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
        .padding(.horizontal, 24)
    }

    // MARK: - Elegir lugar

    private var locationRow: some View {
        Button { showLocationPicker = true } label: {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(goldAccent.opacity(0.15))
                        .frame(width: 44, height: 44)
                    Image(systemName: "location.fill")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(goldMid)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text("Elegir un lugar")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(navyInk)
                    Text(selectedLocation.displayName)
                        .font(.system(size: 12.5, weight: .medium))
                        .foregroundStyle(navyInk.opacity(0.55))
                        .lineLimit(1)
                }
                Spacer()

                HStack(spacing: 6) {
                    Text("\(SacredLocation.allCases.count)")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 24, height: 24)
                        .background(goldMid, in: Circle())

                    Image(systemName: "chevron.right")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(navyInk.opacity(0.4))
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(.white.opacity(0.9))
                    .overlay {
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .strokeBorder(Color.white.opacity(0.75), lineWidth: 1)
                    }
                    .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 4)
            }
        }
        .buttonStyle(.plain)
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

    // MARK: - Continuar

    private var continueButton: some View {
        Button {
            if selectedIntention != nil {
                goToForm = true
            }
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "star.of.david.fill")
                    .font(.system(size: 14, weight: .bold))
                Text("Continuar")
                    .font(.system(size: 17, weight: .bold))
            }
            .foregroundStyle(selectedIntention != nil ? navyInk : navyInk.opacity(0.4))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background {
                Capsule(style: .continuous)
                    .fill(selectedIntention != nil
                          ? LinearGradient(stops: [
                              .init(color: Color(red: 1, green: 0.93, blue: 0.72), location: 0),
                              .init(color: goldAccent, location: 0.45),
                              .init(color: goldMid, location: 1)
                            ], startPoint: .topLeading, endPoint: .bottomTrailing)
                          : LinearGradient(colors: [Color.gray.opacity(0.2), Color.gray.opacity(0.15)], startPoint: .leading, endPoint: .trailing))
                    .shadow(color: selectedIntention != nil ? goldDeep.opacity(0.45) : .clear, radius: 12, x: 0, y: 6)
            }
        }
        .buttonStyle(.plain)
        .disabled(selectedIntention == nil)
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

// MARK: - Location picker sheet

struct LocationPickerSheet: View {
    @Binding var selected: SacredLocation
    @Environment(\.dismiss) private var dismiss

    private let goldMid  = Color(red: 219/255, green: 175/255, blue: 75/255)
    private let navyInk  = Color(red: 42/255, green: 58/255, blue: 98/255)

    var body: some View {
        NavigationStack {
            List {
                ForEach(SacredLocation.allCases) { loc in
                    Button {
                        selected = loc
                        dismiss()
                    } label: {
                        HStack(spacing: 14) {
                            ZStack {
                                Circle()
                                    .fill(loc.accentColor.opacity(0.14))
                                    .frame(width: 40, height: 40)
                                Image(systemName: loc.systemIcon)
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundStyle(loc.accentColor)
                            }
                            VStack(alignment: .leading, spacing: 2) {
                                Text(loc.displayName)
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundStyle(navyInk)
                                Text(loc.subtitle)
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundStyle(navyInk.opacity(0.55))
                            }
                            Spacer()
                            if selected == loc {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(goldMid)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .listStyle(.plain)
            .navigationTitle("Elegir lugar sagrado")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cerrar") { dismiss() }
                        .foregroundStyle(goldMid)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        ChoosePrayerIntentionView()
    }
}
