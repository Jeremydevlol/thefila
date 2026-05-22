import SwiftUI

// MARK: - Tier de servicio

enum PrayerTier: String, CaseIterable, Identifiable {
    case standard
    case premium

    var id: String { rawValue }

    var label: String {
        switch self {
        case .standard: return TefilaCopy.choose("Estándar", "Standard", "סטנדרטי")
        case .premium:  return TefilaCopy.choose("Premium", "Premium", "פרימיום")
        }
    }

    var systemIcon: String {
        switch self {
        case .standard: return "star.of.david.fill"
        case .premium:  return "diamond.fill"
        }
    }

    var accentColor: Color {
        switch self {
        case .standard: return Color(red: 0.18, green: 0.34, blue: 0.72)
        case .premium:  return Color(red: 0.55, green: 0.38, blue: 0.82)
        }
    }
}

// MARK: - Lugares sagrados

enum SacredLocation: String, CaseIterable, Identifiable {
    case kotel
    case rachelsTomb
    case breslov
    case jerusalem
    case meron
    case chevron

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .kotel:       return TefilaCopy.choose("Kotel (Muro Occidental)", "Kotel (Western Wall)", "הכותל המערבי")
        case .rachelsTomb: return TefilaCopy.choose("Tumba de Rajel", "Rachel's Tomb", "קבר רחל")
        case .breslov:     return TefilaCopy.choose("Uman · R. Najmán", "Uman · R. Nachman", "אומן · רבי נחמן")
        case .jerusalem:   return TefilaCopy.choose("Jerusalem · Yerushalayim", "Jerusalem", "ירושלים")
        case .meron:       return TefilaCopy.choose("Monte Merón · R. Shimón", "Mount Meron · R. Shimon", "הר מירון · ר׳ שמעון")
        case .chevron:     return TefilaCopy.choose("Maarat HaMajpelá · Jébrón", "Cave of Machpelah · Hebron", "מערת המכפלה")
        }
    }

    var subtitle: String {
        switch self {
        case .kotel:       return TefilaCopy.choose("Shejiná · pared oeste del Templo", "Shechinah · Temple's western wall", "שכינה · כותל בית המקדש")
        case .rachelsTomb: return TefilaCopy.choose("Majpelá · madre del pueblo", "Mother of Israel · Beit Lechem", "אם ישראל · בית לחם")
        case .breslov:     return TefilaCopy.choose("Tikkun HaKlali · Rosh Hashaná", "Tikkun HaKlali · Rosh Hashana", "תיקון הכללי · ראש השנה")
        case .jerusalem:   return TefilaCopy.choose("Ciudad santa · Ir HaKodesh", "Holy city · Ir HaKodesh", "עיר הקודש")
        case .meron:       return TefilaCopy.choose("Lag BaOmer · ruach kodesh", "Lag BaOmer · holy spirit", "ל״ג בעומר · רוח הקודש")
        case .chevron:     return TefilaCopy.choose("Patriarcas y Matriarcas · Avot", "Patriarchs & Matriarchs · Avot", "אבות ואמהות · חברון")
        }
    }

    var systemIcon: String {
        switch self {
        case .kotel:       return "building.columns.fill"
        case .rachelsTomb: return "figure.stand"
        case .breslov:     return "book.closed.fill"
        case .jerusalem:   return "star.of.david.fill"
        case .meron:       return "mountain.2.fill"
        case .chevron:     return "house.fill"
        }
    }

    var accentColor: Color {
        switch self {
        case .kotel:       return Color(red: 0.72, green: 0.60, blue: 0.38)
        case .rachelsTomb: return Color(red: 0.72, green: 0.32, blue: 0.52)
        case .breslov:     return Color(red: 0.28, green: 0.48, blue: 0.82)
        case .jerusalem:   return Color(red: 0.82, green: 0.62, blue: 0.22)
        case .meron:       return Color(red: 0.42, green: 0.62, blue: 0.38)
        case .chevron:     return Color(red: 0.58, green: 0.42, blue: 0.28)
        }
    }
}

// MARK: - Servicio de oración

