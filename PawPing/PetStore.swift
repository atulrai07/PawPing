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
    
    var activePet: Pet? {
        pets.first { $0.id == activePetId } ?? pets.first
    }
    
    init() {
        // We will fetch pets when the user is authenticated
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
    func addPet(_ pet: Pet) async {
        do {
            let userId = try await client.auth.session.user.id
            var newPet = pet
            newPet.ownerId = userId
            
            try await client
                .from("pets")
                .insert(newPet)
                .execute()
            
            // Refresh list
            await fetchPets()
        } catch {
            print("❌ Error adding pet: \(error)")
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
}
