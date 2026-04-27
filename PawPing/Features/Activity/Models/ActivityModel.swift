//
//  ActivityModel.swift
//  PawPing
//
//  Created by Atul on 01/02/26.
//

import Foundation

// MARK: - Owner


// Removed legacy aliases. Use Pet and PetGender instead.

// MARK: - Activity

struct WalkActivity {
    var currentMinutes: Int
    var goalMinutes: Int

    var progress: Double {
        guard goalMinutes > 0 else { return 0 }
        return Double(currentMinutes) / Double(goalMinutes)
    }
}

struct WalkSession: Identifiable, Codable {
    let id: UUID
    var petId: UUID
    var date: Date
    var durationMinutes: Int
    var distanceMetres: Double
    var routePoints: [WalkPoint]
    
    enum CodingKeys: String, CodingKey {
        case id, date
        case petId = "pet_id"
        case durationMinutes = "duration_minutes"
        case distanceMetres = "distance_metres"
        case routePoints = "route_points"
    }
}

struct WalkPoint: Codable {
    let latitude: Double
    let longitude: Double
}

struct TimeWalkedData: Identifiable {
    let id = UUID()
    let day: String
    var minutes: Int
}

struct TimeWalkedGraphModel {
    var data: [TimeWalkedData]
    let goalMinutes: Int

    var maxMinutes: Int {
        max(goalMinutes, data.map { $0.minutes }.max() ?? 1)
    }
}

struct DistanceData: Identifiable {
    let id = UUID()
    let date: Date
    let distanceInKm: Double
    
    var dayLabel: String {
        let formatter = DateFormatter() // date to String
        formatter.dateFormat = "EEE" //it will be like MON, TUE
        return formatter.string(from: date)
    }
    
    var dayOfMonthLabel: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }
}

struct DistanceSummaryModel {
    let weekData: [DistanceData]
    let monthData: [DistanceData]
    let weekRange: String
    let monthName: String
    
    var totalWeekDistance: Double {
        weekData.reduce(0) { $0 + $1.distanceInKm }
    }
    
    var totalMonthDistance: Double {
        monthData.reduce(0) { $0 + $1.distanceInKm }
    }
}

// MARK: - Activity Logic (moved to Meals for meal specific logic)

// Removed Vaccine and Allergy models to consolidate architecture.
