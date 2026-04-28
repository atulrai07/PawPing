//
//  AddPetView.swift
//  PawPing
//
//  Created by SidMoon on 28/04/26.
//  Description: This screen allows the user to create a new profile for their pet.
//  It captures basic details like name, breed, gender, and weight.
//

import SwiftUI

struct AddPetView: View {
    // MARK: - Properties (Navigation & Callbacks)
    
    @Environment(\.dismiss) var dismiss
    
    /// The closure to call when the user saves the pet profile
    var onSave: (Pet) async -> Bool
    
    // MARK: - State (Pet Details)
    
    @State private var name: String = ""
    @State private var breed: String = ""
    @State private var gender: PetGender = .male
    @State private var weight: String = ""
    @State private var birthday: Date = Date()
    @State private var isNeutered: Bool = false
    @State private var selectedImageName: String = "dog1"
    
    // MARK: - State (UI Control)
    
    @State private var showingBreedPicker = false
    @State private var navigateToBreedTraits = false
    @State private var isSaving = false
    @State private var errorMessage: String? = nil
    @State private var showError = false
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            Form {
                avatarSection
                basicInfoSection
                physicalDetailsSection
            }
            .navigationTitle("Create Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Next") {
                        navigateToBreedTraits = true
                    }
                    .bold()
                    .disabled(name.isEmpty || weight.isEmpty || Double(weight) == nil)
                }
            }
            .navigationDestination(isPresented: $navigateToBreedTraits) {
                breedTraitsFlow
            }
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage ?? "Could not save pet profile. Please try again.")
            }
            .sheet(isPresented: $showingBreedPicker) {
                BreedPickerView(selectedBreed: $breed)
            }
        }
    }
    
    // MARK: - Subviews (Sections)
    
    /// Section for uploading/selecting the pet's profile picture
    private var avatarSection: some View {
        Section {
            HStack {
                Spacer()
                VStack(spacing: 12) {
                    ZStack(alignment: .bottomTrailing) {
                        Image(selectedImageName)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color(.systemGray5), lineWidth: 1))
                        
                        Circle()
                            .fill(Color("baseColor"))
                            .frame(width: 32, height: 32)
                            .overlay(
                                Image(systemName: "camera.fill")
                                    .font(.system(size: 14))
                                    .foregroundStyle(.white)
                            )
                            .offset(x: 4, y: 4)
                    }
                    
                    Text("Upload Profile")
                        .font(.caption)
                        .foregroundStyle(Color("baseColor"))
                        .bold()
                }
                Spacer()
            }
            .padding(.vertical, 8)
            .listRowBackground(Color.clear)
        }
    }
    
    /// Section for name, gender, and breed selection
    private var basicInfoSection: some View {
        Section(header: Text("Basic Information")) {
            HStack {
                Text("Name")
                Spacer()
                TextField("Buddy", text: $name)
                    .multilineTextAlignment(.trailing)
            }
            
            Picker("Gender", selection: $gender) {
                ForEach(PetGender.allCases, id: \.self) { gender in
                    Text(gender.rawValue).tag(gender)
                }
            }
            .pickerStyle(.menu)
            
            Button {
                showingBreedPicker = true
            } label: {
                HStack {
                    Text("Breed")
                        .foregroundStyle(.primary)
                    Spacer()
                    Text(breed.isEmpty ? "Select Breed" : breed)
                        .foregroundStyle(breed.isEmpty ? .secondary : Color("baseColor"))
                    Image(systemName: "chevron.right")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
    
    /// Section for weight, birthday, and medical status
    private var physicalDetailsSection: some View {
        Section(header: Text("Physical Details")) {
            HStack {
                Text("Weight (kg)")
                Spacer()
                TextField("e.g. 12.5", text: $weight)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                    .onChange(of: weight) { oldValue, newValue in
                        validateWeight(newValue)
                    }
            }
            
            DatePicker("Birthday", selection: $birthday, displayedComponents: .date)
            
            Toggle("Neutered / Spayed", isOn: $isNeutered)
                .tint(Color("baseColor"))
        }
    }
    
    // MARK: - Navigation Views
    
    private var breedTraitsFlow: some View {
        BreedTraitsView(petName: name, breed: breed.isEmpty ? "Mixed" : breed) {
            savePet()
        }
        .overlay {
            if isSaving {
                ZStack {
                    Color.black.opacity(0.1).ignoresSafeArea()
                    ProgressView("Saving \(name)...")
                        .padding()
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
        }
    }
    
    // MARK: - Actions (Business Logic)
    
    /// Validates the weight input to ensure it's numeric and has max 1 decimal place
    private func validateWeight(_ newValue: String) {
        var filtered = newValue.filter { "0123456789.".contains($0) }
        
        // Ensure only one decimal point
        let components = filtered.components(separatedBy: ".")
        if components.count > 2 {
            filtered = components[0] + "." + components[1]
        }
        
        // Restrict to 1 decimal place
        if components.count == 2 && components[1].count > 1 {
            filtered = components[0] + "." + String(components[1].prefix(1))
        }
        
        if filtered != newValue {
            weight = filtered
        }
    }
    
    /// Packages the form data into a Pet object and sends it to the save callback
    private func savePet() {
        guard !isSaving else { return }
        
        let weightValue = Double(weight) ?? 0.0
        
        isSaving = true
        errorMessage = nil
        
        let newPet = Pet(
            id: UUID(),
            name: name,
            breed: breed.isEmpty ? "Mixed" : breed,
            gender: gender,
            age: calculateAge(from: birthday),
            weightKg: weightValue,
            imageName: selectedImageName,
            homeLatitude: 28.4210, // Default for now
            homeLongitude: 77.5340, // Default for now
            birthday: birthday,
            isNeutered: isNeutered
        )
        
        Task { @MainActor in
            let success = await onSave(newPet)
            isSaving = false
            
            if success {
                dismiss()
            } else {
                errorMessage = "Failed to save pet to the server. Please check your connection and try again."
                showError = true
            }
        }
    }
    
    /// Simple helper to calculate age in years from a birthday
    private func calculateAge(from birthday: Date) -> String {
        let calendar = Calendar.current
        let ageComponents = calendar.dateComponents([.year], from: birthday, to: Date())
        return "\(ageComponents.year ?? 0)"
    }
}

#Preview {
    AddPetView { _ in true }
}
