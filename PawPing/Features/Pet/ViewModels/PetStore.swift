//
//  PetStore.swift
//  PawPing
//

import Foundation
import Observation
import Supabase

@Observable
class PetStore {
    private let client = SupabaseConfig.client
    
    var pets: [Pet] = []
    var activePetId: UUID?
    var currentUserProfile: Owner?
    
    var activePet: Pet? {
        pets.first { $0.id == activePetId } ?? pets.first
    }
    
    /// Static instance for Xcode Previews
    static var preview: PetStore {
        let store = PetStore()
        store.pets = [
            Pet(id: UUID(), name: "Buddy", breed: "Golden Retriever", gender: .male, age: "2", weightKg: 25.0, imageName: "dog1", homeLatitude: 0, homeLongitude: 0),
            Pet(id: UUID(), name: "Luna", breed: "Husky", gender: .female, age: "3", weightKg: 20.0, imageName: "dog2", homeLatitude: 0, homeLongitude: 0)
        ]
        store.activePetId = store.pets.first?.id
        store.currentUserProfile = Owner(id: UUID(), name: "Preview User", email: "preview@example.com")
        return store
    }
    
    init() {
        // We will fetch pets when the user is authenticated
    }
    
    @MainActor
    func fetchUserProfile() async {
        do {
            let session = try await client.auth.session
            let userId = session.user.id
            let email = session.user.email ?? ""
            let metadata = session.user.userMetadata
            
            var name = "User"
            if let fullName = metadata["full_name"] {
                let nameStr = String(describing: fullName).replacingOccurrences(of: "\"", with: "")
                name = nameStr.isEmpty ? "User" : nameStr
            }
            
            self.currentUserProfile = Owner(
                id: userId,
                name: name,
                email: email,
                phone: nil,
                profileImage: nil
            )
        } catch {
            print("❌ Error fetching user profile: \(error)")
        }
    }
    
    @MainActor
    func fetchPets() async {
        do {
            let userId = try await client.auth.session.user.id
            
            let fetchedPets: [Pet] = try await client
                .from("pets")
                .select()
                .eq("owner_id", value: userId)
                .order("created_at")
                .execute()
                .value
            
            self.pets = fetchedPets
            
            // Set active pet if not set
            if activePetId == nil {
                activePetId = pets.first?.id
            }
        } catch {
            print("❌ Error fetching pets: \(error)")
        }
    }
    
    @MainActor
    func addPet(_ pet: Pet) async -> Bool {
        do {
            print("🚀 Attempting to add pet: \(pet.name)")
            let session = try await client.auth.session
            let userId = session.user.id
            
            var newPet = pet
            newPet.ownerId = userId
            
            try await client
                .from("pets")
                .insert(newPet)
                .execute()
            
            print("✅ Pet added successfully: \(pet.name)")
            
            // Refresh list
            await fetchPets()
            return true
        } catch {
            print("❌ Error adding pet to Supabase: \(error)")
            print("❌ Detailed error: \(error.localizedDescription)")
            return false
        }
    }
    
    func switchPet(to id: UUID) {
        activePetId = id
    }
    
    @MainActor
    func updatePet(_ pet: Pet) async throws {
        // 1. Confirm Identity (Debug)
        let session = try await client.auth.session
        let userId = session.user.id
        
        print("🔍 [DEBUG] Auth UID:", userId.uuidString)
        print("🔍 [DEBUG] Pet ownerId:", pet.ownerId?.uuidString ?? "nil")
        
        // 2. Define an Encodable payload to satisfy RLS and Type Safety
        struct PetUpdatePayload: Encodable {
            let name: String
            let breed: String
            let gender: String
            let age: String
            let weight_kg: Double
            let profile_image_url: String?
            let is_neutered: Bool
            let owner_id: String
            let birthday: String?
        }
        
        var birthdayString: String? = nil
        if let birthday = pet.birthday {
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime]
            birthdayString = formatter.string(from: birthday)
        }
        
        let payload = PetUpdatePayload(
            name: pet.name,
            breed: pet.breed,
            gender: pet.gender.rawValue,
            age: pet.age,
            weight_kg: pet.weightKg,
            profile_image_url: pet.profileImageUrl,
            is_neutered: pet.isNeutered ?? false,
            owner_id: userId.uuidString,
            birthday: birthdayString
        )
        
        try await client
            .from("pets")
            .update(payload)
            .eq("id", value: pet.id)
            .execute()
        
        print("✅ Pet updated successfully with explicit payload")
        await fetchPets()
    }

    @MainActor
    func uploadPetAvatar(petId: UUID, imageData: Data) async throws -> String {
        let userId = try await client.auth.session.user.id.uuidString
        let path = "\(userId)/\(petId.uuidString).jpg"
        
        _ = try await client.storage
            .from("pet-avatars")
            .upload(path, data: imageData, options: FileOptions(contentType: "image/jpeg", upsert: true))
        
        let publicUrl = try client.storage.from("pet-avatars").getPublicURL(path: path).absoluteString
        return publicUrl
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
            print("❌ Error deleting pet: \(error)")
        }
    }
    
    // MARK: - Saved Vets
    var savedVets: [SavedVet] = []
    
    @MainActor
    func fetchSavedVets() async {
        do {
            let userId = try await client.auth.session.user.id
            let fetchedVets: [SavedVet] = try await client
                .from("saved_vets")
                .select()
                .eq("user_id", value: userId)
                .order("created_at", ascending: false)
                .execute()
                .value
            
            self.savedVets = fetchedVets
        } catch {
            print("❌ Error fetching saved vets: \(error)")
        }
    }
    
    @MainActor
    func addSavedVet(_ vet: SavedVet) async {
        do {
            let userId = try await client.auth.session.user.id
            var newVet = vet
            newVet.userId = userId
            
            try await client
                .from("saved_vets")
                .insert(newVet)
                .execute()
            
            await fetchSavedVets()
        } catch {
            print("❌ Error adding saved vet: \(error)")
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
            print("❌ Error deleting saved vet: \(error)")
        }
    }
}
