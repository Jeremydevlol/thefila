import Foundation

/// Cita o enseñanza breve para inspiración diaria.
struct JewishInspirationPhrase: Equatable {
    let text: String
    /// Origen aproximado: Tanaj, Mishná, Pirqé Abot, etc.
    let attribution: String
}

/// Catálogo trilingüe: app y widget comparten la lista según idioma elegido.
enum JewishPhraseLibrary {
    private struct Entry {
        let esText: String
        let esAttr: String
        let enText: String
        let enAttr: String
        let heText: String
        let heAttr: String

        func resolved() -> JewishInspirationPhrase {
            switch LocaleTriple.resolvedLanguage() {
            case .spanish:
                return JewishInspirationPhrase(text: esText, attribution: esAttr)
            case .english:
                return JewishInspirationPhrase(text: enText, attribution: enAttr)
            case .hebrew:
                return JewishInspirationPhrase(text: heText, attribution: heAttr)
            }
        }
    }

    private static let catalog: [Entry] = [
        Entry(
            esText: "Cada palabra de tefilá es un puente hacia Hashem.",
            esAttr: "Enseñanza de tefilá",
            enText: "Every word of prayer is a bridge toward the Divine.",
            enAttr: "Teaching on prayer",
            heText: "כל מילה בתפילה היא גשר אל הקב\"ה.",
            heAttr: "לימוד על תפילה"
        ),
        Entry(
            esText: "No estás obligado a terminar el trabajo, pero tampoco eres libre de abandonarlo.",
            esAttr: "Pirqé Abot 2:21",
            enText: "You are not obligated to finish the work, but neither are you free to abandon it.",
            enAttr: "Pirkei Avot 2:21",
            heText: "אין לך חובה לגמור, ואין לך רשות לבטל ממנה.",
            heAttr: "פרקי אבות ב׳ כ״א"
        ),
        Entry(
            esText: "Según el esfuerzo es la recompensa.",
            esAttr: "Pirqé Abot 5:23",
            enText: "According to the effort is the reward.",
            enAttr: "Pirkei Avot 5:23",
            heText: "לפי עמלו הוא מתפרנס.",
            heAttr: "פרקי אבות ה׳ כ״ג"
        ),
        Entry(
            esText: "Quien es sabio, ¿quién? El que aprende de todo ser humano.",
            esAttr: "Pirqé Abot 4:1",
            enText: "Who is wise? One who learns from every person.",
            enAttr: "Pirkei Avot 4:1",
            heText: "איזהו חכם? הלומד מכל אדם.",
            heAttr: "פרקי אבות ד׳ א׳"
        ),
        Entry(
            esText: "El mundo se sustenta en tres cosas: la Torá, el servicio y la bondad gratuita.",
            esAttr: "Pirqé Abot 1:2",
            enText: "The world stands on three things: Torah, service, and acts of kindness.",
            enAttr: "Pirkei Avot 1:2",
            heText: "על שלושה דברים העולם עומד: על התורה, ועל העבודה, ועל גמילות חסדים.",
            heAttr: "פרקי אבות א׳ ב׳"
        ),
        Entry(
            esText: "Amarás a tu prójimo como a ti mismo; yo soy Hashem.",
            esAttr: "Vaiqra 19:18",
            enText: "Love your neighbor as yourself; I am the Lord.",
            enAttr: "Leviticus 19:18",
            heText: "ואהבת לרעך כמוך; אני ה'.",
            heAttr: "ויקרא י״ט י״ח"
        ),
        Entry(
            esText: "Hashem está cerca de todo el que Lo invoca, de todo el que Lo invoca de verdad.",
            esAttr: "Tehilim 145:18",
            enText: "The Lord is near to all who call upon Him, to all who call upon Him in truth.",
            enAttr: "Psalms 145:18",
            heText: "קרוב ה' לכל קוראיו, לכל אשר יקראוהו באמת.",
            heAttr: "תהילים קמ״ה י״ח"
        ),
        Entry(
            esText: "El silencioso sabio tiene preferencia sobre el hábil parlanchín.",
            esAttr: "Pirqé Abot 1:17",
            enText: "The wise who keep silent are preferable to the clever who speak too much.",
            enAttr: "Pirkei Avot 1:17",
            heText: "כל דברי חכמים בנחת נשמעים.",
            heAttr: "פרקי אבות א׳ י״ז"
        ),
        Entry(
            esText: "Cada amanecer es buen momento para agradecer y elevar el corazón hacia Hashem.",
            esAttr: "Tefilá cotidiana",
            enText: "Each dawn is a good time to give thanks and lift the heart toward the Divine.",
            enAttr: "Daily prayer",
            heText: "כל שחר הוא עת טובה להודות ולהרים את הלב אל הקב\"ה.",
            heAttr: "תפילה יומית"
        ),
        Entry(
            esText: "Hashem bendice lo que tus manos están dispuestas a santificar cada día.",
            esAttr: "Kedushá cotidiana",
            enText: "The Divine blesses what your hands are ready to sanctify each day.",
            enAttr: "Daily holiness",
            heText: "הקב\"ה מברך את מה שהידיים שלך מוכנות לקדש בכל יום.",
            heAttr: "קדושה יומית"
        ),
        Entry(
            esText: "La teshuvá, la tefilá y la tsedaká pueden neutralizar lo adverso del decreto.",
            esAttr: "Liturgia de Rosh Hashaná",
            enText: "Repentance, prayer, and charity can soften what is harsh in a decree.",
            enAttr: "Rosh Hashanah liturgy",
            heText: "תשובה, תפילה וצדקה מעבירין את רוע הגזרה.",
            heAttr: "ליטורגיית ראש השנה"
        ),
        Entry(
            esText: "El Shemá nos recuerda: escucha, Israel — Hashem nuestro Dios es Uno único.",
            esAttr: "Devarim 6:4",
            enText: "The Shema reminds us: Hear, O Israel — the Lord our God, the Lord is One.",
            enAttr: "Deuteronomy 6:4",
            heText: "שמע ישראל, ה' אלוקינו, ה' אחד.",
            heAttr: "דברים ו׳ ד׳"
        ),
        Entry(
            esText: "En la puerta de tu casa pon la palabra de la Torá.",
            esAttr: "Devarim 6:9",
            enText: "Place the word of Torah at the entrance of your home.",
            enAttr: "Deuteronomy 6:9",
            heText: "וכתבתם על מזוזות ביתך.",
            heAttr: "דברים ו׳ ט׳"
        ),
        Entry(
            esText: "¿Quién es rico? El que se alegra de su parte.",
            esAttr: "Pirqé Abot 4:1",
            enText: "Who is rich? One who rejoices in his portion.",
            enAttr: "Pirkei Avot 4:1",
            heText: "איזהו עשיר? השמח בחלקו.",
            heAttr: "פרקי אבות ד׳ א׳"
        ),
        Entry(
            esText: "La paz y la corrección obran donde la Torá sustenta cada paso cotidiano.",
            esAttr: "Enseñanza de Avot baTorá",
            enText: "Peace and repair flourish where Torah upholds each daily step.",
            enAttr: "Teaching of the fathers in Torah",
            heText: "שלום ותיקון פועלים במקום שהתורה מחזיקה כל צעד יומי.",
            heAttr: "לימוד אבות בתורה"
        ),
    ]

