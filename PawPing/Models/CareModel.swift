//
//  CareModel.swift
//  PawPing
//
//  Created by Atul on 03/02/26.
//

import Foundation
import CoreLocation

enum CareType: String, CaseIterable {
    case vet = "Vet Care"
    case dayCare = "Day Care"
}

struct VetPlace: Identifiable {
    let id = UUID()
    let name: String
    let type: String
    let rating: Double
    let distance: Double
    let imageName: String
    let coordinate: CLLocationCoordinate2D
    
    // Formatting distance string
    var distanceString: String {
        return String(format: "%.1f km away", distance)
    }
    
    // Sample Data based on your image
    static let sampleVets: [VetPlace] = [
        VetPlace(
            name: "PupiLife Pet Clinic",
            type: "Veterinary Clinic",
            rating: 4.8,
            distance: 1.2,
            imageName: "placeImage1",
            coordinate: CLLocationCoordinate2D(latitude: 28.6139, longitude: 77.2090)
        ),
        VetPlace(
            name: "Samaria Pet Clinic",
            type: "Veterinary Clinic",
            rating: 4.8,
            distance: 2.3,
            imageName: "placeImage2",
            coordinate: CLLocationCoordinate2D(latitude: 28.6200, longitude: 77.2100)
        ),
        VetPlace(
            name: "Canine Pet Care",
            type: "Veterinary Clinic",
            rating: 4.0,
            distance: 3.3,
            imageName: "placeImage3",
            coordinate: CLLocationCoordinate2D(latitude: 28.6250, longitude: 77.2150)
        ),
        VetPlace(
            name: "Ziggly Pet Care",
            type: "Veterinary Clinic",
            rating: 3.8,
            distance: 4.2,
            imageName: "placeImage4",
            coordinate: CLLocationCoordinate2D(latitude: 28.6300, longitude: 77.2200)
        ),
        VetPlace(
            name: "Atulya's Care",
            type: "Veterinary Clinic",
            rating: 4.8,
            distance: 4.8,
            imageName: "placeImage5",
            coordinate: CLLocationCoordinate2D(latitude: 28.6350, longitude: 77.2250)
        ),
        VetPlace(
            name: "Vet4Pet Clinic",
            type: "Veterinary Clinic",
            rating: 3.8,
            distance: 5.2,
            imageName: "placeImage6",
            coordinate: CLLocationCoordinate2D(latitude: 28.6400, longitude: 77.2300)
        ),
        VetPlace(
            name: "Capital Vets",
            type: "Veterinary Clinic",
            rating: 3.6,
            distance: 6.2,
            imageName: "placeImage7",
            coordinate: CLLocationCoordinate2D(latitude: 28.6450, longitude: 77.2350)
        )
    ]
}

struct DayCare: Identifiable {
    let id = UUID()
    let name: String
    let type: String
    let rating: Double
    let distance: Double
    let imageName: String
    let coordinate: CLLocationCoordinate2D
    
    // Formatting distance string
    var distanceString: String {
        return String(format: "%.1f km away", distance)
    }
    
    // Sample Data based on your image
    static let sampleDayCare: [DayCare] = [
        DayCare(
            name: "Mamoon's Day Care",
            type: "Dog Day Care Center",
            rating: 4.8,
            distance: 1.2,
            imageName: "placeImage1",
            coordinate: CLLocationCoordinate2D(latitude: 28.6139, longitude: 77.2090)
        ),
        DayCare(
            name: "Samaria Pet Clinic",
            type: "Veterinary Clinic",
            rating: 4.8,
            distance: 2.3,
            imageName: "placeImage2",
            coordinate: CLLocationCoordinate2D(latitude: 28.6200, longitude: 77.2100)
        ),
        DayCare(
            name: "Canine Pet Care",
            type: "Veterinary Clinic",
            rating: 4.0,
            distance: 3.3,
            imageName: "placeImage3",
            coordinate: CLLocationCoordinate2D(latitude: 28.6250, longitude: 77.2150)
        ),
        DayCare(
            name: "Ziggly Pet Care",
            type: "Veterinary Clinic",
            rating: 3.8,
            distance: 4.2,
            imageName: "placeImage4",
            coordinate: CLLocationCoordinate2D(latitude: 28.6300, longitude: 77.2200)
        ),
        DayCare(
            name: "Atulya's Care",
            type: "Veterinary Clinic",
            rating: 4.8,
            distance: 4.8,
            imageName: "placeImage5",
            coordinate: CLLocationCoordinate2D(latitude: 28.6350, longitude: 77.2250)
        ),
        DayCare(
            name: "Vet4Pet Clinic",
            type: "Veterinary Clinic",
            rating: 3.8,
            distance: 5.2,
            imageName: "placeImage6",
            coordinate: CLLocationCoordinate2D(latitude: 28.6400, longitude: 77.2300)
        ),
        DayCare(
            name: "Capital Vets",
            type: "Veterinary Clinic",
            rating: 3.6,
            distance: 6.2,
            imageName: "placeImage7",
            coordinate: CLLocationCoordinate2D(latitude: 28.6450, longitude: 77.2350)
        )
    ]
}
