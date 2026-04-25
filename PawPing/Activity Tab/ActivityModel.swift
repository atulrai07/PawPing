//
//  ActivityModel.swift
//  PawPing
//
//  Created by Atul on 01/02/26.
//

import Foundation

struct Owner: Identifiable {
    let id: UUID
    var name: String
    var email: String
    var phone: String?
    var profileImage: String?
}

struct DogProfile: Identifiable {
    let id: UUID
    var ownerId: UUID
    var dogName: String
    var breed: String
    var gender: DogGender
    var age: String
    var weightKg: Double = 25.0          // hardcoded for now — user profile setup later
    var dogImage: String = "profilePhoto"
    var homeLatitude: Double = 28.4210
    var homeLongitude: Double = 77.5340
    
}

enum DogGender: String {
   case male = "Male"
   case female = "Female"
}

// MARK: - Activity

struct WalkActivity {
    var currentMinutes: Int
    var goalMinutes: Int

    var progress: Double {
        guard goalMinutes > 0 else { return 0 }
        return Double(currentMinutes) / Double(goalMinutes)
    }
}

struct TimeWalkedData: Identifiable {
    let id = UUID()
    let day: String
    let minutes: Int
}

struct TimeWalkedGraphModel {
    let data: [TimeWalkedData]
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

// MARK: - Meals

struct Meal: Identifiable {
    let id: UUID
    var dogId: UUID
    var icon: String
    var time: String
    var meridian: String
    var date: Date = Date()
    var mealType: MealType
    var foodType: FoodType?                // nil = not yet selected (replaces old mealName)
    var quantity: Double = 1.0              // default 1.0 (cup, grams, or units)
    var unit: String = "cup"
    var calories: Double = 0               // calculated from food × quantity
    var ingredients: [MealIngredient] = []  // for custom/homemade meals
    var isTaken: Bool
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

enum MealType: String, Codable {
    case breakfast = "Breakfast"
    case lunch     = "Lunch"
    case dinner    = "Dinner"
}

// MARK: - Vaccines

struct Vaccine: Identifiable {
    let id: UUID
    var dogId: UUID
    var name: String
    var givenDate: Date?
    var daysLeft: Int
    var frequency: Int
    var frequencyType: VaccineFrequencyType
    var vaccineNotes: String
}

enum VaccineFrequencyType: String {
    case days = "Days"
    case weekly = "Weekly"
    case monthly = "Monthly"
    case yearly = "Yearly"
}

// MARK: - Allergies

struct Allergy: Identifiable {
    let id: UUID
    var dogId: UUID
    var allergyName: String
    var allergyType: AllergyType
    var allergyNotes: String
    var allergen: String?
}

enum AllergyType: String {
    case food = "Food"
    case medication = "Medication"
    case environmental = "Environmental"
}
