//
//  PetMemory.swift
//  PawPing
//

import Foundation

struct PetMemory: Codable, Identifiable, Hashable {
    let id: UUID
    let imageUrl: String
    let createdAt: Date
    
    // Album support fields
    var name: String?
    var location: String?
    var imageUrls: [String]?
}

extension PetMemory {
    var displayName: String {
        name ?? "Paw Adventure"
    }
    
    var displayLocation: String {
        location ?? "Somewhere Fun"
    }
    
    var allImageUrls: [String] {
        if let urls = imageUrls, !urls.isEmpty {
            return urls
        }
        return [imageUrl]
    }
}
