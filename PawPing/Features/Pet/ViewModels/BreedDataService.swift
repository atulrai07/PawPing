//
//  BreedDataService.swift
//  PawPing
//

import Foundation

@Observable
class BreedDataService {
    static let shared = BreedDataService()
    
    private(set) var breedTraits: [BreedTrait] = []
    private(set) var traitDescriptions: [TraitDescription] = []
    
    private init() {
        loadData()
    }
    
    private func loadData() {
        loadBreedTraits()
        loadTraitDescriptions()
    }
    
    private func loadBreedTraits() {
        guard let url = Bundle.main.url(forResource: "breed_traits", withExtension: "csv") else {
            print("❌ breed_traits.csv not found in bundle")
            return
        }
        
        do {
            let data = try String(contentsOf: url, encoding: .utf8)
            let rows = parseCSV(data)
            
            // Skip header
            for row in rows.dropFirst() {
                guard row.count >= 17 else { continue }
                
                let trait = BreedTrait(
                    breed: row[0],
                    affectionateWithFamily: Int(row[1]) ?? 3,
                    goodWithYoungChildren: Int(row[2]) ?? 3,
                    goodWithOtherDogs: Int(row[3]) ?? 3,
                    sheddingLevel: Int(row[4]) ?? 3,
                    coatGroomingFrequency: Int(row[5]) ?? 3,
                    droolingLevel: Int(row[6]) ?? 3,
                    coatType: row[7],
                    coatLength: row[8],
                    opennessToStrangers: Int(row[9]) ?? 3,
                    playfulnessLevel: Int(row[10]) ?? 3,
                    watchdogNature: Int(row[11]) ?? 3,
                    adaptabilityLevel: Int(row[12]) ?? 3,
                    trainabilityLevel: Int(row[13]) ?? 3,
                    energyLevel: Int(row[14]) ?? 3,
                    barkingLevel: Int(row[15]) ?? 3,
                    mentalStimulationNeeds: Int(row[16]) ?? 3
                )
                breedTraits.append(trait)
            }
            print("✅ Breeds loaded: \(breedTraits.count)")
        } catch {
            print("❌ Error loading breed traits: \(error)")
        }
    }
    
    private func loadTraitDescriptions() {
        guard let url = Bundle.main.url(forResource: "trait_description", withExtension: "csv") else {
            print("❌ trait_description.csv not found in bundle")
            return
        }
        
        do {
            let data = try String(contentsOf: url, encoding: .utf8)
            let rows = parseCSV(data)
            
            for row in rows.dropFirst() {
                guard row.count >= 4 else { continue }
                let desc = TraitDescription(
                    trait: row[0],
                    lowLabel: row[1],
                    highLabel: row[2],
                    description: row[3]
                )
                traitDescriptions.append(desc)
            }
        } catch {
            print("❌ Error loading trait descriptions: \(error)")
        }
    }
    
    func traits(for breed: String) -> BreedTrait? {
        return breedTraits.first { $0.breed.lowercased().contains(breed.lowercased()) }
    }
    
    func description(for trait: String) -> TraitDescription? {
        return traitDescriptions.first { $0.trait == trait }
    }
    
    // Robust CSV parser that handles quoted fields
    private func parseCSV(_ data: String) -> [[String]] {
        var result: [[String]] = []
        var currentRow: [String] = []
        var currentField = ""
        var inQuotes = false
        
        let characters = Array(data)
        var i = 0
        
        while i < characters.count {
            let char = characters[i]
            
            if inQuotes {
                if char == "\"" {
                    if i + 1 < characters.count && characters[i + 1] == "\"" {
                        currentField.append("\"")
                        i += 1
                    } else {
                        inQuotes = false
                    }
                } else {
                    currentField.append(char)
                }
            } else {
                if char == "\"" {
                    inQuotes = true
                } else if char == "," {
                    currentRow.append(currentField.trimmingCharacters(in: .whitespacesAndNewlines))
                    currentField = ""
                } else if char == "\n" || char == "\r\n" {
                    currentRow.append(currentField.trimmingCharacters(in: .whitespacesAndNewlines))
                    if !currentRow.isEmpty { result.append(currentRow) }
                    currentRow = []
                    currentField = ""
                    if char == "\r" && i + 1 < characters.count && characters[i + 1] == "\n" {
                        i += 1
                    }
                } else {
                    currentField.append(char)
                }
            }
            i += 1
        }
        
        if !currentField.isEmpty || !currentRow.isEmpty {
            currentRow.append(currentField.trimmingCharacters(in: .whitespacesAndNewlines))
            result.append(currentRow)
        }
        
        return result
    }
}
