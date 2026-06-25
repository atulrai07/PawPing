//
//  PetStore.swift
//  PawPing
//

import Foundation
import Observation
import Supabase
import UIKit

@MainActor
@Observable
class PetStore {
    private let client = SupabaseConfig.client
    
    var pets: [Pet] = []
    var activePetId: UUID?
    var currentUserProfile: UserModel? = nil
    var savedVets: [SavedVet] = []
    var lastError: String? = nil
    var showError: Bool = false
    
    func clear() {
        self.pets = []
        self.activePetId = nil
        self.currentUserProfile = nil
        self.savedVets = []
        self.lastError = nil
        self.showError = false
    }
    
    var activePet: Pet? {
        pets.first { $0.id == activePetId } ?? pets.first
    }
    
    init() {
        // Pets are fetched via the App's task system
    }
    
    @MainActor
    func fetchPets() async {
        do {
            let session = try await client.auth.session
            let userIdString = session.user.id.uuidString.lowercased()
            
            let fetchedPets: [Pet] = try await client
                .from("pets")
                .select()
                .eq("owner_id", value: userIdString) // Matches lowercase profiles.id
                .order("created_at")
                .execute()
                .value
            
            self.pets = fetchedPets
            
            // Set active pet if not set
            if activePetId == nil {
                activePetId = pets.first?.id
            }
        } catch {
            print("  Error fetching pets: \(error)")
            self.lastError = "Failed to fetch pets. Please check your connection."
            self.showError = true
        }
    }
    
    @MainActor
    func addPet(_ pet: Pet) async -> Bool {
        do {
            lastError = nil
            let session = try await client.auth.session
            let userIdString = session.user.id.uuidString.lowercased()
            
            var newPet = pet
            newPet.ownerId = userIdString // Use lowercase for consistency
            
            try await client
                .from("pets")
                .insert(newPet)
                .execute()
            
            await fetchPets()
            return true
        } catch {
            self.lastError = error.localizedDescription
            self.showError = true
            print("Error adding pet: \(error.localizedDescription)")
            return false
        }
    }
    
    func switchPet(to id: UUID) {
        activePetId = id
    }
    
    @MainActor
    func updatePet(_ pet: Pet) async {
        // Update local memory state immediately to enable universal real-time UI updates
        if let index = pets.firstIndex(where: { $0.id == pet.id }) {
            pets[index] = pet
        }
        
        do {
            try await client
                .from("pets")
                .update(pet)
                .eq("id", value: pet.id)
                .execute()
            
            await fetchPets()
        } catch {
            print("Error updating pet: \(error)")
            self.lastError = "Failed to update pet."
            self.showError = true
        }
    }
    
    @MainActor
    func deletePet(id: UUID) async {
        do {
            try await client
                .from("pets")
                .delete()
                .eq("id", value: id)
                .execute()
            
            await fetchPets()
            
            if activePetId == id {
                activePetId = pets.first?.id
            }
        } catch {
            print("  Error deleting pet: \(error)")
            self.lastError = "Failed to delete pet."
            self.showError = true
        }
    }
    
    // MARK: - Storage
    
    @MainActor
    func uploadImage(data: Data) async -> String? {
        do {
            var finalData = data
            if let uiImage = UIImage(data: data), let compressed = uiImage.jpegData(compressionQuality: 0.6) {
                finalData = compressed
            }
            
            let fileName = UUID().uuidString + ".jpg"
            
            try await SupabaseConfig.client.storage
                .from("pet-avatars")
                .upload(
                    fileName,
                    data: finalData,
                    options: FileOptions(contentType: "image/jpeg")
                )
            
            // Get public URL
            let publicURL = try SupabaseConfig.client.storage
                .from("pet-avatars")
                .getPublicURL(path: fileName)
            
            return publicURL.absoluteString
        } catch {
            print("  Error uploading image: \(error)")
            self.lastError = "Failed to upload image."
            self.showError = true
            return nil
        }
    }
    
    // MARK: - User Profile
    
    @MainActor
    func fetchUserProfile() async {
        do {
            let session = try await client.auth.session
            let user = session.user
            let userId = user.id.uuidString.lowercased()
            
            // Start with session data as a reliable source
            let sessionName: String
            if case let .string(val) = user.userMetadata["full_name"] {
                sessionName = val
            } else {
                sessionName = "Pet Owner"
            }
            
            // Create initial profile from session to avoid "Loading..."
            self.currentUserProfile = UserModel(id: userId, name: sessionName, email: user.email ?? "")
            
            // Then attempt to fetch/sync from profiles table
            let profiles: [UserModel] = try await client
                .from("profiles")
                .select()
                .eq("id", value: userId)
                .execute()
                .value
            
            if let dbProfile = profiles.first {
                self.currentUserProfile = dbProfile
                
                // Sync settings from Supabase to local UserDefaults
                if let settings = dbProfile.mealTimingSettings {
                    settings.save(for: userId)
                }
            }
        } catch {
            print("  Error fetching user profile: \(error)")
        }
    }
    
    func updateMealTimingSettings(_ settings: MealTimingSettings) async {
        guard let userId = currentUserProfile?.id else { return }
        struct ProfileSettingsUpdate: Encodable {
            let meal_timing_settings: MealTimingSettings
        }
        let update = ProfileSettingsUpdate(meal_timing_settings: settings)
        do {
            try await client
                .from("profiles")
                .update(update)
                .eq("id", value: userId)
                .execute()
            
            self.currentUserProfile?.mealTimingSettings = settings
            settings.save(for: userId)
        } catch {
            print("Failed to save meal timing settings to Supabase: \(error)")
        }
    }
    
    // MARK: - Saved Vets
    
    @MainActor
    func fetchSavedVets() async {
        do {
            let session = try await client.auth.session
            let userId = session.user.id.uuidString.lowercased()
            
            let vets: [SavedVet] = try await client
                .from("saved_vets")
                .select()
                .eq("user_id", value: userId)
                .execute()
                .value
            
            self.savedVets = vets
        } catch {
            print("  Error fetching saved vets: \(error)")
        }
    }
    
    @MainActor
    func deleteSavedVet(id: UUID) async {
        do {
            try await client
                .from("saved_vets")
                .delete()
                .eq("id", value: id)
                .execute()
            
            await fetchSavedVets()
        } catch {
            print("  Error deleting saved vet: \(error)")
        }
    }
    
    @MainActor
    func saveVet(name: String, address: String, phone: String, latitude: Double?, longitude: Double?) async -> Bool {
        do {
            let session = try await client.auth.session
            let userId = session.user.id
            
            let vet = SavedVet(
                id: UUID(),
                userId: userId,
                name: name,
                address: address,
                phone: phone,
                latitude: latitude,
                longitude: longitude,
                createdAt: Date()
            )
            
            try await client
                .from("saved_vets")
                .insert(vet)
                .execute()
            
            await fetchSavedVets()
            return true
        } catch {
            print("  Error saving vet: \(error)")
            return false
        }
    }
    
    @MainActor
    func toggleSaveVet(name: String, address: String, phone: String, latitude: Double?, longitude: Double?) async {
        if let existing = savedVets.first(where: { $0.name == name }) {
            await deleteSavedVet(id: existing.id)
        } else {
            _ = await saveVet(name: name, address: address, phone: phone, latitude: latitude, longitude: longitude)
        }
    }
}
