//
//  CareView.swift
//  PawPing
//
//  Created by Atul on 03/02/26.
//
//

import SwiftUI
import MapKit

struct CareView: View {
    // MARK: - Properties

    @State private var selectedCareType: CareType = .vet
    @State private var searchText: String = ""

    @State private var position: MapCameraPosition = .userLocation(fallback: .automatic)
    @State private var selectedLocation: PlaceModel?

    @Environment(CareStore.self) var store
    @Environment(PetStore.self) var petStore

    var filteredLocations: [PlaceModel] {
        let sourceList = selectedCareType == .vet ? store.vets : store.dayCares
        if searchText.isEmpty {
            return sourceList.sorted { $0.distance < $1.distance }
        } else {
            return sourceList
                .filter { $0.name.localizedCaseInsensitiveContains(searchText) }
                .sorted { $0.distance < $1.distance }
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Picker("Care Type", selection: $selectedCareType) {
                    ForEach(CareType.allCases, id: \.self) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .padding(.top, 10)
                
                mapSection
                searchBarSection
                cardsList
            }
            .padding(.top, 10)
            .padding(.bottom, 80)
            .customNavigationScroll(
                title: "Find",
                petStore: petStore,
                refreshAction: {
                    await petStore.fetchPets()
                    store.requestLocationAndFetch()
                }
            )
            .sheet(item: $selectedLocation) { location in
                VetClinicDetails(item: location)
            }
        }
        .onAppear {
            if store.vets.isEmpty && store.dayCares.isEmpty {
                store.requestLocationAndFetch()
            }
        }
        .onChange(of: store.vets) { _, _ in
            withAnimation {
                position = .automatic
            }
        }
        .onChange(of: store.dayCares) { _, _ in
            withAnimation {
                position = .automatic
            }
        }
    }

    // MARK: - Subviews


    private var mapSection: some View {
        Map(position: $position) {
            UserAnnotation()

            Annotation("Home", coordinate: CLLocationCoordinate2D(latitude: petStore.activePet?.homeLatitude ?? 28.4210, longitude: petStore.activePet?.homeLongitude ?? 77.5340)) {
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
                Annotation(item.name, coordinate: item.coordinate) {
                    VStack(spacing: 0) {
                        Image(systemName: item.category == .vet ? "cross.case.fill" : "pawprint.fill")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(.white)
                            .padding(8)
                            .background(Color("baseColor"))
                            .clipShape(Circle())
                            .shadow(radius: 3)
                        
                        Image(systemName: "triangle.fill")
                            .resizable()
                            .frame(width: 8, height: 4)
                            .rotationEffect(.degrees(180))
                            .foregroundStyle(Color("baseColor"))
                            .offset(y: -3)
                    }
                }
            }
        }
        .frame(height: 180)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .overlay(alignment: .bottomTrailing) {
            Button {
                if let userCoord = store.lastLocation?.coordinate {
                    withAnimation {
                        position = .region(MKCoordinateRegion(
                            center: userCoord,
                            latitudinalMeters: 10000,
                            longitudinalMeters: 10000
                        ))
                    }
                } else {
                    // Fallback to home if location not yet available
                    withAnimation {
                        position = .region(MKCoordinateRegion(
                            center: CLLocationCoordinate2D(
                                latitude: petStore.activePet?.homeLatitude ?? 28.4210,
                                longitude: petStore.activePet?.homeLongitude ?? 77.5340
                            ),
                            latitudinalMeters: 10000,
                            longitudinalMeters: 10000
                        ))
                    }
                }
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
            if store.isLoading {
                ProgressView("Searching nearby places...")
                    .padding(.top, 40)
            } else if store.isLocationDenied {
                Text("Location access is denied. Please enable it in Settings to see nearby places.")
                    .font(.system(size: 14))
                    .foregroundStyle(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.top, 40)
            } else if filteredLocations.isEmpty {
                Text("No places found nearby.")
                    .font(.system(size: 14))
                    .foregroundStyle(.gray)
                    .padding(.top, 40)
            } else {
                ForEach(filteredLocations) { item in
                    Button {
                        selectedLocation = item
                    } label: {
                        SimpleCareCardView(item: item)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(.horizontal)
    }
}

struct CareViewPreviewWrapper: View {
    @State private var store = CareStore()
    @State private var petStore = PetStore()
    @State private var authStore = AuthStore()
    @State private var appState = AppState()
    
    var body: some View {
        CareView()
            .environment(store)
            .environment(petStore)
            .environment(authStore)
            .environment(appState)
    }
}

#Preview {
    CareViewPreviewWrapper()
}
