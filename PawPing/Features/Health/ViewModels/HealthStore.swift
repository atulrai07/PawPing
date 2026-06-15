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
    var nearestRecord: HealthRecord?

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
            self.updateNearestRecord()
        } catch {
            print("❌ Error fetching health records from vaccine_records: \(error)")
        }
    }

    @MainActor
    func addHealthRecord(_ record: HealthRecord) async {
        do {
            // 1. Try Primary Insert (with new columns)
            try await client
                .from("vaccine_records")
                .insert(record)
                .execute()
            
            await fetchHealthRecords(for: record.petId)
        } catch {
            print("⚠️ Primary insert failed, trying fallback without new columns...")
            
            // 2. Fallback Insert (Use a legacy struct to exclude missing columns)
            struct LegacyHealthRecord: Encodable {
                let id: UUID
                let pet_id: UUID
                let type: String
                let name: String
                let date_given: Date
                let next_dose_date: Date?
                let notes: String
                let vet_name: String?
                let vet_address: String?
                let vet_phone: String?
                let vet_latitude: Double?
                let vet_longitude: Double?
            }
            
            let legacyRecord = LegacyHealthRecord(
                id: record.id,
                pet_id: record.petId,
                type: record.type,
                name: record.name,
                date_given: record.dateGiven,
                next_dose_date: record.nextDoseDate,
                notes: record.notes,
                vet_name: record.vetName,
                vet_address: record.vetAddress,
                vet_phone: record.vetPhone,
                vet_latitude: record.vetLatitude,
                vet_longitude: record.vetLongitude
            )
            
            do {
                try await client
                    .from("vaccine_records")
                    .insert(legacyRecord)
                    .execute()
                
                await fetchHealthRecords(for: record.petId)
            } catch {
                print("❌ Both insert attempts failed: \(error)")
            }
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
        // Optimistic Update: Update locally first
        guard let index = healthRecords.firstIndex(where: { $0.id == id }) else { return }
        
        let originalRecord = healthRecords[index]
        let now = Date()
        healthRecords[index].isCompleted = true
        healthRecords[index].completedDate = now
        healthRecords[index].nextDoseDate = nil
        
        // 1. Try Primary Update (with new columns)
        struct MarkAsDonePayload: Encodable {
            let is_completed: Bool
            let completed_date: Date
            let next_dose_date: Date?
        }
        
        do {
            try await client
                .from("vaccine_records")
                .update(MarkAsDonePayload(is_completed: true, completed_date: now, next_dose_date: nil))
                .eq("id", value: id)
                .execute()
            
            await fetchHealthRecords(for: petId)
        } catch {
            print("⚠️ Primary update failed (columns might be missing), trying fallback...")
            
            // 2. Fallback Update (only use columns we know exist)
            do {
                try await client
                    .from("vaccine_records")
                    .update([
                        "next_dose_date": nil,
                        "date_given": now
                    ])
                    .eq("id", value: id)
                    .execute()
                
                await fetchHealthRecords(for: petId)
            } catch {
                print("❌ Both update attempts failed: \(error)")
                // Final rollback only if both fail
                healthRecords[index] = originalRecord
            }
        }
    }
    
    private func updateNearestRecord() {
        self.nearestRecord = healthRecords
            .filter { $0.nextDoseDate != nil && $0.nextDoseDate! > Date() }
            .sorted { ($0.nextDoseDate ?? Date.distantFuture) < ($1.nextDoseDate ?? Date.distantFuture) }
            .first
    }
}
