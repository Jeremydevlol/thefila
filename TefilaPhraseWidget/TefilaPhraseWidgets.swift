import SwiftUI
import WidgetKit

// MARK: - Entrada timeline

struct TanakhVerseEntry: TimelineEntry {
    let date: Date
    let verse: String
    let reference: String
}

// MARK: - Catálogo (Tanaj · judío moderno; sin nomenclatura cristiana)

private enum TanakhVersesCatalog {
    static let pairs: [(verse: String, reference: String)] = [
        (
            "Escucha Israel,\nHashem es Uno.",
            "Devarim 6:4"
        ),
        (
            "Shemá Israel, Hashem Eloheinu,\nHashem Ejad.",
            "Devarim 6:4"
        ),
        (
            "Amarás a tu prójimo como a ti mismo; yo soy Hashem.",
            "Vaiqra 19:18"
        ),
        (
            "Hashem es mi luz y mi salvación,\n¿de quién he de temer?",
            "Tehilim 27:1"
        ),
        (
            "En la Torá de Hashem está su delicia,\ny en su Ley medita día y noche.",
            "Tehilim 1:2"
        ),
        (
            "Hashem está cerca de todo el que Lo invoca,\nde todo el que Lo invoca de verdad.",
            "Tehilim 145:18"
        ),
        (
            "No estás obligado a terminar el trabajo,\npero tampoco eres libre de abandonarlo.",
            "Pirqé Abot 2:21"
        ),
        (
            "Según el esfuerzo es la recompensa.",
            "Pirqé Abot 5:23"
        ),
        (
            "Pon la Torá sobre tu corazón;\nenséñalas a tus hijos hablando de ellas.",
            "Devarim 6:7"
        ),
        (
            "¿Quién es rico? El que se alegra de su parte.",
            "Pirqé Abot 4:1"
        ),
    ]

    static func pair(for date: Date, calendar: Calendar = .current) -> (verse: String, reference: String) {
        guard !pairs.isEmpty else {
            return ("Escucha Israel,\nHashem es Uno.", "Devarim 6:4")
        }
        let day = calendar.ordinality(of: .day, in: .year, for: date) ?? 1
        let idx = (max(1, day) - 1) % pairs.count
        return pairs[idx]
    }

    static func entry(for date: Date) -> TanakhVerseEntry {
        let p = pair(for: date)
        return TanakhVerseEntry(date: date, verse: p.verse, reference: p.reference)
    }
}

// MARK: - Provider

private struct TanakhVerseTimelineProvider: TimelineProvider {
    func placeholder(in _: Context) -> TanakhVerseEntry {
        TanakhVersesCatalog.entry(for: Date())
    }

    func getSnapshot(in _: Context, completion: @escaping (TanakhVerseEntry) -> Void) {
        completion(TanakhVersesCatalog.entry(for: Date()))
    }

    func getTimeline(in _: Context, completion: @escaping (Timeline<TanakhVerseEntry>) -> Void) {
        let calendar = Calendar.current
        let now = Date()
        let entry = TanakhVersesCatalog.entry(for: now)

        let startOfTomorrow = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: now))
            ?? now.addingTimeInterval(86400)

        completion(Timeline(entries: [entry], policy: .after(startOfTomorrow)))
    }
}

// MARK: - Calendario semanal (domingo = ראשון … sábado = שבת)

private enum JewishWeekdayLabels {
    /// `Calendar.Component.weekday` con `firstWeekday = 1` (domingo = 1).
    static let hebrew: [Int: String] = [
        1: "ראשון",
        2: "שני",
        3: "שלישי",
        4: "רביעי",
        5: "חמישי",
        6: "שישי",
        7: "שבת",
    ]

    /// Semana gregoriana **domingo → sábado**.
    static func weekDates(containing date: Date) -> [Date] {
        var cal = Calendar(identifier: .gregorian)
        cal.firstWeekday = 1
        let startOfDay = cal.startOfDay(for: date)
        let wd = cal.component(.weekday, from: startOfDay)
        let daysSinceSunday = wd - 1
        guard let sunday = cal.date(byAdding: .day, value: -daysSinceSunday, to: startOfDay) else { return [] }
        return (0 ..< 7).compactMap { cal.date(byAdding: .day, value: $0, to: sunday) }
    }

