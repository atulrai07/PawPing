//
//  WalkMapView.swift
//  PawPing
//
//  Created by Atul on 23/03/26.
//

import SwiftUI
import MapKit

struct WalkMapView: View {
    var routeLocations: [CLLocationCoordinate2D]
    
    var body: some View {
        Map {
            if !routeLocations.isEmpty {
                MapPolyline(coordinates: routeLocations)
                    .stroke(Color("baseColor"), style: StrokeStyle(lineWidth: 5, lineCap: .round, lineJoin: .round))
            }
            UserAnnotation()
        }
        .mapControls {
            MapUserLocationButton()
            MapCompass()
        }
    }
}
