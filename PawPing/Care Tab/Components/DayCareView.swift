import SwiftUI
import MapKit

struct DayCareView: View {
    @State private var selectedCareType: CareType = .dayCare
    @State private var searchText: String = ""
    @State private var isSearching: Bool = false
    
    @State private var position: MapCameraPosition = .automatic
    
    var store: CareStore

    // ✅ Use CareLocation instead of missing models
    var filteredDayCares: [CareLocation] {
        if searchText.isEmpty {
            return store.dayCares
        } else {
            return store.dayCares.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
    }

    var filteredVets: [CareLocation] {
        if searchText.isEmpty {
            return store.vets
        } else {
            return store.vets.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    
                    switch selectedCareType {
                        
                    case .vet:
                        VStack(spacing: 20) {
                            
                            Map(position: $position) {
                                UserAnnotation()
                                
                                ForEach(filteredVets) { item in
                                    Marker(item.name, coordinate: item.coordinate)
                                        .tint(Color("baseColor"))
                                }
                            }
                            .frame(height: 200)
                            .clipShape(RoundedRectangle(cornerRadius: 24))
                            .padding(.horizontal)
                            
                            LazyVStack(spacing: 16) {
                                ForEach(filteredVets) { item in
                                    SimpleCareCardView(item: item)
                                }
                            }
                            .padding(.horizontal)
                        }
                        
                    case .dayCare:
                        VStack(spacing: 20) {
                            
                            Map(position: $position) {
                                UserAnnotation()
                                
                                ForEach(filteredDayCares) { item in
                                    Marker(item.name, coordinate: item.coordinate)
                                        .tint(Color("baseColor"))
                                }
                            }
                            .frame(height: 200)
                            .clipShape(RoundedRectangle(cornerRadius: 24))
                            .padding(.horizontal)
                            
                            LazyVStack(spacing: 16) {
                                ForEach(filteredDayCares) { item in
                                    SimpleCareCardView(item: item)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                .padding(.bottom, 80)
            }
            .background(Color("baseBackground"))
            .searchable(text: $searchText, isPresented: $isSearching)
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    DayCareView(store: CareStore())
}
