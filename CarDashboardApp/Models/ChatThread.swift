import SwiftUI

/// Red de origen del contacto (insignia sobre el avatar).
enum ChatSocialPlatform: Hashable {
    case instagram
    case whatsApp
    case facebook
}

/// Hilo de chat (lista + navegación a conversación).
struct ChatThread: Identifiable, Hashable {
    let id: UUID
    let title: String
    let preview: String
    let time: String
    let unread: Int?
    let avatarInitial: String?
    let avatarIcon: String?
    let avatarR: Double
    let avatarG: Double
    let avatarB: Double
    /// Foto opcional (avatar circular); si es nil se usa inicial o SF Symbol.
    let avatarImageURL: URL?
    /// Red de procedencia (insignia sobre la foto).
    let socialSource: ChatSocialPlatform?
    let isVerified: Bool
    let isPinned: Bool

    enum ReadReceipt: Hashable {
        case none
        case sent
        case read
    }

    let readReceipt: ReadReceipt
    let showOpenButton: Bool

    var avatarColor: Color {
        Color(red: avatarR, green: avatarG, blue: avatarB)
    }

    static let samples: [ChatThread] = [
        ChatThread(
            id: UUID(uuidString: "10000000-0000-0000-0000-000000000001")!,
            title: "Kotel · dedicación",
            preview: "Confirmamos capítulo 121 dedicado con tu intención de shalom bait.",
            time: "9:42",
            unread: 2,
            avatarInitial: nil,
            avatarIcon: nil,
            avatarR: 0.2, avatarG: 0.55, avatarB: 0.95,
            avatarImageURL: RemoteAssets.chatThreadPortrait(1),
            socialSource: nil,
            isVerified: true,
            isPinned: true,
            readReceipt: .none,
            showOpenButton: false
        ),
        ChatThread(
            id: UUID(uuidString: "10000000-0000-0000-0000-000000000002")!,
            title: "WhatsApp · minyán urgente",
            preview: "Necesitamos un décimo antes de plag haMinjá. ¿Estás disponible?",
            time: "Ayer",
            unread: nil,
            avatarInitial: nil,
            avatarIcon: nil,
            avatarR: 0.95, avatarG: 0.35, avatarB: 0.55,
            avatarImageURL: RemoteAssets.chatThreadPortrait(2),
            socialSource: .whatsApp,
            isVerified: false,
            isPinned: false,
            readReceipt: .read,
            showOpenButton: false
        ),
        ChatThread(
            id: UUID(uuidString: "10000000-0000-0000-0000-000000000003")!,
            title: "Kevér Rakhel · escolta",
            preview: "El bus comunitario sale a las 07:05 — traer nombres hebreos en sobre.",
            time: "sáb",
            unread: nil,
            avatarInitial: nil,
            avatarIcon: nil,
            avatarR: 0.95, avatarG: 0.62, avatarB: 0.18,
            avatarImageURL: RemoteAssets.chatThreadPortrait(3),
            socialSource: nil,
            isVerified: true,
            isPinned: false,
            readReceipt: .sent,
            showOpenButton: false
        ),
        ChatThread(
            id: UUID(uuidString: "10000000-0000-0000-0000-000000000004")!,
            title: "Tefila · coordinación pastoral",
            preview: "Se asignó un hazan estudiante para tu tikún nocturno — confirmado.",
            time: "18/03",
            unread: 1,
            avatarInitial: nil,
            avatarIcon: nil,
            avatarR: 0.35, avatarG: 0.78, avatarB: 0.62,
            avatarImageURL: RemoteAssets.chatThreadPortrait(4),
            socialSource: nil,
            isVerified: true,
            isPinned: false,
            readReceipt: .none,
            showOpenButton: false
        ),
        ChatThread(
            id: UUID(uuidString: "10000000-0000-0000-0000-000000000005")!,
            title: "Asistente · Tefila",
            preview: "/start — pregúntame por Tehilim, sedrá o nusaj del día.",
            time: "15/03",
            unread: nil,
            avatarInitial: nil,
            avatarIcon: nil,
            avatarR: 0.45, avatarG: 0.45, avatarB: 0.5,
            avatarImageURL: nil,
            socialSource: nil,
            isVerified: true,
            isPinned: false,
            readReceipt: .none,
            showOpenButton: true
        ),
        ChatThread(
            id: UUID(uuidString: "10000000-0000-0000-0000-000000000006")!,
            title: "Breslov · Uman comunidad",
            preview: "Mapa refrescado: punto de encuentro después de Tikun antes del alba.",
            time: "4:23",
            unread: nil,
            avatarInitial: nil,
            avatarIcon: nil,
            avatarR: 0.25, avatarG: 0.45, avatarB: 0.85,
            avatarImageURL: RemoteAssets.chatThreadPortrait(5),
            socialSource: .facebook,
            isVerified: false,
            isPinned: false,
            readReceipt: .read,
            showOpenButton: false
        ),
        ChatThread(
            id: UUID(uuidString: "10000000-0000-0000-0000-000000000007")!,
            title: "Shabaton · madrichim",
            preview: "Shiur Shir HaShirim mañana 08:45 en salón menor — llegar con sidur marcado.",
            time: "mar",
            unread: 3,
            avatarInitial: nil,
            avatarIcon: nil,
            avatarR: 0.5, avatarG: 0.5, avatarB: 0.52,
            avatarImageURL: RemoteAssets.chatThreadPortrait(6),
            socialSource: nil,
            isVerified: false,
            isPinned: false,
            readReceipt: .sent,
            showOpenButton: false
        ),
        ChatThread(
            id: UUID(uuidString: "10000000-0000-0000-0000-000000000008")!,
            title: "Rab Cohen · Refuá",
            preview: "Dejé el Mishná Berajá cotizado sobre refuá; podemos llamarnos después de Minjá.",
            time: "lun",
            unread: nil,
            avatarInitial: nil,
            avatarIcon: nil,
            avatarR: 0.55, avatarG: 0.6, avatarB: 0.65,
            avatarImageURL: RemoteAssets.chatThreadPortrait(7),
            socialSource: nil,
            isVerified: true,
            isPinned: false,
            readReceipt: .read,
            showOpenButton: false
        ),
    ]
}
