//
//  PetModel.swift
//  PawPing
//

import Foundation

// MARK: - Pet
struct Pet: Identifiable, Codable, Hashable {
    let id: UUID
    var ownerId: UUID?             // References profiles.id in Supabase
    var name: String
    var breed: String
    var gender: PetGender
    var age: String
    var weightKg: Double
    var imageName: String          // asset catalog name (e.g. "dog1")
    var homeLatitude: Double
    var homeLongitude: Double
    var birthday: Date? = nil
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
}

// MARK: - Pet Gender
enum PetGender: String, Codable, CaseIterable {
    case male   = "Male"
    case female = "Female"
}
