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
    var homeLatitude: Double
    var homeLongitude: Double
    var birthday: String? = nil    // Stored as "yyyy-MM-dd" to match Supabase date column
    var isNeutered: Bool? = nil

    /// Fallback image used when no pet exists
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
        case homeLatitude = "home_latitude"
        case homeLongitude = "home_longitude"
        case birthday
        case isNeutered = "is_neutered"
    }
    
    // MARK: - Helpers
    
    /// Convert a Date to the "yyyy-MM-dd" string format used by the database
    static func birthdayString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
    
    /// Parse the stored birthday string back into a Date
    var birthdayDate: Date? {
        guard let birthday else { return nil }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: birthday)
    }
}

// MARK: - Pet Gender
enum PetGender: String, Codable, CaseIterable {
    case male   = "Male"
    case female = "Female"
}
