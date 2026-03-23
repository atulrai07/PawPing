//
//  CareView.swift
//  PawPing
//

import SwiftUI
import MapKit

struct CareView: View {

    @State private var selectedCareType: CareType = .vet
    @State private var searchText: String = ""
    @State private var position: MapCameraPosition = .automatic
    @State private var selectedLocation: CareLocation?

    var store: CareStore
    var profile: DogProfile

    var filteredLocations: [CareLocation] {
        let sourceList = selectedCareType == .vet ? store.vets : store.dayCares
        if searchText.isEmpty {
            return sourceList
        } else {
            return sourceList.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                customSegmentedControl
                mapSection
                searchBarSection
                cardsList
            }
            .padding(.top, 10)
            .padding(.bottom, 80)
            .customNavigationScroll(title: "Care", profileImage: profile.dogImage)
            .sheet(item: $selectedLocation) { location in
                VetClinicDetails(item: location)
            }
        }
    }

    @Namespace private var animationNamespace

    private var customSegmentedControl: some View {
        HStack(spacing: 0) {
            ForEach(CareType.allCases, id: \.self) { type in
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedCareType = type
                    }
                } label: {
                    Text(type.rawValue)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(selectedCareType == type ? .white : Color.pawPrimary.opacity(0.8))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background {
                            if selectedCareType == type {
                                Capsule()
                                    .fill(Color.pawPrimary)
                                    .matchedGeometryEffect(id: "SegmentIndicator", in: animationNamespace)
                            }
                        }
                }
            }
        }
        .padding(4)
        .background(Color.pawPrimary.opacity(0.15))
        .clipShape(Capsule())
        .padding(.horizontal, 40)
        .padding(.top, 10)
    }

    private var mapSection: some View {
        Map(position: $position) {
            UserAnnotation()

            Annotation("Home", coordinate: CLLocationCoordinate2D(
                latitude: profile.homeLatitude,
                longitude: profile.homeLongitude)
            ) {
                ZStack {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 30, height: 30)
                        .shadow(color: .black.opacity(0.15), radius: 3)

                    Image(systemName: "house.fill")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.pawTertiary)
                }
            }

            ForEach(filteredLocations) { item in
                Marker(item.name, coordinate: item.coordinate)
                    .tint(.pawPrimary)
            }
        }
        .frame(height: 180)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .overlay(alignment: .bottomTrailing) {
            Button {
                position = .region(
                    MKCoordinateRegion(
                        center: CLLocationCoordinate2D(
                            latitude: profile.homeLatitude,
                            longitude: profile.homeLongitude
                        ),
                        latitudinalMeters: 3000,
                        longitudinalMeters: 3000
                    )
                )
            } label: {
                Image(systemName: "location.fill")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.pawSecondary)
                    .padding(12)
                    .background(Color.white)
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.15), radius: 4)
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
        .background(Color.pawNeutral)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .padding(.horizontal)
    }

    private var cardsList: some View {
        VStack(spacing: 12) {
            ForEach(filteredLocations) { item in
                Button {
                    selectedLocation = item
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
    CareView(store: CareStore(), profile: DogProfile.sampleProfile)
}
