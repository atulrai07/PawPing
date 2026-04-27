//
//  PetStore.swift
//  PawPing
//

import Foundation
import Observation
import Supabase

@MainActor
@Observable
class PetStore {
    private let client = SupabaseConfig.client
    
    var pets: [Pet] = []
    var activePetId: UUID?
    var lastError: String? = nil
    
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
            print("❌ Error fetching pets: \(error)")
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
            print("❌ Error adding pet: \(error.localizedDescription)")
            return false
        }
    }
    
    func switchPet(to id: UUID) {
        activePetId = id
    }
    
    @MainActor
    func updatePet(_ pet: Pet) async {
        do {
            try await client
                .from("pets")
                .update(pet)
                .eq("id", value: pet.id)
                .execute()
            
            await fetchPets()
        } catch {
            print("❌ Error updating pet: \(error)")
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
            print("❌ Error deleting pet: \(error)")
        }
    }
    
    // MARK: - Storage
    
    @MainActor
    func uploadImage(data: Data) async -> String? {
        do {
            let fileName = UUID().uuidString + ".jpg"
            
            try await SupabaseConfig.storageClient.storage
                .from("pet-avatars")
                .upload(
                    path: fileName,
                    file: data,
                    options: FileOptions(contentType: "image/jpeg")
                )
            
            // Get public URL
            let publicURL = try SupabaseConfig.storageClient.storage
                .from("pet-avatars")
                .getPublicURL(path: fileName)
            
            return publicURL.absoluteString
        } catch {
            print("❌ Error uploading image: \(error)")
            return nil
        }
    }
}
