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
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        
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
        
        // Only perform initial search if we have a valid location
        guard let location = currentUserLocation else {
            if isInitial {
                print("⏳ Waiting for location fix before searching...")
            }
            return
        }
        
        isSearching = true
        errorMessage = nil
        
        let request = MKLocalSearch.Request()
        let query = searchText.isEmpty ? "Veterinary Clinic" : "veterinary clinic \(searchText)"
        request.naturalLanguageQuery = query
        
        // Biasing search to current coordinates
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
                    return
                }
                
                self.searchResults = response?.mapItems ?? []
                if self.searchResults.isEmpty {
                    let searchContext = self.searchText.isEmpty ? "nearby" : "for \"\(self.searchText)\""
                    self.errorMessage = "No clinics found \(searchContext). Try searching a different area."
                }
            }
        }
    }
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        
        // Check if the location is fresh (within last 30 seconds)
        let howRecent = location.timestamp.timeIntervalSinceNow
        guard abs(howRecent) < 30 else { return }
        
        // Check if accuracy is decent
        guard location.horizontalAccuracy < 1000 else { return }
        
        let isFirstFix = currentUserLocation == nil
        currentUserLocation = location
        
        // If this is the first high-accuracy fix, trigger the search
        if isFirstFix && searchResults.isEmpty {
            performSearch(isInitial: true)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            locationManager.startUpdatingLocation()
        }
    }
}
