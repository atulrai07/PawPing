//
//  MyPetsView.swift
//  PawPing
//

import SwiftUI

struct MyPetsView: View {
    @Environment(PetStore.self) var petStore
    @State private var showingAddPet = false
    
    var body: some View {
        Group {
            if petStore.pets.isEmpty {
                emptyState
            } else {
                List {
                    ForEach(petStore.pets) { pet in
                        petRow(pet)
                            .listRowInsets(EdgeInsets())
                            .listRowBackground(Color("cardBackground"))
                            .contentShape(Rectangle())
                            .onTapGesture {
                                withAnimation {
                                    petStore.switchPet(to: pet.id)
                                }
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    Task {
                                        await petStore.deletePet(id: pet.id)
                                    }
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                    }
                }
                .listStyle(.insetGrouped)
            }
        }
        .background(Color("baseBackground"))
        .navigationTitle("My Pets")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showingAddPet = true
                } label: {
                    Label("Add", systemImage: "plus")
                        .font(.system(size: 16, weight: .semibold))
                }
            }
        }
        .fullScreenCover(isPresented: $showingAddPet) {
            AddPetView { newPet in
                let success = await petStore.addPet(newPet)
                if success {
                    petStore.switchPet(to: newPet.id)
                }
                return success
            }
        }
    }
    
    // MARK: - Subviews
    
    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "pawprint.circle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .foregroundStyle(Color("baseColor").opacity(0.5))
            
            Text("No pets yet")
                .font(.title2.bold())
            
            Text("Add your first pet to get started tracking their health and activities.")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            Button {
                showingAddPet = true
            } label: {
                Text("Add your first pet")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color("baseColor"))
                    .clipShape(Capsule())
            }
            .padding(.top, 16)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func petRow(_ pet: Pet) -> some View {
        HStack(spacing: 16) {
            // Avatar
            if let urlString = pet.profileImageUrl, let url = URL(string: urlString) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        Circle().fill(Color("baseColor").opacity(0.2))
                    case .success(let image):
                        image.resizable().scaledToFill()
                    case .failure:
                        Image(Pet.defaultImageName).resizable().scaledToFill()
                    @unknown default:
                        EmptyView()
                    }
                }
                .frame(width: 44, height: 44)
                .clipShape(Circle())
            } else {
                Image(pet.imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 44, height: 44)
                    .clipShape(Circle())
            }
            
            // Details
            VStack(alignment: .leading, spacing: 4) {
                Text(pet.name)
                    .font(.headline)
                
                Text("\(pet.breed) · \(pet.age) yrs")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            // Active Selection Indicator
            if pet.id == petStore.activePetId {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(Color("baseColor"))
                    .font(.system(size: 22))
            } else {
                Circle()
                    .stroke(Color.secondary.opacity(0.3), lineWidth: 1.5)
                    .frame(width: 22, height: 22)
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
    }
}

#Preview {
    NavigationStack {
        MyPetsView()
            .environment(PetStore())
    }
}
