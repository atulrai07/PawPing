//
//  VaccineStore.swift → HealthStore
//  PawPing
//
//  Created by SidMoon on 16/03/26.
//  Updated for Health system on 27/04/26.
//
//  Data source for the Health tab.
//  Holds all health records and a computed summary (done/upcoming/overdue counts).
//  Persists to Supabase using the original `vaccines` table and mapping logic.
//

import Foundation
import Observation
import Supabase

// MARK: - Database Model (matches Supabase `vaccines` table)

/// Codable struct that mirrors the Supabase `vaccines` table schema exactly.
private struct DBVaccineRecord: Codable {
    let id: UUID
    let pet_id: UUID
    let owner_id: String           // Association for RLS
    let name: String
    let date: String               // "yyyy-MM-dd"
    var next_dose_date: String?    // Proper column for next dose
    var notes: String?             // Proper column for notes
    var type: String?              // "vaccine" or "deworming"
    var vet_name: String?
    var vet_address: String?
    var vet_phone: String?
    var vet_latitude: Double?
    var vet_longitude: Double?
    var status: String?            // Existing column in DB
    var batch_number: String?      // Existing column in DB
    var completed: Bool?           // New requirement
}

// MARK: - HealthStore

@Observable
class HealthStore {

    private let client = SupabaseConfig.client

    var healthRecords: [HealthRecord] = []

    /// Computed on the fly — always in sync with healthRecords.
    var summary: HealthSummary {
        HealthSummary(from: healthRecords)
    }

    init() {
        healthRecords = []
    }

    // MARK: - Fetching

    /// Fetches all health records for a specific pet from Supabase.
    @MainActor
    func fetchVaccines(for petId: UUID) async {
        do {
            let session = try await client.auth.session
            let userIdString = session.user.id.uuidString.lowercased()

            let rows: [DBVaccineRecord] = try await client
                .from("vaccines")
                .select()
                .eq("owner_id", value: userIdString)
                .eq("pet_id", value: petId)
                .order("date", ascending: false)
                .execute()
                .value

            self.healthRecords = rows.map { row in
                toHealthRecord(row, petId: petId)
            }
            print(" Successfully fetched \(self.healthRecords.count) health records for pet \(petId)")
        } catch {
            print("  Error fetching health records: \(error)")
        }
    }

    // MARK: - Filtered Access

    func records(for petId: UUID) -> [HealthRecord] {
        healthRecords.filter { $0.petId == petId }
    }

    // MARK: - Add

    @MainActor
    func addHealthRecord(_ record: HealthRecord) async {
        print("Saving record to Supabase...")
        let success = await saveToSupabase(record)
        
        if success {
            print(" Record saved successfully, refetching...")
            await fetchVaccines(for: record.petId)
        } else {
            print("Failed to save record to Supabase.")
        }
    }

    // MARK: - Delete

    @MainActor
    func deleteHealthRecord(id: UUID, petId: UUID) async {
        healthRecords.removeAll { $0.id == id }
        await deleteFromSupabase(id: id)
    }

    // MARK: - Update

    @MainActor
    func updateHealthRecord(_ record: HealthRecord) async {
        if let index = healthRecords.firstIndex(where: { $0.id == record.id }) {
            healthRecords[index] = record
        }
        await updateInSupabase(record)
    }

    // MARK: - Mark as Done (using updateVaccineStatus)

    @MainActor
    func markAsDone(id: UUID, petId: UUID) async {
        await updateVaccineStatus(vaccineId: id, petId: petId, isCompleted: true)
    }

    @MainActor
    func updateVaccineStatus(vaccineId: UUID, petId: UUID, isCompleted: Bool) async {
        do {
            // Using a simple struct for updates to avoid [String: Any] Encodable issues
            struct StatusUpdate: Encodable {
                let completed: Bool
            }
            
            try await client
                .from("vaccines")
                .update(StatusUpdate(completed: isCompleted))
                .eq("id", value: vaccineId)
                .execute()
            
            print("Successfully updated status for vaccine \(vaccineId)")
            await fetchVaccines(for: petId)
        } catch {
            print("  Error updating vaccine status: \(error.localizedDescription)")
        }
    }

    // MARK: - Private Supabase CRUD

    private func saveToSupabase(_ record: HealthRecord) async -> Bool {
        do {
            let session = try await client.auth.session
            let userIdString = session.user.id.uuidString.lowercased()
            let row = toDBRecord(record, ownerId: userIdString)
            
            print("Inserting record into 'vaccines': \(record.name)")
            
            try await client
                .from("vaccines")
                .insert(row)
                .execute()
            return true
        } catch {
            print("  Error saving health record: \(error.localizedDescription)")
            return false
        }
    }

    private func deleteFromSupabase(id: UUID) async {
        do {
            try await client
                .from("vaccines")
                .delete()
                .eq("id", value: id)
                .execute()
        } catch {
            print("  Error deleting health record: \(error)")
        }
    }

    private func updateInSupabase(_ record: HealthRecord) async {
        do {
            let session = try await client.auth.session
            let userIdString = session.user.id.uuidString.lowercased()
            let row = toDBRecord(record, ownerId: userIdString)
            
            try await client
                .from("vaccines")
                .update(row)
                .eq("id", value: record.id)
                .execute()
        } catch {
            print("  Error updating health record: \(error.localizedDescription)")
        }
    }

    // MARK: - Mapping Helpers

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()

    private func toDBRecord(_ record: HealthRecord, ownerId: String) -> DBVaccineRecord {
        let dateStr = Self.dateFormatter.string(from: record.dateGiven)
        let nextDoseStr: String? = record.nextDoseDate.map { Self.dateFormatter.string(from: $0) }

        return DBVaccineRecord(
            id: record.id,
            pet_id: record.petId,
            owner_id: ownerId,
            name: record.name,
            date: dateStr,
            next_dose_date: nextDoseStr,
            notes: record.notes,
            type: record.type,
            vet_name: record.vetName,
            vet_address: record.vetAddress,
            vet_phone: record.vetPhone,
            vet_latitude: record.vetLatitude,
            vet_longitude: record.vetLongitude,
            status: nil,
            batch_number: nil,
            completed: record.isCompleted
        )
    }

    private func toHealthRecord(_ row: DBVaccineRecord, petId: UUID) -> HealthRecord {
        let dateGiven = Self.dateFormatter.date(from: row.date) ?? Date()
        let nextDose: Date? = row.next_dose_date.flatMap { Self.dateFormatter.date(from: $0) }

        return HealthRecord(
            id: row.id,
            petId: petId,
            type: row.type ?? HealthRecordType.vaccine.rawValue,
            name: row.name,
            dateGiven: dateGiven,
            nextDoseDate: nextDose,
            notes: row.notes ?? "",
            isCompleted: row.completed ?? false,
            vetName: row.vet_name,
            vetAddress: row.vet_address,
            vetPhone: row.vet_phone,
            vetLatitude: row.vet_latitude,
            vetLongitude: row.vet_longitude
        )
    }
}
