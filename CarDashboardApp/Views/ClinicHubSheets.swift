import SwiftUI

// MARK: - Informes

struct ClinicReportsSheetView: View {
    @EnvironmentObject private var shell: AppShellRouter
    @Environment(\.dismiss) private var dismiss
    @StateObject private var stats = DealershipStatsViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                DashboardHomeBackdropImage()
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 14) {
                        Text("Momentos destacados")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(Color.black.opacity(0.45))
                            .frame(maxWidth: .infinity, alignment: .leading)

                        reportRow(title: "Minutos de Tehilim comunitarios", value: stats.totalStockValue + "′", badge: stats.totalStockBadge + " esta semana")
                        reportRow(title: "Solicitudes dirigidas esta semana", value: "\(stats.newPatientsCount)", badge: "+\(stats.capturedChangePercent)% vs. medio")
                        reportRow(title: "Sedaríot estudiadas o escuchadas", value: "\(stats.completedTreatmentsCount)", badge: stats.periodDisplayLabel)
                        reportRow(title: "Parashót preparadas solo-Tanaj", value: stats.salesProfit + " capítulos", badge: stats.periodDisplayLabel)
                        reportRow(title: "Kavanot especiales realizadas", value: stats.totalDealershipEarnings, badge: stats.totalEarningsSubtitle)

                        GlassCard(cornerRadius: 20, padding: 16) {
                            VStack(alignment: .leading, spacing: 10) {
                                Text(TefilaCopy.choose("Tu panel espiritual", "Spiritual cockpit", "לוח ההתקרבות הרוחני"))
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundStyle(Color.black.opacity(0.88))
                                Text(TefilaCopy.choose(
                                    "En producción estos datos vivirían en tus reportes rabínicos. Mientras llega esa integración, usa el centro de inspiración como ancla cotidiana.",
                                    "Soon these KPIs tie into trusted clergy dashboards. Tap below to revisit your daily uplift.",
                                    "בקרוב הנתונים יחוברו לשרת שבתוכו רוקנים מתאמים הרוחני — עד אז משתמשים בראשית ההשראה בעמוד הבית."
                                ))
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundStyle(Color.black.opacity(0.5))
                                    .fixedSize(horizontal: false, vertical: true)
                                Button {
                                    dismiss()
                                    shell.goHomeAndFocusKPI()
                                } label: {
                                    Label(
                                        TefilaCopy.choose("Ir al centro de inspiración", "Jump to Inspiration Home", "מעבר לראש ההשראה"),
                                        systemImage: "sun.max.circle.fill")
                                        .font(.system(size: 15, weight: .semibold))
                                }
                                .buttonStyle(.borderedProminent)
                                .tint(PremiumAccent.tabActive)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                }
            }
            .environment(\.colorScheme, .light)
            .preferredColorScheme(.light)
            .navigationTitle(LocalizedStringKey(tefilaDynamic: TefilaCopy.choose("Tu camino espiritual", "Spiritual journey", "המסע הרוחני")))
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
            .toolbarColorScheme(.light, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cerrar") { dismiss() }
                        .fontWeight(.semibold)
                }
                .sharedBackgroundVisibility(.hidden)
            }
        }
    }

    private func reportRow(title: String, value: String, badge: String) -> some View {
        GlassCard(cornerRadius: 18, padding: 14) {
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Color.black.opacity(0.48))
                Text(value)
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.black.opacity(0.92))
                if !badge.trimmingCharacters(in: .whitespaces).isEmpty {
                    Text(badge)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(Color.black.opacity(0.42))
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

// MARK: - Facturación

struct ClinicBillingSheetView: View {
    @EnvironmentObject private var shell: AppShellRouter
    @Environment(\.dismiss) private var dismiss
    @State private var showExportHint = false

    var body: some View {
        NavigationStack {
            ZStack {
                DashboardHomeBackdropImage()
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 14) {
                        billingCard(
                            title: "Donativo para apoyo rabbínico",
                            amount: "48 € · demostración",
                            subtitle: TefilaCopy.choose(
                                "Sugerencias de maaser voluntario · marzo 2026",
                                "Sample maaser-style contribution · March 2026",
                                "הדגמה למעשר למטרות משפיעות הרוחני — מרץ 2026."
                            ),
                        )
                        billingCard(
                            title: "Pendientes de reciprocidad",
                            amount: "3 donativos cortos",
                            subtitle: "Breslov · Kotel · Tikun próximo Shabat — seguimiento comunitario"
                        )
                        GlassCard(cornerRadius: 20, padding: 16) {
                            VStack(alignment: .leading, spacing: 12) {
                                Text(TefilaCopy.choose("Gestión comunitaria", "Community treasury", "ניהול קהילתי"))
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundStyle(Color.black.opacity(0.88))

                                Button {
                                    showExportHint = true
                                } label: {
                                    Label(
                                        TefilaCopy.choose("Exportar compromisos espirituales (PDF demo)", "Export spiritual pledges", "ייצוא נדרים לדמו"),
                                        systemImage: "doc.richtext"
                                    )
                                    .font(.system(size: 15, weight: .semibold))
                                    .frame(maxWidth: .infinity)
                                }
                                .buttonStyle(.borderedProminent)
                                .tint(PremiumAccent.tabActive)

                                Button {
                                    dismiss()
                                    shell.openHomeSheet(.reports)
                                } label: {
                                    Label(
                                        TefilaCopy.choose("Ver resumen de impacto espiritual", "Open spiritual impact summary", "פתיחת משוב רוחני"),
                                        systemImage: "chart.bar.xaxis"
                                    )
                                    .font(.system(size: 14, weight: .semibold))
                                    .frame(maxWidth: .infinity)
                                }
                                .buttonStyle(.bordered)
                                .tint(Color.black.opacity(0.55))
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                }
            }
            .environment(\.colorScheme, .light)
            .preferredColorScheme(.light)
            .navigationTitle(LocalizedStringKey(tefilaDynamic: TefilaCopy.choose("Ayuda económica comunitaria", "Community gifting", "תמיכה קהילתית")))
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
            .toolbarColorScheme(.light, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cerrar") { dismiss() }
                        .fontWeight(.semibold)
                }
                .sharedBackgroundVisibility(.hidden)
            }
            .alert("Exportación", isPresented: $showExportHint) {
                Button("Entendido", role: .cancel) {}
            } message: {
                Text(TefilaCopy.choose(
                    "Este PDF será firmado cuando conectemos maaser automatizado.",
                    "This PDF activates once treasury sync goes live.",
                    "הקבצים ייחתמו עם חיבור מערך המעשר הרשמי."
                ))
            }
        }
    }

    private func billingCard(title: String, amount: String, subtitle: String) -> some View {
        GlassCard(cornerRadius: 20, padding: 16) {
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Color.black.opacity(0.48))
                Text(amount)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.black.opacity(0.92))
                Text(subtitle)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Color.black.opacity(0.45))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

// MARK: - Más opciones

struct ClinicMoreSheetView: View {
    @EnvironmentObject private var shell: AppShellRouter
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                DashboardHomeBackdropImage()
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 12) {
                        moreRow(
                            title: TefilaCopy.hebrewNamesNavTitle,
                            subtitle: TefilaCopy.choose(
                                "Escribir nombre hebreo + causa espiritual",
                                "Capture Hebrew spelling + sacred intent",
                                "למלא שם עברית וכותרת הבקשה"
                            ),
                            icon: "person.badge.plus",
                            action: {
                                dismiss()
                                DispatchQueue.main.async { shell.openPatientRecordsBrowser() }
                            }
                        )
                        moreRow(
                            title: TefilaCopy.choose("Escuchas comunales", "Guided listens", "הקראות מהקהילה"),
                            subtitle: TefilaCopy.choose(
                                "Solicitudes vinculadas a rabín o hazan disponible",
                                "Requests pooled with clergy partners",
                                "בקשות ותפילות אצל מתפלל מאומת"
                            ),
                            icon: "person.3.fill",
                            action: {
                                dismiss()
                                DispatchQueue.main.async { shell.showLeadsBrowser = true }
                            }
                        )
                        moreRow(
                            title: TefilaCopy.tabChat,
                            subtitle: TefilaCopy.choose(
                                "Rabín, estudiante de Torá o guía pastoral judío",
                                "Rabbis · Torah tutors · pastoral Jewish guide",
                                "רבן · מדריך תורני · הרב החביר שלך ברשת"
                            ),
                            icon: "bubble.left.and.bubble.right.fill",
                            action: {
                                dismiss()
                                DispatchQueue.main.async { shell.selectedTab = .chat }
                            }
                        )
                        moreRow(
                            title: TefilaCopy.choose("Preferencias espirituales", "Spiritual preferences", "הגדרות רוח נפשיות"),
                            subtitle: "Cuenta, idioma · נוסח התפילה",
                            icon: "gearshape.fill",
                            action: {
                                dismiss()
                                DispatchQueue.main.async { shell.openSettingsSheet() }
                            }
                        )
                        moreRow(
                            title: TefilaCopy.choose("Panel de métricas", "Impact dashboard", "לוח ההשפעות"),
                            subtitle: TefilaCopy.choose(
                                "Tehilim, peticiones activas · sedrá",
                                "Psalms pledged · live petitions · sedra pacing",
                                "תהילים · בקשות פעילות · פרשה"
                            ),
                            icon: "chart.bar.xaxis",
                            action: {
                                dismiss()
                                DispatchQueue.main.async { shell.openHomeSheet(.reports) }
                            }
                        )
                        moreRow(
                            title: TefilaCopy.choose(
                                "Ofrendas guiadas maaser",
                                "Guided gifting",
                                "תרומות בניחות מידות"
                            ),
                            subtitle: TefilaCopy.choose(
                                "Donativos y seguimiento comunitarios",
                                "Voluntary gifting transparency",
                                "ניהול שקיפות ההבטחות"
                            ),
                            icon: "doc.text.fill",
                            action: {
                                dismiss()
                                DispatchQueue.main.async { shell.openHomeSheet(.billing) }
                            }
                        )
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                }
            }
            .environment(\.colorScheme, .light)
            .preferredColorScheme(.light)
            .navigationTitle(LocalizedStringKey(tefilaDynamic: TefilaCopy.choose("Atajos sagrados", "Sacred shortcuts", "קיצורי דרך קדושים")))
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
            .toolbarColorScheme(.light, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cerrar") { dismiss() }
                        .fontWeight(.semibold)
                }
                .sharedBackgroundVisibility(.hidden)
            }
        }
    }

    private func moreRow(title: String, subtitle: String, icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            GlassCard(cornerRadius: 18, padding: 14) {
                HStack(spacing: 14) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Color.black.opacity(0.06))
                            .frame(width: 44, height: 44)
                        Image(systemName: icon)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(PremiumAccent.tabActive)
                    }
                    VStack(alignment: .leading, spacing: 3) {
                        Text(title)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(Color.black.opacity(0.9))
                        Text(subtitle)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(Color.black.opacity(0.48))
                            .multilineTextAlignment(.leading)
                    }
                    Spacer(minLength: 8)
                    Image(systemName: "chevron.right")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Color.black.opacity(0.3))
                }
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Notificaciones

