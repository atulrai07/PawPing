//
//  MedicationStore.swift
//  PawPing
//

import Foundation
import Observation

@Observable
class MedicationStore {
    var medications: [Medication] = []
    
    private let userDefaultsKey = "pawping_medications_data"
    
    init() {
        loadFromUserDefaults()
    }
    
    // MARK: - Filtered Access
    
    func medications(for petId: UUID) -> [Medication] {
        medications.filter { $0.petId == petId }
    }
    
    var activeMedicationsCount: Int {
        medications.filter { $0.status == .active }.count
    }
    
    // MARK: - CRUD
    
    func addMedication(_ medication: Medication) {
        medications.append(medication)
        saveToUserDefaults()
        
        // Setup reminders based on start date and frequency
        Task {
            await NotificationManager.shared.scheduleMedicationReminders(for: medication)
        }
    }
    
    func updateMedication(_ medication: Medication) {
        if let index = medications.firstIndex(where: { $0.id == medication.id }) {
            medications[index] = medication
            saveToUserDefaults()
            
            // Reschedule reminders
            Task {
                await NotificationManager.shared.cancelReminders(for: medication.id)
                await NotificationManager.shared.scheduleMedicationReminders(for: medication)
            }
        }
    }
    
    func deleteMedication(id: UUID) {
        medications.removeAll { $0.id == id }
        saveToUserDefaults()
        
        Task {
            await NotificationManager.shared.cancelReminders(for: id)
        }
    }
    
    func logDose(for id: UUID, date: Date = Date()) {
        if let index = medications.firstIndex(where: { $0.id == id }) {
            medications[index].completedDoses.append(date)
            saveToUserDefaults()
        }
    }
    
    // MARK: - Persistence
    
    private func saveToUserDefaults() {
        do {
            let data = try JSONEncoder().encode(medications)
            UserDefaults.standard.set(data, forKey: userDefaultsKey)
        } catch {
            print("Error encoding medications: \(error)")
        }
    }
    
    private func loadFromUserDefaults() {
        guard let data = UserDefaults.standard.data(forKey: userDefaultsKey) else { return }
        do {
            let decoded = try JSONDecoder().decode([Medication].self, from: data)
            self.medications = decoded
        } catch {
            print("Error decoding medications: \(error)")
        }
    }
}
