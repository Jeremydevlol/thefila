import Foundation
import SwiftUI

// MARK: - Idioma persistido · español / inglés / hebreo

/// Idioma de interfaz elegido por el usuario (persistido en `UserDefaults`).
enum TefilaAppLanguage: String, CaseIterable, Identifiable, Hashable {
    case spanish = "es"
    case english = "en"
    case hebrew = "he"

    var id: String { rawValue }

    /// Debajo del control segmentado — misma cara en cualquier modo de UI.
    var segmentLabel: String {
        switch self {
        case .spanish: return "ES"
        case .english: return "EN"
        case .hebrew: return "עב"
        }
    }

    static let persistenceKey = "TefilaAppLanguageSelection"

    static func inferredFromSystemLocale() -> TefilaAppLanguage {
        switch String(Locale.current.language.languageCode?.identifier.prefix(2) ?? "es") {
        case "he":
            return .hebrew
        case "en":
            return .english
        default:
            return .spanish
        }
    }
}

/// Selección de cadenas trilingües; respeta **`TefilaAppLanguage`** en Ajustes o, si falta valor, deduce desde el idioma del sistema.
enum LocaleTriple {
    static func resolvedLanguage() -> TefilaAppLanguage {
        if let raw = UserDefaults.standard.string(forKey: TefilaAppLanguage.persistenceKey),
           let lang = TefilaAppLanguage(rawValue: raw) {
            return lang
        }
        return TefilaAppLanguage.inferredFromSystemLocale()
    }

    static func pick(_ es: String, _ en: String, _ he: String) -> String {
        switch resolvedLanguage() {
        case .spanish:
            return es
        case .english:
            return en
        case .hebrew:
            return he
        }
    }
}

// MARK: - Localización liviana (`TefilaCopy.choose`)

/// Textos de producto en **español, inglés y hebreo** según idioma elegido en Ajustes (o idioma del sistema hasta la primera visita).
enum TefilaCopy {
    /// Elige cadena según idioma.
    static func choose(_ es: String, _ en: String, _ he: String) -> String {
        LocaleTriple.pick(es, en, he)
    }

    // MARK: - Pestañas

    static var tabHome: String { choose("Inicio", "Home", "בית") }
    static var tabPassages: String { choose("Pasajes", "Passages", "שמורים") }
    static var tabTefila: String { choose("Mis oraciones", "My prayers", "תפילותיי") }
    /// Pestaña Ajustes / perfil.
    static var tabProfile: String { choose("Perfil", "Profile", "פרופיל") }

    /// SF Symbol pestaña Mis oraciones (`book.pages.fill` se lee mejor en tamaño Tab que la menorá).
    static let tabTefilaSystemImage = "book.pages.fill"

    static var tabChat: String { choose("Guía", "Guide", "הדרכה") }

    // MARK: - Sesión · autenticación

    static var authConnecting: String {
        choose("Conectando…", "Connecting…", "מתחבר…")
    }

    static var loginHelpTitle: String { choose("Ayuda", "Help", "עזרה") }
    static var loginHelpMessage: String {
        choose(
            "Próximamente podrás obtener ayuda desde aquí.",
            "Help from here will arrive in a future update.",
            "בקרוב יהיה אפשר לקבל עזרה מכאן."
        )
    }
    static var loginOK: String { choose("OK", "OK", "אישור") }

    static var loginWelcomeSignIn: String {
        choose("Iniciar sesión", "Sign in", "התחברות")
    }
    static var loginWelcomeSignUp: String {
        choose("Crear cuenta", "Create account", "יצירת חשבון")
    }

    static var loginSignInTitle: String {
        choose(
            "Nos alegra verte de nuevo · ברוכים הבאים",
            "Glad to see you · ברוכים הבאים",
            "ברוכים השבים · שמחים לראותך"
        )
    }
    static var loginSignInSubtitle: String {
        choose(
            "Introduce el correo y la contraseña de tu cuenta Tefila.",
            "Enter your email and password for Tefila.",
            "הזן את האימייל והסיסמה לחשבון טפלה."
        )
    }

    static var loginSignUpTitle: String {
        choose("Crea tu cuenta", "Create your account", "צור חשבון")
    }
    static var loginSignUpSubtitle: String {
        choose(
            "Usa tu correo para registrar Tefila y sincronizar preferencias cuando actives tu cuenta.",
            "Use your email to register for Tefila and sync preferences when your account activates.",
            "השתמש באימייל כדי להירשם לטפלה ולסנכרן הגדרות כשהחשבון יופעל."
        )
    }

    static var loginEmailPlaceholder: String {
        choose("Correo electrónico", "Email", "אימייל")
    }
    static var loginPasswordPlaceholder: String {
        choose("Contraseña", "Password", "סיסמה")
    }

