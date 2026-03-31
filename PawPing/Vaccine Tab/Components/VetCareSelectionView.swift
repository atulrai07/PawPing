//
//  VetCareSelectionView.swift
//  PawPing
//
//  Created by SidMoon on 28/03/26.
//

import SwiftUI
import MapKit

struct VetCareSelectionView: View {
    @Environment(\.dismiss) private var dismiss
    
    // Dependencies needed to show the map and profile
    @Environment(CareStore.self) var careStore
    @Environment(ActivityStore.self) var activityStore
    
    // Callback when a user taps a card
    var onSelect: (CareLocation) -> Void

    @State private var searchText: String = ""
    @State private var position: MapCameraPosition = .automatic
    
    var filteredLocations: [CareLocation] {
        if searchText.isEmpty {
            return careStore.vets
        } else {
            return careStore.vets.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                mapSection
                searchBarSection
                cardsList
            }
            .padding(.top, 10)
            .padding(.bottom, 80)
        }
        .background(Color("baseBackground"))
        .navigationTitle("Vet Care")
        .navigationBarTitleDisplayMode(.inline)
        // Match the navigation style of "Dog Profile" shown in the user's images
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Image(activityStore.dogProfile.dogImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 34, height: 34)
                    .clipShape(Circle())
            }
        }
    }

    // MARK: - Subviews

    private var mapSection: some View {
        Map(position: $position) {
            UserAnnotation()

            Annotation("Home", coordinate: CLLocationCoordinate2D(latitude: activityStore.dogProfile.homeLatitude, longitude: activityStore.dogProfile.homeLongitude)) {
                ZStack {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 30, height: 30)
                        .shadow(color: .black.opacity(0.15), radius: 3)
                    Image(systemName: "house.fill")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(Color("baseColor"))
                }
            }

            ForEach(filteredLocations) { item in
                Marker(item.name, coordinate: item.coordinate)
                    .tint(Color("baseColor"))
            }
        }
        .frame(height: 180)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .overlay(alignment: .bottomTrailing) {
            Button {
                position = .region(MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: activityStore.dogProfile.homeLatitude, longitude: activityStore.dogProfile.homeLongitude), latitudinalMeters: 3000, longitudinalMeters: 3000))
            } label: {
                Image(systemName: "location.fill")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(Color("baseColor"))
                    .padding(12)
                    .background(Color.white)
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.15), radius: 4, x: 0, y: 2)
            }
            .padding(12)
        }
        .padding(.horizontal)
    }

    private var searchBarSection: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.gray)
            TextField("Search", text: $searchText)
                .font(.system(size: 16))
            Image(systemName: "mic.fill")
                .foregroundStyle(.gray)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .padding(.horizontal)
    }

    private var cardsList: some View {
        VStack(spacing: 12) {
            ForEach(filteredLocations) { item in
                Button {
                    onSelect(item)
                    dismiss()
                } label: {
                    SimpleCareCardView(item: item)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal)
    }
}

#Preview {
    NavigationStack {
        VetCareSelectionView(onSelect: { _ in })
            .environment(CareStore())
            .environment(ActivityStore())
    }
}
