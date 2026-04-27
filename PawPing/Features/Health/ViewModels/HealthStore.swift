//
//  HealthStore.swift
//  PawPing
//
//  Created by SidMoon on 16/03/26.
//  Updated for Health system on 27/04/26.
//

import Foundation
import Observation
import Supabase

@Observable
class HealthStore {
    private let client = SupabaseConfig.client
    var healthRecords: [HealthRecord] = []

    var summary: HealthSummary {
        HealthSummary(from: healthRecords)
    }

    init() {
        healthRecords = []
    }

    // MARK: - Supabase Integration

    @MainActor
    func fetchHealthRecords(for petId: UUID) async {
        do {
            let fetched: [HealthRecord] = try await client
                .from("vaccine_records")
                .select()
                .eq("pet_id", value: petId)
                .order("date_given", ascending: false)
                .execute()
                .value
            
            self.healthRecords = fetched
        } catch {
            print("❌ Error fetching health records from vaccine_records: \(error)")
        }
    }

    @MainActor
    func addHealthRecord(_ record: HealthRecord) async {
        do {
            try await client
                .from("vaccine_records")
                .insert(record)
                .execute()
            
            await fetchHealthRecords(for: record.petId)
        } catch {
            print("❌ Error adding health record to vaccine_records: \(error)")
            // Bubble up error if needed
        }
    }

    @MainActor
    func updateHealthRecord(_ record: HealthRecord) async {
        do {
            try await client
                .from("vaccine_records")
                .update(record)
                .eq("id", value: record.id)
                .execute()
            
            await fetchHealthRecords(for: record.petId)
        } catch {
            print("❌ Error updating health record in vaccine_records: \(error)")
        }
    }

    @MainActor
    func deleteHealthRecord(id: UUID, petId: UUID) async {
        do {
            try await client
                .from("vaccine_records")
                .delete()
                .eq("id", value: id)
                .execute()
            
            await fetchHealthRecords(for: petId)
        } catch {
            print("❌ Error deleting health record from vaccine_records: \(error)")
        }
    }

    @MainActor
    func markAsDone(id: UUID, petId: UUID) async {
        if let index = healthRecords.firstIndex(where: { $0.id == id }) {
            var updated = healthRecords[index]
            updated.nextDoseDate = nil
            updated.dateGiven = Date()
            
            await updateHealthRecord(updated)
        }
    }
}
