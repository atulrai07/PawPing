//
//  CareModel.swift
//  PawPing
//
//  Created by Atul on 03/02/26.
//
<<<<<<< HEAD
=======
//  Data models for the Care tab — used by both vet clinics and day cares.
//
>>>>>>> develop-atul

import Foundation
import CoreLocation

// MARK: - Care Type

/// The two modes in the Care tab's segmented control
enum CareType: String, CaseIterable {
    case vet     = "Vet Care"
    case dayCare = "Day Care"
}

// MARK: - Unified Care Location
<<<<<<< HEAD
// Represents both vet clinics and day care facilities.
// `subType` is nil for vets; for day cares it holds a descriptor
// like "Pet Restaurant" or "Pet Shelter".
=======
// One struct for both vets and day cares.
// subType is nil for vets (defaults to "Veterinary Clinic" in the UI).
// For day cares it holds something like "Pet Boarding Service" or "Pet DayCare".
>>>>>>> develop-atul

struct CareLocation: Identifiable {
    let id: UUID
    var name: String
    var subType: String?
    var rating: Double
    var distance: Double       // in km
    var imageName: String      // asset catalog image name
    var latitude: Double
    var longitude: Double
    var contactNumber: String?
    var email: String?
    var address: String?
    var openingTime: String?
    var closingTime: String?
    
    // Extra stats shown in VetClinicDetails
    var petSeen: String?       // e.g. "850+"
    var experience: String?    // e.g. "12 Years"
    var about: String?

    /// Convenience — converts lat/lng into the type MapKit needs
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    /// Formatted distance string for display (e.g. "1.2 km away")
    var distanceString: String {
        String(format: "%.1f km away", distance)
    }
}
