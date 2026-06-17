//
//  MyPetsView.swift
//  PawPing
//
//  Created by Atul on 25/03/26.
//

import SwiftUI

struct MyPetsView: View {
    @Environment(PetStore.self) var petStore
    @State private var showingAddPet = false
    @State private var selectedPet: Pet? = nil
    @State private var petToDelete: Pet? = nil
    
    var body: some View {
        Group {
            if petStore.pets.isEmpty {
                ContentUnavailableView(
                    "No Pets Added",
                    systemImage: "pawprint.fill",
                    description: Text("You haven't added any pets yet. Tap + to add one.")
                )
            } else {
                List {
                    ForEach(petStore.pets) { pet in
                HStack(spacing: 16) {
                    if let urlString = pet.profileImageUrl, let url = URL(string: urlString) {
                        AsyncImage(url: url) { image in
                            image.resizable().scaledToFill()
                        } placeholder: {
                            Color.gray.opacity(0.2)
                        }
                        .frame(width: 50, height: 50)
                        .clipShape(Circle())
                    } else {
                        Image(pet.imageName)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 50, height: 50)
                            .clipShape(Circle())
                    }
                    
                    VStack(alignment: .leading) {
                        Text(pet.name)
                            .font(.headline)
                        Text(pet.breed)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                    
                    if pet.id == petStore.activePetId {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(Color("baseColor"))
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    petStore.switchPet(to: pet.id)
                    selectedPet = pet
                }
                .swipeActions(edge: .trailing) {
                    Button(role: .destructive) {
                        petToDelete = pet
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
                }
                }
            }
        }
        .alert("Do you really want to delete?", isPresented: Binding(
            get: { petToDelete != nil },
            set: { if !$0 { petToDelete = nil } }
        ), presenting: petToDelete) { pet in
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                Task {
                    await petStore.deletePet(id: pet.id)
                }
            }
        } message: { _ in
            Text("All the data for this pet will be lost")
        }
        .navigationTitle("My Pets")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showingAddPet = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddPet) {
            AddPetView {
                showingAddPet = false
            }
        }
        .sheet(item: $selectedPet) { pet in
            EditPetView()
        }
    }
}
