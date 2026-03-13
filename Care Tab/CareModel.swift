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


// Care & Places
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
        return String(format: "%.1f km away", distance)
    }
    
    static let sampleVets: [Vet] = [
            Vet(
                id: UUID(), vetName: "Pupi Pet Life", rating: 4.3, distance: 2.3, image: "profileImage", latitude: 90.123, longitude: 76.859, contactNumber: "6430297691", email: "samplemails@gmail.com", address: "n/a", openingTime: "10:30AM", closingTime: "10:30PM"
            ),
            Vet(
                id: UUID(), vetName: "Vet 2", rating: 3.3, distance: 1.3, image: "profileImage", latitude: 99.123, longitude: 36.859, contactNumber: "3430212391", email: "samplemails@gmail.com", address: "n/a", openingTime: "10:30AM", closingTime: "10:30PM"
            ),
        ]
}


struct DayCare: Identifiable{
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
        return String(format: "%.1f km away", distance)
    }
    
    static let sampleDayCare : [DayCare] = [
        DayCare(id: UUID(), name: "Mamoon's Day Care", type: "Pet Restraunt", rating: 4.6, distance: 1.2, imageName: "profileImage", latitude: 78.221, longitude: 67.6767, contactNumber: "01712345678", email: "mamoon@example.com", address: "123 Main St, Anytown, USA", openingTime: "09:00 AM", closingTime: "05:00 PM"),
        
        DayCare(id:UUID(), name: "Paws & Claws", type: "Pet Shelter", rating: 4.0, distance: 2.5, imageName: "profileImage", latitude: 78.221, longitude: 67.6767, contactNumber: "01712345678", email: "paws@example.com", address: "456 Elm St, Anytown, USA", openingTime: "08:00 AM", closingTime: "06:00 PM")
    ]
}
