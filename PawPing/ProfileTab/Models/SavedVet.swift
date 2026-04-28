//
//  SavedVet.swift
//  PawPing
//
//  Created by Atul on 25/03/26.
//

import Foundation

struct SavedVet: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var userId: UUID
    var name: String
    var address: String
    var phone: String
    var latitude: Double?
    var longitude: Double?
    var createdAt: Date = Date()
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case name
        case address
        case phone
        case latitude
        case longitude
        case createdAt = "created_at"
    }
}