    static func label(for weekday: Int) -> String {
        hebrew[weekday] ?? ""
    }
}

private struct JewishWeekCalendarView: View {
    let weekDates: [Date]
    let today: Date
    /// `true` en Medium: tipografía y celdas algo más compactas para que entre la barra semanal.
    var compact: Bool = false

    private var calendar: Calendar {
        var cal = Calendar(identifier: .gregorian)
        cal.firstWeekday = 1
        return cal
    }

    var body: some View {
        HStack(spacing: 0) {
            ForEach(weekDates, id: \.timeIntervalSince1970) { day in
                dayCell(for: day)
                    .frame(maxWidth: .infinity)
            }
        }
    }

    private func dayCell(for day: Date) -> some View {
        let startDay = calendar.startOfDay(for: day)
        let startToday = calendar.startOfDay(for: today)
        let isToday = startDay == startToday
        let weekday = calendar.component(.weekday, from: day)
        let dayNum = calendar.component(.day, from: day)
        let label = JewishWeekdayLabels.label(for: weekday)

        let labelSize: CGFloat = compact ? 8 : 9
        let numSize: CGFloat = compact ? 10 : 11
        let circle: CGFloat = compact ? 23 : 27

        return VStack(spacing: compact ? 3 : 4) {
            Text(label)
                .font(.system(size: labelSize, weight: .semibold, design: .rounded))
                .foregroundStyle(.white.opacity(0.88))
                .minimumScaleFactor(compact ? 0.42 : 0.55)
                .lineLimit(1)

            ZStack {
                if isToday {
                    Circle()
                        .fill(Color.white)
                } else {
                    Circle()
                        .strokeBorder(Color.white.opacity(0.78), lineWidth: 1)
                }
                Text("\(dayNum)")
                    .font(.system(size: numSize, weight: .bold, design: .rounded))
                    .foregroundStyle(isToday ? Color.black.opacity(0.88) : Color.white)
            }
            .frame(width: circle, height: circle)
        }
    }
}

// MARK: - Fondo fullscreen (Tanaj · pergamino; asset por tamaño)

private struct TorahWidgetFullscreenBackdrop: View {
    let assetName: String

