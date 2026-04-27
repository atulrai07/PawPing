//
//  SavedVet.swift
//  PawPing
//

import Foundation

struct SavedVet: Identifiable, Codable, Hashable {
    let id: UUID
    var userId: UUID
    var name: String
    var address: String?
    var phone: String?
    var createdAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case name
        case address
        case phone
        case createdAt = "created_at"
    }
}
