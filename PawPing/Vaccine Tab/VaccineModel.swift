//
//  VaccineModel.swift
//  PawPing
//
//  Created by Atul on 15/03/26.
//

import Foundation

// MARK: - Vaccine Name

enum VaccineName: Hashable {
    case rabies
    case rabiesBooster
    case dhpp
    case dhppBooster
    case bordetella
    case leptospirosis
    case deworming
    case other(String)

    var displayName: String {
        switch self {
        case .rabies:          return "Rabies Annual"
        case .rabiesBooster:   return "Rabies Booster"
        case .dhpp:            return "DHPP"
        case .dhppBooster:     return "DHPP Booster"
        case .bordetella:      return "Bordetella"
        case .leptospirosis:   return "Leptospirosis"
        case .deworming:       return "Deworming"
        case .other(let name): return name // Use hashable and not the Standard String Way to allow inclusion of Custom Vaccine names.
        }
    }

    // Standard list used for pickers in Dropdown to be chosen by User as Default
    static let allStandard: [VaccineName] = [
        .rabies, .rabiesBooster, .dhpp, .dhppBooster,
        .bordetella, .leptospirosis, .deworming
    ]
}

// MARK: - Vaccine Status

enum VaccineStatus: String, CaseIterable {
    case done     = "Done"
    case upcoming = "Upcoming"
    case overdue  = "Overdue"
}

// MARK: - Clinic Info

struct ClinicInfo: Identifiable, Hashable {
    let id: UUID
    var vetName: String
    var clinicName: String
    var address: String?
    var phoneNumber: String?

    /// Links to Vet from CareModel
    var linkedVetId: UUID?

    static let sample = ClinicInfo(
        id: UUID(),
        vetName: "Dr. Sharma",
        clinicName: "PupiLife Pet Clinic",
        address: "123 Main St, Dankour",
        phoneNumber: "9876543210",
        linkedVetId: nil
    )
}

// MARK: - Vaccine Record

struct VaccineRecord: Identifiable {

    let id: UUID
    var dogId: UUID
    var vaccineName: VaccineName
    var dateGiven: Date
    var clinicInfo: ClinicInfo?
    var nextDoseDate: Date?
    var notes: String

    // MARK: Computed Properties

    var status: VaccineStatus {
        guard let nextDose = nextDoseDate else { return .done }
        return nextDose <= Date() ? .overdue : .upcoming
    }

    var displayName: String {
        vaccineName.displayName
    }

    var timeRemainingText: String {

        guard let nextDose = nextDoseDate else { return "" }

        let calendar = Calendar.current
        let now = Date()

        if nextDose > now {

            let components = calendar.dateComponents([.day,.weekOfYear,.month], from: now, to: nextDose)

            if let months = components.month, months >= 1 {
                return months == 1 ? "1 month left" : "\(months) months left"
            }

            if let weeks = components.weekOfYear, weeks >= 1 {
                return weeks == 1 ? "1 week left" : "\(weeks) weeks left"
            }

            if let days = components.day {
                return days == 1 ? "1 day left" : "\(days) days left"
            }

        } else {

            let components = calendar.dateComponents([.day,.weekOfYear,.month], from: nextDose, to: now)

            if let months = components.month, months >= 1 {
                return months == 1 ? "1 month ago" : "\(months) months ago"
            }

            if let weeks = components.weekOfYear, weeks >= 1 {
                return weeks == 1 ? "1 week ago" : "\(weeks) weeks ago"
            }

            if let days = components.day {
                return days == 0 ? "Today" : (days == 1 ? "1 day ago" : "\(days) days ago")
            }
        }

        return ""
    }

    var isOverdue: Bool {
        status == .overdue
    }

    var formattedDateGiven: String {

        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d yyyy"

        return formatter.string(from: dateGiven)
    }

    var formattedNextDoseDate: String? {

        guard let nextDose = nextDoseDate else { return nil }

        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMMM yyyy"

        return formatter.string(from: nextDose)
    }

    // MARK: Sample Data

    static let sampleRecords: [VaccineRecord] = [

        VaccineRecord(
            id: UUID(),
            dogId: UUID(),
            vaccineName: .dhppBooster,
            dateGiven: Calendar.current.date(byAdding: .month, value: -2, to: Date())!,
            clinicInfo: nil,
            nextDoseDate: Calendar.current.date(byAdding: .weekOfYear, value: 3, to: Date()),
            notes: ""
        ),

        VaccineRecord(
            id: UUID(),
            dogId: UUID(),
            vaccineName: .leptospirosis,
            dateGiven: Calendar.current.date(byAdding: .month, value: -4, to: Date())!,
            clinicInfo: nil,
            nextDoseDate: Calendar.current.date(byAdding: .day, value: -5, to: Date()),
            notes: ""
        ),

        VaccineRecord(
            id: UUID(),
            dogId: UUID(),
            vaccineName: .rabiesBooster,
            dateGiven: Calendar.current.date(byAdding: .month, value: -2, to: Date())!,
            clinicInfo: .sample,
            nextDoseDate: nil,
            notes: ""
        )
    ]
}

// MARK: - Vaccine Summary

struct VaccineSummary {

    let doneCount: Int
    let upcomingCount: Int
    let overdueCount: Int

    init(from records: [VaccineRecord]) {

        doneCount     = records.filter { $0.status == .done }.count
        upcomingCount = records.filter { $0.status == .upcoming }.count
        overdueCount  = records.filter { $0.status == .overdue }.count
    }

    static let sample = VaccineSummary(from: VaccineRecord.sampleRecords)
}

// MARK: - Vaccine Report Config

struct VaccineReportConfig {

    var includeClinicContactInfo: Bool = true
    var includeMissedAlerts: Bool      = true
    var includeAppWatermark: Bool      = true

    static let defaultConfig = VaccineReportConfig()
}

// MARK: - Clinic Input Mode

enum ClinicInputMode: String, CaseIterable {
    case manual    = "Enter Manually"
    case vetCenter = "Select from vet center"
}
