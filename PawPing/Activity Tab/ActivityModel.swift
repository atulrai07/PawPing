//
//  ActivityModel.swift
//  PawPing
//
//  Created by Atul on 01/02/26.
//

import Foundation
import CoreLocation

// MARK: - Activity

struct CoordinateModel: Codable {
    let latitude: Double
    let longitude: Double
    
    var clLocationCoordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

struct Activity: Codable, Identifiable {
    var id = UUID()
    var date: Date
    var routePoints: [CoordinateModel]
    var distanceInKm: Double
    var durationMinutes: Int
}

struct WalkActivity: Codable {
    var currentMinutes: Int
    var goalMinutes: Int

    var progress: Double {
        guard goalMinutes > 0 else { return 0 }
        return Double(currentMinutes) / Double(goalMinutes)
    }
}

struct TimeWalkedData: Identifiable, Codable {
    var id = UUID()
    let day: String
    var minutes: Int
}

struct TimeWalkedGraphModel: Codable {
    var data: [TimeWalkedData]
    let goalMinutes: Int

    var maxMinutes: Int {
        max(goalMinutes, data.map { $0.minutes }.max() ?? 1)
    }
}

struct DistanceData: Identifiable, Codable {
    var id = UUID()
    let date: Date
    let distanceInKm: Double
    
    var dayLabel: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE" //it will be like MON, TUE
        return formatter.string(from: date)
    }
    
    var dayOfMonthLabel: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }
}

struct DistanceSummaryModel: Codable {
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

// MARK: - Meals

struct Meal: Identifiable, Codable {
    let id: UUID
    var petId: UUID
    var icon: String
    var time: String
    var meridian: String
    var date: Date = Date()
    var mealType: MealType
    var foodType: FoodType?
    var quantity: Double = 1.0
    var unit: String = "cup"
    var calories: Double = 0
    var ingredients: [MealIngredient] = []
    var isTaken: Bool
    
    /// Returns true if this meal's date is today
    var isToday: Bool {
        Calendar.current.isDateInToday(date)
    }
}

struct MealIngredient: Codable, Identifiable {
    var id = UUID()
    var name: String
    var quantity: Double
    var unit: String = "g"
    var caloriesPer100g: Double
    
    var calculatedCalories: Double {
        (caloriesPer100g / 100.0) * quantity
    }
}

struct USDAFood: Codable, Identifiable {
    var id: String { name }
    let name: String
    let caloriesPer100g: Double
}

enum MealType: String, Codable, CaseIterable {
    case breakfast = "Breakfast"
    case lunch     = "Lunch"
    case dinner    = "Dinner"
    
    var icon: String {
        switch self {
        case .breakfast: return "sun.max"
        case .lunch:     return "sunset.fill"
        case .dinner:    return "moon"
        }
    }
    
    var defaultTime: String {
        switch self {
        case .breakfast: return "8:00"
        case .lunch:     return "12:30"
        case .dinner:    return "8:30"
        }
    }
    
    var defaultMeridian: String {
        switch self {
        case .breakfast: return "AM"
        case .lunch:     return "PM"
        case .dinner:    return "PM"
        }
    }
}


