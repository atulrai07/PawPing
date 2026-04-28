import SwiftUI
import MapKit

struct DaycareView: View {
    @State private var viewModel = NearbyFacilityViewModel(type: .daycare)
    @State private var selectedFacility: MKMapItem?
    
    var body: some View {
        Group {
            if viewModel.isSearching {
                loadingView(label: "Finding nearby daycares…")
            } else if let error = viewModel.errorMessage, viewModel.searchResults.isEmpty {
                emptyStateView(icon: "pawprint.fill", message: error)
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
        .navigationTitle("Pet Daycares")
        .sheet(item: $selectedFacility) { item in
            FacilityDetailSheet(item: item, accentColor: .orange)
                .presentationDragIndicator(.visible)
        }
        .onAppear {
            viewModel.loadNearbyFacilities()
        }
    }
}

#Preview {
    NavigationStack {
        DaycareView()
    }
}
