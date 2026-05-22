import Foundation

// MARK: - Localización liviana (sigue el idioma del sistema)

/// Textos de producto en **español, inglés y hebreo** según `Locale.current`.
/// No usa catálogos `.strings` para no romper el árbol del proyecto; todo el contenido está definido aquí.
enum TefilaCopy {
    /// Elige cadena según idioma (he / en / resto → es).
    static func choose(_ es: String, _ en: String, _ he: String) -> String {
        LocaleTriple.pick(es, en, he)
    }

    // MARK: - Pestañas

    static var tabHome: String { choose("Inicio", "Home", "בית") }
    static var tabPassages: String { choose("Pasajes", "Passages", "שמורים") }
    static var tabTefila: String { choose("Mis oraciones", "My prayers", "תפילותיי") }

    /// SF Symbol pestaña Mis oraciones (`book.pages.fill` se lee mejor en tamaño Tab que la menorá).
    static let tabTefilaSystemImage = "book.pages.fill"

    static var tabChat: String { choose("Guía", "Guide", "הדרכה") }

    // MARK: - Inicio

    static var homePrimaryCTA: String {
        choose(
            "Solicitar tefilá personalizada · תפילה",
            "Request personalized prayer · Tefilah",
            "לבקשת תפילה אישית"
        )
    }

    static var homeCategoryHeading: String {
        choose(
            "Elige una intención espiritual · תורה",
            "Choose a spiritual intention · Torah",
            "בחירת כוונה רוחנית · תורה"
        )
    }

    /// Título corto sobre la inspiración diaria en la tarjeta superior.
    static var inspirationCardTitle: String {
        choose(
            "FRASE DEL TANAJ",
            "VERSE FROM THE TANAKH",
            "פסוק מהתנ״ך"
        )
    }

    static var inspirationCardTorahAccent: String {
        choose("תורה · מקור התעוררות", "Torah · daily inspiration", "תורה")
    }

    // MARK: - Tefilá (lista principal)

    static var prayersNavTitle: String { tabTefila }

    // MARK: - Pasajes

    static var passagesNavTitle: String {
        choose("Pasajes", "Passages", "שמורים")
    }

    // MARK: - Chat

    static var chatSearchPrompt: String {
        choose(
            "Buscar conversaciones",
            "Search conversations",
            "חיפוש שיחות"
        )
    }

    static var spiritualProgressHint: String {
        choose(
            "Tu camino espiritual",
            "Your spiritual path",
            "המסע הרוחני שלך"
        )
    }

    static var widgetsLanguageFootnote: String {
        choose(
            "El idioma principal sigue tu iPhone (es/en/he). Pantallas grandes usan estos textos al instante.",
            "Titles follow system language instantly (Spanish · English · Hebrew snippets).",
            "הטקסטים המרכזיים מותאמים לפי הגדרות המכשיר (ספרדית, אנגלית ועברית בסיסית)."
        )
    }

    // MARK: - Nombres · peticiones (pantalla heredada de listado)

    static var hebrewNamesNavTitle: String {
        choose(
            "Nombres para tefilá",
            "Names for prayer",
            "שמות לתפילה"
        )
    }

    static func hebrewNamesCountLabel(_ countString: String) -> String {
        choose(
            "\(countString) nombres hebreos",
            "\(countString) Hebrew names",
            "\(countString) שמות שנרשמו"
        )
    }

    static var hebrewNamesEmptyTitle: String {
        choose("Sin coincidencias", "No matches", "אין תוצאות")
    }

    static var hebrewNamesEmptySubtitle: String {
        choose(
            "Prueba con otro nombre hebreo o su motivo espiritual.",
            "Try another Hebrew name or spiritual note.",
            "נסה לחפש בשם בעברית או לפי הערת כוונה."
        )
    }

    static var hebrewNamesAddTitle: String {
        choose(
            "Añadir nombre hebreo",
            "Add Hebrew name",
            "הוספת שם עברי"
        )
    }

    static var hebrewNamesAddSubtitle: String {
        choose(
            "Incluye el nombre para tefilot y Tehilim comunitarios.",
            "Adds the name for communal tefilah and Psalms.",
            "מוסיף את השם לתפילה ולאמירת תהילים."
        )
    }
}
