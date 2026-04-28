//
//  HealthModel.swift
//  PawPing
//
//  Created by Atul on 15/03/26.
//  Refactored into Health system on 27/04/26.
//

import Foundation

// MARK: - Health Record Type

// MARK: - Health Record Type

enum HealthRecordType: String, Codable, CaseIterable, Equatable {
    case vaccine   = "vaccine"
    case deworming = "deworming"
    
    var displayName: String {
        self.rawValue.capitalized
    }
}

// MARK: - Health Record Status

enum HealthStatus: String, CaseIterable {
    case done     = "Done"
    case upcoming = "Upcoming"
    case overdue  = "Overdue"
}

// MARK: - Health Record

struct HealthRecord: Identifiable, Codable, Equatable {

    let id: UUID
    var petId: UUID
    var type: String // "vaccine" or "deworming"
    var name: String
    var dateGiven: Date
    var nextDoseDate: Date?
    var notes: String
    var isCompleted: Bool = false
    
    // Flattened Vet Info (Supabase Ready)
    var vetName: String?
    var vetAddress: String?
    var vetPhone: String?
    var vetLatitude: Double?
    var vetLongitude: Double?

    enum CodingKeys: String, CodingKey {
        case id, type, name, notes
        case isCompleted = "completed"
        case petId = "pet_id"
        case dateGiven = "date_given"
        case nextDoseDate = "next_dose_date"
        case vetName = "vet_name"
        case vetAddress = "vet_address"
        case vetPhone = "vet_phone"
        case vetLatitude = "vet_latitude"
        case vetLongitude = "vet_longitude"
    }

    // MARK: - Computed Properties

    var recordType: HealthRecordType {
        HealthRecordType(rawValue: type) ?? .vaccine
    }

    var status: HealthStatus {
        if isCompleted { return .done }
        guard let nextDose = nextDoseDate else { return .upcoming }
        let now = Date()
        
        if nextDose <= now {
            return .overdue
        }
        
        return .upcoming
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
    
    // MARK: - Sample Data

    static let sampleRecords: [HealthRecord] = [
        HealthRecord(
            id: UUID(),
            petId: UUID(),
            type: HealthRecordType.vaccine.rawValue,
            name: "DHPP Booster",
            dateGiven: Calendar.current.date(byAdding: .month, value: -2, to: Date())!,
            nextDoseDate: Calendar.current.date(byAdding: .weekOfYear, value: 3, to: Date()),
            notes: "",
            vetName: "PupiLife Pet Clinic",
            vetAddress: "Saket, New Delhi"
        ),
        HealthRecord(
            id: UUID(),
            petId: UUID(),
            type: HealthRecordType.deworming.rawValue,
            name: "Broad Spectrum",
            dateGiven: Calendar.current.date(byAdding: .month, value: -1, to: Date())!,
            nextDoseDate: Calendar.current.date(byAdding: .month, value: 2, to: Date()),
            notes: ""
        )
    ]
}

// MARK: - Health Summary

struct HealthSummary {
    let doneCount: Int
    let upcomingCount: Int
    let overdueCount: Int

    init(from records: [HealthRecord]) {
        doneCount     = records.filter { $0.status == .done }.count
        upcomingCount = records.filter { $0.status == .upcoming }.count
        overdueCount  = records.filter { $0.status == .overdue }.count
    }

    static let sample = HealthSummary(from: HealthRecord.sampleRecords)
}

// MARK: - Health Record Options (for UI)

enum CommonHealthRecords {
    static let vaccines = [
        "Rabies Annual",
        "Rabies Booster",
        "DHPP",
        "DHPP Booster",
        "Bordetella",
        "Leptospirosis"
    ]
    
    static let deworming = [
        "Broad Spectrum",
        "Heartworm",
        "Tapeworm"
    ]
}

// MARK: - Health Report Config

struct VaccineReportConfig {
    var includeClinicContactInfo: Bool = true
    var includeMissedAlerts: Bool      = true
    var includeAppWatermark: Bool      = true

    static let defaultConfig = VaccineReportConfig()
}


