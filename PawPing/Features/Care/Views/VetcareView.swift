import SwiftUI
import MapKit

struct VetcareView: View {
    @State private var viewModel = NearbyFacilityViewModel(type: .vetClinic)
    @State private var showingSearch = false
    @State private var selectedFacility: MKMapItem?
    
    var body: some View {
        Group {
            if viewModel.isSearching {
                loadingView(label: "Finding nearby clinics…")
            } else if let error = viewModel.errorMessage, viewModel.searchResults.isEmpty {
                emptyStateView(icon: "cross.case.fill", message: error)
            } else {
                List(viewModel.searchResults, id: \.id) { item in
                    FacilityRowView(item: item) {
                        selectedFacility = item.mapItem
                    }
                }
                .listStyle(.plain)
                .refreshable {
                    viewModel.loadNearbyFacilities()
                }
            }
        }
        .navigationTitle("Vet Clinics")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showingSearch = true
                } label: {
                    Image(systemName: "magnifyingglass")
                }
            }
        }
        .sheet(isPresented: $showingSearch) {
            VetSearchView(onSelect: { _ in })
        }
        .sheet(item: $selectedFacility) { item in
            FacilityDetailSheet(item: item, accentColor: .pawPrimary)
                .presentationDragIndicator(.visible)
        }
        .onAppear {
            viewModel.loadNearbyFacilities()
        }
    }
}

#Preview {
    NavigationStack {
        VetcareView()
    }
}
