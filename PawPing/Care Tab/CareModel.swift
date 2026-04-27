//
//  CareModel.swift
//  PawPing
//
//  Created by Atul on 03/02/26.
//
//  Data models for the Care tab — used by both vet clinics and day cares.
//

import Foundation
import CoreLocation

// MARK: - Care Type

/// The two modes in the Care tab's segmented control
enum CareType: String, CaseIterable {
    case vet     = "Vet Care"
    case dayCare = "Day Care"
}

// MARK: - Place Model
// Dynamic model for MapKit results

struct PlaceModel: Identifiable {
    let id = UUID()
    var name: String
    var latitude: Double
    var longitude: Double
    var distance: Double       // in km
    var category: CareType

    /// Convenience — converts lat/lng into the type MapKit needs
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    /// Formatted distance string for display (e.g. "1.2 km away")
    var distanceString: String {
        String(format: "%.1f km away", distance)
    }
}
