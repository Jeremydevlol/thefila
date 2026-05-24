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
            return LocaleTriple.pick("Sustento", "Livelihood", "פרנסה")
        case .shalomBayit:
            return LocaleTriple.pick("Paz en el hogar", "Peace in the home", "שלום בית")
        case .refua:
            return LocaleTriple.pick("Sanación completa", "Complete healing", "רפואה שלימה")
        case .zeraBeracha:
            return LocaleTriple.pick(
                "Fertilidad y descendencia",
                "Fertility and family blessing",
                "זרע ברוך וברכה משפחתית"
            )
        case .shemira:
            return LocaleTriple.pick(
                "Protección y cuidado",
                "Protection and watchfulness",
                "שמירה והסתרה"
            )
        case .hazlacha:
            return LocaleTriple.pick(
                "Éxito con bendición",
                "Success with blessing",
                "הצלחה בברכה"
            )
        }
    }

    var subtitle: String {
        switch self {
        case .parnassa:
            return LocaleTriple.pick(
                "Salmos y oración · sustento digno",
                "Psalms and prayer · dignified sustenance",
                "תהילים ותפילה · פרנסה בכבוד"
            )
        case .shalomBayit:
            return LocaleTriple.pick(
                "Armonía familiar y amor",
                "Family harmony and love",
                "הרמוניה ביתית · אהבה וסבלנות"
            )
        case .refua:
            return LocaleTriple.pick(
                "Recuperación con compasión",
                "Merciful recovery",
                "רחמים ורפואה גוף־נפש"
            )
        case .zeraBeracha:
            return LocaleTriple.pick(
                "Deseo santo de formar familia",
                "Holy desire for children",
                "בקשה בהכרת הטוב"
            )
        case .shemira:
            return LocaleTriple.pick(
                "Amparo y cobertura divina",
                "Heavenly protection",
                "שמירת שמים ברחמים"
            )
        case .hazlacha:
            return LocaleTriple.pick(
                "Pasos con integridad y santidad",
                "Success with integrity",
                "הצלחה בקדושה ויושר"
            )
        }
    }
}
