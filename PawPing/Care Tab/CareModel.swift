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
import MapKit
import SwiftUI

// MARK: - Care Type

/// The modes in the Care tab's category selector
enum CareType: String, CaseIterable {
    case all      = "All"
    case vet      = "Vet"
    case dayCare  = "Day Care"
    case grooming = "Grooming"
    case petStore = "Store"
    case outdoor  = "Outdoor"
    
    var iconName: String {
        switch self {
        case .all: return "stethoscope"
        case .vet: return "cross.case.fill"
        case .dayCare: return "pawprint.fill"
        case .grooming: return "scissors"
        case .petStore: return "storefront.fill"
        case .outdoor: return "tree.fill"
        }
    }
    
    var displayColor: Color {
        switch self {
        case .all: return Color(hex: "6E54D7") ?? .purple
        case .vet: return .green
        case .dayCare: return .blue
        case .grooming: return .orange
        case .petStore: return .blue
        case .outdoor: return Color(hex: "6E54D7") ?? .purple
        }
    }
}

// MARK: - Place Model
// Dynamic model for MapKit results

struct PlaceModel: Identifiable, Equatable {
    let id = UUID()
    var name: String
    var latitude: Double
    var longitude: Double
    var distance: Double       // in km
    var category: CareType
    var address: String?
    var phone: String?
    var websiteURL: URL?
    var mapItem: MKMapItem?    // Store the original map item to avoid deprecations

    /// Convenience — converts lat/lng into the type MapKit needs
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    /// Formatted distance string for display (e.g. "1.2 km away")
    var distanceString: String {
        String(format: "%.1f km away", distance)
    }
    
    /// The real category name from MapKit, formatted nicely
    var displayCategoryName: String {
        if let raw = mapItem?.pointOfInterestCategory?.rawValue {
            let name = raw.replacingOccurrences(of: "MKPOICategory", with: "")
            let spaced = name.replacingOccurrences(of: "([a-z])([A-Z])", with: "$1 $2", options: .regularExpression)
            if !spaced.isEmpty {
                return spaced
            }
        }
        return category.rawValue
    }
    
    // Manual Equatable implementation since MKMapItem is not Equatable
    static func == (lhs: PlaceModel, rhs: PlaceModel) -> Bool {
        lhs.name == rhs.name &&
        lhs.latitude == rhs.latitude &&
        lhs.longitude == rhs.longitude &&
        lhs.distance == rhs.distance &&
        lhs.category == rhs.category &&
        lhs.address == rhs.address
    }
}
