//
//  WeightStore.swift
//  PawPing
//

import Foundation
import Observation

@Observable
class WeightStore {
    private(set) var records: [WeightRecord] = []
    private var petId: UUID?

    // Load from UserDefaults on init, keyed by petId
    func load(for petId: UUID) {
        self.petId = petId
        let key = "weight_records_\(petId)"
        guard let data = UserDefaults.standard.data(forKey: key),
              let decoded = try? JSONDecoder().decode([WeightRecord].self, from: data)
        else {
            records = []    // no mock data — empty state is honest
            return
        }
        records = decoded.sorted { $0.date < $1.date }
    }

    func addRecord(petId: UUID, weightKg: Double, condition: BodyCondition) {
        let record = WeightRecord(
            id: UUID(),
            petId: petId,
            date: Date(),
            weightKg: weightKg,
            bodyCondition: condition
        )
        records.append(record)
        records.sort { $0.date < $1.date }
        persist(for: petId)
    }

    private func persist(for petId: UUID) {
        let key = "weight_records_\(petId)"
        if let data = try? JSONEncoder().encode(records) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    // Latest record for summary display
    var latest: WeightRecord? { records.last }
}
