//
//  AddPetView.swift
//  PawPing
//

import SwiftUI
import PhotosUI

struct AddPetView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(AuthStore.self) var authStore
    @Environment(AppState.self) var appState
    var onSave: () -> Void
    
    @State private var name: String = ""
    @State private var breed: String = ""
    @State private var gender: PetGender = .male
    @State private var weight: Double = 10.0
    @State private var birthday: Date = Date()
    @State private var isNeutered: Bool = false
    @State private var selectedImageName: String = "dog1"
    @State private var showingBreedPicker = false
    
    @State private var pickedImage: UIImage? = nil
    @State private var selectedImageData: Data? = nil
    @State private var showingImageSourceOptions = false
    @State private var showingImagePicker = false
    @State private var imageSourceType: UIImagePickerController.SourceType = .photoLibrary
    
    @State private var navigateToBreedTraits = false
    
    var body: some View {
        NavigationStack {
            Form {
                // MARK: - Avatar Section
                Section {
                    HStack {
                        Spacer()
                        Button {
                            showingImageSourceOptions = true
                        } label: {
                            VStack(spacing: 12) {
                                ZStack(alignment: .bottomTrailing) {
                                    if let uiImage = pickedImage {
                                        Image(uiImage: uiImage)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 100, height: 100)
                                            .clipShape(Circle())
                                            .overlay(Circle().stroke(Color(.systemGray5), lineWidth: 1))
                                    } else {
                                        Image(selectedImageName)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 100, height: 100)
                                            .clipShape(Circle())
                                            .overlay(Circle().stroke(Color(.systemGray5), lineWidth: 1))
                                    }
                                    
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
                        }
                        .buttonStyle(.plain)
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
                
                // MARK: - Physical Details Section
                Section(header: Text("Physical Details")) {
                    HStack {
                        Text("Weight (kg)")
                        Spacer()
                        TextField("10", value: $weight, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    DatePicker("Birthday", selection: $birthday, displayedComponents: .date)
                    
                    Toggle("Neutered / Spayed", isOn: $isNeutered)
                        .tint(Color("baseColor"))
                }
            }
            .tint(Color("baseColor"))
            .onChange(of: pickedImage) { _, newImage in
                if let newImage, let compressedData = newImage.jpegData(compressionQuality: 0.7) {
                    selectedImageData = compressedData
                }
            }
            .confirmationDialog("Select Image Source", isPresented: $showingImageSourceOptions) {
                Button("Take Photo") {
                    imageSourceType = .camera
                    showingImagePicker = true
                }
                Button("Choose from Photo Library") {
                    imageSourceType = .photoLibrary
                    showingImagePicker = true
                }
                Button("Cancel", role: .cancel) {}
            }
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(selectedImage: $pickedImage, sourceType: imageSourceType)
            }
            .navigationTitle("Create Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(appState.hasPets ? "Cancel" : "Log Out") {
                        if !appState.hasPets {
                            Task {
                                await authStore.logout()
                            }
                        } else {
                            dismiss()
                        }
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
                BreedTraitsView(
                    petName: name,
                    breed: breed.isEmpty ? "Mixed" : breed,
                    petData: (name: name, gender: gender, weight: weight, birthday: birthday, isNeutered: isNeutered, image: selectedImageName, imageData: selectedImageData)
                ) {
                    onSave()
                }
            }
            .sheet(isPresented: $showingBreedPicker) {
                BreedPickerView(selectedBreed: $breed)
            }
        }
        .tint(Color("baseColor"))
    }
}
