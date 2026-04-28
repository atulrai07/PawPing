//
//  VetSearchManager.swift
//  PawPing
//
//  Created by Atul on 24/04/26.
//

import Foundation
import MapKit
import Observation

@Observable
class VetSearchManager {
    var nearbyVets: [NearbyVet] = []
    var isSearching = false
    var error: String?

    func searchNearbyVets(near coordinate: CLLocationCoordinate2D) {
        isSearching = true
        error = nil
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = "Veterinary Clinic"
        request.region = MKCoordinateRegion(
            center: coordinate,
            latitudinalMeters: 5000,
            longitudinalMeters: 5000
        )
        
        let search = MKLocalSearch(request: request)
        search.start { [weak self] response, error in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isSearching = false
                
                if let error = error {
                    self.error = error.localizedDescription
                    return
                }
                
                guard let response = response else {
                    self.error = "No clinics found nearby."
                    return
                }
                
                // Map to our model and take top 3
                self.nearbyVets = response.mapItems.prefix(3).map { item in
                    let clinicLocation = item.location
                    let userLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
                    let distance = userLocation.distance(from: clinicLocation) / 1000.0 // in km
                    
                    return NearbyVet(
                        name: item.name ?? "Unknown Clinic",
                        phoneNumber: item.phoneNumber,
                        address: item.address?.fullAddress ?? "",
                        distance: distance,
                        coordinate: clinicLocation.coordinate
                    )
                }
            }
        }
    }
}

struct NearbyVet: Identifiable {
    let id = UUID()
    let name: String
    let phoneNumber: String?
    let address: String
    let distance: Double
    let coordinate: CLLocationCoordinate2D
    
    var distanceText: String {
        String(format: "%.1f km away", distance)
    }
}
