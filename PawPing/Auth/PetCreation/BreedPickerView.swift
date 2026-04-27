//
//  BreedPickerView.swift
//  PawPing
//

import SwiftUI

struct BreedPickerView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var selectedBreed: String
    
    @State private var searchText = ""
    
    // Get all breed names from the data service
    private var allBreeds: [String] {
        BreedDataService.shared.breedTraits.map { $0.breed }.sorted()
    }
    
    // Filter breeds based on search text
    private var filteredBreeds: [String] {
        if searchText.isEmpty {
            return allBreeds
        } else {
            return allBreeds.filter { $0.lowercased().contains(searchText.lowercased()) }
        }
    }
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(filteredBreeds, id: \.self) { breed in
                    Button {
                        selectedBreed = breed
                        dismiss()
                    } label: {
                        HStack {
                            Text(breed)
                                .foregroundStyle(.primary)
                            Spacer()
                            if breed == selectedBreed {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(Color("baseColor"))
                                    .bold()
                            }
                        }
                    }
                }
            }
            .navigationTitle("Select Breed")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search breeds")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    BreedPickerView(selectedBreed: .constant("Labrador"))
}
