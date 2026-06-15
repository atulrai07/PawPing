//
//  WalkDetailView.swift
//  PawPing
//

import SwiftUI
import MapKit

struct WalkDetailView: View {
    let session: WalkSession
    @Environment(\.dismiss) private var dismiss
    
    @State private var position: MapCameraPosition = .automatic

    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Map View
            Map(position: $position) {
                if !session.routePoints.isEmpty {
                    let coordinates = session.routePoints.map { CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude) }
                    MapPolyline(coordinates: coordinates)
                        .stroke(
                            Color("baseColor"),
                            style: StrokeStyle(lineWidth: 6, lineCap: .round, lineJoin: .round)
                        )
                    
                    // Markers for Start and End
                    if let start = coordinates.first {
                        Marker("Start", coordinate: start)
                            .tint(.green)
                    }
                    if let end = coordinates.last {
                        Marker("End", coordinate: end)
                            .tint(.red)
                    }
                }
            }
            .frame(height: 350)
            .mapStyle(.standard(elevation: .realistic))
            .onAppear {
                fitCameraToRoute()
            }
            
            // MARK: - Stats Card
            VStack(spacing: 24) {
                HStack(spacing: 0) {
                    statItem(label: "Distance", value: String(format: "%.2f", session.distanceMetres / 1000.0), unit: "km")
                    Divider().frame(height: 40).padding(.horizontal, 16)
                    statItem(label: "Duration", value: "\(session.durationMinutes)", unit: "min")
                    Divider().frame(height: 40).padding(.horizontal, 16)
                    statItem(label: "Pace", value: calculatePace(), unit: "min/km")
                }
                .padding(.top, 24)
                
                Divider()
                
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "calendar")
                            .foregroundStyle(Color("baseColor"))
                        Text(session.date.formatted(date: .complete, time: .shortened))
                            .font(.system(size: 15, weight: .medium))
                    }
                    
                    HStack {
                        Image(systemName: "pawprint.fill")
                            .foregroundStyle(Color("baseColor"))
                        Text("Completed with \(PetStore().activePet?.name ?? "your pet")")
                            .font(.system(size: 15, weight: .medium))
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 8)
                
                Spacer()
            }
            .padding(24)
            .background(Color("baseBackground"))
            .clipShape(RoundedRectangle(cornerRadius: 32))
            .offset(y: -32)
        }
        .ignoresSafeArea(edges: .top)
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Walk Details")
    }

    private func fitCameraToRoute() {
        guard !session.routePoints.isEmpty else { return }
        
        let latitudes = session.routePoints.map(\.latitude)
        let longitudes = session.routePoints.map(\.longitude)
        
        let minLat = latitudes.min()!
        let maxLat = latitudes.max()!
        let minLon = longitudes.min()!
        let maxLon = longitudes.max()!
        
        let center = CLLocationCoordinate2D(
            latitude: (minLat + maxLat) / 2,
            longitude: (minLon + maxLon) / 2
        )
        
        let span = MKCoordinateSpan(
            latitudeDelta: (maxLat - minLat) * 1.5,
            longitudeDelta: (maxLon - minLon) * 1.5
        )
        
        withAnimation(.easeInOut) {
            position = .region(MKCoordinateRegion(center: center, span: span))
        }
    }

    private func statItem(label: String, value: String, unit: String) -> some View {
        VStack(spacing: 4) {
            HStack(alignment: .lastTextBaseline, spacing: 2) {
                Text(value)
                    .font(.system(size: 24, weight: .bold))
                Text(unit)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.secondary)
            }
            Text(label)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }

    private func calculatePace() -> String {
        guard session.distanceMetres > 0 else { return "--" }
        let km = session.distanceMetres / 1000.0
        let pace = Double(session.durationMinutes) / km
        return String(format: "%.1f", pace)
    }
}

#Preview {
    NavigationStack {
        WalkDetailView(session: WalkSession(
            id: UUID(),
            petId: UUID(),
            date: Date(),
            durationMinutes: 24,
            distanceMetres: 1250,
            routePoints: [
                WalkPoint(latitude: 28.4744, longitude: 77.5040),
                WalkPoint(latitude: 28.4750, longitude: 77.5050),
                WalkPoint(latitude: 28.4760, longitude: 77.5060)
            ]
        ))
    }
}
