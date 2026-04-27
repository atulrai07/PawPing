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
    }
    
    func requestLocationPermission() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    func performSearch() {
        guard !searchText.isEmpty else {
            searchResults = []
            return
        }
        
        isSearching = true
        errorMessage = nil
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = "veterinary clinic \(searchText)"
        
        // If we have a location, bias the search towards it
        if let location = currentUserLocation {
            request.region = MKCoordinateRegion(
                center: location.coordinate,
                latitudinalMeters: 10000,
                longitudinalMeters: 10000
            )
        }
        
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
                    self.errorMessage = "No clinics found for \"\(self.searchText)\""
                }
            }
        }
    }
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentUserLocation = locations.first
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            locationManager.startUpdatingLocation()
        }
    }
}
