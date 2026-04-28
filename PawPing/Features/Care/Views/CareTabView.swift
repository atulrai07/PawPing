//
//  CareTabView.swift
//  PawPing
//

import SwiftUI
import MapKit

struct CareTabView: View {
    @Environment(PetStore.self) var petStore
    @State private var selectedTab: CareTab = .vet
    @State private var searchText: String = ""
    @State private var viewModel = NearbyFacilityViewModel(type: .vetClinic)
    @State private var selectedFacility: MKMapItem?
    
    enum CareTab: String, CaseIterable {
        case vet = "Vet Care"
        case daycare = "Day care"
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                headerSection
                
                VStack(spacing: 20) {
                    mapSection
                    searchSection
                    facilityList
                }
                .padding(.bottom, 100)
            }
            .customNavigationScroll(title: "Care", petStore: petStore)
            .sheet(item: $selectedFacility) { item in
                FacilityDetailSheet(item: item, accentColor: selectedTab == .vet ? .pawPrimary : .orange)
                    .presentationDragIndicator(.visible)
            }
            .onAppear {
                viewModel.loadNearbyFacilities()
            }
            .onDisappear {
                viewModel.stopTracking()
            }
        }
    }

    private var headerSection: some View {
        HStack(spacing: 0) {
            ForEach(CareTab.allCases, id: \.self) { tab in
                Button {
                    withAnimation(.spring()) {
                        selectedTab = tab
                        viewModel.updateType(tab == .vet ? .vetClinic : .daycare)
                    }
                } label: {
                    Text(tab.rawValue)
                        .font(.system(size: 14, weight: .medium))
                        .frame(maxWidth: .infinity)
                        .frame(height: 38)
                        .background(selectedTab == tab ? Color.pawPrimary : Color.clear)
                        .foregroundStyle(selectedTab == tab ? .white : Color.pawPrimary)
                        .clipShape(Capsule())
                }
            }
        }
        .padding(4)
        .background(Color.pawPrimary.opacity(0.12))
        .clipShape(Capsule())
        .padding(.horizontal, 24)
        .padding(.top, 10)
    }

    private var mapSection: some View {
        MapPreviewSection(searchResults: viewModel.searchResults.map { $0.mapItem })
            .frame(height: 180)
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .padding(.horizontal)
    }

    private var searchSection: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)
            TextField("Search", text: $searchText)
            Image(systemName: "mic.fill")
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color(.secondarySystemBackground))
        .clipShape(Capsule())
        .padding(.horizontal)
    }

    private var facilityList: some View {
        Group {
            if viewModel.isSearching {
                ProgressView()
                    .padding(.top, 40)
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(viewModel.searchResults, id: \.id) { item in
                        FacilityRowView(item: item) {
                            selectedFacility = item.mapItem
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

struct MapPreviewSection: View {
    let searchResults: [MKMapItem]

    @State private var position: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 28.4744, longitude: 77.5040),
            latitudinalMeters: 8_000,
            longitudinalMeters: 8_000
        )
    )

    var body: some View {
        Map(position: $position) {
            UserAnnotation()
            ForEach(searchResults, id: \.self) { item in
                Marker(item.name ?? "Clinic", coordinate: item.placemark.coordinate)
                    .tint(.red)
            }
        }
        .mapStyle(.standard)
        .onChange(of: searchResults) { _, newResults in
            guard !newResults.isEmpty else { return }
            withAnimation(.easeInOut(duration: 0.6)) {
                position = .automatic
            }
        }
        .overlay(alignment: .bottomTrailing) {
            Image(systemName: "location.fill.viewfinder")
                .padding(8)
                .background(.ultraThinMaterial)
                .clipShape(Circle())
                .padding(12)
        }
    }
}

#Preview {
    CareTabView()
        .environment(PetStore.preview)
}
