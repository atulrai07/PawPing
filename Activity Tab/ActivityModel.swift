//
//  ActivityModel.swift
//  PawPing
//
//  Created by SidMoon on 01/02/26.
//

import Foundation
import CoreLocation

// MARK: - User & Pet

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
    var gender: String
    var age: String
    var dogImage: String = "profilePhoto"
}

// MARK: - Activity

struct Activity: Identifiable {
    let id: UUID
    var dogId: UUID
    var date: Date
    var currentMinutes: Int
    var goalMinutes: Int
    var distanceWalked: Double
    var goalDistanceWalked: Double

    var progress: Double {
        guard goalMinutes > 0 else { return 0 }
        return Double(currentMinutes) / Double(goalMinutes)
    }
}

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

// MARK: - Meals

struct Meals: Identifiable {
    let id: UUID
    var dogId: UUID
    var icon: String
    var time: String
    var meridian: String
    var date: Date = Date()
    var mealType: MealType
    var mealName: MealName
    var isTaken: Bool
}

enum MealType: String {
    case breakFast = "Breakfast"
    case lunch     = "Lunch"
    case dinner    = "Dinner"
}

enum MealName: String {
    case eggAndCheese       = "Egg and Cheese"
    case eggAndRice         = "Egg and Rice"
    case chickenAndRice     = "Chicken and Rice"
    case curdAndRice        = "Curd and Rice"
    case dogFood            = "Dog Food"
    case dogFoodWithCarrots = "Dog Food with Carrots"
    case others             = "Others"
}

// MARK: - Vaccines (Activity Tab)

struct Vaccines: Identifiable {
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
    case days    = "Days"
    case weekly  = "Weekly"
    case monthly = "Monthly"
    case yearly  = "Yearly"
}

// MARK: - Allergies

struct Allergy: Identifiable {
    let id: UUID
    var dogId: UUID
    var allergyName: String
    var alleryType: AllergyType
    var alleryNotes: String
    var allergen: String?
}

enum AllergyType: String {
    case food          = "Food"
    case medication    = "Medication"
    case environmental = "Environmental"
}
