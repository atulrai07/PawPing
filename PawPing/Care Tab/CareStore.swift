//
//  CareStore.swift
//  PawPing
//
//  Created by SidMoon on 16/03/26.
//
//  Data source for the Care tab — fetches real vet clinics and day cares using MapKit.
//

import Foundation
import Observation
import CoreLocation
import MapKit

@Observable
class CareStore: NSObject, CLLocationManagerDelegate {

    var vets: [PlaceModel] = []
    var dayCares: [PlaceModel] = []
    
    var isLoading: Bool = false
    var isLocationDenied: Bool = false
    
    private let locationManager = CLLocationManager()
    var lastLocation: CLLocation?
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    }
    
    func requestLocationAndFetch() {
        isLoading = true
        isLocationDenied = false
        
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            isLoading = false
            isLocationDenied = true
        case .authorizedAlways, .authorizedWhenInUse:
            locationManager.requestLocation()
        @unknown default:
            break
        }
    }
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus == .authorizedWhenInUse || manager.authorizationStatus == .authorizedAlways {
            manager.requestLocation()
        } else if manager.authorizationStatus == .denied || manager.authorizationStatus == .restricted {
            isLoading = false
            isLocationDenied = true
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else {
            isLoading = false
            return
        }
        lastLocation = location
        fetchPlaces(near: location)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager failed: \(error)")
        isLoading = false
    }
    
    // MARK: - MapKit Search
    
    private func fetchPlaces(near location: CLLocation) {
        Task { @MainActor in
            do {
                async let fetchedVets = search(query: "veterinary clinic", near: location, category: .vet)
                async let fetchedDaycares = search(query: "pet daycare", near: location, category: .dayCare)
                async let fetchedPetCare = search(query: "pet care", near: location, category: .dayCare)
                
                let v = try await fetchedVets
                let d1 = try await fetchedDaycares
                let d2 = try await fetchedPetCare
                
                // Merge daycares and remove duplicates
                let combinedDaycares = d1 + d2
                var uniqueDaycares = [PlaceModel]()
                var seenNames = Set<String>()
                for item in combinedDaycares {
                    if !seenNames.contains(item.name) {
                        seenNames.insert(item.name)
                        uniqueDaycares.append(item)
                    }
                }
                
                self.vets = v
                self.dayCares = uniqueDaycares
                self.isLoading = false
                
            } catch {
                print("Search failed: \(error)")
                self.isLoading = false
            }
        }
    }
    
    private func search(query: String, near location: CLLocation, category: CareType) async throws -> [PlaceModel] {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        // 10 km region
        request.region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 10000, longitudinalMeters: 10000)
        
        let search = MKLocalSearch(request: request)
        let response = try await search.start()
        
        var results = [PlaceModel]()
        for item in response.mapItems {
            guard let name = item.name else { continue }
            
            let destLoc = item.location
            let distanceInMeters = location.distance(from: destLoc)
            let distanceInKm = distanceInMeters / 1000.0
            
            results.append(PlaceModel(
                name: name,
                latitude: destLoc.coordinate.latitude,
                longitude: destLoc.coordinate.longitude,
                distance: distanceInKm,
                category: category,
                address: item.address?.fullAddress ?? item.name ?? "Address not available",
                phone: item.phoneNumber,
                websiteURL: item.url,
                mapItem: item
            ))
        }
        
        // Filter out results that are too far away (e.g. > 50km) to ensure they are actually "nearby"
        // Also sort by distance strictly.
        results = results.filter { $0.distance < 50.0 }
        results.sort { $0.distance < $1.distance }
        
        return Array(results.prefix(15))
    }
}
