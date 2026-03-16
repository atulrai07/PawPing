//
//  VaccineModel.swift
//  PawPing
//
//  Created by SidMoon on 15/03/26.
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
        case .other(let name): return name
        }
    }

    // Standard list of vaccine options (not sample data — used to populate pickers)
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
    // Links to an existing Vet from CareModel when selected from vet centre
    var linkedVetId: UUID?
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

    /// Determines the current status based on nextDoseDate relative to today.
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
            let components = calendar.dateComponents([.day, .weekOfYear, .month], from: now, to: nextDose)
            if let months = components.month, months >= 1 { return months == 1 ? "1 month left"  : "\(months) months left" }
            if let weeks  = components.weekOfYear, weeks >= 1 { return weeks  == 1 ? "1 week left"   : "\(weeks) weeks left"  }
            if let days   = components.day  { return days   == 1 ? "1 day left"    : "\(days) days left"   }
        } else {
            let components = calendar.dateComponents([.day, .weekOfYear, .month], from: nextDose, to: now)
            if let months = components.month, months >= 1 { return months == 1 ? "1 month ago"  : "\(months) months ago" }
            if let weeks  = components.weekOfYear, weeks >= 1 { return weeks  == 1 ? "1 week ago"   : "\(weeks) weeks ago"  }
            if let days   = components.day  { return days   == 0 ? "Today" : (days == 1 ? "1 day ago" : "\(days) days ago") }
        }
        return ""
    }

    /// Convenience check for overdue status.
    var isOverdue: Bool { status == .overdue }

    /// Formatted "Last Taken" date string, e.g. "Jan 10 2025".
    var formattedDateGiven: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d yyyy"
        return formatter.string(from: dateGiven)
    }

    /// Formatted next dose date string, e.g. "26 June 2024".
    var formattedNextDoseDate: String? {
        guard let nextDose = nextDoseDate else { return nil }
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMMM yyyy"
        return formatter.string(from: nextDose)
    }
}

// MARK: - Vaccine Summary

struct VaccineSummary {
    let doneCount: Int
    let upcomingCount: Int
    let overdueCount: Int

    /// Compute summary counts from an array of vaccine records.
    init(from records: [VaccineRecord]) {
        doneCount     = records.filter { $0.status == .done }.count
        upcomingCount = records.filter { $0.status == .upcoming }.count
        overdueCount  = records.filter { $0.status == .overdue }.count
    }
}

// MARK: - Vaccine Report Config

struct VaccineReportConfig {
    var includeClinicContactInfo: Bool = true
    var includeMissedAlerts: Bool      = true
    var includeAppWatermark: Bool      = true

    // Default config (not sample data — used as the starting state for settings)
    static let defaultConfig = VaccineReportConfig()
}

// MARK: - Clinic Input Mode

/// Represents how clinic info is entered during record creation.
enum ClinicInputMode: String, CaseIterable {
    case manual    = "Enter Manually"
    case vetCenter = "Select from vet center"
}
