//
//  SavedVetsView.swift
//  PawPing
//

import SwiftUI
import Supabase

struct SavedVetsView: View {
    @Environment(PetStore.self) var petStore
    @State private var isLoading = false
    @State private var showingAddVet = false
    @State private var newVetName = ""
    @State private var newVetAddress = ""
    @State private var newVetPhone = ""
    
    var body: some View {
        Group {
            if isLoading && petStore.savedVets.isEmpty {
                ProgressView("Loading...")
            } else if petStore.savedVets.isEmpty {
                emptyState
            } else {
                List {
                    ForEach(petStore.savedVets) { vet in
                        vetRow(vet)
                    }
                    .onDelete(perform: deleteVets)
                }
                .listStyle(.insetGrouped)
            }
        }
        .background(Color("baseBackground"))
        .navigationTitle("Saved Vets")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showingAddVet = true
                } label: {
                    Label("Add", systemImage: "plus")
                        .font(.system(size: 16, weight: .semibold))
                }
            }
        }
        .sheet(isPresented: $showingAddVet) {
            NavigationStack {
                Form {
                    Section("Vet Details") {
                        TextField("Clinic Name", text: $newVetName)
                        TextField("Address", text: $newVetAddress)
                        TextField("Phone Number", text: $newVetPhone)
                            .keyboardType(.phonePad)
                    }
                }
                .navigationTitle("Add Vet")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Cancel") { showingAddVet = false }
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Save") {
                            Task { await saveVet() }
                        }
                        .font(.headline)
                        .disabled(newVetName.isEmpty)
                    }
                }
            }
        }
        .task {
            await fetchVets()
        }
    }
    
    // MARK: - Subviews
    
    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "cross.case.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 60, height: 60)
                .foregroundStyle(Color("baseColor").opacity(0.5))
            
            Text("No saved vets")
                .font(.title2.bold())
            
            Text("Keep your vet clinic's contact info handy for quick access in emergencies.")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func vetRow(_ vet: SavedVet) -> some View {
        HStack(alignment: .top, spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text(vet.name)
                    .font(.headline)
                
                if let address = vet.address, !address.isEmpty {
                    HStack(alignment: .top, spacing: 4) {
                        Image(systemName: "mappin.and.ellipse")
                            .foregroundStyle(.secondary)
                        Text(address)
                            .foregroundStyle(.secondary)
                    }
                    .font(.subheadline)
                }
                
                if let phone = vet.phone, !phone.isEmpty {
                    HStack(spacing: 4) {
                        Image(systemName: "phone.fill")
                            .foregroundStyle(.secondary)
                        Text(phone)
                            .foregroundStyle(.secondary)
                    }
                    .font(.subheadline)
                }
            }
            
            Spacer()
            
            if let phone = vet.phone, !phone.isEmpty {
                Button {
                    callNumber(phone)
                } label: {
                    Image(systemName: "phone.circle.fill")
                        .resizable()
                        .frame(width: 36, height: 36)
                        .foregroundStyle(Color.green)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, 4)
    }
    
    // MARK: - Logic
    
    private func fetchVets() async {
        isLoading = true
        await petStore.fetchSavedVets()
        isLoading = false
    }
    
    private func saveVet() async {
        let newVet = SavedVet(
            id: UUID(),
            userId: UUID(), // PetStore will override this with the actual user ID
            name: newVetName,
            address: newVetAddress.isEmpty ? nil : newVetAddress,
            phone: newVetPhone.isEmpty ? nil : newVetPhone,
            createdAt: Date()
        )
        
        await petStore.addSavedVet(newVet)
        
        showingAddVet = false
        newVetName = ""
        newVetAddress = ""
        newVetPhone = ""
    }
    
    private func deleteVets(at offsets: IndexSet) {
        let idsToDelete = offsets.map { petStore.savedVets[$0].id }
        
        Task {
            for id in idsToDelete {
                await petStore.deleteSavedVet(id: id)
            }
        }
    }
    
    private func callNumber(_ number: String) {
        let numericString = number.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        if let url = URL(string: "tel://\(numericString)"), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
}

#Preview {
    NavigationStack {
        SavedVetsView()
            .environment(PetStore())
    }
}
