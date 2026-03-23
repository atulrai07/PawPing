//
//  VaccineStore.swift
//  PawPing
//
//  Created by SidMoon on 16/03/26.
//
//  Data source for the Vaccine tab.
//  Holds all vaccine records and a computed summary (done/upcoming/overdue counts).
//  Mock data for now — same pattern as ActivityStore and CareStore.
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
        let sampleDogId = UUID()

        let sampleClinic = ClinicInfo(
            id: UUID(),
            vetName: "Dr. Sharma",
            clinicName: "PupiLife Pet Clinic",
            address: "123 Main St, Dankour",
            phoneNumber: "9876543210",
            linkedVetId: nil
        )

        vaccineRecords = [
            // Upcoming — next dose is in the future
            VaccineRecord(
                id: UUID(), dogId: sampleDogId,
                vaccineName: .dhppBooster,
                dateGiven: Calendar.current.date(byAdding: .month, value: -2, to: Date())!,
                clinicInfo: nil,
                nextDoseDate: Calendar.current.date(byAdding: .weekOfYear, value: 3, to: Date()),
                notes: ""
            ),
            // Overdue — next dose is in the past
            VaccineRecord(
                id: UUID(), dogId: sampleDogId,
                vaccineName: .leptospirosis,
                dateGiven: Calendar.current.date(byAdding: .month, value: -4, to: Date())!,
                clinicInfo: nil,
                nextDoseDate: Calendar.current.date(byAdding: .day, value: -5, to: Date()),
                notes: ""
            ),
            VaccineRecord(
                id: UUID(), dogId: sampleDogId,
                vaccineName: .deworming,
                dateGiven: Calendar.current.date(byAdding: .month, value: -11, to: Date())!,
                clinicInfo: nil,
                nextDoseDate: Calendar.current.date(byAdding: .month, value: -1, to: Date()),
                notes: ""
            ),
            // Done — no nextDoseDate means the vaccine is complete
            VaccineRecord(
                id: UUID(), dogId: sampleDogId,
                vaccineName: .rabiesBooster,
                dateGiven: Calendar.current.date(byAdding: .month, value: -2, to: Date())!,
                clinicInfo: sampleClinic,
                nextDoseDate: nil,
                notes: ""
            ),
            VaccineRecord(
                id: UUID(), dogId: sampleDogId,
                vaccineName: .bordetella,
                dateGiven: Calendar.current.date(byAdding: .month, value: -7, to: Date())!,
                clinicInfo: sampleClinic,
                nextDoseDate: nil,
                notes: ""
            ),
            VaccineRecord(
                id: UUID(), dogId: sampleDogId,
                vaccineName: .dhpp,
                dateGiven: Calendar.current.date(byAdding: .month, value: -2, to: Date())!,
                clinicInfo: sampleClinic,
                nextDoseDate: nil,
                notes: ""
            ),
            VaccineRecord(
                id: UUID(), dogId: sampleDogId,
                vaccineName: .rabies,
                dateGiven: Calendar.current.date(byAdding: .month, value: -3, to: Date())!,
                clinicInfo: sampleClinic,
                nextDoseDate: nil,
                notes: ""
            )
        ] // vaccineRecords
    } // init

    // MARK: - Methods

    func records(for dogId: UUID) -> [VaccineRecord] {
        vaccineRecords.filter { $0.dogId == dogId }
    }

    func addRecord(_ record: VaccineRecord) {
        vaccineRecords.append(record)
    }

    func deleteRecord(id: UUID) {
        vaccineRecords.removeAll { $0.id == id }
    }
} // VaccineStore
