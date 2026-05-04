//
//  WalkDetailView.swift
//  PawPing
//

import SwiftUI
import MapKit

struct WalkDetailView: View {
    let activity: Activity
    
    @State private var cameraPosition: MapCameraPosition = .automatic
    
    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Map
            Map(position: $cameraPosition) {
                if !activity.routePoints.isEmpty {
                    MapPolyline(coordinates: activity.routePoints.map(\.clLocationCoordinate))
                        .stroke(Color("baseColor"), style: StrokeStyle(lineWidth: 5, lineCap: .round, lineJoin: .round))
                }
            }
            .frame(height: 300)
            .clipShape(RoundedRectangle(cornerRadius: 0))
            
            // MARK: - Summary
            VStack(spacing: 24) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("DATE")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(.secondary)
                            .tracking(1)
                        Text(activity.date.formatted(date: .abbreviated, time: .shortened))
                            .font(.system(size: 18, weight: .semibold))
                    }
                    Spacer()
                }
                
                HStack(spacing: 40) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("DISTANCE")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(.secondary)
                            .tracking(1)
                        Text(String(format: "%.2f km", activity.distanceInKm))
                            .font(.system(size: 28, weight: .bold))
                            .foregroundStyle(Color("baseColor"))
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("TIME")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(.secondary)
                            .tracking(1)
                        Text("\(activity.durationMinutes) min")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundStyle(.primary)
                    }
                    Spacer()
                }
                
                Spacer()
            }
            .padding(24)
            .background(Color("baseBackground"))
        }
        .navigationTitle("Walk Summary")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            guard !activity.routePoints.isEmpty else { return }
            let lats = activity.routePoints.map(\.latitude)
            let lons = activity.routePoints.map(\.longitude)
            let center = CLLocationCoordinate2D(
                latitude: (lats.min()! + lats.max()!) / 2,
                longitude: (lons.min()! + lons.max()!) / 2
            )
            let span = MKCoordinateSpan(
                latitudeDelta: (lats.max()! - lats.min()!) * 1.5,
                longitudeDelta: (lons.max()! - lons.min()!) * 1.5
            )
            let region = MKCoordinateRegion(center: center, span: span)
            cameraPosition = .region(region)
        }
    }
}
