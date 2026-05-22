import Foundation
import SwiftUI

/// Ficha de paciente (datos locales; contacto, teléfono, notas y foto opcionales).
struct PatientRecord: Identifiable, Hashable, Codable {
    let id: UUID
    var firstName: String
    var lastName: String
    var email: String
    var phone: String
    var subtitle: String
    var detailLine: String
    /// Notas libres (historial breve, preferencias, etc.).
    var notes: String

    /// Contacto editable «Sin asignar» para listados y filtros rápidos.
    static let sinAsignarId = UUID(uuidString: "a0000000-0000-4000-8000-000000000001")!

    static func sinAsignarTemplate() -> PatientRecord {
        PatientRecord(
            id: sinAsignarId,
            firstName: "",
            lastName: "",
            email: "",
            phone: "",
            subtitle: "Completa datos cuando quieras",
            detailLine: "Sin asignar",
            notes: ""
        )
    }

    var isSinAsignarSlot: Bool { id == Self.sinAsignarId }

    var displayName: String {
        let t = "\(firstName) \(lastName)".trimmingCharacters(in: .whitespacesAndNewlines)
        if t.isEmpty {
            if isSinAsignarSlot { return "Sin asignar" }
            return "Cliente sin nombre"
        }
        return t
    }

    enum CodingKeys: String, CodingKey {
        case id, firstName, lastName, email, phone, subtitle, detailLine, notes
    }

    init(
        id: UUID,
        firstName: String,
        lastName: String,
        email: String,
        phone: String = "",
        subtitle: String,
        detailLine: String,
        notes: String = ""
    ) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.phone = phone
        self.subtitle = subtitle
        self.detailLine = detailLine
        self.notes = notes
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(UUID.self, forKey: .id)
        firstName = try c.decodeIfPresent(String.self, forKey: .firstName) ?? ""
        lastName = try c.decodeIfPresent(String.self, forKey: .lastName) ?? ""
        email = try c.decodeIfPresent(String.self, forKey: .email) ?? ""
        phone = try c.decodeIfPresent(String.self, forKey: .phone) ?? ""
        subtitle = try c.decodeIfPresent(String.self, forKey: .subtitle) ?? ""
        detailLine = try c.decodeIfPresent(String.self, forKey: .detailLine) ?? ""
        notes = try c.decodeIfPresent(String.self, forKey: .notes) ?? ""
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(id, forKey: .id)
        try c.encode(firstName, forKey: .firstName)
        try c.encode(lastName, forKey: .lastName)
        try c.encode(email, forKey: .email)
        try c.encode(phone, forKey: .phone)
        try c.encode(subtitle, forKey: .subtitle)
        try c.encode(detailLine, forKey: .detailLine)
        try c.encode(notes, forKey: .notes)
    }

    static let samples: [PatientRecord] = [
        PatientRecord(
            id: UUID(uuidString: "a1000000-0000-4000-8000-000000000001")!,
            firstName: "María",
            lastName: "López García",
            email: "maria.lopez@email.com",
            phone: "+34 600 000 001",
            subtitle: "Última visita · hace 3 días",
            detailLine: "Medicina · revisión",
            notes: ""
        ),
        PatientRecord(
            id: UUID(uuidString: "a1000000-0000-4000-8000-000000000002")!,
            firstName: "Javier",
            lastName: "Ruiz",
            email: "",
            phone: "+34 611 222 333",
            subtitle: "Seguimiento · mañana 10:30",
            detailLine: "Pediatría",
            notes: ""
        ),
        PatientRecord(
            id: UUID(uuidString: "a1000000-0000-4000-8000-000000000003")!,
            firstName: "Ana",
            lastName: "Martínez",
            email: "",
            phone: "",
            subtitle: "Tratamiento en curso",
            detailLine: "Estética · pack 5 sesiones",
            notes: ""
        ),
        PatientRecord(
            id: UUID(uuidString: "a1000000-0000-4000-8000-000000000004")!,
            firstName: "Carlos",
            lastName: "Vega",
            email: "",
            phone: "",
            subtitle: "Sin visita próxima",
            detailLine: "Medicina general",
            notes: ""
        ),
        PatientRecord(
            id: UUID(uuidString: "a1000000-0000-4000-8000-000000000005")!,
            firstName: "Laura",
            lastName: "Sánchez",
            email: "",
            phone: "",
            subtitle: "Último contacto · 18/03/2026",
            detailLine: "Bienestar · seguimiento",
            notes: ""
        ),
        PatientRecord(
            id: UUID(uuidString: "a1000000-0000-4000-8000-000000000006")!,
            firstName: "Pedro",
            lastName: "Gómez",
            email: "",
            phone: "",
            subtitle: "Recordatorio enviado",
            detailLine: "Revisión anual",
            notes: ""
        ),
    ]
}
