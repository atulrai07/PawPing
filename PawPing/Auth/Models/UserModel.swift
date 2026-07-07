//
//  UserModel.swift
//  PawPing
//

import Foundation

struct UserModel: Identifiable, Codable {
    let id: String // Supabase UUID as String
    var name: String
    var email: String?
    var mealTimingSettings: MealTimingSettings?
    
    enum CodingKeys: String, CodingKey { //used coding keys to match swift Camel Case convention
        case id
        case name = "full_name"
        case email
        case mealTimingSettings = "meal_timing_settings"
    }
}
