//
//  ActivityModel.swift
//  PawPing
//
//  Created by Atul on 01/02/26.
//
//  All the data models used by the Activity tab.
//  These are plain structs — no @Observable needed because
//  the store holds them as vars and SwiftUI tracks changes at the store level.
//

import Foundation
import CoreLocation


// MARK: - Owner

struct Owner: Identifiable {
    let id: UUID
    var name: String
    var email: String
    var phone: String?
    var profileImage: String?
}

// MARK: - Dog Profile

struct DogProfile: Identifiable {
    let id: UUID
    var ownerId: UUID
    var dogName: String
    var breed: String
    var gender: DogGender
    var age: String
    var dogImage: String = "profilePhoto"
    var homeLatitude: Double = 37.3346
    var homeLongitude: Double = -122.0090
    
    // Home coordinates — used by the Care tab's map to place the "Home" pin.
//    // Defaults to Delhi/NCR area. Update these when we add real user location.
//    var homeLatitude: Double = 28.535
//    var homeLongitude: Double = 77.240
    
    static let sampleProfile = DogProfile(
        id: UUID(),
        ownerId: UUID(),
        dogName: "Buddy",
        breed: "Labrador",
        gender: .male,
        age: "2",
        homeLatitude: 28.535,
        homeLongitude: 77.240
    )
}

enum DogGender: String {
   case male = "Male"
   case female = "Female"
}

// MARK: - Walk Activity

struct WalkActivity {
    var currentMinutes: Int
    var goalMinutes: Int

    /// 0.0 to 1.0 — used by CircularProgressView
    var progress: Double {
        guard goalMinutes > 0 else { return 0 }
        return Double(currentMinutes) / Double(goalMinutes)
    }
}

// MARK: - Walk Time Graph

/// A single bar on the weekly graph
struct TimeWalkedData: Identifiable {
    let id = UUID()
    let day: String
    let minutes: Int
}

/// The full week's data + the goal line
struct TimeWalkedGraphModel {
    let data: [TimeWalkedData]
    let goalMinutes: Int

    static let sample = TimeWalkedGraphModel(
        data: [
            TimeWalkedData(day: "MON", minutes: 10),
            TimeWalkedData(day: "TUE", minutes: 28),
            TimeWalkedData(day: "WED", minutes: 18),
            TimeWalkedData(day: "THU", minutes: 42),
            TimeWalkedData(day: "FRI", minutes: 38),
            TimeWalkedData(day: "SAT", minutes: 0),
            TimeWalkedData(day: "SUN", minutes: 0)
        ],
        goalMinutes: 60
    )

    /// Used to scale bar heights — whichever is bigger, the goal or the best day
    var maxMinutes: Int {
        max(goalMinutes, data.map { $0.minutes }.max() ?? 1)
    }
}

// MARK: - Meals

struct Meal: Identifiable {
    let id: UUID
    var dogId: UUID
    var icon: String      // SF Symbol name
    var time: String
    var meridian: String   // "AM" or "PM"
    var date: Date = Date()
    var mealType: MealType
    var mealName: MealName
    var isTaken: Bool
    
    static let sampleMeals: [Meal] = [
        Meal(id: UUID(), dogId: UUID(), icon: "sun.max", time: "8:00", meridian: "AM", mealType: .breakfast, mealName: .dogFood, isTaken: true),
        Meal(id: UUID(), dogId: UUID(), icon: "sunset.fill", time: "12:30", meridian: "PM", mealType: .lunch, mealName: .chickenAndRice, isTaken: false),
        Meal(id: UUID(), dogId: UUID(), icon: "moon", time: "8:30", meridian: "PM", mealType: .dinner, mealName: .eggAndRice, isTaken: false)
    ]
}

enum MealType: String {
    case breakfast = "Breakfast"
    case lunch     = "Lunch"
    case dinner    = "Dinner"
}

enum MealName: String {
    case eggAndCheese = "Egg and Cheese"
    case eggAndRice = "Egg and Rice"
    case chickenAndRice = "Chicken and Rice"
    case curdAndRice = "Curd and Rice"
    case dogFood = "Dog Food"
    case dogFoodWithCarrots = "Dog Food with Carrots"
    case others = "Others"
}

// MARK: - Vaccines (lightweight model for Activity tab's mini-card)

struct Vaccine: Identifiable {
    let id: UUID
    var dogId: UUID
    var name: String
    var givenDate: Date?
    var daysLeft: Int
    var frequency: Int
    var frequencyType: VaccineFrequencyType
    var vaccineNotes: String
    
    static let sampleVaccines = Vaccine(
        id: UUID(),
        dogId: UUID(),
        name: "Rabies Booster",
        givenDate: Date(),
        daysLeft: 3,
        frequency: 12,
        frequencyType: .monthly,
        vaccineNotes: "N/A"
    )
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
    var allergen: String?   // the specific substance (e.g. "Gluten", "Lactose")
    
    static let sampleAllergies: [Allergy] = [
        Allergy(id: UUID(), dogId: UUID(), allergyName: "Flea Dermatitis", allergyType: .environmental, allergyNotes: "N/A", allergen: "Gluten"),
        Allergy(id: UUID(), dogId: UUID(), allergyName: "Flea Dermatitis", allergyType: .environmental, allergyNotes: "N/A", allergen: "Lactose")
    ]
}

enum AllergyType: String {
    case food = "Food"
    case medication = "Medication"
    case environmental = "Environmental"
}
