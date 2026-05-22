import SwiftUI
import UIKit

// MARK: - Lista de chats (cristal + mismo lenguaje que Inicio)

private enum ChatListTheme {
    /// Texto secundario (previews, hora).
    static let subtitle = Color.black.opacity(0.45)
    static let title = Color.black.opacity(0.92)
    static let accent = PremiumAccent.tabActive
    static let readAccent = PremiumAccent.mint
    static let rowCorner: CGFloat = 20
}

struct ChatView: View {
    @Binding var searchText: String

    @EnvironmentObject private var inbox: ChatInboxStore
    @EnvironmentObject private var auth: AuthViewModel
    @EnvironmentObject private var shell: AppShellRouter
    @State private var path = NavigationPath()
    @FocusState private var chatSearchFieldFocused: Bool

    private var filteredThreads: [ChatThread] {
        let q = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let base = inbox.liveThreads
        guard !q.isEmpty else { return base }
        return base.filter {
            $0.title.lowercased().contains(q) || $0.preview.lowercased().contains(q)
        }
    }

    var body: some View {
        ZStack {
            DashboardHomeBackdropImage()
            ChatBackgroundPatternOverlay(opacity: 0.07)
                .allowsHitTesting(false)

            NavigationStack(path: $path) {
                VStack(spacing: 0) {
                    VStack(spacing: 0) {
                        AppChromeHeaderRow(
                            initials: auth.userInitials,
                            profileImage: auth.profileAvatarImage,
                            searchText: $searchText,
                            prompt: Text(TefilaCopy.chatSearchPrompt)
                                .foregroundStyle(Color.black.opacity(DashboardChromeSearchFieldStyle.promptOpacity)),
                            showsSearchClearButton: true,
                            searchFieldFocused: $chatSearchFieldFocused
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
                    }
                    .background(Color.clear)

                    List {
                        ForEach(filteredThreads) { thread in
                            Button {
                                path.append(thread)
                            } label: {
                                chatListRow(thread)
                            }
                            .buttonStyle(.plain)
                            .listRowInsets(EdgeInsets(top: 5, leading: 16, bottom: 5, trailing: 16))
                            .listRowBackground(
                                LiquidGlassCardBackground(cornerRadius: ChatListTheme.rowCorner)
                            )
                            .listRowSeparator(.hidden)
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button {
                                    archiveThread(thread)
                                } label: {
                                    Label("Archivar", systemImage: "archivebox.fill")
                                }
                                .tint(Color(white: 0.55))

                                Button(role: .destructive) {
                                    deleteThread(thread)
                                } label: {
                                    Label("Eliminar", systemImage: "trash.fill")
                                }

                                Button {
                                    muteThread(thread)
                                } label: {
                                    Label("Silenciar", systemImage: "speaker.slash.fill")
                                }
                                .tint(.orange)
                            }
                            .swipeActions(edge: .leading, allowsFullSwipe: true) {
                                Button {
                                    markUnread(thread)
                                } label: {
                                    Label("No leído", systemImage: "bubble.left.and.bubble.right.fill")
                                }
                                .tint(ChatListTheme.accent)

                                Button {
                                    togglePin(thread)
                                } label: {
                                    Label("Fijar", systemImage: "pin.fill")
                                }
                                .tint(PremiumAccent.mint)
                            }
                        }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                    .background(Color.clear)
                }
                .background(Color.clear)
                .navigationTitle("")
                .navigationBarTitleDisplayMode(.inline)
                .toolbarBackground(.hidden, for: .navigationBar)
                .toolbarColorScheme(.light, for: .navigationBar)
                .toolbar {
                    ToolbarItemGroup(placement: .keyboard) {
                        LiquidGlassKeyboardAccessoryBar {
                            chatSearchFieldFocused = false
                        }
                    }
                }
                .navigationDestination(for: ChatThread.self) { thread in
                    ChatConversationView(thread: thread)
                        .toolbar(.hidden, for: .tabBar)
                }
            }
        }
        .environment(\.colorScheme, .light)
        .preferredColorScheme(.light)
    }

    // MARK: - Acciones swipe

    private func archiveThread(_ thread: ChatThread) {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        inbox.archiveThread(thread)
    }

    private func deleteThread(_ thread: ChatThread) {
        UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
        inbox.deleteThread(thread)
    }

    private func muteThread(_ thread: ChatThread) {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    private func markUnread(_ thread: ChatThread) {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        inbox.markUnread(thread)
    }

    private func togglePin(_ thread: ChatThread) {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        inbox.togglePin(thread)
    }

    // MARK: - Fila (layout tipo Telegram)

    private func effectivePinned(_ thread: ChatThread) -> Bool {
        inbox.effectivePinned(thread)
    }

    private func effectiveUnread(_ thread: ChatThread) -> Int? {
        inbox.effectiveUnread(thread)
    }

    private func chatListRow(_ thread: ChatThread) -> some View {
        let pinned = effectivePinned(thread)
        let unread = effectiveUnread(thread)

        return HStack(alignment: .top, spacing: 12) {
            avatar(for: thread)
                .padding(.top, 1)

            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .firstTextBaseline, spacing: 5) {
                    Text(thread.title)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(ChatListTheme.title)
                        .lineLimit(1)

                    if thread.isVerified {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(ChatListTheme.accent)
                    }

                    Spacer(minLength: 6)

                    Text(thread.time)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(ChatListTheme.subtitle)
                }

                HStack(alignment: .center, spacing: 6) {
                    if pinned {
                        Image(systemName: "pin.fill")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(ChatListTheme.accent.opacity(0.85))
                            .rotationEffect(.degrees(35))
                    }

                    Text(thread.preview)
                        .font(.system(size: 15, weight: .regular))
                        .foregroundStyle(ChatListTheme.subtitle)
                        .lineLimit(1)
                        .truncationMode(.tail)

                    Spacer(minLength: 4)

                    trailingStatus(thread, unread: unread)
                }
            }
        }
        .padding(.vertical, 6)
        .contentShape(Rectangle())
    }

    private func avatar(for thread: ChatThread) -> some View {
        ChatThreadAvatarView(thread: thread, diameter: 56)
    }

    @ViewBuilder
    private func trailingStatus(_ thread: ChatThread, unread: Int?) -> some View {
        if thread.showOpenButton {
            Text("ABRIR")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 5)
                .background {
                    Capsule(style: .continuous)
                        .fill(ChatListTheme.accent)
                }
        } else if let n = unread, n > 0 {
            Text("\(n)")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(.white)
                .frame(minWidth: 22, minHeight: 22)
                .background {
                    Circle()
                        .fill(ChatListTheme.accent)
                }
        } else {
            readReceiptView(thread.readReceipt)
        }
    }

    @ViewBuilder
    private func readReceiptView(_ state: ChatThread.ReadReceipt) -> some View {
        switch state {
        case .none:
            Color.clear.frame(width: 1, height: 1)
        case .sent:
            Image(systemName: "checkmark")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(ChatListTheme.accent)
        case .read:
            HStack(spacing: -5) {
                Image(systemName: "checkmark")
                    .font(.system(size: 12, weight: .bold))
                Image(systemName: "checkmark")
                    .font(.system(size: 12, weight: .bold))
            }
            .foregroundStyle(ChatListTheme.readAccent)
        }
    }
}

#Preview {
    ChatView(searchText: .constant(""))
        .environmentObject(ChatInboxStore())
        .environmentObject(AuthViewModel())
        .environmentObject(AppShellRouter())
}
