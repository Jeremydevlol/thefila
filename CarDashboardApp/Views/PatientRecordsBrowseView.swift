import SwiftUI

/// Listado histórico de **nombres hebreos** para tefilot (se abre desde *Más*).
struct PatientRecordsBrowseView: View {
    @EnvironmentObject private var patientsVM: PatientsRegistryViewModel
    @EnvironmentObject private var auth: AuthViewModel
    @EnvironmentObject private var shell: AppShellRouter

    private var displayedPatients: [PatientRecord] {
        patientsVM.displayedPatients()
    }

    private var resultCountText: String {
        displayedPatients.count.formatted(.number.grouping(.automatic).locale(Locale(identifier: "es_ES")))
    }

    var body: some View {
        ZStack {
            DashboardHomeBackdropImage()
            VStack(spacing: 0) {
                DashboardHomeTopBar(
                    initials: auth.userInitials,
                    profileImage: auth.profileAvatarImage,
                    searchText: $patientsVM.browseSearchText,
                    onNotifications: { shell.openHomeSheet(.notifications) }
                )
                .appChromeHeaderOuterPadding()

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 18) {
                        Text(TefilaCopy.hebrewNamesCountLabel(resultCountText))
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(Color.black.opacity(0.88))
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)
                            .padding(.horizontal, 16)
                            .padding(.top, 6)

                        if displayedPatients.isEmpty {
                            ContentUnavailableView(
                                TefilaCopy.hebrewNamesEmptyTitle,
                                systemImage: "scroll",
                                description: Text(TefilaCopy.hebrewNamesEmptySubtitle)
                            )
                            .foregroundStyle(Color.black.opacity(0.88))
                            .symbolRenderingMode(.hierarchical)
                            .tint(Color.black.opacity(0.45))
                            .padding(.vertical, 24)
                            .padding(.horizontal, 16)
                        } else {
                            LazyVStack(spacing: 14) {
                                ForEach(displayedPatients) { patient in
                                    PatientListingRow(
                                        patient: patient,
                                        isSelected: patientsVM.isSelected(patient)
                                    ) {
                                        patientsVM.selectPatient(patient)
                                    }
                                    .frame(maxWidth: .infinity)
                                }
                            }
                            .frame(maxWidth: .infinity)
                        }

                        Button {
                            let p = patientsVM.addEmptyPatient()
                            patientsVM.selectPatient(p)
                        } label: {
                            newRecordButton
                        }
                        .buttonStyle(.plain)
                        .padding(.horizontal, 16)
                    }
                    .padding(.bottom, 28)
                    .frame(minWidth: 0, maxWidth: .infinity)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .environment(\.colorScheme, .light)
        .preferredColorScheme(.light)
        .navigationTitle(TefilaCopy.hebrewNamesNavTitle)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
        .toolbarColorScheme(.light, for: .navigationBar)
    }

    private var newRecordButton: some View {
        GlassCard(cornerRadius: 20, padding: 16) {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(Color.black.opacity(0.06))
                        .frame(width: 44, height: 44)
                        .overlay {
                            Circle()
                                .strokeBorder(Color.black.opacity(0.08), lineWidth: 0.5)
                        }

                    Image(systemName: "plus")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(Color.black.opacity(0.85))
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(TefilaCopy.hebrewNamesAddTitle)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Color.black)

                    Text(TefilaCopy.hebrewNamesAddSubtitle)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(Color.black.opacity(0.52))
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.black.opacity(0.35))
            }
        }
    }
}

#Preview {
    NavigationStack {
        PatientRecordsBrowseView()
    }
    .environmentObject(PatientsRegistryViewModel())
    .environmentObject(AuthViewModel())
    .environmentObject(AppShellRouter())
}
