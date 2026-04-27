//
//  CreateProfileView.swift
//  PawPing
//

import SwiftUI

struct CreateProfileView: View {
    @Environment(AppState.self) var appState
    @Environment(PetStore.self) var petStore
    
    @State private var name = ""
    @State private var selectedGender: PetGender = .male
    @State private var breed = "Labrador"
    @State private var weight = "36kg"
    @State private var birthday = Date()
    @State private var isNeutered = true
    
    let breeds = ["Labrador", "Golden Retriever", "Poodle", "Bulldog", "Beagle"]
    let weights = ["10kg", "20kg", "36kg", "40kg"]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                Text("Create Profile")
                    .font(.system(size: 20, weight: .semibold))
                    .padding(.top, 16)
                
                // Profile Image
                VStack(spacing: 8) {
                    Image(Pet.defaultImageName)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.white, lineWidth: 4))
                        .shadow(color: .black.opacity(0.1), radius: 4)
                    
                    Text("Upload Profile")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(Color("baseColor"))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color("baseColor").opacity(0.1))
                        .clipShape(Capsule())
                }
                .padding(.top, 10)
                
                // Form Fields
                VStack(spacing: 0) {
                    // Name
                    formRow(title: "Name") {
                        TextField("Enter name", text: $name)
                            .multilineTextAlignment(.trailing)
                            .font(.system(size: 16, weight: .medium))
                    }
                    
                    Divider().padding(.horizontal)
                    
                    // Gender
                    formRow(title: "Gender") {
                        Picker("Gender", selection: $selectedGender) {
                            ForEach(PetGender.allCases, id: \.self) { gender in
                                Text(gender.rawValue).tag(gender)
                            }
                        }
                        .tint(.primary)
                    }
                    
                    Divider().padding(.horizontal)
                    
                    // Breed
                    formRow(title: "Breed") {
                        Picker("Breed", selection: $breed) {
                            ForEach(breeds, id: \.self) { b in
                                Text(b).tag(b)
                            }
                        }
                        .tint(.primary)
                    }
                    
                    Divider().padding(.horizontal)
                    
                    // Weight
                    formRow(title: "Weight") {
                        Picker("Weight", selection: $weight) {
                            ForEach(weights, id: \.self) { w in
                                Text(w).tag(w)
                            }
                        }
                        .tint(.primary)
                    }
                    
                    Divider().padding(.horizontal)
                    
                    // Birthday
                    formRow(title: "Birthday") {
                        DatePicker("", selection: $birthday, displayedComponents: .date)
                            .labelsHidden()
                            .colorMultiply(Color("baseColor"))
                    }
                    
                    Divider().padding(.horizontal)
                    
                    // Neutered
                    formRow(title: "Neutered") {
                        Picker("Neutered", selection: $isNeutered) {
                            Text("Yes").tag(true)
                            Text("No").tag(false)
                        }
                        .tint(.primary)
                    }
                }
                .background(Color("cardBackground"))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: .black.opacity(0.05), radius: 10, y: 5)
                .padding(.horizontal, 24)
                
                Spacer(minLength: 40)
                
                // Action Button
                Button {
                    saveProfile()
                } label: {
                    Text("Next")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color("baseColor"))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 30)
            }
        }
        .background(Color("baseBackground"))
    }
    
    private func formRow<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 16, weight: .regular))
                .foregroundStyle(.primary)
            
            Spacer()
            
            content()
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 20)
    }
    
    private func saveProfile() {
        let weightVal = Double(weight.replacingOccurrences(of: "kg", with: "")) ?? 0
        
        let newPet = Pet(
            id: UUID(),
            name: name.isEmpty ? "Buddy" : name,
            breed: breed,
            gender: selectedGender,
            age: "1", // Derived from birthday in full app
            weightKg: weightVal,
            imageName: Pet.defaultImageName,
            homeLatitude: 28.4210, // Mock location
            homeLongitude: 77.5340,
            birthday: birthday,
            isNeutered: isNeutered
        )
        
        Task {
            await petStore.addPet(newPet)
            appState.hasPets = true
        }
    }
}

#Preview {
    CreateProfileView()
        .environment(AppState())
        .environment(PetStore())
}
