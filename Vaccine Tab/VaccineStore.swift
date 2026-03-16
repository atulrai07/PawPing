//
//  VaccineStore.swift
//  PawPing
//
//  Created by Atul on 15/03/26.
//

import Foundation

@Observable
class VaccineStore {

    var vaccineRecords: [VaccineRecord] = []

    /// Computed summary — always reflects the current state of vaccineRecords.
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
            // Upcoming
            VaccineRecord(
                id: UUID(), dogId: sampleDogId,
                vaccineName: .dhppBooster,
                dateGiven: Calendar.current.date(byAdding: .month, value: -2, to: Date())!,
                clinicInfo: nil,
                nextDoseDate: Calendar.current.date(byAdding: .weekOfYear, value: 3, to: Date()),
                notes: ""
            ),
            // Overdue
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
            // Done
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
        ]
    }

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
}
