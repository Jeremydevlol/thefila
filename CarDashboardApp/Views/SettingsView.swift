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
                    prompt: Text(TefilaCopy.settingsSearchPlaceholder)
                        .foregroundStyle(Color.black.opacity(DashboardChromeSearchFieldStyle.promptOpacity)),
                    showsSearchClearButton: true,
                    searchFieldFocused: $settingsSearchFieldFocused
                ) {
                    HStack(spacing: AppChromeHeaderMetrics.hStackSpacing) {
                        AppChromeHeaderCircleIconButton(
                            systemName: "chart.bar.fill",
                            accessibilityLabel: TefilaCopy.spiritualProgressHint,
                            action: { shell.goHomeAndFocusKPI() }
                        )
                        AppChromeHeaderCircleIconButton(
                            catalogAssetName: "TefilaNotificationsIcon",
                            accessibilityLabel: TefilaCopy.settingsNotificationsAccent,
                            action: { shell.openHomeSheet(.notifications) }
                        )
                    }
                }
                .appChromeHeaderOuterPadding()

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 12) {
                        languageSection
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
        .navigationTitle(LocalizedStringKey(tefilaDynamic: TefilaCopy.settingsTitle))
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
        .toolbarColorScheme(.light, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button { dismiss() } label: {
                    Text(TefilaCopy.settingsDone)
                        .fontWeight(.semibold)
                }
            }
            .sharedBackgroundVisibility(.hidden)
            ToolbarItemGroup(placement: .keyboard) {
                LiquidGlassKeyboardAccessoryBar {
                    settingsSearchFieldFocused = false
                }
            }
        }
        .confirmationDialog(
            LocalizedStringKey(tefilaDynamic: TefilaCopy.settingsSignOutDialogTitle),
            isPresented: $confirmSignOut,
            titleVisibility: .visible
        ) {
            Button(role: .destructive) {
                dismiss()
                Task { await auth.signOut() }
            } label: {
                Text(TefilaCopy.settingsSignOutDestructive)
            }
            Button(role: .cancel) {
            } label: {
                Text(TefilaCopy.settingsCancel)
            }
        } message: {
            Text(auth.isAuthenticated
                ? TefilaCopy.settingsSignOutDialogMessageAuthenticated
                : TefilaCopy.settingsSignOutDialogMessageGuest)
        }
    }

    // MARK: - Idioma

    private var languageSection: some View {
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

                        Image(systemName: "globe")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(PremiumAccent.tabActive)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text(TefilaCopy.settingsLanguageSectionTitle)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(Color.black.opacity(0.92))

                        Text(TefilaCopy.settingsLanguageSectionSubtitle)
                            .font(.system(size: 12.5, weight: .medium))
                            .foregroundStyle(Color.black.opacity(0.48))
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Spacer(minLength: 0)
                }

                Picker("", selection: $settingsVM.appLanguage) {
                    ForEach(TefilaAppLanguage.allCases) { lang in
                        Text(lang.segmentLabel).tag(lang)
                    }
                }
                .pickerStyle(.segmented)
                .labelsHidden()
                .environment(\.layoutDirection, .leftToRight)
            }
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

                    Text(auth.isAuthenticated ? TefilaCopy.settingsProfileCloud : TefilaCopy.settingsProfileLocal)
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

                    Text(TefilaCopy.settingsWidgetsExplainer)
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
                    Text(TefilaCopy.settingsWidgetsReload)
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
                            Text(TefilaCopy.settingsSignOutRowTitle)
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(Color.black)
                            Text(auth.isAuthenticated
                                ? (auth.userEmail ?? auth.userDisplayName)
                                : TefilaCopy.settingsSignOutRowSubtitleGuest)
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
                    title: TefilaCopy.settingsVersionRow
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
