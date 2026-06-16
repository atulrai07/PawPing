//
//  Medication.swift
//  PawPing
//

import Foundation

enum MedicationUnit: String, Codable, CaseIterable {
    case tablet = "Tablet(s)"
    case ml = "ml"
    case drops = "Drop(s)"
    case capsule = "Capsule(s)"
}

enum MedicationFrequency: String, Codable, CaseIterable {
    case onceDaily = "Once Daily"
    case twiceDaily = "Twice Daily"
    case every8Hours = "Every 8 Hours"
    case asNeeded = "As Needed"
}

enum MedicationStatus: String, Codable {
    case active
    case upcoming
    case completed
}

struct Medication: Identifiable, Codable {
    let id: UUID
    var petId: UUID
    var name: String
    var dosage: String
    var unit: MedicationUnit
    var frequency: MedicationFrequency
    var startDate: Date
    var endDate: Date?
    var instructions: String
    var prescribingVet: String?
    var vetAddress: String?
    var vetPhone: String?
    var vetLatitude: Double?
    var vetLongitude: Double?
    
    /// Tracks dates when doses were logged as completed
    var completedDoses: [Date]
    
    enum CodingKeys: String, CodingKey {
        case id
        case petId = "pet_id"
        case name
        case dosage
        case unit
        case frequency
        case startDate = "start_date"
        case endDate = "end_date"
        case instructions
        case prescribingVet = "prescribing_vet"
        case vetAddress = "vet_address"
        case vetPhone = "vet_phone"
        case vetLatitude = "vet_latitude"
        case vetLongitude = "vet_longitude"
        case completedDoses = "completed_doses"
    }
    
    init(id: UUID = UUID(), petId: UUID, name: String, dosage: String, unit: MedicationUnit, frequency: MedicationFrequency, startDate: Date, endDate: Date? = nil, instructions: String = "", prescribingVet: String? = nil, vetAddress: String? = nil, vetPhone: String? = nil, vetLatitude: Double? = nil, vetLongitude: Double? = nil, completedDoses: [Date] = []) {
        self.id = id
        self.petId = petId
        self.name = name
        self.dosage = dosage
        self.unit = unit
        self.frequency = frequency
        self.startDate = startDate
        self.endDate = endDate
        self.instructions = instructions
        self.prescribingVet = prescribingVet
        self.vetAddress = vetAddress
        self.vetPhone = vetPhone
        self.vetLatitude = vetLatitude
        self.vetLongitude = vetLongitude
        self.completedDoses = completedDoses
    }
    
    var status: MedicationStatus {
        let now = Date()
        if now < startDate {
            return .upcoming
        }
        if let endDate = endDate, now > endDate {
            return .completed
        }
        return .active
    }

    // MARK: - Dynamic Schedule Helpers
    
    struct DoseSlot: Identifiable, Hashable {
        var id: String { "\(time)-\(index)" }
        let index: Int
        let time: String // Scheduled time string, e.g. "09:00 AM"
        let completedDate: Date? // Date it was taken, nil if pending
    }
    
    func isActive(on date: Date) -> Bool {
        let calendar = Calendar.current
        let startOfDayDate = calendar.startOfDay(for: date)
        let startOfStartDate = calendar.startOfDay(for: startDate)
        
        if startOfDayDate < startOfStartDate {
            return false
        }
        
        if let endDate = endDate {
            let startOfEndDate = calendar.startOfDay(for: endDate)
            if startOfDayDate > startOfEndDate {
                return false
            }
        }
        
        return true
    }
    
    var dailyScheduledTimes: [String] {
        switch frequency {
        case .onceDaily:
            return ["09:00 AM"]
        case .twiceDaily:
            return ["09:00 AM", "09:00 PM"]
        case .every8Hours:
            return ["08:00 AM", "04:00 PM", "12:00 AM"]
        case .asNeeded:
            return []
        }
    }
    
    func completedDoses(on date: Date) -> [Date] {
        let calendar = Calendar.current
        return completedDoses.filter { calendar.isDate($0, inSameDayAs: date) }
            .sorted()
    }
    
    func doseSlots(for date: Date) -> [DoseSlot] {
        let scheduled = dailyScheduledTimes
        if scheduled.isEmpty {
            // As Needed: return already taken doses today, plus one pending placeholder at the end
            let completed = completedDoses(on: date)
            var slots = completed.enumerated().map { index, doseDate in
                DoseSlot(index: index, time: "Logged Dose", completedDate: doseDate)
            }
            slots.append(DoseSlot(index: slots.count, time: "As Needed", completedDate: nil))
            return slots
        }
        
        let completed = completedDoses(on: date)
        return scheduled.enumerated().map { index, timeStr in
            let completedDate = index < completed.count ? completed[index] : nil
            return DoseSlot(index: index, time: timeStr, completedDate: completedDate)
        }
    }
}

// MARK: - TimelineEventProtocol Conformance
extension Medication: TimelineEventProtocol {
    var eventDate: Date {
        // For timeline display, we could return start date or the most recent dose.
        // For simplicity, we'll return the start date as the primary event date,
        // or the user could see individual doses.
        startDate
    }
    
    var title: String {
        name
    }
    
    var subtitle: String {
        "\(dosage) \(unit.rawValue) - \(frequency.rawValue)"
    }
    
    var eventType: TimelineEventType {
        .medication
    }
    
    var isCompleted: Bool {
        status == .completed
    }
}
