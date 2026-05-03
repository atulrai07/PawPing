//
//  PetService.swift
//  PawPing
//
//  Created by SidMoon on 27/04/26.
//  Description: A dedicated service for all Pet-related database operations in Supabase.
//  This layer is only responsible for talking to the backend.
//

import Foundation
import Supabase

class PetService {
    // MARK: - Properties
    private let client = SupabaseConfig.client
    
    // MARK: - Public Methods
    
    /// Fetches all pets for a specific user.
    func fetchPets(for userId: UUID) async throws -> [Pet] {
        return try await client
            .from("pets")
            .select()
            .eq("owner_id", value: userId)
            .order("created_at")
            .execute()
            .value
    }
    
    /// Adds a new pet to the database.
    func addPet(_ pet: Pet) async throws {
        try await client
            .from("pets")
            .insert(pet)
            .execute()
    }
    
    /// Updates an existing pet in the database.
    func updatePet(_ pet: Pet) async throws {
        try await client
            .from("pets")
            .update(pet)
            .eq("id", value: pet.id)
            .execute()
    }
    
    /// Deletes a pet from the database.
    func deletePet(id: UUID) async throws {
        try await client
            .from("pets")
            .delete()
            .eq("id", value: id)
            .execute()
    }
    
    /// Fetches the profile details of an owner.
    func fetchOwnerProfile(for userId: UUID) async throws -> Owner? {
        return try await client
            .from("profiles")
            .select()
            .eq("id", value: userId)
            .single()
            .execute()
            .value
    }
}