struct PrayerService: Identifiable, Hashable, Equatable {
    let id: String
    let categoryId: String          // SpiritualCategoryID.rawValue
    let eyebrow: String             // "Tehilim", "Tikkun HaKlali", etc.
    let title: String
    let description: String
    let longDescription: String     // Para la pantalla de detalle
    let durationLabel: String       // "30 mín", "25 mín"
    let iconSystemName: String
    let iconColor: Color
    let backdropAsset: String
    let hebrewTitle: String
    let spiritualNote: String       // Texto de bendición / fuente espiritual
    let rabbiSource: String         // "Según el Baba Sali…"

    static func == (lhs: PrayerService, rhs: PrayerService) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

// MARK: - Solicitud de oración

struct PrayerRequest: Identifiable {
    let id: String
    let service: PrayerService
    let tier: PrayerTier
    let hebrewName: String
    let mothersHebrewName: String
    let personalNote: String
    let sacredLocation: SacredLocation
    let submittedAt: Date

    init(
        service: PrayerService,
        tier: PrayerTier,
        hebrewName: String,
        mothersHebrewName: String,
        personalNote: String,
        sacredLocation: SacredLocation
    ) {
        self.id = UUID().uuidString
        self.service = service
        self.tier = tier
        self.hebrewName = hebrewName
        self.mothersHebrewName = mothersHebrewName
        self.personalNote = personalNote
        self.sacredLocation = sacredLocation
        self.submittedAt = Date()
    }
}

// MARK: - Catálogo completo de servicios por categoría

enum PrayerServiceCatalog {

