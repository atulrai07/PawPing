//
//  PetMemory.swift
//  PawPing
//

import Foundation

struct PetMemory: Codable, Identifiable, Hashable {
    let id: UUID
    let imageUrl: String
    let createdAt: Date
}
