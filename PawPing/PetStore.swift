//
//  PetStore.swift
//  PawPing
//
//  Created by Antigravity on 27/04/26.
//
//  Global store managing multiple pet profiles.
//  Handles: pet list, active pet selection, pet switching,
//  and one-time data migration from single-pet to multi-pet.
//
//  Persisted to UserDefaults for now — designed for Supabase migration.
//

import Foundation
import Observation

// MARK: - Persistence Keys

private enum PetStoreKeys {
    static let pets           = "pawping_pets"
    static let activePetId    = "pawping_active_pet_id"
    static let hasMigrated    = "pawping_has_migrated_to_multi_pet"
}

// MARK: - PetStore

@Observable
class PetStore {

    // MARK: - Properties

    var pets: [Pet] = []
    var activePetId: UUID?

    /// The currently active pet — computed from the pet list and activePetId
    var activePet: Pet? {
        guard let id = activePetId else { return pets.first }
        return pets.first(where: { $0.id == id }) ?? pets.first
    }

    /// Convenience — true when at least one pet exists
    var hasPets: Bool { !pets.isEmpty }

    // MARK: - Init

    init() {
        loadPets()
        migrateIfNeeded()
    }

    // MARK: - Pet Management

    func switchPet(to id: UUID) {
        guard pets.contains(where: { $0.id == id }) else { return }
        activePetId = id
        persistActivePetId()
    }

    func addPet(_ pet: Pet) {
        pets.append(pet)
        // If this is the first pet, make it active
        if pets.count == 1 {
            activePetId = pet.id
            persistActivePetId()
        }
        persistPets()
    }

    func deletePet(id: UUID) {
        pets.removeAll(where: { $0.id == id })
        // If we deleted the active pet, switch to first available
        if activePetId == id {
            activePetId = pets.first?.id
            persistActivePetId()
        }
        persistPets()
    }

    func updatePet(_ pet: Pet) {
        if let index = pets.firstIndex(where: { $0.id == pet.id }) {
            pets[index] = pet
            persistPets()
        }
    }

    // MARK: - Migration (one-time, single-pet → multi-pet)

    private func migrateIfNeeded() {
        let hasMigrated = UserDefaults.standard.bool(forKey: PetStoreKeys.hasMigrated)
        guard !hasMigrated else { return }

        // If no pets exist, create a default pet
        if pets.isEmpty {
            let defaultPet = Pet(
                id: UUID(),
                name: "Buddy",
                breed: "Labrador",
                gender: .male,
                age: "2",
                weightKg: 25.0,
                imageName: "dog1",
                homeLatitude: 28.4210,
                homeLongitude: 77.5340
            )
            pets.append(defaultPet)
            activePetId = defaultPet.id
            persistPets()
            persistActivePetId()
        }

        // Mark migration as complete
        UserDefaults.standard.set(true, forKey: PetStoreKeys.hasMigrated)
    }

    // MARK: - Persistence

    private func persistPets() {
        if let data = try? JSONEncoder().encode(pets) {
            UserDefaults.standard.set(data, forKey: PetStoreKeys.pets)
        }
    }

    private func persistActivePetId() {
        if let id = activePetId {
            UserDefaults.standard.set(id.uuidString, forKey: PetStoreKeys.activePetId)
        }
    }

    private func loadPets() {
        // Load pet list
        if let data = UserDefaults.standard.data(forKey: PetStoreKeys.pets),
           let decoded = try? JSONDecoder().decode([Pet].self, from: data) {
            pets = decoded
        }

        // Load active pet ID
        if let idString = UserDefaults.standard.string(forKey: PetStoreKeys.activePetId),
           let id = UUID(uuidString: idString) {
            activePetId = id
        }
    }
}
