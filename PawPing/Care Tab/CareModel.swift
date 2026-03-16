//
//  CareModel.swift
//  PawPing
//
//  Created by Atul on 03/02/26.
//

import Foundation
import CoreLocation

enum CareType: String, CaseIterable {
    case vet     = "Vet Care"
    case dayCare = "Day Care"
}

// MARK: - Unified Care Location
// Represents both vet clinics and day care facilities.
// `subType` is nil for vets; for day cares it holds a descriptor
// like "Pet Restaurant" or "Pet Shelter".

struct CareLocation: Identifiable {
    let id: UUID
    var name: String
    var subType: String?
    var rating: Double
    var distance: Double
    var imageName: String
    var latitude: Double
    var longitude: Double
    var contactNumber: String?
    var email: String?
    var address: String?
    var openingTime: String?
    var closingTime: String?

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    var distanceString: String {
        String(format: "%.1f km away", distance)
    }
}
