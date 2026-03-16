//
//  VaccineModel.swift
//  PawPing
//
//  Created by Atul on 15/03/26.
//

import Foundation

// Vaccine Name

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
    
    static let allStandard: [VaccineName] = [
        .rabies, .rabiesBooster, .dhpp, .dhppBooster,
        .bordetella, .leptospirosis, .deworming
    ]
}

// Vaccine Status

enum VaccineStatus: String, CaseIterable {
    case done     = "Done"
    case upcoming = "Upcoming"
    case overdue  = "Overdue"
}

// Clinic Info

struct ClinicInfo: Identifiable, Hashable {
    let id: UUID
    var vetName: String
    var clinicName: String
    var address: String?
    var phoneNumber: String?
    // Links to an existing `Vet` from `CareModel` when selected from vet center
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

// Vaccine Record
struct VaccineRecord: Identifiable {
    let id: UUID
    var dogId: UUID
    var vaccineName: VaccineName
    var dateGiven: Date
    var clinicInfo: ClinicInfo?
    var nextDoseDate: Date?
    var notes: String
    
    // Computed Properties
    
    //Determines the current status based on `nextDoseDate` relative to today.
    var status: VaccineStatus {
        guard let nextDose = nextDoseDate else { return .done }
        if nextDose <= Date() {
            return .overdue
        } else {
            return .upcoming
        }
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
            
            if let months = components.month, months >= 1 {
                return months == 1 ? "1 month left" : "\(months) months left"
            } else if let weeks = components.weekOfYear, weeks >= 1 {
                return weeks == 1 ? "1 week left" : "\(weeks) weeks left"
            } else if let days = components.day {
                return days == 1 ? "1 day left" : "\(days) days left"
            }
            return ""
        } else {
            // Overdue — show time since
            let components = calendar.dateComponents([.day, .weekOfYear, .month], from: nextDose, to: now)
            
            if let months = components.month, months >= 1 {
                return months == 1 ? "1 month ago" : "\(months) months ago"
            } else if let weeks = components.weekOfYear, weeks >= 1 {
                return weeks == 1 ? "1 week ago" : "\(weeks) weeks ago"
            } else if let days = components.day {
                return days == 0 ? "Today" : (days == 1 ? "1 day ago" : "\(days) days ago")
            }
            return ""
        }
    }
    
    // Convenience check for overdue status.
    var isOverdue: Bool {
        status == .overdue
    }
    
    // Formatted "Last Taken" date string, e.g., "Jan 10 2025".
    var formattedDateGiven: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d yyyy"
        return formatter.string(from: dateGiven)
    }
    
    // Formatted next dose date string, e.g., "26 June 2024".
    var formattedNextDoseDate: String? {
        guard let nextDose = nextDoseDate else { return nil }
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMMM yyyy"
        return formatter.string(from: nextDose)
    }
    
    // Sample Data
    static let sampleRecords: [VaccineRecord] = [
        // Upcoming
        VaccineRecord(
            id: UUID(), dogId: UUID(),
            vaccineName: .dhppBooster,
            dateGiven: Calendar.current.date(byAdding: .month, value: -2, to: Date())!,
            clinicInfo: nil,
            nextDoseDate: Calendar.current.date(byAdding: .weekOfYear, value: 3, to: Date()),
            notes: ""
        ),
        // Overdue
        VaccineRecord(
            id: UUID(), dogId: UUID(),
            vaccineName: .leptospirosis,
            dateGiven: Calendar.current.date(byAdding: .month, value: -4, to: Date())!,
            clinicInfo: nil,
            nextDoseDate: Calendar.current.date(byAdding: .day, value: -5, to: Date()),
            notes: ""
        ),
        VaccineRecord(
            id: UUID(), dogId: UUID(),
            vaccineName: .deworming,
            dateGiven: Calendar.current.date(byAdding: .month, value: -11, to: Date())!,
            clinicInfo: nil,
            nextDoseDate: Calendar.current.date(byAdding: .month, value: -1, to: Date()),
            notes: ""
        ),
        // Done
        VaccineRecord(
            id: UUID(), dogId: UUID(),
            vaccineName: .rabiesBooster,
            dateGiven: Calendar.current.date(byAdding: .month, value: -2, to: Date())!,
            clinicInfo: .sample,
            nextDoseDate: nil,
            notes: ""
        ),
        VaccineRecord(
            id: UUID(), dogId: UUID(),
            vaccineName: .bordetella,
            dateGiven: Calendar.current.date(byAdding: .month, value: -7, to: Date())!,
            clinicInfo: .sample,
            nextDoseDate: nil,
            notes: ""
        ),
        VaccineRecord(
            id: UUID(), dogId: UUID(),
            vaccineName: .dhpp,
            dateGiven: Calendar.current.date(byAdding: .month, value: -2, to: Date())!,
            clinicInfo: .sample,
            nextDoseDate: nil,
            notes: ""
        ),
        VaccineRecord(
            id: UUID(), dogId: UUID(),
            vaccineName: .rabies,
            dateGiven: Calendar.current.date(byAdding: .month, value: -3, to: Date())!,
            clinicInfo: .sample,
            nextDoseDate: nil,
            notes: ""
        ),
    ]
}

// Vaccine Summary

struct VaccineSummary {
    let doneCount: Int
    let upcomingCount: Int
    let overdueCount: Int
    
    // Computing summary counts from an array of vaccine records.
    init(from records: [VaccineRecord]) {
        self.doneCount     = records.filter { $0.status == .done }.count
        self.upcomingCount = records.filter { $0.status == .upcoming }.count
        self.overdueCount  = records.filter { $0.status == .overdue }.count
    }
    
    static let sample = VaccineSummary(from: VaccineRecord.sampleRecords)
}

// Vaccine Report Configuration
struct VaccineReportConfig {
    var includeClinicContactInfo: Bool = true
    var includeMissedAlerts: Bool = true
    var includeAppWatermark: Bool = true
    
    static let defaultConfig = VaccineReportConfig()
}

// Clinic Input Mode
enum ClinicInputMode: String, CaseIterable {
    case manual    = "Enter Manually"
    case vetCenter = "Select from vet center"
}