    static var loginForgotPassword: String {
        choose("¿Olvidaste la contraseña?", "Forgot password?", "שכחת את הסיסמה?")
    }
    static var loginNoAccount: String {
        choose("¿No tienes cuenta? Crear cuenta", "No account? Create one", "אין לך חשבון? הירשם")
    }
    static var loginHasAccount: String {
        choose("¿Ya tienes cuenta? Iniciar sesión", "Have an account? Sign in", "כבר יש לך חשבון? התחבר")
    }

    static var loginContinue: String { choose("Continuar", "Continue", "המשך") }

    static var loginResetShortEmail: String { choose("Correo", "Email", "מייל") }
    static var loginResetNavTitle: String {
        choose("Recuperar acceso", "Recover access", "שחזור גישה")
    }
    static var loginClose: String { choose("Cerrar", "Close", "סגירה") }
    static var loginSend: String { choose("Enviar", "Send", "שליחה") }

    // MARK: - Ajustes

    static var settingsTitle: String { choose("Ajustes", "Settings", "הגדרות") }
    static var settingsSearchPlaceholder: String { choose("Buscar", "Search", "חיפוש") }
    static var settingsDone: String { choose("Listo", "Done", "סיום") }
    static var settingsLanguageSectionTitle: String {
        choose("Idioma de la app", "App language", "שפת האפליקציה")
    }
    static var settingsLanguageSectionSubtitle: String {
        choose(
            "Español, inglés y hebreo. Al cambiar, se actualizan todas las pantallas.",
            "Spanish, English, and Hebrew. All screens refresh when you change this.",
            "ספרדית, אנגלית ועברית. עם השינוי כל המסכים מתעדכנים מחדש."
        )
    }
    static var settingsNotificationsAccent: String {
        choose("Notificaciones", "Notifications", "התראות")
    }

    static var settingsSignOutDialogTitle: String {
        choose("¿Cerrar sesión?", "Sign out?", "להתנתק?")
    }
    static var settingsSignOutDialogMessageAuthenticated: String {
        choose(
            "Se cerrará tu sesión en la nube en este dispositivo.",
            "Your cloud session on this device will end.",
            "ההתחברות לענן במכשיר זה תיסגר."
        )
    }
    static var settingsSignOutDialogMessageGuest: String {
        choose(
            "Se borrarán los datos de sesión guardados aquí.",
            "Locally saved session data will be cleared.",
            "נתוני ההתחברות השמורים כאן יימחקו."
        )
    }
    static var settingsSignOutDestructive: String {
        choose("Cerrar sesión", "Sign out", "התנתקות")
    }
    static var settingsCancel: String { choose("Cancelar", "Cancel", "ביטול") }

    static var settingsSignOutRowTitle: String {
        choose("Cerrar sesión", "Sign out", "התנתקות")
    }
    static var settingsSignOutRowSubtitleAuthenticated: String {
        choose(
            "Tu cuenta enlazada en la nube",
            "Your linked cloud account",
            "החשבון המחובר לענן"
        )
    }
    static var settingsSignOutRowSubtitleGuest: String {
        choose(
            "Sin cuenta vinculada · limpiar sesión local",
            "No linked account · clear local session",
            "ללא חשבון מקושר · ניקוי מקומי"
        )
    }

    static var settingsWidgetsExplainer: String {
        choose(
            "Los widgets «Tefila · Tanaj» muestran frases del Tanaj (tamaños grandes, mediano y pequeño) y texto compacto en la pantalla de bloqueo. Mantén pulsado el inicio · + · busca «Tefila». Si ya añadiste el widget, el botón de abajo fuerza una actualización.",
            "«Tefila · Tanakh» widgets show Torah verses on the Home Screen and Lock Screen. Touch and hold the Home Screen · + · search for «Tefila». If added already, tap below to reload timelines.",
            "ווידג'טים «טפלה · תנ״ך» מראים קטעי תנ\"ך במסך הבית ובמסך הנעילה. לחץ לחיצה ארוכה על הבית · + · חפש «Tefila». אם כבר הוספת, השורה הבאה תרענן."
        )
    }

    static var settingsWidgetsReload: String {
        choose("Actualizar widgets ahora", "Reload widgets now", "עדכן ווידג'טים")
    }

    static var settingsVersionRow: String { choose("Versión", "Version", "גרסה") }

    static var settingsProfileCloud: String {
        choose("Sesión Supabase", "Supabase session", "התחברות Supabase")
    }
    static var settingsProfileLocal: String {
        choose("Acceso directo · sin cuenta", "Direct access · no account", "גישה ישירה · ללא חשבון")
    }

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
            "Los textos de la app siguen el idioma que elijas en Ajustes.",
            "In-app text follows your language choice in Settings.",
            "כיתובי האפליקציה לפי השפה שבחרת בהגדרות."
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

// MARK: - SwiftUI · claves desde cadenas de `TefilaCopy`

extension LocalizedStringKey {
    /// Texto decidido en runtime (`TefilaCopy`).
    init(tefilaDynamic string: String) {
        self.init(string)
    }
}
