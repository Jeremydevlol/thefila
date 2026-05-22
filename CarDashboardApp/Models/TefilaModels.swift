import SwiftUI

// MARK: - Pasaje del Tanaj

struct TanajPassage: Identifiable, Hashable, Equatable {
    let id: String
    let title: String           // "Shema Israel"
    let reference: String       // "Devarim 6:4"
    let book: String            // "Devarim"
    let hebrewText: String
    let spanishText: String
    let tag: PassageTag
    var isFavorite: Bool = false

    static func == (lhs: TanajPassage, rhs: TanajPassage) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

enum PassageTag: String, CaseIterable {
    case torah    = "Torah"
    case tehilim  = "Tehilim"
    case mishle   = "Mishlé"
    case shir     = "Shir HaShirim"
    case nevi     = "Nevi'im"

    var color: Color {
        switch self {
        case .torah:   return Color(red: 0.82, green: 0.62, blue: 0.22)
        case .tehilim: return Color(red: 0.32, green: 0.48, blue: 0.82)
        case .mishle:  return Color(red: 0.42, green: 0.68, blue: 0.52)
        case .shir:    return Color(red: 0.72, green: 0.38, blue: 0.62)
        case .nevi:    return Color(red: 0.52, green: 0.38, blue: 0.78)
        }
    }

    var background: Color { color.opacity(0.13) }
}

// MARK: - Mock pasajes

enum MockPassages {
    static var all: [TanajPassage] = [
        TanajPassage(
            id: "shema",
            title: "Shema Israel",
            reference: "Devarim 6:4",
            book: "Devarim",
            hebrewText: "שְׁמַע יִשְׂרָאֵל יְהוָה אֱלֹהֵינוּ יְהוָה אֶחָד",
            spanishText: "Escucha, Israel: Hashem es nuestro Dios, Hashem es Uno.",
            tag: .torah,
            isFavorite: true
        ),
        TanajPassage(
            id: "vaahavta_reaj",
            title: "Ve'ahavta Lere'acha Kamocha",
            reference: "Vayikrá 19:18",
            book: "Vayikrá",
            hebrewText: "וְאָהַבְתָּ לְרֵעֲךָ כָּמוֹךָ",
            spanishText: "Amarás a tu prójimo como a ti mismo.",
            tag: .torah
        ),
        TanajPassage(
            id: "tehilim_23",
            title: "Hashem Ro'i",
            reference: "Tehilim 23:1",
            book: "Tehilim",
            hebrewText: "יְהוָה רֹעִי לֹא אֶחְסָר",
            spanishText: "Hashem es mi pastor, nada me faltará.",
            tag: .tehilim,
            isFavorite: true
        ),
        TanajPassage(
            id: "tehilim_121",
            title: "Esá Einai",
            reference: "Tehilim 121:1–2",
            book: "Tehilim",
            hebrewText: "אֶשָּׂא עֵינַי אֶל הֶהָרִים מֵאַיִן יָבֹא עֶזְרִי׃ עֶזְרִי מֵעִם יְהוָה עֹשֵׂה שָׁמַיִם וָאָרֶץ",
            spanishText: "Alzaré mis ojos a los montes; ¿de dónde vendrá mi ayuda? Mi ayuda viene de Hashem, el que hizo el cielo y la tierra.",
            tag: .tehilim
        ),
        TanajPassage(
            id: "mishle_3_5",
            title: "Betach el Hashem",
            reference: "Mishlé 3:5",
            book: "Mishlé",
            hebrewText: "בְּטַח אֶל יְהוָה בְּכָל לִבֶּךָ",
            spanishText: "Confía en Hashem con todo tu corazón.",
            tag: .mishle,
            isFavorite: true
        ),
        TanajPassage(
            id: "tehilim_100_5",
            title: "Ki Tov Hashem",
            reference: "Tehilim 100:5",
            book: "Tehilim",
            hebrewText: "כִּי טוֹב יְהוָה לְעוֹלָם חַסְדּוֹ",
            spanishText: "Porque Hashem es bueno; para siempre es su misericordia, y su fidelidad por todas las generaciones.",
            tag: .tehilim
        ),
        TanajPassage(
            id: "devarim_31_6",
            title: "Jazak ve'Ematz",
            reference: "Devarim 31:6",
            book: "Devarim",
            hebrewText: "חִזְקוּ וְאִמְצוּ אַל תִּירְאוּ וְאַל תַּעַרְצוּ מִפְּנֵיהֶם",
            spanishText: "Sed fuertes y valientes; no temáis ni os espantéis ante ellos, porque Hashem tu Dios es quien va contigo.",
            tag: .torah
        ),
        TanajPassage(
            id: "tehilim_91_1",
            title: "Yoshev BeSeter",
            reference: "Tehilim 91:1",
            book: "Tehilim",
            hebrewText: "יֹשֵׁב בְּסֵתֶר עֶלְיוֹן בְּצֵל שַׁדַּי יִתְלוֹנָן",
            spanishText: "El que mora en el abrigo del Altísimo, a la sombra del Omnipotente descansará.",
            tag: .tehilim,
            isFavorite: true
        ),
        TanajPassage(
            id: "shir_1_2",
            title: "Yishakeni",
            reference: "Shir HaShirim 1:2",
            book: "Shir HaShirim",
            hebrewText: "יִשָּׁקֵנִי מִנְּשִׁיקוֹת פִּיהוּ",
            spanishText: "Que me bese con los besos de su boca, porque mejor es tu amor que el vino.",
            tag: .shir
        ),
        TanajPassage(
            id: "yirmiyahu_29_11",
            title: "Ki Anochi Yodea",
            reference: "Yirmiyahu 29:11",
            book: "Yirmiyahu",
            hebrewText: "כִּי אָנֹכִי יָדַעְתִּי אֶת הַמַּחֲשָׁבֹת אֲשֶׁר אָנֹכִי חֹשֵׁב עֲלֵיכֶם",
            spanishText: "Porque yo sé los planes que tengo para vosotros, dice Hashem, planes de bienestar y no de calamidad, para daros un futuro y una esperanza.",
            tag: .nevi
        ),
        TanajPassage(
            id: "mishlei_31_10",
            title: "Eshet Chayil",
            reference: "Mishlé 31:10",
            book: "Mishlé",
            hebrewText: "אֵשֶׁת חַיִל מִי יִמְצָא וְרָחֹק מִפְּנִינִים מִכְרָהּ",
            spanishText: "Mujer de valor, ¿quién la hallará? Su valor supera en mucho al de las joyas.",
            tag: .mishle
        ),
        TanajPassage(
            id: "bamidbar_6_24",
            title: "Birkat Kohanim",
            reference: "Bamidbar 6:24–26",
            book: "Bamidbar",
            hebrewText: "יְבָרֶכְךָ יְהוָה וְיִשְׁמְרֶךָ׃ יָאֵר יְהוָה פָּנָיו אֵלֶיךָ וִיחֻנֶּךָּ׃ יִשָּׂא יְהוָה פָּנָיו אֵלֶיךָ וְיָשֵׂם לְךָ שָׁלוֹם",
            spanishText: "Que Hashem te bendiga y te guarde. Que Hashem haga brillar Su rostro sobre ti y te sea gracioso. Que Hashem levante Su rostro hacia ti y te conceda shalom.",
            tag: .torah,
            isFavorite: true
        ),
    ]
}

// MARK: - Intención de tefilá

struct PrayerIntention: Identifiable, Hashable {
    let id: String
    let title: String
    let subtitle: String
    let sfSymbol: String
    let hebrewKeyword: String
    let accentColor: Color

