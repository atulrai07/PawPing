//
//  UserModel.swift
//  PawPing
//

import Foundation

struct UserModel: Identifiable, Codable {
    let id: String // Supabase UUID as String
    var name: String
    var email: String
}
