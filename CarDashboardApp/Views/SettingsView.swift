import SwiftUI
import UIKit
import WidgetKit

struct SettingsView: View {
    @EnvironmentObject var settingsVM: SettingsViewModel
    @EnvironmentObject var auth: AuthViewModel
    @EnvironmentObject private var shell: AppShellRouter
    @Environment(\.dismiss) private var dismiss

    @State private var settingsSearchText = ""
    @FocusState private var settingsSearchFieldFocused: Bool
    @State private var confirmSignOut = false

    var body: some View {
        RevolutChromeContainer {
            VStack(spacing: 0) {
                AppChromeHeaderRow(
                    initials: auth.userInitials,
                    profileImage: auth.profileAvatarImage,
                    onProfileTap: {},
                    searchText: $settingsSearchText,
                    prompt: Text("Buscar")
                        .foregroundStyle(Color.black.opacity(DashboardChromeSearchFieldStyle.promptOpacity)),
                    showsSearchClearButton: true,
                    searchFieldFocused: $settingsSearchFieldFocused
                ) {
                    HStack(spacing: AppChromeHeaderMetrics.hStackSpacing) {
                        AppChromeHeaderCircleIconButton(
                            systemName: "chart.bar.fill",
                            accessibilityLabel: LocalizedStringKey(TefilaCopy.spiritualProgressHint),
                            action: { shell.goHomeAndFocusKPI() }
                        )
                        AppChromeHeaderCircleIconButton(
                            catalogAssetName: "TefilaNotificationsIcon",
                            accessibilityLabel: "Notificaciones",
                            action: { shell.openHomeSheet(.notifications) }
                        )
                    }
                }
                .appChromeHeaderOuterPadding()

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 12) {
                        profileSection
                        widgetsSection
                        accountSection
                        aboutSection
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                    .padding(.bottom, 24)
                    .frame(minWidth: 0, maxWidth: .infinity)
                }
                .frame(maxWidth: .infinity)
            }
            .frame(maxWidth: .infinity)
        }
        .navigationTitle("Ajustes")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
        .toolbarColorScheme(.light, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Listo") { dismiss() }
                    .fontWeight(.semibold)
            }
            ToolbarItemGroup(placement: .keyboard) {
                LiquidGlassKeyboardAccessoryBar {
                    settingsSearchFieldFocused = false
                }
            }
        }
        .confirmationDialog(
            "¿Cerrar sesión?",
            isPresented: $confirmSignOut,
            titleVisibility: .visible
        ) {
            Button("Cerrar sesión", role: .destructive) {
                dismiss()
                Task { await auth.signOut() }
            }
            Button("Cancelar", role: .cancel) {}
        } message: {
            Text(auth.isAuthenticated
                ? "Se cerrará tu sesión en la nube en este dispositivo."
                : "Se borrarán los datos de sesión guardados aquí.")
        }
    }

    // MARK: - Profile

    private var profileSection: some View {
        ChromeSettingsCard(cornerRadius: 24, padding: 20) {
            HStack(spacing: 16) {
                ZStack {
                    if let photo = auth.profileAvatarImage {
                        Image(uiImage: photo)
                            .resizable()
                            .scaledToFill()
                    } else {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [.cyan.opacity(0.5), .purple.opacity(0.4)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                        Text(String(auth.userDisplayName.prefix(1)).uppercased())
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                    }
                }
                .frame(width: 60, height: 60)
                .clipShape(Circle())

                VStack(alignment: .leading, spacing: 4) {
                    Text(auth.userDisplayName)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(Color.black)

                    Text(auth.isAuthenticated ? "Sesión Supabase" : "Acceso directo · sin cuenta")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(PremiumAccent.tabActive.opacity(0.9))
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.black.opacity(0.35))
            }
        }
    }

    // MARK: - Widgets

    private var widgetsSection: some View {
        ChromeSettingsCard(cornerRadius: 22, padding: 16) {
            VStack(alignment: .leading, spacing: 14) {
                HStack(alignment: .top, spacing: 12) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(Color.black.opacity(0.06))
                            .frame(width: 32, height: 32)
                            .overlay {
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .strokeBorder(Color.black.opacity(0.08), lineWidth: 0.5)
                            }
                        Image(systemName: "square.stack.3d.up.fill")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(PremiumAccent.tabActive)
                    }

                    Text("Los widgets «Tefila · Tanaj» muestran frases del Tanaj (tamaños grandes, mediano y pequeño) y texto compacto en la pantalla de bloqueo. Mantén pulsado el inicio · + · busca «Tefila». Si ya añadiste el widget, el botón de abajo fuerza una actualización.")
                        .font(.system(size: 13.5, weight: .medium))
                        .foregroundStyle(Color.black.opacity(0.62))
                        .fixedSize(horizontal: false, vertical: true)

                    Text(TefilaCopy.widgetsLanguageFootnote)
                        .font(.system(size: 11.5, weight: .medium))
                        .foregroundStyle(Color.black.opacity(0.42))
                        .fixedSize(horizontal: false, vertical: true)

                    Spacer(minLength: 0)
                }

                Button {
                    WidgetCenter.shared.reloadAllTimelines()
                } label: {
                    Text("Actualizar widgets ahora")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 13)
                        .background(
                            Capsule(style: .continuous).fill(PremiumAccent.tabActive)
                        )
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - Cuenta

    private var accountSection: some View {
        ChromeSettingsCard(cornerRadius: 22, padding: 4) {
            VStack(spacing: 0) {
                Button {
                    confirmSignOut = true
                } label: {
                    HStack(spacing: 14) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .fill(Color.black.opacity(0.06))
                                .frame(width: 32, height: 32)
                                .overlay {
                                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                                        .strokeBorder(Color.black.opacity(0.08), lineWidth: 0.5)
                                }
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(.red.opacity(0.95))
                        }
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Cerrar sesión")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(Color.black)
                            Text(auth.isAuthenticated
                                ? (auth.userEmail ?? auth.userDisplayName)
                                : "Sin cuenta vinculada · limpiar sesión local")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(Color.black.opacity(0.45))
                                .lineLimit(1)
                                .truncationMode(.middle)
                        }
                        Spacer(minLength: 0)
                        Image(systemName: "chevron.right")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(Color.black.opacity(0.28))
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - Acerca de

    private var aboutSection: some View {
        ChromeSettingsCard(cornerRadius: 22, padding: 4) {
            VStack(spacing: 0) {
                settingsRow(
                    icon: "info.circle.fill",
                    iconColor: PremiumAccent.tabActive,
                    title: "Versión"
                ) {
                    Text("\(settingsVM.appVersion) (\(settingsVM.buildNumber))")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(Color.black.opacity(0.48))
                }
            }
        }
    }

    // MARK: - Helpers

    private func settingsRow<Trailing: View>(
        icon: String,
        iconColor: Color,
        title: String,
        @ViewBuilder trailing: () -> Trailing
    ) -> some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(Color.black.opacity(0.06))
                    .frame(width: 32, height: 32)
                    .overlay {
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .strokeBorder(Color.black.opacity(0.08), lineWidth: 0.5)
                    }

                Image(systemName: icon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(iconColor)
            }

            Text(title)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(Color.black)

            Spacer()

            trailing()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

#Preview {
    SettingsView()
        .environmentObject(SettingsViewModel())
        .environmentObject(AuthViewModel())
        .environmentObject(AppShellRouter())
}