    /// Todos los servicios disponibles en la plataforma.
    static let allServices: [PrayerService] = [

        // ── HAZLACHA (Éxito) ────────────────────────────────────────────────
        PrayerService(
            id: "hazlacha_tehilim_monthly",
            categoryId: "hazlacha",
            eyebrow: TefilaCopy.choose("Tehilim mensual", "Monthly Tehillim", "תהילים חודשי"),
            title: TefilaCopy.choose("Tehilim del mes (completo)", "Today's (Monthly) Tehillim", "תהילים חודשי מלא"),
            description: TefilaCopy.choose(
                "Tehilim (Salmos) es un libro de oraciones, alabanzas e himnos a Dios, compuesto por el Rey David.",
                "Tehillim (Psalms) is a book of prayers, praises, and hymns to G-d, composed by King David.",
                "תהילים הוא ספר תפילות, שבחות והמנונים לה', שחוברו על ידי המלך דוד."
            ),
            longDescription: TefilaCopy.choose(
                "Según el Baba Sali, recitar los Salmos tiene una virtud especial, y los versículos de los Salmos tienen un efecto poderoso en los cielos. Un estudioso de Torá recitará el Tehilim completo del mes en tu nombre.",
                "According to the Baba Sali, reciting Psalms has a special virtue, and the verses of Psalms have a powerful effect in the heavens. A Torah scholar will recite the complete monthly Tehillim on your behalf.",
                "לפי הבבא סאלי, לאמירת תהילים יש סגולה מיוחדת, ולפסוקי תהילים יש השפעה עצומה בשמים."
            ),
            durationLabel: TefilaCopy.choose("30 mínimo", "30 minutes", "30 דקות"),
            iconSystemName: "book.closed.fill",
            iconColor: Color(red: 0.52, green: 0.36, blue: 0.78),
            backdropAsset: "Salmo",
            hebrewTitle: "תהילים חודשי",
            spiritualNote: TefilaCopy.choose(
                "«Dichoso el hombre que no camina en el consejo de los impíos…» — Tehilim 1",
                "«Blessed is the man who does not walk in step with the wicked…» — Psalm 1",
                "«אַשְׁרֵי הָאִישׁ אֲשֶׁר לֹא הָלַךְ בַּעֲצַת רְשָׁעִים» — תהילים א׳"
            ),
            rabbiSource: TefilaCopy.choose(
                "Tradición del Baba Sali · Mekubal de Marruecos",
                "Tradition of Baba Sali · Moroccan Kabbalist",
                "מסורת הבבא סאלי · מקובל ממרוקו"
            )
        ),

        PrayerService(
            id: "hazlacha_tikkun_klali",
            categoryId: "hazlacha",
            eyebrow: TefilaCopy.choose("Tikkun HaKlali", "Tikkun Ha'Klali", "תיקון הכללי"),
            title: TefilaCopy.choose("Tikkun HaKlali (R. Najmán)", "Tikkun Ha'Klali", "תיקון הכללי"),
            description: TefilaCopy.choose(
                "El Tikun Haklali es una serie de diez capítulos de Salmos compuestos por el Rabino Najmán de Breslov como un secreto…",
                "The Tikun Haklali is a series of ten chapters of Psalms composed by Rabbi Nachman of Breslov, as a secr…",
                "תיקון הכללי הוא עשרה פרקי תהילים שנקבעו על ידי רבי נחמן מברסלב."
            ),
            longDescription: TefilaCopy.choose(
                "El Rabino Najmán de Breslov reveló que estos diez capítulos de Tehilim (16, 32, 41, 42, 59, 77, 90, 105, 137, 150) constituyen un remedio espiritual completo. Un rabino breslov los recitará por ti.",
                "Rabbi Nachman of Breslov revealed that these ten chapters of Tehillim constitute a complete spiritual remedy. A Breslov rabbi will recite them on your behalf.",
                "רבי נחמן מברסלב גילה שעשרה פרקים אלו הם תיקון שלם לנפש."
            ),
            durationLabel: TefilaCopy.choose("25 mínimo", "25 minutes", "25 דקות"),
            iconSystemName: "scroll.fill",
            iconColor: Color(red: 0.32, green: 0.48, blue: 0.82),
            backdropAsset: "Minja",
            hebrewTitle: "תיקון הכללי",
            spiritualNote: TefilaCopy.choose(
                "«El justo vive por su fe.» — Habacuc 2:4",
                "«The righteous shall live by his faith.» — Habakkuk 2:4",
                "«וְצַדִּיק בֶּאֱמוּנָתוֹ יִחְיֶה» — חבקוק ב׳ד׳"
            ),
            rabbiSource: TefilaCopy.choose(
                "Tradición de R. Najmán de Breslov · Ucrania",
                "Tradition of R. Nachman of Breslov · Ukraine",
                "מסורת רבי נחמן מברסלב"
            )
        ),

        PrayerService(
            id: "hazlacha_shir_hamaalot",
            categoryId: "hazlacha",
            eyebrow: TefilaCopy.choose("Shir HaMaalot", "Shir Ha'Maalot", "שיר המעלות"),
            title: TefilaCopy.choose("Tehilim 120–134 · Shir HaMaalot", "Tehillim (120-134) Shir Ha'Maalot", "תהילים קכ׳-קלד׳ שיר המעלות"),
            description: TefilaCopy.choose(
                "Los Cánticos de los Ascensos (Salmos 120–134) son un grupo de quince salmos del Libro de Salmos que se han convertido en parte central de la liturgia.",
                "The Songs of Ascents (Psalms 120-134) are a group of fifteen psalms in the Book of Psalms that have become central to liturgy.",
                "שירי המעלות הם קבוצה של חמישה עשר מזמורים בספר תהילים."
            ),
            longDescription: TefilaCopy.choose(
                "Estos quince salmos eran cantados por los levitas en el Templo de Jerusalem al ascender los quince escalones. Recitarlos hoy conecta con esa elevación espiritual y es segulá para el éxito y la ascensión.",
                "These fifteen psalms were sung by the Levites in the Jerusalem Temple as they ascended fifteen steps. Reciting them today connects to that spiritual elevation.",
                "שירי המעלות נאמרו על ידי הלויים במקדש ירושלים על פני חמישה עשר מדרגות."
            ),
            durationLabel: TefilaCopy.choose("20 mínimo", "20 minutes", "20 דקות"),
            iconSystemName: "music.note",
            iconColor: Color(red: 0.38, green: 0.70, blue: 0.52),
            backdropAsset: "Palabra",
            hebrewTitle: "שיר המעלות",
            spiritualNote: TefilaCopy.choose(
                "«Cántico de los ascensos. Alcé mis ojos a los montes, ¿de dónde vendrá mi socorro?» — Tehilim 121",
                "«A song of ascents. I lift my eyes to the mountains — where does my help come from?» — Psalm 121",
                "«שִׁיר לַמַּעֲלוֹת אֶשָּׂא עֵינַי אֶל הֶהָרִים» — תהילים קכ״א"
            ),
            rabbiSource: TefilaCopy.choose(
                "Tradición del Templo · Levi'im · Jerusalem",
                "Temple tradition · Levites · Jerusalem",
                "מסורת בית המקדש · לויים · ירושלים"
            )
        ),

        PrayerService(
            id: "hazlacha_shir_hashirim",
            categoryId: "hazlacha",
            eyebrow: TefilaCopy.choose("Shir HaShirim", "Shir Ha'Shirim", "שיר השירים"),
            title: TefilaCopy.choose("Shir HaShirim (Cantar de Cantares)", "Shir Ha'Shirim (Song of Songs)", "שיר השירים"),
            description: TefilaCopy.choose(
                "El Cantar de los Cantares es el libro más sagrado de las Escrituras, el kodesh kedoshim de toda la Torá (Rabí Akiva).",
                "The Song of Songs is the holiest of writings, the Holy of Holies of the entire Torah (Rabbi Akiva).",
                "שיר השירים הוא קדש הקדשים של כל כתבי הקודש (רבי עקיבא)."
            ),
            longDescription: TefilaCopy.choose(
                "Shir HaShirim representa el amor eterno entre el Pueblo de Israel y el Creador. Recitarlo tiene una poderosa segulá para el éxito en los negocios, en la vida y en las relaciones. Se lee especialmente en Shabat y Pesaj.",
                "Shir HaShirim represents the eternal love between the Jewish people and the Creator. Reciting it carries a powerful segulah for success in business, life, and relationships.",
                "שיר השירים מייצג את האהבה הנצחית בין עם ישראל לבורא. אמירתו סגולה להצלחה."
            ),
            durationLabel: TefilaCopy.choose("15 mínimo", "15 minutes", "15 דקות"),
            iconSystemName: "music.quarternote.3",
            iconColor: Color(red: 0.78, green: 0.42, blue: 0.62),
            backdropAsset: "Tefila",
            hebrewTitle: "שיר השירים",
            spiritualNote: TefilaCopy.choose(
                "«Que me bese con los besos de su boca, porque mejor es tu amor que el vino.» — Shir HaShirim 1:2",
                "«Let him kiss me with the kisses of his mouth: for thy love is better than wine.» — Song of Songs 1:2",
                "«יִשָּׁקֵנִי מִנְּשִׁיקוֹת פִּיהוּ כִּי טוֹבִים דּוֹדֶיךָ מִיָּיִן» — שיר השירים א׳ב׳"
            ),
            rabbiSource: TefilaCopy.choose(
                "R. Akiva · Mishná · Yadayim 3:5",
                "R. Akiva · Mishnah · Yadayim 3:5",
                "רבי עקיבא · משנה יד׳ ג׳ה׳"
            )
        ),

        // ── REFUA (Salud) ────────────────────────────────────────────────────
        PrayerService(
            id: "refua_tehilim_refua",
            categoryId: "refua",
            eyebrow: "Tehilim",
            title: TefilaCopy.choose("Tehilim para Refuá Shlemá", "Psalms for Complete Healing", "תהילים לרפואה שלימה"),
            description: TefilaCopy.choose(
                "Capítulos especiales de Tehilim — 20, 22, 23, 121 — recitados por su poder curativo según la tradición.",
                "Special Tehillim chapters — 20, 22, 23, 121 — recited for their healing power per tradition.",
                "פרקי תהילים מיוחדים כ׳ כ״ב כ״ג קכ״א — לרפואה שלימה."
            ),
            longDescription: TefilaCopy.choose(
                "Estos capítulos de Tehilim han sido elegidos por generaciones de rabinos como segulot para la recuperación de enfermos. Un estudioso los recitará pronunciando tu nombre hebreo.",
                "These Tehillim chapters have been chosen by generations of rabbis as segulot for healing the sick. A scholar will recite them while pronouncing your Hebrew name.",
                "פרקים אלו נבחרו על ידי דורות של רבנים כסגולות לרפואת חולים."
            ),
            durationLabel: TefilaCopy.choose("20 mínimo", "20 minutes", "20 דקות"),
            iconSystemName: "cross.fill",
            iconColor: Color(red: 0.62, green: 0.28, blue: 0.72),
            backdropAsset: "fortelza",
            hebrewTitle: "רפואה שלימה",
            spiritualNote: TefilaCopy.choose(
                "«El Señor lo sostendrá en el lecho del dolor; en su enfermedad mudará toda su cama.» — Tehilim 41:4",
                "«The Lord sustains them on their sickbed and restores them from their bed of illness.» — Psalm 41:4",
                "«ה׳ יִסְעָדֶנּוּ עַל עֶרֶשׂ דְּוָי» — תהילים מ״א ד׳"
            ),
            rabbiSource: TefilaCopy.choose(
                "Sidur · Birkat HaCholim · tradición askenazí y sefardí",
                "Siddur · Birkat HaCholim · Ashkenazic and Sephardic tradition",
                "סידור · ברכת החולים · מסורת אשכנז וספרד"
            )
        ),

        PrayerService(
            id: "refua_mi_sheberach",
            categoryId: "refua",
            eyebrow: TefilaCopy.choose("Tefilá", "Prayer", "תפילה"),
            title: "Mi Sheberach",
            description: TefilaCopy.choose(
                "La bendición de recuperación por excelencia, recitada en la sinagoga durante la lectura de la Torá.",
                "The quintessential healing blessing, recited in synagogue during Torah reading.",
                "ברכת הרפואה המרכזית הנאמרת בבית הכנסת בעת קריאת התורה."
            ),
            longDescription: TefilaCopy.choose(
                "El Mi Sheberach es recitado por el rabino con el nombre hebreo del enfermo y el nombre de su madre. Es la plegaria más poderosa por la salud plena — refuá shlemá — de cuerpo y alma.",
                "The Mi Sheberach is recited by the rabbi with the Hebrew name of the sick person and their mother's name. It is the most powerful prayer for complete health — refuah shlemah — of body and soul.",
                "מי שברך נאמר על ידי הרב בשם העברי של החולה ושם אמו."
            ),
            durationLabel: TefilaCopy.choose("10 mínimo", "10 minutes", "10 דקות"),
            iconSystemName: "heart.circle.fill",
            iconColor: Color(red: 0.82, green: 0.28, blue: 0.38),
            backdropAsset: "Shajarit",
            hebrewTitle: "מי שברך",
            spiritualNote: TefilaCopy.choose(
                "«Sánanos, Señor, y seremos sanados; sálvanos y seremos salvados.» — Jeremías 17:14",
                "«Heal me, Lord, and I will be healed; save me and I will be saved.» — Jeremiah 17:14",
                "«רְפָאֵנִי ה׳ וְאֵרָפֵא הוֹשִׁיעֵנִי וְאִוָּשֵׁעָה» — ירמיהו י״ז"
            ),
            rabbiSource: TefilaCopy.choose(
                "Sidur · Mi Sheberach · recitado por el rabino de la comunidad",
                "Siddur · Mi Sheberach · recited by the community rabbi",
                "סידור · מי שברך · נאמר על ידי רב הקהילה"
            )
        ),

        PrayerService(
            id: "refua_tikkun_klali_refua",
            categoryId: "refua",
            eyebrow: TefilaCopy.choose("Tikkun HaKlali", "Tikkun Ha'Klali", "תיקון הכללי"),
            title: TefilaCopy.choose("Tikkun HaKlali para sanación", "Tikkun Ha'Klali for healing", "תיקון הכללי לרפואה"),
            description: TefilaCopy.choose(
                "Los diez salmos de R. Najmán — tikkun completo para el alma y el cuerpo.",
                "The ten psalms of R. Nachman — complete tikkun for soul and body.",
                "עשרת מזמורי ר׳ נחמן — תיקון שלם לנשמה ולגוף."
            ),
            longDescription: TefilaCopy.choose(
                "R. Najmán de Breslov enseñó que el Tikkun HaKlali purifica y sana la raíz espiritual del alma, lo que a su vez puede traer sanación física. Un rabino breslov lo recitará por tu ser querido.",
                "R. Nachman of Breslov taught that the Tikkun HaKlali purifies and heals the spiritual root of the soul, which can in turn bring physical healing.",
                "ר׳ נחמן לימד שתיקון הכללי מטהר ומרפא את השורש הרוחני של הנשמה."
            ),
            durationLabel: TefilaCopy.choose("25 mínimo", "25 minutes", "25 דקות"),
            iconSystemName: "scroll.fill",
            iconColor: Color(red: 0.32, green: 0.48, blue: 0.82),
            backdropAsset: "Minja",
            hebrewTitle: "תיקון הכללי לרפואה",
            spiritualNote: TefilaCopy.choose(
                "«Dios mío, sáname, porque mis huesos están turbados.» — Tehilim 6:3",
                "«Have mercy on me, Lord, for I am faint; heal me, Lord.» — Psalm 6:3",
                "«חָנֵּנִי ה׳ כִּי אֻמְלַל אָנִי רְפָאֵנִי ה׳» — תהילים ו׳ג׳"
            ),
            rabbiSource: TefilaCopy.choose(
                "R. Najmán de Breslov · Líkutei Moharán",
                "R. Nachman of Breslov · Likutey Moharan",
                "רבי נחמן מברסלב · ליקוטי מוהר״ן"
            )
        ),

        // ── PARNASSA (Sustento) ───────────────────────────────────────────────
        PrayerService(
            id: "parnassa_tehilim_daily",
            categoryId: "parnassa",
            eyebrow: "Tehilim",
            title: TefilaCopy.choose("Tehilim para Parnassá", "Psalms for Livelihood", "תהילים לפרנסה"),
            description: TefilaCopy.choose(
                "Salmos seleccionados — 23, 34, 112 — con poder especial para abrir las puertas de la abundancia.",
                "Selected Psalms — 23, 34, 112 — with special power to open the gates of abundance.",
                "מזמורים נבחרים כ״ג, ל״ד, קי״ב — לפתיחת שערי פרנסה."
            ),
            longDescription: TefilaCopy.choose(
                "Estos salmos son conocidos en la tradición como segulot específicas para la parnassá — el sustento honrado. El Rebe de Lubavitch recomendaba el Tehilim 23 a diario para la apertura de la parnassá.",
                "These psalms are known in tradition as specific segulot for parnassah — honorable livelihood. The Lubavitcher Rebbe recommended Psalm 23 daily for opening parnassah.",
                "מזמורים אלו ידועים כסגולות מיוחדות לפרנסה. הרבי מליובאוויטש המליץ על תהילים כ״ג."
            ),
            durationLabel: TefilaCopy.choose("15 mínimo", "15 minutes", "15 דקות"),
            iconSystemName: "leaf.fill",
            iconColor: Color(red: 0.72, green: 0.58, blue: 0.22),
            backdropAsset: "Shajarit",
            hebrewTitle: "תהילים לפרנסה",
            spiritualNote: TefilaCopy.choose(
                "«El Señor es mi pastor, nada me faltará.» — Tehilim 23:1",
                "«The Lord is my shepherd, I shall not want.» — Psalm 23:1",
                "«ה׳ רֹעִי לֹא אֶחְסָר» — תהילים כ״ג א׳"
            ),
            rabbiSource: TefilaCopy.choose(
                "Rebe de Lubavitch · Chabad · Likutei Torah",
                "Lubavitcher Rebbe · Chabad · Likutey Torah",
                "הרבי מליובאוויטש · חב״ד · ליקוטי תורה"
            )
        ),

        PrayerService(
            id: "parnassa_birkat_kohanim",
            categoryId: "parnassa",
            eyebrow: TefilaCopy.choose("Birkat Kohanim", "Priestly Blessing", "ברכת כהנים"),
            title: TefilaCopy.choose("Birkat HaKohanim para parnassá", "Priestly Blessing for livelihood", "ברכת הכהנים לפרנסה"),
            description: TefilaCopy.choose(
                "La triple bendición sacerdotal — la más antigua de las bendiciones de la Torá — recitada en tu nombre.",
                "The triple priestly blessing — the oldest in the Torah — recited on your behalf.",
                "ברכת הכהנים המשולשת — העתיקה בתורה — תאמר בשמך."
            ),
            longDescription: TefilaCopy.choose(
                "Dios le dijo a Moshé: «Así bendeciréis a los hijos de Israel». La Birkat Kohanim (Bamidbar 6:24-26) es la bendición más antigua y poderosa de la Torah. Un kohén recitará esta bendición específicamente por tu sustento.",
                "G-d told Moses: 'This is how you are to bless the Israelites.' The Birkat Kohanim (Numbers 6:24-26) is the oldest and most powerful blessing in the Torah. A kohen will recite it specifically for your livelihood.",
                "ה׳ אמר למשה: ״כה תברכו את בני ישראל״. ברכת כהנים היא הברכה הוותיקה ביותר בתורה."
            ),
            durationLabel: TefilaCopy.choose("10 mínimo", "10 minutes", "10 דקות"),
            iconSystemName: "hands.sparkles.fill",
            iconColor: Color(red: 0.58, green: 0.44, blue: 0.22),
            backdropAsset: "Tefila",
            hebrewTitle: "ברכת הכהנים",
            spiritualNote: TefilaCopy.choose(
                "«Te bendiga el Señor y te guarde; ilumine el Señor su rostro sobre ti.» — Bamidbar 6:24-25",
                "«The Lord bless you and keep you; the Lord make his face shine on you.» — Numbers 6:24-25",
                "«יְבָרֶכְךָ ה׳ וְיִשְׁמְרֶךָ יָאֵר ה׳ פָּנָיו אֵלֶיךָ» — במדבר ו׳"
            ),
            rabbiSource: TefilaCopy.choose(
                "Bamidbar 6:22-27 · tradición del Templo de Jerusalem",
                "Numbers 6:22-27 · Jerusalem Temple tradition",
                "במדבר ו׳ · מסורת בית המקדש"
            )
        ),

        // ── SHALOM BAYIT (Paz en el hogar) ───────────────────────────────────
        PrayerService(
            id: "shalom_bayit_tehilim",
            categoryId: "shalomBayit",
            eyebrow: "Tehilim",
            title: TefilaCopy.choose("Tehilim para Shalom Bayit", "Psalms for Peace at Home", "תהילים לשלום בית"),
            description: TefilaCopy.choose(
                "Salmos 45 y 128 — dedicados a la armonía del hogar, al amor conyugal y al pacto familiar.",
                "Psalms 45 and 128 — dedicated to home harmony, marital love, and family covenant.",
                "מזמורים מ״ה וקכ״ח — לאהבה זוגית והרמוניה ביתית."
            ),
            longDescription: TefilaCopy.choose(
                "El Tehilim 45 es el mizmor nupcial por excelencia y el 128 bendice la mesa familiar. Juntos forman la tefilá más poderosa por el Shalom Bayit. Un estudioso los recitará mencionando los nombres de la pareja.",
                "Psalm 45 is the quintessential nuptial mizmor and Psalm 128 blesses the family table. Together they form the most powerful tefila for Shalom Bayit.",
                "מזמור מ״ה הוא מזמור החתונה המרכזי ומזמור קכ״ח מברך את שולחן המשפחה."
            ),
            durationLabel: TefilaCopy.choose("15 mínimo", "15 minutes", "15 דקות"),
            iconSystemName: "house.fill",
            iconColor: Color(red: 0.42, green: 0.72, blue: 0.62),
            backdropAsset: "Tefila",
            hebrewTitle: "תהילים לשלום בית",
            spiritualNote: TefilaCopy.choose(
                "«Tu mujer será como vid fructífera en los lados de tu casa.» — Tehilim 128:3",
                "«Your wife will be like a fruitful vine within your house.» — Psalm 128:3",
                "«אֶשְׁתְּךָ כְּגֶפֶן פֹּרִיָּה בְּיַרְכְּתֵי בֵיתֶךָ» — תהילים קכ״ח"
            ),
            rabbiSource: TefilaCopy.choose(
                "Sidur · Shalom Bayit · tradición judía universal",
                "Siddur · Shalom Bayit · universal Jewish tradition",
                "סידור · שלום בית · מסורת ישראל"
            )
        ),

        // ── ZERA BERACHA (Fertilidad) ─────────────────────────────────────────
        PrayerService(
            id: "zera_tehilim",
            categoryId: "zeraBeracha",
            eyebrow: "Tehilim",
            title: TefilaCopy.choose("Tehilim para Zerajim y Berajá", "Psalms for Children & Blessing", "תהילים לזרע ברוך"),
            description: TefilaCopy.choose(
                "Salmos 128, 113, 127 — la trilogía de la bendición familiar y el nacimiento de los hijos.",
                "Psalms 128, 113, 127 — the trilogy of family blessing and the birth of children.",
                "מזמורים קכ״ח, קי״ג, קכ״ז — לברכת הילדים."
            ),
            longDescription: TefilaCopy.choose(
                "Estos salmos forman una trilogía espiritual para la fertilidad y la bendición de los hijos. El Tehilim 113 alaba a Dios por «hacer habitar a la estéril en el hogar, como madre gozosa de hijos». Un rabino los recitará junto con una plegaria especial.",
                "These psalms form a spiritual trilogy for fertility and the blessing of children. Psalm 113 praises G-d for 'making the barren woman dwell in her home as a joyful mother of children.' A rabbi will recite them with a special prayer.",
                "מזמורים אלו יוצרים שלישייה רוחנית לפריון ולברכת ילדים."
            ),
            durationLabel: TefilaCopy.choose("20 mínimo", "20 minutes", "20 דקות"),
            iconSystemName: "figure.and.child.holdinghands",
            iconColor: Color(red: 0.72, green: 0.48, blue: 0.72),
            backdropAsset: "Minja",
            hebrewTitle: "זרע ברוך",
            spiritualNote: TefilaCopy.choose(
                "«Como flechas en mano del valiente, así son los hijos habidos en la juventud.» — Tehilim 127:4",
                "«Like arrows in the hands of a warrior are children born in one's youth.» — Psalm 127:4",
                "«כַּחִצִּים בְּיַד גִּבּוֹר כֵּן בְּנֵי הַנְּעוּרִים» — תהילים קכ״ז"
            ),
            rabbiSource: TefilaCopy.choose(
                "Tehilim 113:9 · «hace habitar a la estéril» · tradición sefardí",
                "Psalm 113:9 · 'He settles the barren woman' · Sephardic tradition",
                "תהילים קי״ג ט׳ · מסורת ספרד"
            )
        ),

        // ── SHEMIRA (Protección) ──────────────────────────────────────────────
        PrayerService(
            id: "shemira_tehilim",
            categoryId: "shemira",
            eyebrow: "Tehilim",
            title: TefilaCopy.choose("Tehilim para Shemirá", "Psalms for Protection", "תהילים לשמירה"),
            description: TefilaCopy.choose(
                "Salmos 91 «Yoshev BeSeter» y 121 — los salmos de protección divina más poderosos de la Torá.",
                "Psalms 91 «Yoshev BeSeter» and 121 — the most powerful divine protection psalms in Torah.",
                "מזמורים צ״א ׳יושב בסתר׳ וקכ״א — סגולת שמירה."
            ),
            longDescription: TefilaCopy.choose(
                "El Tehilim 91 (Yoshev BeSeter — «el que mora en el abrigo del Altísimo») es la tefilá de protección por excelencia, recitada por soldados, viajeros y personas en peligro. El 121 promete: «el que te guarda no dormirá». Un rabino los recitará en tu nombre.",
                "Psalm 91 (Yoshev BeSeter — 'he who dwells in the shelter of the Most High') is the quintessential protection tefila, recited by soldiers, travelers and people in danger. Psalm 121 promises: 'he who watches over you will not sleep.' A rabbi will recite them on your behalf.",
                "תהילים צ״א — ׳יושב בסתר׳ — הוא תפילת השמירה המרכזית."
            ),
            durationLabel: TefilaCopy.choose("15 mínimo", "15 minutes", "15 דקות"),
            iconSystemName: "shield.fill",
            iconColor: Color(red: 0.28, green: 0.38, blue: 0.72),
            backdropAsset: "Arvit",
            hebrewTitle: "תהילים לשמירה",
            spiritualNote: TefilaCopy.choose(
                "«El que mora en el abrigo del Altísimo, a la sombra del Omnipotente descansará.» — Tehilim 91:1",
                "«Whoever dwells in the shelter of the Most High will rest in the shadow of the Almighty.» — Psalm 91:1",
                "«יֹשֵׁב בְּסֵתֶר עֶלְיוֹן בְּצֵל שַׁדַּי יִתְלוֹנָן» — תהילים צ״א"
            ),
            rabbiSource: TefilaCopy.choose(
                "Tehilim 91 · Yoshev BeSeter · segulá de protección universal",
                "Psalm 91 · Yoshev BeSeter · universal protection segulah",
                "תהילים צ״א · יושב בסתר · סגולת שמירה"
            )
        ),
    ]

    /// Servicios filtrados por categoría.
    static func services(for categoryId: String) -> [PrayerService] {
        allServices.filter { $0.categoryId == categoryId }
    }

    /// Servicio por ID.
    static func service(id: String) -> PrayerService? {
        allServices.first { $0.id == id }
    }
}