struct ClinicNotificationsSheetView: View {
    @EnvironmentObject private var shell: AppShellRouter
    @EnvironmentObject private var inbox: ChatInboxStore
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                DashboardHomeBackdropImage()
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(TefilaCopy.choose("Últimos hilos rabínicos", "Latest clergy threads", "שיחות אחרונות עם ההדרכה"))
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(Color.black.opacity(0.45))
                            .padding(.horizontal, 4)

                        ForEach(inbox.liveThreads.prefix(12)) { thread in
                            Button {
                                inbox.markThreadAsRead(thread.id)
                                dismiss()
                                DispatchQueue.main.async { shell.selectedTab = .chat }
                            } label: {
                                GlassCard(cornerRadius: 18, padding: 14) {
                                    HStack(alignment: .top, spacing: 12) {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(thread.title)
                                                .font(.system(size: 15, weight: .semibold))
                                                .foregroundStyle(Color.black.opacity(0.9))
                                                .multilineTextAlignment(.leading)
                                            Text(thread.preview)
                                                .font(.system(size: 13, weight: .medium))
                                                .foregroundStyle(Color.black.opacity(0.48))
                                                .lineLimit(2)
                                            Text(thread.time)
                                                .font(.system(size: 11, weight: .medium))
                                                .foregroundStyle(Color.black.opacity(0.38))
                                        }
                                        Spacer(minLength: 0)
                                        if let u = inbox.effectiveUnread(thread), u > 0 {
                                            Text("\(u)")
                                                .font(.system(size: 11, weight: .bold))
                                                .foregroundStyle(.white)
                                                .frame(minWidth: 22, minHeight: 22)
                                                .background(Circle().fill(PremiumAccent.tabActive))
                                        }
                                    }
                                }
                            }
                            .buttonStyle(.plain)
                        }

                        GlassCard(cornerRadius: 18, padding: 16) {
                            Button {
                                dismiss()
                                DispatchQueue.main.async { shell.selectedTab = .chat }
                            } label: {
                                Label(TefilaCopy.tabChat, systemImage: "bubble.left.and.bubble.right.fill")
                                    .font(.system(size: 15, weight: .semibold))
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(PremiumAccent.tabActive)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                }
            }
            .environment(\.colorScheme, .light)
            .preferredColorScheme(.light)
            .navigationTitle("Notificaciones")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
            .toolbarColorScheme(.light, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cerrar") { dismiss() }
                        .fontWeight(.semibold)
                }
                .sharedBackgroundVisibility(.hidden)
            }
        }
    }
}


