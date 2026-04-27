//
//  VaccineStore.swift
//  PawPing
//
//  Created by SidMoon on 16/03/26.
//
//  Data source for the Vaccine tab.
//  Holds all vaccine records and a computed summary (done/upcoming/overdue counts).
//  Now persists to Supabase instead of in-memory only.
//

import Foundation
import Observation
import Supabase

// MARK: - Database Model (matches Supabase `vaccines` table)

/// Codable struct that mirrors the Supabase `vaccines` table schema exactly.
/// Columns: id, pet_id, name, date, status, batch_number, created_at
private struct DBVaccineRecord: Codable {
    let id: UUID
    let pet_id: UUID
    let owner_id: String           // Association for RLS
    let name: String
    let date: String               // "yyyy-MM-dd"
    var next_dose_date: String?    // Proper column for next dose
    var notes: String?             // Proper column for notes
}

// MARK: - VaccineStore

@Observable
class VaccineStore {

    private let client = SupabaseConfig.client

    var vaccineRecords: [VaccineRecord] = []

    /// Computed on the fly — always in sync with vaccineRecords.
    /// No need to manually update counts when records change.
    var summary: VaccineSummary {
        VaccineSummary(from: vaccineRecords)
    }

    init() {
        vaccineRecords = []
    }

    // MARK: - Fetching

    /// Fetches all vaccine records for a specific pet from Supabase.
    @MainActor
    func fetchRecords(for petId: UUID) async {
        do {
            let rows: [DBVaccineRecord] = try await client
                .from("vaccines")
                .select()
                .eq("pet_id", value: petId)
                .order("date", ascending: false)
                .execute()
                .value

            self.vaccineRecords = rows.map { row in
                toVaccineRecord(row, petId: petId)
            }
        } catch {
            print("❌ Error fetching vaccines: \(error)")
        }
    }

    // MARK: - Filtered Access

    func records(for petId: UUID) -> [VaccineRecord] {
        vaccineRecords.filter { $0.petId == petId }
    }

    // MARK: - Add

    @MainActor
    func addRecord(_ record: VaccineRecord) {
        // Add locally immediately for UI responsiveness
        vaccineRecords.append(record)

        // Persist to Supabase in background
        Task {
            await saveToSupabase(record)
        }
    }

    // MARK: - Delete

    @MainActor
    func deleteRecord(id: UUID) {
        vaccineRecords.removeAll { $0.id == id }

        Task {
            await deleteFromSupabase(id: id)
        }
    }

    // MARK: - Mark as Done

    @MainActor
    func markAsDone(id: UUID) {
        if let index = vaccineRecords.firstIndex(where: { $0.id == id }) {
            vaccineRecords[index].nextDoseDate = nil
            vaccineRecords[index].dateGiven = Date()

            let updated = vaccineRecords[index]
            Task {
                await updateInSupabase(updated)
            }
        }
    }

    // MARK: - Private Supabase CRUD

    private func saveToSupabase(_ record: VaccineRecord) async {
        do {
            let session = try await client.auth.session
            let userIdString = session.user.id.uuidString.lowercased()
            
            let row = toDBRecord(record, ownerId: userIdString)
            try await client
                .from("vaccines")
                .insert(row)
                .execute()
        } catch {
            print("❌ Error saving vaccine: \(error)")
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
            print("❌ Error deleting vaccine: \(error)")
        }
    }

    private func updateInSupabase(_ record: VaccineRecord) async {
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
            print("❌ Error updating vaccine: \(error)")
        }
    }

    // MARK: - Mapping Helpers

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()

    /// Convert app model → DB row
    private func toDBRecord(_ record: VaccineRecord, ownerId: String) -> DBVaccineRecord {
        let dateStr = Self.dateFormatter.string(from: record.dateGiven)
        let nextDoseStr: String? = record.nextDoseDate.map { Self.dateFormatter.string(from: $0) }

        return DBVaccineRecord(
            id: record.id,
            pet_id: record.petId,
            owner_id: ownerId,
            name: record.vaccineName.displayName,
            date: dateStr,
            next_dose_date: nextDoseStr,
            notes: record.notes
        )
    }

    /// Convert DB row → app model
    private func toVaccineRecord(_ row: DBVaccineRecord, petId: UUID) -> VaccineRecord {
        let dateGiven = Self.dateFormatter.date(from: row.date) ?? Date()
        let nextDose: Date? = row.next_dose_date.flatMap { Self.dateFormatter.date(from: $0) }

        // Reconstruct VaccineName from the stored display string
        let vaccineName = parseVaccineName(row.name)

        return VaccineRecord(
            id: row.id,
            petId: petId,
            vaccineName: vaccineName,
            dateGiven: dateGiven,
            clinicInfo: nil,                          // Not persisted in current table
            nextDoseDate: nextDose,
            notes: row.notes ?? ""
        )
    }

    /// Tries to match a display name string back to a VaccineName enum case.
    private func parseVaccineName(_ name: String) -> VaccineName {
        switch name {
        case "Rabies Annual":    return .rabies
        case "Rabies Booster":   return .rabiesBooster
        case "DHPP":             return .dhpp
        case "DHPP Booster":     return .dhppBooster
        case "Bordetella":       return .bordetella
        case "Leptospirosis":    return .leptospirosis
        case "Deworming":        return .deworming
        default:                 return .other(name)
        }
    }
}
