//
//  CareView.swift
//  PawPing
//
//  Created by Atul on 03/02/26.
//
//test commit1

import SwiftUI
import MapKit

struct CareView: View {
    // MARK: - Properties
    @State private var selectedCareType: CareType = .vet
    @State private var searchText: String = ""
    @State private var isSearching: Bool = false
    
    // Map Position
    @State private var position: MapCameraPosition = .userLocation(fallback: .automatic)
    
    // Data
    let vets = Vet.sampleVets
    
    // Filter Logic
    var filteredVets: [Vet] {
        if searchText.isEmpty {
            return vets
        } else {
            return vets.filter { $0.vetName.localizedCaseInsensitiveContains(searchText) }
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
                        // Day Care Content Placeholder
                        VStack(spacing: 20) {
                            DayCareView()
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .padding(.bottom, 80)
                .padding(.top, 10)
            }
            .background(Color("baseBackground"))
            
            // MARK: - Native Search Functionality
            .searchable(text: $searchText, isPresented: $isSearching)
            .toolbar {
                // 1. Search Button
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        isSearching = true // Triggers the hidden search bar to appear
                    } label: {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(.primary)
                    }
                }
                
                // 2. Segmented Picker
                ToolbarItem(placement: .principal) {
                    Picker("Care Type", selection: $selectedCareType) {
                        ForEach(CareType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 200)
                }
                
                // 3. Profile Image
                ToolbarItem(placement: .topBarTrailing) {
                    Circle()
                        .fill(.gray.opacity(0.2))
                        .frame(width: 36, height: 36)
                        .overlay(
                            Image("profilePhoto")
                                .resizable()
                                .scaledToFill()
                                .clipShape(Circle())
                        )
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    CareView()
}
