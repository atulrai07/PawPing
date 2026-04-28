//
//  WalkMapView.swift
//  PawPing
//

import SwiftUI
import MapKit

/// A reusable map component that renders the live walk route using a polyline.
struct WalkMapView: View {
    // MARK: - Properties
    /// The sequence of GPS coordinates recorded during the walk
    var routeLocations: [CLLocationCoordinate2D]
    
    var body: some View {
        Map {
            // Draw the walking path if coordinates exist
            if !routeLocations.isEmpty {
                MapPolyline(coordinates: routeLocations)
                    .stroke(
                        Color("baseColor"),
                        style: StrokeStyle(lineWidth: 5, lineCap: .round, lineJoin: .round)
                    )
            }
            
            // Show the user's current position pulse
            UserAnnotation()
        }
        .mapControls {
            // Standard iOS map utilities
            MapUserLocationButton()
            MapCompass()
        }
    }
}

#Preview {
    WalkMapView(routeLocations: [])
}
