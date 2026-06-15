//
//  SavedVetsView.swift
//  PawPing
//
//  Created by Atul on 25/03/26.
//

import SwiftUI

struct SavedVetsView: View {
    @Environment(PetStore.self) var petStore
    
    var body: some View {
        List {
            if petStore.savedVets.isEmpty {
                ContentUnavailableView("No Saved Vets", systemImage: "cross.case", description: Text("You haven't saved any veterinary clinics yet."))
            } else {
                ForEach(petStore.savedVets) { vet in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(vet.name)
                            .font(.headline)
                        Text(vet.address)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        
                        let cleanedPhone = vet.phone.filter { "+0123456789".contains($0) }
                        
                        if !cleanedPhone.isEmpty {
                            HStack {
                                Button {
                                    if let url = URL(string: "tel://\(cleanedPhone)") {
                                        UIApplication.shared.open(url)
                                    }
                                } label: {
                                    Label("Call", systemImage: "phone.fill")
                                        .font(.caption)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(Color("baseColor").opacity(0.1))
                                        .clipShape(Capsule())
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .padding(.vertical, 4)
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            Task {
                                await petStore.deleteSavedVet(id: vet.id)
                            }
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
            }
        }
        .navigationTitle("Saved Vets")
        .task {
            await petStore.fetchSavedVets()
        }
    }
}
