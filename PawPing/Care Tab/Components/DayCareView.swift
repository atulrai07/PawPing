//
//  DayCareView.swift
//  PawPing
//
//  Created by Atul on 04/02/26.
//

import SwiftUI
import MapKit

struct DayCareView: View {
    @State private var selectedCareType: CareType = .dayCare
    @State private var searchText: String = ""
    @State private var isSearching: Bool = false
    
    // Map Position
    @State private var position: MapCameraPosition = .userLocation(fallback: .automatic)
    
    // Data Sources
    let dayCareData = DayCare.sampleDayCare
    let vetData = Vet.sampleVets
    
    // Filter Logic for DayCare
    var filteredDayCares: [DayCare] {
        if searchText.isEmpty {
            return dayCareData
        } else {
            return dayCareData.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    // Filter Logic for Vets
    var filteredVets: [Vet] {
        if searchText.isEmpty {
            return vetData
        } else {
            return vetData.filter { $0.vetName.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    var body: some View {
        NavigationStack {
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
                                    Marker(vet.vetName, coordinate: vet.coordinate)
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
                            }
                            .padding(.horizontal)
                        }
                        
                    case .dayCare:
                        // Day Care Content (Map + List)
                        VStack(spacing: 20) {
                            // Map View
                            Map(position: $position) {
                                UserAnnotation()
                                
                                ForEach(filteredDayCares) { dayCare in
                                    Marker(dayCare.name, coordinate: dayCare.coordinate)
                                        .tint(Color("baseRed"))
                                }
                            }
                            .frame(height: 200)
                            .clipShape(RoundedRectangle(cornerRadius: 24))
                            .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 5)
                            .padding(.horizontal)
                            
                            // Day Care List
                            LazyVStack(spacing: 16) {
                                ForEach(filteredDayCares) { item in
                                    // Inline conversion of DayCare to Vet
                                    VetCardView(vet: Vet(
                                        id: item.id,
                                        vetName: item.name,
                                        rating: item.rating,
                                        distance: item.distance,
                                        image: item.imageName,
                                        latitude: item.latitude,
                                        longitude: item.longitude
                                    ))
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                .padding(.bottom, 80)
            }
            .background(Color("baseBackground"))
            
            // MARK: - Native Search Functionality
            .searchable(text: $searchText, isPresented: $isSearching)
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    DayCareView()
}
