//
//  ActivityModel.swift
//  PawPing
//
//  Created by Atul on 01/02/26.
//

import Foundation
struct Profile {
    var dogName: String
    var breed: String
    var gender : String
    var age : String
    var dogImage: String = "profilePhoto"
    
    static let sampleProfile : Profile = Profile(dogName: "Buddy", breed: "Labrador", gender: "F", age: "3")
}

struct WalkActivity {
    var currentMinutes: Int
    var goalMinutes: Int
    
    // Helper to calculate progress (0.0 to 1.0)
    var progress: Double {
        guard goalMinutes > 0 else { return 0 }
        return Double(currentMinutes) / Double(goalMinutes)
    }
}

struct Vaccine {
    var name: String
    var daysLeft: Int
    
    static let sampleVaccines: Vaccine = Vaccine(name: "Rabies Booster", daysLeft: 3)
}

struct Meal: Identifiable {
    let id = UUID()
    var icon: String 
    var time: String
    var meridiem: String
    var isTaken: Bool
    
    static let sampleMeals: [Meal] = [
        Meal(icon: "sun.max", time: "8:00", meridiem: "AM", isTaken: true),
        Meal(icon: "sunset.fill", time: "12:30", meridiem: "PM", isTaken: false),
        Meal(icon: "moon", time: "8:00", meridiem: "PM", isTaken: false)
    ]
}

struct Allergies : Identifiable {
    let id = UUID()
    let allergyName : String
    
    static let sampleAllergies: [Allergies] = [
        Allergies(allergyName: "Gluten"),
        Allergies(allergyName: "Lactose"),
        Allergies(allergyName: "Wheat"),
        Allergies(allergyName: "Peanuts")
    ]
}
