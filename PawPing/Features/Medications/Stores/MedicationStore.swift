//
//  MedicationStore.swift
//  PawPing
//

import Foundation
import Observation
import Supabase

@Observable
class MedicationStore {
    var medications: [Medication] = []
    
    private let client = SupabaseConfig.client
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
    
    // MARK: - Supabase Fetching
    
    @MainActor
    func fetchMedications(for petId: UUID) async {
        do {
            let fetched: [Medication] = try await client
                .from("medications")
                .select()
                .eq("pet_id", value: petId.uuidString)
                .execute()
                .value
            
            // Remove existing local medications for this pet, and replace with fetched ones
            self.medications.removeAll { $0.petId == petId }
            self.medications.append(contentsOf: fetched)
            saveToUserDefaults()
            
            print("Successfully fetched \(fetched.count) medications from Supabase for pet \(petId)")
        } catch {
            print("Error fetching medications from Supabase: \(error)")
        }
    }
    
    // MARK: - CRUD
    
    func addMedication(_ medication: Medication) {
        medications.append(medication)
        saveToUserDefaults()
        
        // Setup reminders based on start date and frequency
        Task {
            await NotificationManager.shared.scheduleMedicationReminders(for: medication)
            
            do {
                try await client
                    .from("medications")
                    .insert(medication)
                    .execute()
                print("Successfully added medication to Supabase")
            } catch {
                print("Error saving medication to Supabase: \(error)")
            }
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
                
                do {
                    try await client
                        .from("medications")
                        .update(medication)
                        .eq("id", value: medication.id.uuidString)
                        .execute()
                    print("Successfully updated medication in Supabase")
                } catch {
                    print("Error updating medication in Supabase: \(error)")
                }
            }
        }
    }
    
    func deleteMedication(id: UUID) {
        medications.removeAll { $0.id == id }
        saveToUserDefaults()
        
        Task {
            await NotificationManager.shared.cancelReminders(for: id)
            
            do {
                try await client
                    .from("medications")
                    .delete()
                    .eq("id", value: id.uuidString)
                    .execute()
                print("Successfully deleted medication from Supabase")
            } catch {
                print("Error deleting medication from Supabase: \(error)")
            }
        }
    }
    
    func logDose(for id: UUID, date: Date = Date()) {
        if let index = medications.firstIndex(where: { $0.id == id }) {
            medications[index].completedDoses.append(date)
            saveToUserDefaults()
            
            let updatedMedication = medications[index]
            Task {
                do {
                    try await client
                        .from("medications")
                        .update(updatedMedication)
                        .eq("id", value: id.uuidString)
                        .execute()
                    print("Successfully logged dose in Supabase")
                } catch {
                    print("Error logging dose in Supabase: \(error)")
                }
            }
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
