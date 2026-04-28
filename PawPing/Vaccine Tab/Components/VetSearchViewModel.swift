//
//  VetSearchViewModel.swift
//  PawPing
//
//  Created by Atul on 27/04/26.
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
        isSearching = true
        errorMessage = nil
        
        let query = searchText.isEmpty ? "veterinary clinic" : "veterinary clinic \(searchText)"
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        
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
        let firstLocation = currentUserLocation == nil
        currentUserLocation = locations.first
        
        // If this is the first time we get a location and we are in an empty search state,
        // trigger the search again to get accurate nearby results.
        if firstLocation && searchText.isEmpty {
            performSearch()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            locationManager.startUpdatingLocation()
        }
    }
}
