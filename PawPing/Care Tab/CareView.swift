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

    @State private var selectedCareType: CareType = .all
    @State private var searchText: String = ""

    @State private var position: MapCameraPosition = .userLocation(fallback: .automatic)
    @State private var selectedLocation: PlaceModel?
    @State private var showPetSwitcher = false

    @Environment(CareStore.self) var store
    @Environment(PetStore.self) var petStore
    @Environment(AppState.self) var appState

    // Categories to display in horizontal list (excluding dayCare from UI, but supported if needed)
    let displayCategories: [CareType] = [.all, .vet, .grooming, .petStore, .outdoor]

    var filteredLocations: [PlaceModel] {
        let sourceList: [PlaceModel]
        switch selectedCareType {
        case .all: sourceList = store.allPlaces
        case .vet: sourceList = store.vets
        case .dayCare: sourceList = store.dayCares
        case .grooming: sourceList = store.groomers
        case .petStore: sourceList = store.petStores
        case .outdoor: sourceList = store.outdoors
        }
        
        if searchText.isEmpty {
            return sourceList
        } else {
            return sourceList
                .filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                searchBarSection
                    .padding(.horizontal, 24)
                    .padding(.bottom, 24)
                    .padding(.top, 16)
                
                categorySelectorSection
                    .padding(.bottom, 28)
                
                mapSection
                    .padding(.horizontal, 24)
                    .padding(.bottom, 28)
                
                cardsList
                    .padding(.horizontal, 24)
            }
            .padding(.bottom, 80)
            .background(Color.white.ignoresSafeArea())
            .customNavigationScroll(
                title: "Find",
                petStore: petStore,
                refreshAction: {
                    await petStore.fetchPets()
                    store.requestLocationAndFetch()
                },
                backgroundColor: .white
            )
            .sheet(item: $selectedLocation) { location in
                VetClinicDetails(item: location)
            }
            .refreshable {
                await petStore.fetchPets()
                store.requestLocationAndFetch()
            }
        }
        .onAppear {
            if store.vets.isEmpty && store.dayCares.isEmpty {
                store.requestLocationAndFetch()
            }
        }
        .onChange(of: selectedCareType) { _, _ in
            withAnimation {
                position = .automatic
            }
        }
    }

    // MARK: - Subviews

    // Removed headerSection because we are using customNavigationScroll

    private var searchBarSection: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
                .font(.system(size: 22))
            
            TextField("Search clinics, services, doctors...", text: $searchText)
                .font(.system(size: 18))
                .foregroundColor(.black)
        }
        .padding(.horizontal, 20)
        .frame(height: 60)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 30))
        .overlay(
            RoundedRectangle(cornerRadius: 30)
                .stroke(Color(hex: "E6E0F8") ?? .purple.opacity(0.3), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
    }

    private var categorySelectorSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(displayCategories, id: \.self) { category in
                    let isSelected = selectedCareType == category
                    
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedCareType = category
                        }
                    } label: {
                        VStack(spacing: 8) {
                            Image(systemName: category.iconName)
                                .font(.system(size: 24))
                                .foregroundColor(isSelected ? Color(hex: "6E54D7") ?? .purple : category.displayColor)
                            
                            Text(category.rawValue)
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(isSelected ? Color(hex: "6E54D7") ?? .purple : .init(white: 0.2))
                        }
                        .frame(width: 80, height: 90)
                        .background(isSelected ? (Color(hex: "F3F0FF") ?? .purple.opacity(0.1)) : Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                        .overlay(
                            RoundedRectangle(cornerRadius: 24)
                                .stroke(isSelected ? (Color(hex: "E6E0F8") ?? .purple.opacity(0.3)) : Color.gray.opacity(0.2), lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 24)
        }
    }

    private var mapSection: some View {
        Map(position: $position) {
            // User Location
            Annotation("Home", coordinate: CLLocationCoordinate2D(latitude: petStore.activePet?.homeLatitude ?? 28.4210, longitude: petStore.activePet?.homeLongitude ?? 77.5340)) {
                ZStack {
                    Circle()
                        .fill(Color(hex: "6E54D7")?.opacity(0.3) ?? .purple.opacity(0.3))
                        .frame(width: 40, height: 40)
                        .blur(radius: 4)
                    
                    Circle()
                        .fill(Color(hex: "6E54D7") ?? .purple)
                        .frame(width: 16, height: 16)
                        .overlay(Circle().stroke(Color.white, lineWidth: 2))
                }
            }

            // Places
            ForEach(filteredLocations) { item in
                Annotation(item.name, coordinate: item.coordinate) {
                    VStack(spacing: 0) {
                        Image(systemName: item.category.iconName)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(.white)
                            .padding(8)
                            .background(item.category.displayColor)
                            .clipShape(Circle())
                            .shadow(radius: 3)
                        
                        Image(systemName: "triangle.fill")
                            .resizable()
                            .frame(width: 8, height: 4)
                            .rotationEffect(.degrees(180))
                            .foregroundStyle(item.category.displayColor)
                            .offset(y: -3)
                    }
                }
            }
        }
        .frame(height: 200)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .shadow(color: .black.opacity(0.05), radius: 15, x: 0, y: 8)
    }

    private var cardsList: some View {
        VStack(spacing: 16) {
            HStack {
                Text(selectedCareType == .all ? "Nearby Pet Services" : "Top \(selectedCareType.rawValue) Near You")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.black)
                
                Spacer()
            }
            .padding(.bottom, 8)
            
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
                VStack(spacing: 12) {
                    Image(systemName: selectedCareType.iconName)
                        .font(.system(size: 40))
                        .foregroundColor(.gray.opacity(0.5))
                    Text("No \(selectedCareType.rawValue.lowercased()) found nearby.")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(.gray)
                }
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
