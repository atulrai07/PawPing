//
//  VetSearchViewModel.swift
//  PawPing
//
//  Created by Antigravity on 27/04/26.
//

import Foundation
import MapKit
import Observation

@Observable
class VetSearchViewModel: NSObject, CLLocationManagerDelegate {
    var searchText: String = ""
    var searchResults: [MKMapItem] = []
    var isSearching: Bool = false
    var errorMessage: String? = nil
    
    private let locationManager = CLLocationManager()
    private var currentUserLocation: CLLocation?
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        // Start updates immediately if already authorized
        if locationManager.authorizationStatus == .authorizedWhenInUse || 
           locationManager.authorizationStatus == .authorizedAlways {
            locationManager.startUpdatingLocation()
        }
    }
    
    func requestLocationPermission() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    /// Searches for veterinary clinics nearby based on current location and optional search text
    func performSearch(isInitial: Bool = false) {
        // If it's not the initial automatic search, require text
        if !isInitial && searchText.isEmpty {
            searchResults = []
            return
        }
        
        // STRICT: Only search if we have a confirmed location to avoid Delhi/US defaults
        guard let location = currentUserLocation else {
            if isInitial {
                print("⏳ Waiting for Greater Noida location fix...")
            }
            return
        }
        
        isSearching = true
        errorMessage = nil
        
        let request = MKLocalSearch.Request()
        // Use a generic query if searchText is empty (for initial load)
        let query = searchText.isEmpty ? "Veterinary Clinic" : "veterinary clinic \(searchText)"
        request.naturalLanguageQuery = query
        
        // Tight biasing to ensure we stay in Greater Noida
        request.region = MKCoordinateRegion(
            center: location.coordinate,
            latitudinalMeters: 5000,
            longitudinalMeters: 5000
        )
        
        let search = MKLocalSearch(request: request)
        search.start { [weak self] response, error in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isSearching = false
                if let error = error {
                    self.errorMessage = "Search failed: \(error.localizedDescription)"
                } else {
                    self.searchResults = response?.mapItems ?? []
                }
            }
        }
    }
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        // 1. Check if the location is fresh (within last 30 seconds)
        let howRecent = location.timestamp.timeIntervalSinceNow
        guard abs(howRecent) < 30 else {
            print("⏳ Ignoring old/cached location...")
            return
        }
        
        // 2. Check if accuracy is decent (less than 1km)
        // This prevents the "General Delhi" result before GPS has a solid lock
        guard location.horizontalAccuracy > 0 && location.horizontalAccuracy < 1000 else {
            print("⏳ Location accuracy too low (\(Int(location.horizontalAccuracy))m), waiting for better fix...")
            return
        }
        
        let firstUpdate = currentUserLocation == nil
        currentUserLocation = location
        
        // If this is the first high-quality location fix, trigger a search
        if firstUpdate {
            print("📍 High-accuracy fix acquired! Searching nearby...")
            performSearch(isInitial: true)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // Ignore transient error 0 (Location Unknown)
        if let clError = error as? CLError, clError.code == .locationUnknown {
            return
        }
        
        print("❌ Location manager failed: \(error.localizedDescription)")
        isSearching = false
        errorMessage = error.localizedDescription
    }
}
