//
//  EditPetView.swift
//  PawPing
//
//  Created by Atul on 25/03/26.
//

import SwiftUI
import PhotosUI

struct EditPetView: View {
    @Environment(PetStore.self) var petStore
    @Environment(\.dismiss) var dismiss
    
    @State private var name: String = ""
    @State private var breed: String = ""
    @State private var weight: Double = 0
    @State private var birthday: Date = Date()
    @State private var isNeutered: Bool = false
    
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var selectedImageData: Data? = nil
    @State private var isUploading = false
    
    var body: some View {
        let currentPet = petStore.activePet
        
        NavigationStack {
            Form {
                Section {
                    HStack {
                        Spacer()
                        PhotosPicker(selection: $selectedItem, matching: .images) {
                            ZStack(alignment: .bottomTrailing) {
                                if let data = selectedImageData, let uiImage = UIImage(data: data) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 100, height: 100)
                                        .clipShape(Circle())
                                } else if let pet = currentPet {
                                    if let urlString = pet.profileImageUrl, let url = URL(string: urlString) {
                                        AsyncImage(url: url) { image in
                                            image.resizable().scaledToFill()
                                        } placeholder: {
                                            Color.gray.opacity(0.2)
                                        }
                                        .frame(width: 100, height: 100)
                                        .clipShape(Circle())
                                    } else {
                                        Image(pet.imageName)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 100, height: 100)
                                            .clipShape(Circle())
                                    }
                                }
                                
                                Circle()
                                    .fill(Color("baseColor"))
                                    .frame(width: 32, height: 32)
                                    .overlay(
                                        Image(systemName: "camera.fill")
                                            .font(.system(size: 14))
                                            .foregroundStyle(.white)
                                    )
                            }
                        }
                        Spacer()
                    }
                }
                .onChange(of: selectedItem) { _, newItem in
                    Task {
                        if let data = try? await newItem?.loadTransferable(type: Data.self) {
                            selectedImageData = data
                        }
                    }
                }
                
                Section("Basic Info") {
                    TextField("Name", text: $name)
                    TextField("Breed", text: $breed)
                }
                
                Section("Details") {
                    HStack {
                        Text("Weight")
                        Spacer()
                        TextField("20", value: $weight, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 60)
                        Text("kg")
                            .foregroundStyle(.secondary)
                    }
                    DatePicker("Birthday", selection: $birthday, displayedComponents: .date)
                    Toggle("Neutered", isOn: $isNeutered)
                }
            }
            .navigationTitle("Edit Pet")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        saveChanges()
                    }
                    .disabled(isUploading)
                }
            }
            .onAppear {
                if let pet = petStore.activePet {
                    name = pet.name
                    breed = pet.breed
                    weight = pet.weightKg
                    birthday = pet.birthdayDate ?? Date()
                    isNeutered = pet.isNeutered ?? false
                }
            }
        }
    }
    
    private func saveChanges() {
        guard var pet = petStore.activePet else { return }
        isUploading = true
        
        Task {
            if let data = selectedImageData {
                if let url = await petStore.uploadImage(data: data) {
                    pet.profileImageUrl = url
                }
            }
            
            pet.name = name
            pet.breed = breed
            pet.weightKg = weight
            pet.birthday = Pet.birthdayString(from: birthday)
            pet.isNeutered = isNeutered
            
            await petStore.updatePet(pet)
            isUploading = false
            dismiss()
        }
    }
}
