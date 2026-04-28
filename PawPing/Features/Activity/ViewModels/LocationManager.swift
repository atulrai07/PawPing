//
//  LocationManager.swift
//  PawPing
//
//  Created by Atul on 21/03/26.
//

import Foundation
import CoreLocation
import Observation

/// `LocationManager` is responsible for high-precision GPS tracking during walks.
/// It calculates total distance traveled and records coordinate points for route mapping.
@Observable
class LocationManager: NSObject, CLLocationManagerDelegate {

    // MARK: - Public State
    /// Total distance covered in the current session (metres)
    var totalDistance: Double = 0
    /// Current GPS permission status
    var authorizationStatus: CLAuthorizationStatus = .notDetermined
    /// List of coordinates recorded during the walk for map rendering
    var routeLocations: [CLLocationCoordinate2D] = []

    // MARK: - Dependencies
    /// Apple's core location service engine
    private let manager = CLLocationManager()
    /// Reference to the previous GPS point to calculate distance delta
    private var lastLocation: CLLocation?

    // MARK: - Initialization
    override init() {
        super.init()
        setupManager()
    }
    
    /// Configures the GPS hardware settings for optimal fitness tracking
    private func setupManager() {
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        // Filters out small movements (under 3m) to save battery and reduce noise
        manager.distanceFilter = 3
        // Note: Set to true if background tracking is enabled in Info.plist
        manager.allowsBackgroundLocationUpdates = false
        manager.activityType = .fitness
    }

    // MARK: - Lifecycle Controls

    /// Triggers the system permission dialog for GPS access
    func requestPermission() {
        manager.requestWhenInUseAuthorization()
    }

    /// Resets all counters and begins active GPS tracking
    func startTracking() {
        totalDistance = 0
        lastLocation = nil
        routeLocations.removeAll()
        manager.startUpdatingLocation()
    }

    /// Ceases GPS updates and clears the session state
    func stopTracking() {
        manager.stopUpdatingLocation()
        lastLocation = nil
    }

    // MARK: - CLLocationManagerDelegate

    /// Called by iOS whenever a new set of GPS coordinates is available
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let newLocation = locations.last else { return }

        // 1. Accuracy Filter: Skip readings with high uncertainty (> 20m)
        // This prevents "jumping" when walking near tall buildings or under trees
        guard newLocation.horizontalAccuracy >= 0,
              newLocation.horizontalAccuracy <= 20 else { return }

        if let last = lastLocation {
            // Calculate the distance between the current and previous point
            let delta = newLocation.distance(from: last)
            
            // 2. Jitter Filter: Ignore unrealistic jumps (> 50m in one update)
            // This is usually caused by GPS signal reflecting off surfaces (multipath)
            if delta < 50 {
                totalDistance += delta
                routeLocations.append(newLocation.coordinate)
            }
        } else {
            // First valid point recorded for the session
            routeLocations.append(newLocation.coordinate)
        }
        
        lastLocation = newLocation
    }

    /// Monitors changes in user permission (e.g., if they disable GPS in Settings)
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
    }

    /// Handles GPS hardware or connection errors
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("❌ Location Manager Error: \(error.localizedDescription)")
    }
}