    var body: some View {
        ZStack {
            Image(assetName)
                .resizable()
                .scaledToFill()
                .blur(radius: 0.9)
                .containerRelativeFrame([.horizontal, .vertical])
                .clipped()

            ZStack {
                LinearGradient(
                    colors: [
                        Color.black.opacity(0.22),
                        Color.black.opacity(0.48),
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                LinearGradient(
                    colors: [
                        Color(red: 0.98, green: 0.86, blue: 0.48).opacity(0.14),
                        Color.clear,
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }
            .allowsHitTesting(false)
        }
    }
}

// MARK: - Widget Small / Medium / Large — mismo idioma visual, densidad adaptada

private struct TefilaSmallJewishVerseWidgetView: View {
    let entry: TanakhVerseEntry

    private var dayOfYearBadge: Int {
        Calendar.current.ordinality(of: .day, in: .year, for: entry.date) ?? 1
    }

    private var referenceCaps: String {
        entry.reference.uppercased(with: Locale(identifier: "es_ES"))
    }

    var body: some View {
        ZStack {
            TorahWidgetFullscreenBackdrop(assetName: "Small")

            VStack(spacing: 0) {
                HStack(spacing: 8) {
                    Text("FRASE DEL DÍA")
                        .font(.system(size: 9, weight: .bold, design: .rounded))
                        .tracking(0.8)
                        .foregroundStyle(.white.opacity(0.9))
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)
                    Spacer(minLength: 0)
                    Image(systemName: "menorah.fill")
                        .font(.system(size: 11, weight: .semibold))
                        .symbolRenderingMode(.hierarchical)
                        .foregroundStyle(Color(red: 1, green: 0.88, blue: 0.55))
                }
                .padding(.horizontal, 12)
                .padding(.top, 11)

                Spacer(minLength: 4)

                Text(entry.verse)
                    .font(.system(size: 14, weight: .bold, design: .serif))
                    .multilineTextAlignment(.center)
                    .lineSpacing(2)
                    .minimumScaleFactor(0.62)
                    .foregroundStyle(Color.white)
                    .padding(.horizontal, 10)

                Text(referenceCaps)
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .tracking(0.4)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.white.opacity(0.92))
                    .padding(.top, 8)
                    .padding(.horizontal, 10)

                Spacer(minLength: 8)

                Text("#\(dayOfYearBadge)")
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(.white.opacity(0.55))
                    .padding(.bottom, 11)
            }
        }
        .foregroundStyle(.white)
    }
}

private struct TefilaMediumJewishVerseWidgetView: View {
    let entry: TanakhVerseEntry

    private var weekDates: [Date] {
        JewishWeekdayLabels.weekDates(containing: entry.date)
    }

    private var dayOfYearBadge: Int {
        Calendar.current.ordinality(of: .day, in: .year, for: entry.date) ?? 1
    }

    private var referenceCaps: String {
        entry.reference.uppercased(with: Locale(identifier: "es_ES"))
    }

    var body: some View {
        ZStack {
            TorahWidgetFullscreenBackdrop(assetName: "Medium")

            VStack(spacing: 0) {
                mediumTopBar
                    .padding(.horizontal, 14)
                    .padding(.top, 11)

                Spacer(minLength: 6)

                VStack(spacing: 10) {
                    Text(entry.verse)
                        .font(.system(size: 17, weight: .bold, design: .serif))
                        .multilineTextAlignment(.center)
                        .lineSpacing(2)
                        .minimumScaleFactor(0.72)
                        .foregroundStyle(Color.white)

                    Text(referenceCaps)
                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                        .tracking(0.55)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.white.opacity(0.93))
                }
                .padding(.horizontal, 14)

                Spacer(minLength: 8)

                JewishWeekCalendarView(weekDates: weekDates, today: entry.date, compact: true)
                    .padding(.horizontal, 8)
                    .padding(.bottom, 11)
            }
        }
        .foregroundStyle(.white)
    }

    private var mediumTopBar: some View {
        HStack(alignment: .center, spacing: 8) {
            Text("FRASE DEL DÍA")
                .font(.system(size: 10, weight: .bold, design: .rounded))
                .tracking(1)
                .foregroundStyle(.white.opacity(0.92))

            Spacer(minLength: 0)

            HStack(spacing: 4) {
                Image(systemName: "menorah.fill")
                    .font(.system(size: 11, weight: .semibold))
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(Color(red: 1, green: 0.88, blue: 0.55))
                Text("\(dayOfYearBadge)")
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(.white.opacity(0.95))
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                Capsule(style: .continuous)
                    .fill(Color.white.opacity(0.14))
            )
        }
    }
}

private struct TefilaLargeJewishVerseWidgetView: View {
    let entry: TanakhVerseEntry

    private var weekDates: [Date] {
        JewishWeekdayLabels.weekDates(containing: entry.date)
    }

    private var dayOfYearBadge: Int {
        Calendar.current.ordinality(of: .day, in: .year, for: entry.date) ?? 1
    }

    private var referenceCaps: String {
        entry.reference.uppercased(with: Locale(identifier: "es_ES"))
    }

    var body: some View {
        ZStack {
            TorahWidgetFullscreenBackdrop(assetName: "Large")

            VStack(spacing: 0) {
                topBar
                    .padding(.horizontal, 16)
                    .padding(.top, 14)

                Spacer(minLength: 8)

                verseContent
                    .padding(.horizontal, 18)

                Spacer(minLength: 8)

                JewishWeekCalendarView(weekDates: weekDates, today: entry.date)
                    .padding(.horizontal, 10)
                    .padding(.bottom, 14)
            }
        }
        .foregroundStyle(.white)
    }

    private var topBar: some View {
        HStack(alignment: .center, spacing: 10) {
            Text("FRASE DEL DÍA")
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .tracking(1.1)
                .foregroundStyle(.white.opacity(0.92))

            Spacer(minLength: 0)

            HStack(spacing: 5) {
                Image(systemName: "menorah.fill")
                    .font(.system(size: 12, weight: .semibold))
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(Color(red: 1, green: 0.88, blue: 0.55))
                Text("\(dayOfYearBadge)")
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(.white.opacity(0.95))
            }
            .padding(.horizontal, 9)
            .padding(.vertical, 5)
            .background(
                Capsule(style: .continuous)
                    .fill(Color.white.opacity(0.14))
            )
        }
    }

