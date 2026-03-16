//
//  CareModel.swift
//  PawPing
//
//  Created by SidMoon on 03/02/26.
//

import Foundation
import CoreLocation

enum CareType: String, CaseIterable {
    case vet     = "Vet Care"
    case dayCare = "Day Care"
}

struct Vet: Identifiable {
    let id: UUID
    var vetName: String
    var rating: Double
    var distance: Double
    var image: String
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

struct DayCare: Identifiable {
    let id: UUID
    var name: String
    var type: String
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
