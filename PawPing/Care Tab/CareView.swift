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
    var activityStore: ActivityStore

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
//            .customNavigationScroll(
//                title: "Care",
//                profileImage: activityStore.dogProfile.dogImage
//            )
//            .sheet(item: $selectedLocation) { location in
//                VetClinicDetails(item: location)
//            }
        }
    }

    @Namespace private var animationNamespace

    private var customSegmentedControl: some View {
        HStack(spacing: 0) {
            ForEach(CareType.allCases, id: \.self) { type in
                Button {
                    selectedCareType = type
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
                            }
                        }
                }
            }
        }
        .padding(4)
        .background(Color.pawPrimary.opacity(0.15))
        .clipShape(Capsule())
        .padding(.horizontal, 40)
    }

    private var mapSection: some View {
        Map(position: $position) {
            UserAnnotation()

            Annotation(
                "Home",
                coordinate: CLLocationCoordinate2D(
                    latitude: activityStore.dogProfile.homeLatitude,
                    longitude: activityStore.dogProfile.homeLongitude
                )
            ) {
                Circle()
                    .fill(Color.white)
                    .frame(width: 30, height: 30)
            }

            ForEach(filteredLocations) { item in
                Marker(item.name, coordinate: item.coordinate)
            }
        }
        .frame(height: 180)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .padding(.horizontal)
    }

    private var searchBarSection: some View {
        TextField("Search", text: $searchText)
            .padding()
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
            }
        }
        .padding(.horizontal)
    }
}

#Preview {
    CareView(store: CareStore(), activityStore: ActivityStore())
}
