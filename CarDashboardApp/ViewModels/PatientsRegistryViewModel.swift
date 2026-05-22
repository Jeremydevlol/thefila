import Foundation
import SwiftUI

@MainActor
final class PatientsRegistryViewModel: ObservableObject {
    @Published var patients: [PatientRecord] = []
    @Published var selectedPatientId: UUID?
    @Published var browseSearchText = ""

    private static var storeURL: URL {
        let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        return base.appendingPathComponent("patients_registry.json")
    }

    init() {
        loadFromDisk()
    }

    var selectedPatient: PatientRecord? {
        patients.first { $0.id == selectedPatientId }
    }

    func displayedPatients() -> [PatientRecord] {
        let q = browseSearchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !q.isEmpty else { return patients }
        return patients.filter {
            $0.displayName.lowercased().contains(q)
                || $0.email.lowercased().contains(q)
                || $0.phone.lowercased().contains(q)
                || $0.subtitle.lowercased().contains(q)
                || $0.detailLine.lowercased().contains(q)
                || $0.notes.lowercased().contains(q)
        }
    }

    func selectPatient(_ patient: PatientRecord) {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
            selectedPatientId = patient.id
        }
    }

    func isSelected(_ patient: PatientRecord) -> Bool {
        patient.id == selectedPatientId
    }

    /// Nuevo cliente sin datos; puedes completar la ficha después.
    @discardableResult
    func addEmptyPatient() -> PatientRecord {
        let p = PatientRecord(
            id: UUID(),
            firstName: "",
            lastName: "",
            email: "",
            subtitle: "Cliente nuevo",
            detailLine: "Completa la ficha cuando quieras"
        )
        patients.append(p)
        saveToDisk()
        return p
    }

    func upsertPatient(_ patient: PatientRecord) {
        if let idx = patients.firstIndex(where: { $0.id == patient.id }) {
            patients[idx] = patient
        } else {
            patients.append(patient)
        }
        saveToDisk()
    }

    func loadFromDisk() {
        guard let data = try? Data(contentsOf: Self.storeURL),
              var decoded = try? JSONDecoder().decode([PatientRecord].self, from: data),
              !decoded.isEmpty
        else {
            patients = defaultPatientsList()
            return
        }
        decoded = ensureSinAsignar(in: decoded)
        patients = decoded
    }

    private func defaultPatientsList() -> [PatientRecord] {
        [PatientRecord.sinAsignarTemplate()] + PatientRecord.samples
    }

    private func ensureSinAsignar(in list: [PatientRecord]) -> [PatientRecord] {
        let rest = list.filter { !$0.isSinAsignarSlot }
        let sin = list.first(where: { $0.isSinAsignarSlot }) ?? PatientRecord.sinAsignarTemplate()
        return [sin] + rest
    }

    func saveToDisk() {
        patients = ensureSinAsignar(in: patients)
        guard let data = try? JSONEncoder().encode(patients) else { return }
        try? data.write(to: Self.storeURL, options: .atomic)
    }
}
