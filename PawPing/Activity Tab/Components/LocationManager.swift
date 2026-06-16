//
//  LocationManager.swift
//  PawPing
//
//  Created by Atul on 21/03/26.
//
//

import Foundation
import CoreLocation

@Observable
class LocationManager: NSObject, CLLocationManagerDelegate {

    // MARK: - Public State
    var totalDistance: Double = 0          // metres
    var authorizationStatus: CLAuthorizationStatus = .notDetermined
    var routeLocations: [CLLocationCoordinate2D] = []

    // MARK: - Private
    private let manager = CLLocationManager()
    private var lastLocation: CLLocation?

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.distanceFilter = 3            // only update every 3 metres (saves battery)
        manager.allowsBackgroundLocationUpdates = false
        manager.activityType = .fitness        // tells iOS to optimise for walking
    }

    // MARK: - Controls

    func requestPermission() {
        manager.requestWhenInUseAuthorization()
    }

    func startTracking() {
        totalDistance = 0
        lastLocation = nil
        routeLocations.removeAll()
        manager.startUpdatingLocation()
    }

    func stopTracking() {
        manager.stopUpdatingLocation()
        lastLocation = nil
    }

    // MARK: - CLLocationManagerDelegate


    func locationManager(_ manager: CLLocationManager,
                         didUpdateLocations locations: [CLLocation]) {
        guard let newLocation = locations.last else { return }

        // Skip inaccurate readings (> 20m uncertainty)
        guard newLocation.horizontalAccuracy >= 0,
              newLocation.horizontalAccuracy <= 20 else { return }

        if let last = lastLocation {
            let delta = newLocation.distance(from: last)
            // Ignore unrealistic jumps (> 50m in one update) — usually GPS drift
            if delta < 50 {
                totalDistance += delta
                routeLocations.append(newLocation.coordinate)
            }
        } else {
            routeLocations.append(newLocation.coordinate)
        }
        lastLocation = newLocation
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
    }

    func locationManager(_ manager: CLLocationManager,
                         didFailWithError error: Error) {
        print("Location error: \(error.localizedDescription)")
    }
}
