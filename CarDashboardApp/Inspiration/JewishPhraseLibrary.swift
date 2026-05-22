import Foundation

/// Cita o enseñanza breve para inspiración diaria (tradición judía, texto en español).
struct JewishInspirationPhrase: Equatable {
    let text: String
    /// Origen aproximado: Tanaj, Mishná, Pirqé Abot, etc.
    let attribution: String
}

/// Catálogo editable: añade más entradas cuando quieras; app y widget comparten la lista.
enum JewishPhraseLibrary {
    static let all: [JewishInspirationPhrase] = [
        JewishInspirationPhrase(
            text: "Cada palabra de tefilá es un puente hacia Hashem.",
            attribution: "Enseñanza de tefilá"
        ),
        JewishInspirationPhrase(
            text: "No estás obligado a terminar el trabajo, pero tampoco eres libre de abandonarlo.",
            attribution: "Pirqé Abot 2:21"
        ),
        JewishInspirationPhrase(
            text: "Según el esfuerzo es la recompensa.",
            attribution: "Pirqé Abot 5:23"
        ),
        JewishInspirationPhrase(
            text: "Quien es sabio, ¿quién? El que aprende de todo ser humano.",
            attribution: "Pirqé Abot 4:1"
        ),
        JewishInspirationPhrase(
            text: "El mundo se sustenta en tres cosas: la Torá, el servicio y la bondad gratuita.",
            attribution: "Pirqé Abot 1:2"
        ),
        JewishInspirationPhrase(
            text: "Amarás a tu prójimo como a ti mismo; yo soy Hashem.",
            attribution: "Vaiqra 19:18"
        ),
        JewishInspirationPhrase(
            text: "Hashem está cerca de todo el que Lo invoca, de todo el que Lo invoca de verdad.",
            attribution: "Tehilim 145:18"
        ),
        JewishInspirationPhrase(
            text: "El silencioso sabio tiene preferencia sobre el hábil parlanchín.",
            attribution: "Pirqé Abot 1:17"
        ),
        JewishInspirationPhrase(
            text: "Cada amanecer es buen momento para agradecer y elevar el corazón hacia Hashem.",
            attribution: "Tefilá cotidiana"
        ),
        JewishInspirationPhrase(
            text: "Hashem bendice lo que tus manos están dispuestas a santificar cada día.",
            attribution: "Kedushá cotidiana"
        ),
        JewishInspirationPhrase(
            text: "La teshuvá, la tefilá y la tsedaká pueden neutralizar lo adverso del decreto.",
            attribution: "Liturgia de Rosh Hashaná · tradición rabínica"
        ),
        JewishInspirationPhrase(
            text: "El Shemá nos recuerda: escucha, Israel — Hashem nuestro Dios es Uno único.",
            attribution: "Devarim 6:4"
        ),
        JewishInspirationPhrase(
            text: "En la puerta de tu casa pon la palabra de la Torá.",
            attribution: "Devarim 6:9 — mezuzá"
        ),
        JewishInspirationPhrase(
            text: "¿Quién es rico? El que se alegra de su parte.",
            attribution: "Pirqé Abot 4:1"
        ),
        JewishInspirationPhrase(
            text: "La paz y la corrección obran donde la Torá sustenta cada paso cotidiano.",
            attribution: "Enseñanza de Avot baTorá"
        ),
    ]

    /// Día gregoriano (1…365/366): número mostrado en la tarjeta «Frase del Tanaj» y coherencia con widgets.
    static func dayOrdinal(for date: Date = Date(), calendar: Calendar = .current) -> Int {
        let day = calendar.ordinality(of: .day, in: .year, for: date) ?? 1
        return max(1, day)
    }

    /// Una frase por día gregoriano estable (coincide con el widget principal).
    static func phrase(for date: Date = Date(), calendar: Calendar = .current) -> JewishInspirationPhrase {
        let day = dayOrdinal(for: date, calendar: calendar)
        guard !all.isEmpty else {
            return JewishInspirationPhrase(text: "Añade frases en JewishPhraseLibrary.", attribution: "")
        }
        return all[(day - 1) % all.count]
    }

    /// Varios huecos dentro del día (ej. cada 4 horas) para segundo widget tipo carrusel.
    static func phrase(slotWithinDay slot: Int, on date: Date = Date(), calendar: Calendar = .current) -> JewishInspirationPhrase {
        let day = dayOrdinal(for: date, calendar: calendar)
        guard !all.isEmpty else {
            return phrase(for: date, calendar: calendar)
        }
        /// Desfase estable por día y hueco (no es la misma que “frase del día”).
        let idx = (day - 1 + slot * 17) % all.count
        return all[idx]
    }
}
