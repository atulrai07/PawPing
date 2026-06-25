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
        ZStack {
            LinearGradient(colors: [.bgWarmTop, .bgWarmBottom], startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()
            
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
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(pet.name)
                                    .font(.headline)
                                    .foregroundStyle(Color.textPrimary)
                                Text(pet.breed)
                                    .font(.subheadline)
                                    .foregroundStyle(Color.textSecondary)
                            }
                            
                            Spacer()
                            
                            if pet.id == petStore.activePetId {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(Color("baseColor"))
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.cardIvory)
                                .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 3)
                        )
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
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: 8, leading: 20, bottom: 8, trailing: 20))
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
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
