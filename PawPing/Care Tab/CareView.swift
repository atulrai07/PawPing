//
//  CareView.swift
//  PawPing
//
//  Created by Atul on 03/02/26.
//
//  The Care tab — lets users browse nearby vet clinics or day cares
//  on a map, search by name, and tap into details.
//

import SwiftUI
import MapKit

struct CareView: View {
    // MARK: - Properties

    // @State = this view owns these values and SwiftUI watches them.
    @State private var selectedCareType: CareType = .vet
    @State private var searchText: String = ""
<<<<<<< HEAD
    @State private var isSearching: Bool = false
    
    // Map Position
    @State private var position: MapCameraPosition = .userLocation(fallback: .automatic)

    // Store
=======

    // .automatic tells MapKit to frame all annotations automatically
    @State private var position: MapCameraPosition = .automatic
    // When a user taps a card, we store the location here to trigger the detail sheet
    @State private var selectedLocation: CareLocation?

    // Passed in from ContentView — we don't own these, just read them
>>>>>>> develop-atul
    var store: CareStore
    var profile: DogProfile

<<<<<<< HEAD
    // Filter Logic
    var filteredVets: [CareLocation] {
=======
    // Switches between vets and dayCares based on the selected segment,
    // then filters by search text if the user typed something
    var filteredLocations: [CareLocation] {
        let sourceList = selectedCareType == .vet ? store.vets : store.dayCares
>>>>>>> develop-atul
        if searchText.isEmpty {
            return sourceList
        } else {
<<<<<<< HEAD
            return store.vets.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
=======
            return sourceList.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
>>>>>>> develop-atul
        }
    }

    var body: some View {
        NavigationStack {
<<<<<<< HEAD
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    
                    // MARK: - Content Switcher
                    switch selectedCareType {
                    case .vet:
                        // Vet Content (Map + List)
                        VStack(spacing: 20) {
                            // Map View
                            Map(position: $position) {
                                UserAnnotation()
                                
                                ForEach(filteredVets) { vet in
                                    Marker(vet.name, coordinate: vet.coordinate)
                                        .tint(Color("baseRed"))
                                }
                            }
                            .frame(height: 200)
                            .clipShape(RoundedRectangle(cornerRadius: 24))
                            .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 5)
                            .padding(.horizontal)
                            
                            // Vet List
                            LazyVStack(spacing: 16) {
                                ForEach(filteredVets) { vet in
                                    VetCardView(vet: vet)
                                }
=======
            VStack(spacing: 20) {
                customSegmentedControl
                mapSection
                searchBarSection
                cardsList
            } // VStack — main content
            .padding(.top, 10)
            .padding(.bottom, 80)
            .customNavigationScroll(title: "Care", profileImage: profile.dogImage)
            // .sheet presents VetClinicDetails as a half-sheet when a card is tapped.
            // `item:` binding means the sheet shows whenever selectedLocation != nil.
            .sheet(item: $selectedLocation) { location in
                VetClinicDetails(item: location)
            }
        } // NavigationStack
    }

    // @Namespace creates a shared animation ID space so the capsule
    // indicator can smoothly slide between "Vet Care" and "Day Care".
    @Namespace private var animationNamespace

    // MARK: - Subviews

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
                        .foregroundStyle(selectedCareType == type ? .white : Color("baseColor").opacity(0.8))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background {
                            if selectedCareType == type {
                                // matchedGeometryEffect makes this capsule animate
                                // smoothly from one tab to the other
                                Capsule()
                                    .fill(Color("baseColor"))
                                    .matchedGeometryEffect(id: "SegmentIndicator", in: animationNamespace)
>>>>>>> develop-atul
                            }
                        }
                }
            }
<<<<<<< HEAD
            .background(Color("baseBackground"))
            
            // MARK: - Native Search Functionality
            .searchable(text: $searchText, isPresented: $isSearching)
            .toolbar {
                // Segmented Picker
                ToolbarItem(placement: .principal) {
                    Picker("Care Type", selection: $selectedCareType) {
                        ForEach(CareType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 200)
                }
                
                // Profile Image
                ToolbarItem(placement: .topBarTrailing) {
=======
        } // HStack — segment buttons
        .padding(4)
        .background(Color("baseColor").opacity(0.15))
        .clipShape(Capsule())
        .padding(.horizontal, 40)
        .padding(.top, 10)
    }

    private var mapSection: some View {
        Map(position: $position) {
            // Blue dot for the user's real GPS location (if permission granted)
            UserAnnotation()

            // "Home" pin — pulls lat/lng from the dog's profile
            Annotation("Home", coordinate: CLLocationCoordinate2D(latitude: profile.homeLatitude, longitude: profile.homeLongitude)) {
                ZStack {
>>>>>>> develop-atul
                    Circle()
                        .fill(Color.white)
                        .frame(width: 30, height: 30)
                        .shadow(color: .black.opacity(0.15), radius: 3)
                    Image(systemName: "house.fill")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(Color("baseColor"))
                } // ZStack — home pin
            }

            // Drop a marker for each vet/daycare in the filtered list
            ForEach(filteredLocations) { item in
                Marker(item.name, coordinate: item.coordinate)
                    .tint(Color("baseColor"))
            }
        } // Map
        .frame(height: 180)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .overlay(alignment: .bottomTrailing) {
            // Recenter button — snaps the map back to the pet's home area
            Button {
                position = .region(MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: profile.homeLatitude, longitude: profile.homeLongitude), latitudinalMeters: 3000, longitudinalMeters: 3000))
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
        } // Map overlay
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
        } // HStack — search bar
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
                    selectedLocation = item
                } label: {
                    SimpleCareCardView(item: item)
                }
                .buttonStyle(.plain) // keeps card styling instead of default blue text
            }
        } // VStack — cards list
        .padding(.horizontal)
    }
} // CareView

#Preview {
<<<<<<< HEAD
    CareView(store: CareStore())
=======
    CareView(store: CareStore(), profile: DogProfile.sampleProfile)
>>>>>>> develop-atul
}
