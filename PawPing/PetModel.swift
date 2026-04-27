//
//  PetModel.swift
//  PawPing
//
//  Created by Antigravity on 27/04/26.
//
//  Central model for a pet profile.
//  Replaces the old DogProfile struct — same fields, cleaner naming,
//  Codable for persistence, ready for Supabase migration.
//

import Foundation

// MARK: - Pet

struct Pet: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var breed: String
    var gender: PetGender
    var age: String
    var weightKg: Double
    var imageName: String          // asset catalog name (e.g. "dog1")
    var homeLatitude: Double
    var homeLongitude: Double

    /// Fallback image used when no pet exists
    static let defaultImageName = "profilePhoto"
}

// MARK: - Pet Gender

enum PetGender: String, Codable, CaseIterable {
    case male   = "Male"
    case female = "Female"
}
