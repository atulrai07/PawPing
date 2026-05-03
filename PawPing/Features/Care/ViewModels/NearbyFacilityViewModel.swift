//
//  NearbyFacilityViewModel.swift
//  PawPing
//

import Foundation
import MapKit
import Observation
import CoreLocation

@Observable
class NearbyFacilityViewModel: NSObject, CLLocationManagerDelegate {

    struct FacilityItem: Identifiable, Hashable {
        let id: String
        let mapItem: MKMapItem
        let distance: String?
        
        static func == (lhs: FacilityItem, rhs: FacilityItem) -> Bool {
            lhs.id == rhs.id
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }
    }

    enum FacilityType {
        case vetClinic
        case daycare

        var searchQuery: String {
            switch self {
            case .vetClinic: return "Veterinary Clinic"
            case .daycare:   return "Dog Daycare"
            }
        }

        var emptyStateMessage: String {
            switch self {
            case .vetClinic: return "No vet clinics found nearby"
            case .daycare:   return "No pet daycares found nearby"
            }
        }
    }

    // MARK: - State
    var searchResults: [FacilityItem] = []
    var isSearching: Bool = false
    var errorMessage: String? = nil
    var locationPermissionGranted: Bool = false

    // MARK: - Private
    private var facilityType: FacilityType
    private let locationManager = CLLocationManager()
    private var currentUserLocation: CLLocation?

    init(type: FacilityType) {
        self.facilityType = type
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        // Start updates immediately if already authorized
        let status = locationManager.authorizationStatus
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            locationManager.startUpdatingLocation()
        }
    }

    deinit {
        locationManager.stopUpdatingLocation()
    }

    // MARK: - Public
    
    func updateType(_ newType: FacilityType) {
        guard facilityType != newType else { return }
        facilityType = newType
        loadNearbyFacilities()
    }

    func stopTracking() {
        locationManager.stopUpdatingLocation()
    }

    func loadNearbyFacilities() {
        // Show spinner immediately while we wait for location/results
        isSearching = true
        errorMessage = nil

        // Start tracking immediately if permissions exist
        let status = locationManager.authorizationStatus
        if status == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        } else if status == .authorizedWhenInUse || status == .authorizedAlways {
            locationManager.startUpdatingLocation()
        }

        // If we already have a fix, search now
        if let location = currentUserLocation {
            performSearch(with: location)
        }
    }

    private func performSearch(with location: CLLocation) {
        isSearching = true
        errorMessage = nil

        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = facilityType.searchQuery
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
                    self.errorMessage = error.localizedDescription
                } else {
                    let items = response?.mapItems ?? []
                    self.searchResults = items.map { item in
                        let meters = location.distance(from: item.location)
                        let distanceStr = String(format: "%.1f km away", meters / 1000)
                        
                        return FacilityItem(
                            id: item.name ?? UUID().uuidString,
                            mapItem: item,
                            distance: distanceStr
                        )
                    }
                    
                    if self.searchResults.isEmpty {
                        self.errorMessage = self.facilityType.emptyStateMessage
                    }
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
            print("⏳ Ignoring old/cached location in Care tab...")
            return
        }
        
        // 2. Check if accuracy is decent (less than 1km)
        guard location.horizontalAccuracy > 0 && location.horizontalAccuracy < 1000 else {
            print("⏳ Care location accuracy too low (\(Int(location.horizontalAccuracy))m), waiting...")
            return
        }
        
        let firstUpdate = currentUserLocation == nil
        currentUserLocation = location
        
        // If this is the first high-quality location fix, trigger a search
        if firstUpdate {
            print("📍 Care Tab: High-accuracy fix acquired! Searching nearby...")
            performSearch(with: location)
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // Ignore transient error 0 (Location Unknown)
        if let clError = error as? CLError, clError.code == .locationUnknown {
            return
        }
        
        print("❌ Care Location Error: \(error.localizedDescription)")
        isSearching = false
        errorMessage = error.localizedDescription
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        locationPermissionGranted = (status == .authorizedWhenInUse || status == .authorizedAlways)
        if locationPermissionGranted {
            manager.startUpdatingLocation()
        }
    }
}