  static var all: [JewishInspirationPhrase] {
        catalog.map { $0.resolved() }
    }

    /// Día gregoriano (1…365/366): número mostrado en la tarjeta «Frase del Tanaj» y coherencia con widgets.
    static func dayOrdinal(for date: Date = Date(), calendar: Calendar = .current) -> Int {
        let day = calendar.ordinality(of: .day, in: .year, for: date) ?? 1
        return max(1, day)
    }

    /// Una frase por día gregoriano estable (coincide con el widget principal).
    static func phrase(for date: Date = Date(), calendar: Calendar = .current) -> JewishInspirationPhrase {
        let day = dayOrdinal(for: date, calendar: calendar)
        guard !catalog.isEmpty else {
            return JewishInspirationPhrase(
                text: LocaleTriple.pick(
                    "Añade frases en JewishPhraseLibrary.",
                    "Add phrases in JewishPhraseLibrary.",
                    "הוסף פסוקים ב-JewishPhraseLibrary."
                ),
                attribution: ""
            )
        }
        return catalog[(day - 1) % catalog.count].resolved()
    }

    /// Varios huecos dentro del día (ej. cada 4 horas) para segundo widget tipo carrusel.
    static func phrase(slotWithinDay slot: Int, on date: Date = Date(), calendar: Calendar = .current) -> JewishInspirationPhrase {
        let day = dayOrdinal(for: date, calendar: calendar)
        guard !catalog.isEmpty else {
            return phrase(for: date, calendar: calendar)
        }
        let idx = (day - 1 + slot * 17) % catalog.count
        return catalog[idx].resolved()
    }
}
