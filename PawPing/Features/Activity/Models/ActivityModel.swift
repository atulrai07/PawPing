//
//  ActivityModel.swift
//  PawPing
//
//  Created by Atul on 01/02/26.
//

import Foundation

 
// MARK: - Core Walk Data

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

// MARK: - Activity Summary

struct WalkActivity {
    var currentMinutes: Int
    var goalMinutes: Int

    var progress: Double {
        guard goalMinutes > 0 else { return 0 }
        return Double(currentMinutes) / Double(goalMinutes)
    }
}

// MARK: - Graph Models

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

// MARK: - Distance Summary

struct DistanceData: Identifiable {
    let id = UUID()
    let date: Date
    let distanceInKm: Double
    
    var dayLabel: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
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
