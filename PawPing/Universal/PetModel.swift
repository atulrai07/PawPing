//
//  PetModel.swift
//  PawPing
//

import Foundation

// MARK: - Pet
struct Pet: Identifiable, Codable, Hashable {
    let id: UUID
    var ownerId: String?           // References profiles.id in Supabase
    var name: String
    var breed: String
    var gender: PetGender
    var age: String
    var weightKg: Double
    var imageName: String          // asset catalog name (e.g. "dog1")
    var profileImageUrl: String? = nil // Public URL for uploaded avatars
    var homeLatitude: Double
    var homeLongitude: Double
    var birthday: String? = nil    // Stored as "yyyy-MM-dd" to match Supabase date column
    var isNeutered: Bool? = nil
    var walkGoalMinutes: Int? = nil  // User-set custom goal, nil = use breed default
    var walkCardImageUrl: String? = nil  // Public URL for custom walk card dog image

    static let defaultImageName = "profilePhoto"
    
    // Mapping keys to match Supabase snake_case columns
    enum CodingKeys: String, CodingKey {
        case id
        case ownerId = "owner_id"
        case name
        case breed
        case gender
        case age
        case weightKg = "weight_kg"
        case imageName = "image_name"
        case profileImageUrl = "profile_image_url"
        case homeLatitude = "home_latitude"
        case homeLongitude = "home_longitude"
        case birthday
        case isNeutered = "is_neutered"
        case walkGoalMinutes = "walk_goal_minutes"
        case walkCardImageUrl = "walk_card_image_url"
    }
    
    // MARK: - Helpers
    
    static func birthdayString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
    
    var birthdayDate: Date? {
        guard let birthday else { return nil }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: birthday)
    }
    
    var ageDisplay: String {
        guard let birthdayDate = birthdayDate else {
            if age == "1" {
                return "1 year"
            } else if let num = Int(age) {
                return "\(num) years"
            }
            return age
        }
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: birthdayDate, to: Date())
        
        if let years = components.year, years > 0 {
            if years == 1 {
                if let months = components.month, months > 0 {
                    return "1 yr \(months) mo"
                }
                return "1 year"
            } else {
                if let months = components.month, months > 0 {
                    return "\(years) yrs \(months) mo"
                }
                return "\(years) years"
            }
        } else if let months = components.month, months > 0 {
            return months == 1 ? "1 month" : "\(months) months"
        } else {
            let days = calendar.dateComponents([.day], from: birthdayDate, to: Date()).day ?? 0
            return days == 1 ? "1 day" : "\(days) days"
        }
    }
}

// MARK: - Pet Gender
enum PetGender: String, Codable, CaseIterable {
    case male   = "Male"
    case female = "Female"
}
