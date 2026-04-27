//
//  AddPetView.swift
//  PawPing
//

import SwiftUI

struct AddPetView: View {
    @Environment(\.dismiss) var dismiss
    var onSave: (Pet) -> Void
    
    @State private var name: String = ""
    @State private var breed: String = ""
    @State private var gender: PetGender = .male
    @State private var weight: Double = 10.0
    @State private var birthday: Date = Date()
    @State private var isNeutered: Bool = false
    @State private var selectedImageName: String = "dog1"
    @State private var showingBreedPicker = false
    
    @State private var navigateToBreedTraits = false
    
    let breeds = ["Labrador", "Golden Retriever", "German Shepherd", "Poodle", "Beagle", "Bulldog", "Mixed", "Other"]
    
    var body: some View {
        NavigationStack {
            Form {
                // MARK: - Avatar Section
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
                
                // MARK: - Details Section
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
                .sheet(isPresented: $showingBreedPicker) {
                    BreedPickerView(selectedBreed: $breed)
                }
                
                Section(header: Text("Physical Details")) {
                    HStack {
                        Text("Weight (kg)")
                        Spacer()
                        Stepper("\(Int(weight)) kg", value: $weight, in: 1...100)
                    }
                    
                    DatePicker("Birthday", selection: $birthday, displayedComponents: .date)
                    
                    Toggle("Neutered / Spayed", isOn: $isNeutered)
                        .tint(Color("baseColor"))
                }
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
                    .disabled(name.isEmpty)
                }
            }
            .navigationDestination(isPresented: $navigateToBreedTraits) {
                BreedTraitsView(petName: name, breed: breed.isEmpty ? "Mixed" : breed) {
                    savePet()
                }
            }
        }
    }
    
    private func savePet() {
        let newPet = Pet(
            id: UUID(),
            name: name,
            breed: breed.isEmpty ? "Mixed" : breed,
            gender: gender,
            age: calculateAge(from: birthday),
            weightKg: weight,
            imageName: selectedImageName,
            homeLatitude: 28.4210, // Defaults for now
            homeLongitude: 77.5340,
            birthday: birthday,
            isNeutered: isNeutered
        )
        
        Task {
            onSave(newPet)
        }
        dismiss()
    }
    
    private func calculateAge(from birthday: Date) -> String {
        let calendar = Calendar.current
        let ageComponents = calendar.dateComponents([.year], from: birthday, to: Date())
        return "\(ageComponents.year ?? 0)"
    }
}

#Preview {
    AddPetView { _ in }
}
