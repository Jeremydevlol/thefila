import UIKit

/// Fotos de perfil de pacientes en Application Support (`PatientAvatars/{uuid}.jpg`).
enum PatientAvatarStore {
    private static var folderURL: URL {
        let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let dir = base.appendingPathComponent("PatientAvatars", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }

    private static func fileURL(for patientId: UUID) -> URL {
        folderURL.appendingPathComponent("\(patientId.uuidString).jpg")
    }

    static func save(jpeg: Data, patientId: UUID) throws {
        try jpeg.write(to: fileURL(for: patientId), options: .atomic)
    }

    static func image(for patientId: UUID) -> UIImage? {
        let url = fileURL(for: patientId)
        guard let data = try? Data(contentsOf: url) else { return nil }
        return UIImage(data: data)
    }

    static func remove(for patientId: UUID) {
        try? FileManager.default.removeItem(at: fileURL(for: patientId))
    }
}