    private var verseContent: some View {
        VStack(spacing: 12) {
            Text(entry.verse)
                .font(.system(size: 22, weight: .bold, design: .serif))
                .multilineTextAlignment(.center)
                .lineSpacing(3)
                .minimumScaleFactor(0.74)
                .foregroundStyle(Color.white)

            Text(referenceCaps)
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .tracking(0.6)
                .multilineTextAlignment(.center)
                .foregroundStyle(.white.opacity(0.93))
        }
    }
}

// MARK: - Pantalla de bloqueo · rectangular

struct TefilaLockRectangularWidgetView: View {
    let entry: TanakhVerseEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(entry.reference.uppercased(with: Locale(identifier: "es_ES")))
                .font(.subheadline.weight(.bold))

            Text(entry.verse)
                .font(.caption.weight(.medium))
                .multilineTextAlignment(.leading)
                .lineSpacing(2)
                .fixedSize(horizontal: false, vertical: true)
                .minimumScaleFactor(0.62)
                .allowsTightening(true)
        }
        .padding(.leading, 2)
        .padding(.trailing, 4)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .foregroundStyle(.primary)
    }
}

// MARK: - Raíz unificada

private struct TefilaTanakhWidgetContent: View {
    let entry: TanakhVerseEntry
    @Environment(\.widgetFamily) private var family

    var body: some View {
        Group {
            switch family {
            case .systemLarge:
                TefilaLargeJewishVerseWidgetView(entry: entry)
            case .systemMedium:
                TefilaMediumJewishVerseWidgetView(entry: entry)
            case .systemSmall:
                TefilaSmallJewishVerseWidgetView(entry: entry)
            case .accessoryRectangular:
                TefilaLockRectangularWidgetView(entry: entry)
            default:
                TefilaLockRectangularWidgetView(entry: entry)
            }
        }
    }
}

private struct TanakhAdaptiveWidgetBackground: View {
    @Environment(\.widgetFamily) private var family

    var body: some View {
        switch family {
        case .systemLarge:
            Color.clear
        case .accessoryRectangular:
            AccessoryWidgetBackground()
        default:
            Color.clear
        }
    }
}

// MARK: - Widget único

private struct TefilaTanakhWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: "com.tefila.tanakh.verse",
            provider: TanakhVerseTimelineProvider()
        ) { entry in
            TefilaTanakhWidgetContent(entry: entry)
                .widgetURL(URL(string: "tefiladashboard://home"))
                .containerBackground(for: .widget) {
                    TanakhAdaptiveWidgetBackground()
                }
        }
        .configurationDisplayName("Tefila · Tanaj")
        .description("Frases del Tanaj en pequeño, mediano y grande (arte Small, Medium y Large) y frase compacta en la pantalla de bloqueo.")
        .supportedFamilies([
            .systemLarge,
            .systemMedium,
            .systemSmall,
            .accessoryRectangular,
        ])
    }
}

@main
struct TefilaPhraseWidgets: WidgetBundle {
    var body: some Widget {
        TefilaTanakhWidget()
    }
}

#if DEBUG && TEWIDGET
private enum TefilaWidgetPreviewSamples {
    static let entry = TanakhVersesCatalog.entry(for: Date())
}

struct TefilaWidget_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            TefilaTanakhWidgetContent(entry: TefilaWidgetPreviewSamples.entry)
                .previewContext(WidgetPreviewContext(family: .systemLarge))
                .previewDisplayName("Large · Tanaj · Large.png")
            TefilaTanakhWidgetContent(entry: TefilaWidgetPreviewSamples.entry)
                .previewContext(WidgetPreviewContext(family: .systemMedium))
                .previewDisplayName("Medium · Tanaj · Medium.png")
            TefilaTanakhWidgetContent(entry: TefilaWidgetPreviewSamples.entry)
                .previewContext(WidgetPreviewContext(family: .systemSmall))
                .previewDisplayName("Small · Tanaj · Small.png")
            TefilaLockRectangularWidgetView(entry: TefilaWidgetPreviewSamples.entry)
                .previewContext(WidgetPreviewContext(family: .accessoryRectangular))
                .previewDisplayName("Lock · Rectangular")
        }
    }
}
#endif
