//
//  EditPetView.swift
//  PawPing
//

import SwiftUI
import PhotosUI
import Supabase

struct EditPetView: View {
    // MARK: - Properties (Dependencies)
    
    @Environment(\.dismiss) private var dismiss
    @Environment(PetStore.self) var petStore
    
    // MARK: - State (Form Data)
    
    @State private var name: String = ""
    @State private var breed: String = ""
    @State private var gender: PetGender = .male
    @State private var weight: String = ""
    @State private var birthday: Date = Date()
    @State private var isNeutered: Bool = false
    
    // Image Handling
    @State private var selectedPhotoItem: PhotosPickerItem? = nil
    @State private var uiImage: UIImage? = nil
    @State private var showPhotoOptions = false
    @State private var showCamera = false
    @State private var showGallery = false
    
    // MARK: - State (UI Control)
    
    @State private var showingBreedPicker = false
    @State private var isLoading = false
    @State private var errorMessage: String? = nil
    @State private var showingError = false

    var body: some View {
        NavigationStack {
            Form {
                avatarSection
                petDetailsSection
                additionalInfoSection
            }
            .navigationTitle("Edit Pet")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                toolbarItems
            }
            .overlay {
                loadingOverlay
            }
            // MARK: - Sheets & Dialogs
            .confirmationDialog("Change Photo", isPresented: $showPhotoOptions, titleVisibility: .visible) {
                Button("Camera") { showCamera = true }
                Button("Photo Library") { showGallery = true }
                Button("Cancel", role: .cancel) { }
            }
            .fullScreenCover(isPresented: $showCamera) {
                ImagePicker(selectedImage: $uiImage, sourceType: .camera)
                    .ignoresSafeArea()
            }
            .photosPicker(isPresented: $showGallery, selection: $selectedPhotoItem, matching: .images)
            .onChange(of: selectedPhotoItem) { _, newItem in
                handlePhotoSelection(newItem)
            }
            .alert("Error", isPresented: $showingError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage ?? "An unknown error occurred.")
            }
            .sheet(isPresented: $showingBreedPicker) {
                BreedPickerView(selectedBreed: $breed)
            }
            .onAppear {
                loadPetData()
            }
        }
    }
    
    // MARK: - Subviews (Sections)
    
    private var avatarSection: some View {
        Section {
            HStack {
                Spacer()
                VStack(spacing: 12) {
                    Button {
                        showPhotoOptions = true
                    } label: {
                        avatarImage
                    }
                    .buttonStyle(.plain)
                    
                    Text("Change Photo")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }
            .padding(.vertical, 8)
            .listRowBackground(Color.clear)
        }
    }
    
    private var avatarImage: some View {
        ZStack(alignment: .bottomTrailing) {
            if let uiImage {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.gray.opacity(0.2), lineWidth: 1))
            } else if let pet = petStore.activePet {
                petAvatar(for: pet)
            } else {
                Image(Pet.defaultImageName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
            }
            
            cameraBadge
        }
    }
    
    private func petAvatar(for pet: Pet) -> some View {
        Group {
            if let urlString = pet.profileImageUrl, let url = URL(string: urlString) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        Circle().fill(Color("baseColor").opacity(0.1))
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
        }
    }
    
    private var cameraBadge: some View {
        Circle()
            .fill(Color("baseColor"))
            .frame(width: 32, height: 32)
            .overlay(
                Image(systemName: "camera.fill")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.white)
            )
            .overlay(
                Circle().stroke(Color(UIColor.systemGroupedBackground), lineWidth: 3)
            )
            .offset(x: 4, y: 4)
    }
    
    private var petDetailsSection: some View {
        Section("Pet Details") {
            TextField("Name", text: $name)
            
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
            
            Picker("Gender", selection: $gender) {
                ForEach(PetGender.allCases, id: \.self) { g in
                    Text(g.rawValue).tag(g)
                }
            }
            
            HStack {
                Text("Weight (kg)")
                Spacer()
                TextField("e.g. 12.5", text: $weight)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                    .onChange(of: weight) { _, newValue in
                        validateWeight(newValue)
                    }
            }
        }
    }
    
    private var additionalInfoSection: some View {
        Section("Additional Info") {
            DatePicker("Birthday", selection: $birthday, displayedComponents: .date)
            Toggle("Neutered/Spayed", isOn: $isNeutered)
        }
    }
    
    private var toolbarItems: some ToolbarContent {
        Group {
            ToolbarItem(placement: .topBarLeading) {
                Button("Cancel") { dismiss() }
                    .disabled(isLoading)
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button("Save") {
                    Task { await saveChanges() }
                }
                .font(.headline)
                .disabled(isLoading || name.isEmpty || weight.isEmpty || Double(weight) == nil)
            }
        }
    }
    
    private var loadingOverlay: some View {
        Group {
            if isLoading {
                ZStack {
                    Color.black.opacity(0.3).ignoresSafeArea()
                    VStack(spacing: 16) {
                        ProgressView()
                            .scaleEffect(1.2)
                        Text("Saving...")
                            .font(.subheadline)
                            .bold()
                    }
                    .padding(32)
                    .background(RoundedRectangle(cornerRadius: 16).fill(Color(UIColor.systemBackground)))
                }
            }
        }
    }
    
    // MARK: - Logic (Form Handling)
    
    private func handlePhotoSelection(_ item: PhotosPickerItem?) {
        Task {
            if let data = try? await item?.loadTransferable(type: Data.self), 
               let image = UIImage(data: data) {
                uiImage = image
            }
        }
    }
    
    private func validateWeight(_ newValue: String) {
        var filtered = newValue.filter { "0123456789.".contains($0) }
        
        let components = filtered.components(separatedBy: ".")
        if components.count > 2 {
            filtered = components[0] + "." + components[1]
        }
        
        if components.count == 2 && components[1].count > 1 {
            filtered = components[0] + "." + String(components[1].prefix(1))
        }
        
        if filtered != newValue {
            weight = filtered
        }
    }
    
    private func loadPetData() {
        guard let pet = petStore.activePet else { return }
        name = pet.name
        breed = pet.breed
        gender = pet.gender
        weight = String(format: "%.1f", pet.weightKg)
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
            
            let calendar = Calendar.current
            let ageComponents = calendar.dateComponents([.year], from: birthday, to: Date())
            pet.age = "\(ageComponents.year ?? 0)"
            
            // 3. Save to Supabase
            try await petStore.updatePet(pet)
            
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
        .environment(PetStore.preview)
}
