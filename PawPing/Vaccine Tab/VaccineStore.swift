//
//  VaccineStore.swift
//  PawPing
//
//  Created by SidMoon on 16/03/26.
//
//  Data source for the Vaccine tab.
//  Holds all vaccine records and a computed summary (done/upcoming/overdue counts).
//

import Foundation
import Observation

// @Observable — SwiftUI auto-tracks any property we change here
// and refreshes the views that use it. No @Published needed.
@Observable
class VaccineStore {

    var vaccineRecords: [VaccineRecord] = []

    /// Computed on the fly — always in sync with vaccineRecords.
    /// No need to manually update counts when records change.
    var summary: VaccineSummary {
        VaccineSummary(from: vaccineRecords)
    }

    init() {
        vaccineRecords = []
    }

    // MARK: - Methods

    func records(for petId: UUID) -> [VaccineRecord] {
        vaccineRecords.filter { $0.petId == petId }
    }

    func addRecord(_ record: VaccineRecord) {
        vaccineRecords.append(record)
    }

    func deleteRecord(id: UUID) {
        vaccineRecords.removeAll { $0.id == id }
    }

    func markAsDone(id: UUID) {
        if let index = vaccineRecords.firstIndex(where: { $0.id == id }) {
            // Setting nextDoseDate to nil automatically updates the status to .done
            vaccineRecords[index].nextDoseDate = nil
            // Optional: update dateGiven to today if marking it done implies taking it right now
            vaccineRecords[index].dateGiven = Date()
        }
    }
}
