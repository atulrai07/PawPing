import Foundation
import Observation

@Observable
class WeightStore {
    var records: [WeightRecord] = []
    
    func load(for petId: UUID, petName: String = "") {
        let key = "weight_records_\(petId.uuidString)"
        if let data = UserDefaults.standard.data(forKey: key),
           let decoded = try? JSONDecoder().decode([WeightRecord].self, from: data) {
            self.records = decoded.sorted { $0.date > $1.date }
        } else {
            self.records = []
        }
        
        // Schedule monthly weight reminder if enabled
        let weightEnabled = UserDefaults.standard.object(forKey: "pawping_notif_weight") as? Bool ?? false
        if weightEnabled && !petName.isEmpty {
            Task {
                await NotificationManager.shared.scheduleWeightLogReminder(
                    petName: petName,
                    petId: petId
                )
            }
        }
    }
    
    func addRecord(petId: UUID, weightKg: Double, condition: BodyCondition) {
        let newRecord = WeightRecord(
            id: UUID(),
            petId: petId,
            date: Date(),
            weightKg: weightKg,
            bodyCondition: condition
        )
        records.insert(newRecord, at: 0)
        save(for: petId)
    }
    
    private func save(for petId: UUID) {
        let key = "weight_records_\(petId.uuidString)"
        if let encoded = try? JSONEncoder().encode(records) {
            UserDefaults.standard.set(encoded, forKey: key)
        }
    }
    
    var latestRecord: WeightRecord? {
        records.first
    }
}
