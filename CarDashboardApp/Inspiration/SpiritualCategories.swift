import Foundation

// MARK: - Intenciones en Inicio (rejilla 2 columnas × 6 tarjetas)

enum SpiritualCategoryID: String, CaseIterable, Identifiable {
    case parnassa
    case shalomBayit
    case refua
    case zeraBeracha
    case shemira
    case hazlacha

    var id: String { rawValue }

    var headline: String {
        switch self {
        case .parnassa:
            return LocaleTriple.pick("Parnassá", "Parnassah", "פרנסה")
        case .shalomBayit:
            return LocaleTriple.pick("Shalom bait", "Peace in the home", "שלום בית")
        case .refua:
            return LocaleTriple.pick("Refuá shlemá", "Complete healing", "רפואה שלימה")
        case .zeraBeracha:
            return LocaleTriple.pick(
                "Fertilidad y zera kadosh",
                "Fertility & holy seed",
                "זרע ברוך וברכה משפחתית"
            )
        case .shemira:
            return LocaleTriple.pick(
                "Protección y shemirá",
                "Protection & watchfulness",
                "שמירה והסתרה"
            )
        case .hazlacha:
            return LocaleTriple.pick(
                "Hazlajá beraja",
                "Success with blessing",
                "הצלחה בברכה"
            )
        }
    }

    var subtitle: String {
        switch self {
        case .parnassa:
            return LocaleTriple.pick(
                "Tehilim y tefilá · sustento con dignidad",
                "Psalms & tefilah · dignified sustenance",
                "תהילים ותפילה · פרנסה בכבוד"
            )
        case .shalomBayit:
            return LocaleTriple.pick(
                "Armonía familiar · אהבה",
                "Family harmony · ahavah",
                "הרמוניה ביתית · אהבה וסבלנות"
            )
        case .refua:
            return LocaleTriple.pick(
                "Recuperación con rachamim",
                "Merciful recovery",
                "רחמים ורפואה גוף־נפש"
            )
        case .zeraBeracha:
            return LocaleTriple.pick(
                "Mesirut nefesh parental",
                "Holy desire for children",
                "בקשה בהכרת הטוב"
            )
        case .shemira:
            return LocaleTriple.pick(
                "Cubierta de Shamáyim",
                "Heavenly covering",
                "שמירת שמים ברחמים"
            )
        case .hazlacha:
            return LocaleTriple.pick(
                "Pasos con kedushá",
                "Success with integrity",
                "הצלחה בקדושה ויושר"
            )
        }
    }
}