    static func == (lhs: PrayerIntention, rhs: PrayerIntention) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

enum MockIntentions {
    static let all: [PrayerIntention] = [
        PrayerIntention(id: "exito",      title: "Éxito",                subtitle: "Para el éxito en todos los asuntos.",             sfSymbol: "star.fill",                    hebrewKeyword: "הצלחה",    accentColor: .goldAccent),
        PrayerIntention(id: "paz_casa",   title: "Paz en casa",          subtitle: "Armonía, paz y tranquilidad en el hogar.",        sfSymbol: "house.fill",                   hebrewKeyword: "שלום בית", accentColor: .goldAccent),
        PrayerIntention(id: "riqueza",    title: "Parnassá",             subtitle: "Bendiciones materiales y abundancia.",            sfSymbol: "leaf.fill",                    hebrewKeyword: "פרנסה",    accentColor: .goldAccent),
        PrayerIntention(id: "alma_gemela",title: "Alma gemela",          subtitle: "Para encontrar pareja y formar un hogar.",        sfSymbol: "heart.fill",                   hebrewKeyword: "זיווג",    accentColor: .goldAccent),
        PrayerIntention(id: "en_memoria", title: "En memoria",           subtitle: "Por el alma de un ser querido.",                 sfSymbol: "moon.stars.fill",              hebrewKeyword: "נשמה",    accentColor: .goldAccent),
        PrayerIntention(id: "hijos",      title: "Éxito de los niños",   subtitle: "Protección y éxito para tus hijos.",             sfSymbol: "figure.and.child.holdinghands",hebrewKeyword: "ילדים",    accentColor: .goldAccent),
        PrayerIntention(id: "parto",      title: "Parto fácil",          subtitle: "Por un embarazo y parto bendecidos.",            sfSymbol: "figure.2.and.child.holdinghands",hebrewKeyword: "לידה",   accentColor: .goldAccent),
        PrayerIntention(id: "fertilidad", title: "Fertilidad",           subtitle: "Bendición para concebir y formar una familia.",  sfSymbol: "sparkles",                     hebrewKeyword: "פריון",    accentColor: .goldAccent),
        PrayerIntention(id: "salud",      title: "Refuá shlemá",         subtitle: "Por salud, bienestar y recuperación.",           sfSymbol: "cross.fill",                   hebrewKeyword: "רפואה",    accentColor: .goldAccent),
        PrayerIntention(id: "proteccion", title: "Protección",           subtitle: "Shemirá y protección divina.",                  sfSymbol: "shield.fill",                  hebrewKeyword: "שמירה",    accentColor: .goldAccent),
        PrayerIntention(id: "emuna",      title: "Emuná",                subtitle: "Fortaleza espiritual y fe profunda.",            sfSymbol: "bolt.fill",                    hebrewKeyword: "אמונה",    accentColor: .goldAccent),
        PrayerIntention(id: "zera",       title: "Zera kadosh",          subtitle: "Por descendencia santa y berajá familiar.",      sfSymbol: "tree.fill",                    hebrewKeyword: "זרע",     accentColor: .goldAccent),
    ]
}

// MARK: - Color extension

private extension Color {
    static let goldAccent = Color(red: 236/255, green: 196/255, blue: 95/255)
}

// MARK: - Generador de oración mock

enum TefilaMockGenerator {
    static func generate(hebrewName: String, mothersName: String, intention: PrayerIntention, location: SacredLocation, personalNote: String) -> String {
        let name = hebrewName.isEmpty ? "el solicitante" : hebrewName
        let motherPart = mothersName.isEmpty ? "" : " ben/bat \(mothersName)"
        let locationName = location.displayName
        let intentionHebrew = intention.hebrewKeyword

        let opening = "יְהִי רָצוֹן מִלְּפָנֶיךָ ה׳ אֱלֹהֵינוּ — Que sea la voluntad de Hashem nuestro Dios:"

        let body: String
        switch intention.id {
        case "salud":
            body = "Que Hashem escuche esta tefilá por \(name)\(motherPart), recitada en \(locationName). Que reciba refuá shlemá — sanación completa de cuerpo y alma. Que los caminos de la recuperación se abran con rachamim y que la luz de la Torá ilumine cada momento de su vida. Que reciba fortaleza, shalom interior y emuná profunda en el Creador."
        case "exito":
            body = "Que Hashem escuche esta tefilá por \(name)\(motherPart), recitada en \(locationName). Que reciba hazlajá y berajá en todos sus asuntos. Que sus pasos sean guiados con sabiduría de la Torá, que el éxito acompañe su trabajo con kedushá y yishar koaj espiritual. Que sus emprendimientos florezcan con integridad y que la berajá de Shamáyim descienda sobre él."
        case "paz_casa":
            body = "Que Hashem escuche esta tefilá por \(name)\(motherPart), recitada en \(locationName). Que el shalom bayit impregne cada rincón de su hogar. Que la armonía, el ahavá y el respeto mutuo sean la base de su vida familiar. Que Hashem bendiga su hogar con paz genuina, como está escrito: «Paz en tus muros y shalom en tus palacios» (Tehilim 122)."
        case "alma_gemela":
            body = "Que Hashem escuche esta tefilá por \(name)\(motherPart), recitada en \(locationName). Que su zivug — su alma gemela — se revele pronto, en el tiempo correcto según la voluntad del Creador. Que el amor que los una sea verdadero, construido sobre emuná y kedushá. Que formen un bayit neeman beYisrael — un hogar fiel en el pueblo de Israel."
        case "fertilidad", "parto", "zera":
            body = "Que Hashem escuche esta tefilá por \(name)\(motherPart), recitada en \(locationName). Como Hashem recordó a Sara, Rivka y Rajel, que recuerde también a este solicitante y abra las puertas de la berajá. Que reciban zera kadosh — descendencia santa — y que su hogar se llene de alegría, risas y luz de Torá. Como está escrito: «Hará habitar a la estéril en el hogar como madre gozosa de hijos» (Tehilim 113:9)."
        case "en_memoria":
            body = "Que Hashem escuche esta tefilá por el alma del ser querido de \(name)\(motherPart), recitada en \(locationName). Que su neshamá tenga una aliyat neshamá — elevación espiritual. Que descanse en Gan Eden bajo la sombra del Altísimo. Que el mérito de estas tefilot y del Tehilim recitado en su nombre sea una berajá eterna para su alma y consuelo para quienes lo recuerdan."
        case "proteccion":
            body = "Que Hashem escuche esta tefilá por \(name)\(motherPart), recitada en \(locationName). Que la shemirá divina lo rodee como está escrito: «El que mora en el abrigo del Altísimo, a la sombra del Omnipotente descansará» (Tehilim 91:1). Que los ángeles de Hashem guarden todos sus caminos, que el mal no se acerque a su morada y que viva con seguridad y bitajón completo."
        default:
            body = "Que Hashem escuche esta tefilá por \(name)\(motherPart), recitada en \(locationName). Que reciba berajá en todo lo que necesita — \(intentionHebrew). Que la luz de la Torá ilumine su camino, que sus días estén llenos de shalom, emuná y hazlajá. Que esta tefilá suba ante el Trono de Gloria y sea aceptada con rachamim y favor."
        }

        let personalSection = personalNote.isEmpty ? "" : "\n\nPetición personal: «\(personalNote)»"

        let closing = "\n\nAmén · אָמֵן · וְאָמֵן"

        return "\(opening)\n\n\(body)\(personalSection)\(closing)"
    }
}
