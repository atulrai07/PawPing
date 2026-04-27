//
//  EditPetView.swift
//  PawPing
//

import SwiftUI
import PhotosUI
import Supabase

struct EditPetView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(PetStore.self) var petStore
    
    @State private var name: String = ""
    @State private var breed: String = ""
    @State private var gender: PetGender = .male
    @State private var weight: String = ""
    @State private var birthday: Date = Date()
    @State private var isNeutered: Bool = false
    
    @State private var selectedPhotoItem: PhotosPickerItem? = nil
    @State private var uiImage: UIImage? = nil
    
    @State private var isLoading = false
    @State private var errorMessage: String? = nil
    @State private var showingError = false

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack {
                        Spacer()
                        VStack(spacing: 12) {
                            PhotosPicker(selection: $selectedPhotoItem, matching: .images, photoLibrary: .shared()) {
                                ZStack(alignment: .bottomTrailing) {
                                    if let uiImage {
                                        Image(uiImage: uiImage)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 100, height: 100)
                                            .clipShape(Circle())
                                    } else if let pet = petStore.activePet {
                                        if let urlString = pet.profileImageUrl, let url = URL(string: urlString) {
                                            AsyncImage(url: url) { phase in
                                                switch phase {
                                                case .empty:
                                                    Circle().fill(Color("baseColor").opacity(0.2))
                                                        .frame(width: 100, height: 100)
                                                case .success(let image):
                                                    image.resizable().scaledToFill()
                                                        .frame(width: 100, height: 100)
                                                        .clipShape(Circle())
                                                case .failure:
                                                    Image(Pet.defaultImageName).resizable().scaledToFill()
                                                        .frame(width: 100, height: 100)
                                                        .clipShape(Circle())
                                                @unknown default:
                                                    EmptyView()
                                                }
                                            }
                                        } else {
                                            Image(pet.imageName)
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 100, height: 100)
                                                .clipShape(Circle())
                                        }
                                    } else {
                                        Image(Pet.defaultImageName)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 100, height: 100)
                                            .clipShape(Circle())
                                    }
                                    
                                    Circle()
                                        .fill(Color("baseColor"))
                                        .frame(width: 30, height: 30)
                                        .overlay(
                                            Image(systemName: "camera.fill")
                                                .font(.system(size: 14))
                                                .foregroundStyle(.white)
                                        )
                                        .overlay(
                                            Circle().stroke(Color(UIColor.systemGroupedBackground), lineWidth: 3)
                                        )
                                        .offset(x: 4, y: 4)
                                }
                            }
                            .onChange(of: selectedPhotoItem) { _, newItem in
                                Task {
                                    if let data = try? await newItem?.loadTransferable(type: Data.self), let image = UIImage(data: data) {
                                        uiImage = image
                                    }
                                }
                            }
                            
                            Text("Change Photo")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                    }
                    .padding(.vertical, 8)
                    .listRowBackground(Color.clear)
                }
                
                Section("Pet Details") {
                    TextField("Name", text: $name)
                    TextField("Breed", text: $breed)
                    
                    Picker("Gender", selection: $gender) {
                        ForEach(PetGender.allCases, id: \.self) { g in
                            Text(g.rawValue).tag(g)
                        }
                    }
                    
                    HStack {
                        Text("Weight")
                        Spacer()
                        TextField("0.0", text: $weight)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 60)
                        Text("kg")
                    }
                }
                
                Section("Additional Info") {
                    DatePicker("Birthday", selection: $birthday, displayedComponents: .date)
                    Toggle("Neutered/Spayed", isOn: $isNeutered)
                }
            }
            .navigationTitle("Edit Pet")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                        .disabled(isLoading)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        Task { await saveChanges() }
                    }
                    .font(.headline)
                    .disabled(isLoading || name.isEmpty || breed.isEmpty)
                }
            }
            .overlay {
                if isLoading {
                    ZStack {
                        Color.black.opacity(0.3).ignoresSafeArea()
                        ProgressView()
                            .padding(24)
                            .background(RoundedRectangle(cornerRadius: 12).fill(Color(UIColor.systemBackground)))
                    }
                }
            }
            .alert("Error", isPresented: $showingError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage ?? "An unknown error occurred.")
            }
            .onAppear {
                loadPetData()
            }
        }
    }
    
    // MARK: - Logic
    
    private func loadPetData() {
        guard let pet = petStore.activePet else { return }
        name = pet.name
        breed = pet.breed
        gender = pet.gender
        weight = String(pet.weightKg)
        birthday = pet.birthday ?? Date()
        isNeutered = pet.isNeutered ?? false
    }
    
    private func saveChanges() async {
        guard var pet = petStore.activePet else { return }
        isLoading = true
        
        do {
            // 1. Upload new photo if selected
            if let uiImage, let imageData = uiImage.jpegData(compressionQuality: 0.7) {
                let imageUrl = try await petStore.uploadPetAvatar(petId: pet.id, imageData: imageData)
                pet.profileImageUrl = imageUrl
            }
            
            // 2. Update pet fields
            pet.name = name
            pet.breed = breed
            pet.gender = gender
            pet.weightKg = Double(weight) ?? pet.weightKg
            pet.birthday = birthday
            pet.isNeutered = isNeutered
            
            // Age update (basic logic)
            let calendar = Calendar.current
            let ageComponents = calendar.dateComponents([.year], from: birthday, to: Date())
            pet.age = "\(ageComponents.year ?? 0)"
            
            // 3. Save to Supabase
            await petStore.updatePet(pet)
            
            isLoading = false
            dismiss()
            
        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
            showingError = true
        }
    }
}

#Preview {
    EditPetView()
        .environment(PetStore())
}
