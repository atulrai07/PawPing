//
//  ActivityModel.swift
//  PawPing
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
    var homeLatitude: Double = 28.4210
    var homeLongitude: Double = 77.5340

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

    var progress: Double {
        guard goalMinutes > 0 else { return 0 }
        return Double(currentMinutes) / Double(goalMinutes)
    }
}

// MARK: - Walk Time Graph

struct TimeWalkedData: Identifiable {
    let id = UUID()
    let day: String
    let minutes: Int
}

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

    var maxMinutes: Int {
        max(goalMinutes, data.map { $0.minutes }.max() ?? 1)
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
    case lunch = "Lunch"
    case dinner = "Dinner"
}

enum MealName: String {
    case eggAndCheese
    case eggAndRice
    case chickenAndRice
    case curdAndRice
    case dogFood
    case dogFoodWithCarrots
    case others
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
    case days
    case weekly
    case monthly
    case yearly
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
    case food
    case medication
    case environmental
}
