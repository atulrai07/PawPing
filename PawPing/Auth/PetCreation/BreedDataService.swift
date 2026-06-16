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
    private(set) var breedExercise: [String: Int] = [:]
    
    /// Default fallback when breed is not found in the exercise dataset
    static let defaultGoalMinutes = 60
    
    private init() {
        loadData()
    }
    
    private func loadData() {
        loadBreedTraits()
        loadTraitDescriptions()
        loadBreedExercise()
    }
    
    private func loadBreedTraits() {
        guard let url = Bundle.main.url(forResource: "breed_traits", withExtension: "csv") else {
            print("  breed_traits.csv not found in bundle")
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
            print(" Breeds loaded: \(breedTraits.count)")
        } catch {
            print("  Error loading breed traits: \(error)")
        }
    }
    
    private func loadTraitDescriptions() {
        guard let url = Bundle.main.url(forResource: "trait_description", withExtension: "csv") else {
            print("  trait_description.csv not found in bundle")
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
            print("  Error loading trait descriptions: \(error)")
        }
    }
    
    private func normalizeBreedName(_ name: String) -> String {
        // Replace non-breaking spaces and all whitespaces with regular space
        var normalized = name.replacingOccurrences(of: "\u{00A0}", with: " ")
        normalized = normalized.replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
        normalized = normalized.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Remove common punctuation/parentheses to help with cases like "Retrievers (Labrador)"
        normalized = normalized.replacingOccurrences(of: "[()\\-,.]", with: "", options: .regularExpression)
        
        // Normalize plurals/singulars
        let words = normalized.components(separatedBy: " ")
        let processedWords = words.map { word -> String in
            if word.hasSuffix("ies") {
                return String(word.dropLast(3)) + "y"
            } else if word.hasSuffix("s") && word.count > 3 && !word.hasSuffix("ss") {
                return String(word.dropLast())
            }
            return word
        }
        return processedWords.filter { !$0.isEmpty }.joined(separator: " ")
    }
    
    func traits(for breed: String) -> BreedTrait? {
        let cleanBreed = normalizeBreedName(breed)
        if cleanBreed.isEmpty { return nil }
        
        // Exact normalized match first
        if let match = breedTraits.first(where: { normalizeBreedName($0.breed) == cleanBreed }) {
            return match
        }
        
        // Substring normalized match
        if let match = breedTraits.first(where: {
            let traitBreedClean = normalizeBreedName($0.breed)
            return traitBreedClean.contains(cleanBreed) || cleanBreed.contains(traitBreedClean)
        }) {
            return match
        }
        
        // Word-set intersection match
        let breedWords = Set(cleanBreed.components(separatedBy: " "))
        return breedTraits.first {
            let traitBreedWords = Set(normalizeBreedName($0.breed).components(separatedBy: " "))
            return breedWords.isSubset(of: traitBreedWords) || traitBreedWords.isSubset(of: breedWords)
        }
    }
    
    func description(for trait: String) -> TraitDescription? {
        return traitDescriptions.first { $0.trait == trait }
    }
    
    // MARK: - Breed Exercise Lookup
    
    private func loadBreedExercise() {
        guard let url = Bundle.main.url(forResource: "breed_exercise", withExtension: "json") else {
            print("  breed_exercise.json not found in bundle")
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            if let dict = try JSONSerialization.jsonObject(with: data) as? [String: Int] {
                self.breedExercise = dict
                print(" Breed exercise data loaded: \(dict.count) breeds")
            }
        } catch {
            print("  Error loading breed exercise data: \(error)")
        }
    }
    
    /// Returns the recommended daily walk minutes for a breed (without age adjustment).
    func recommendedWalkMinutes(for breed: String) -> Int {
        let cleanBreed = normalizeBreedName(breed)
        if cleanBreed.isEmpty { return Self.defaultGoalMinutes }
        
        // 1. Try exact normalized match
        if let match = breedExercise.first(where: { normalizeBreedName($0.key) == cleanBreed }) {
            return match.value
        }
        
        // 2. Try substring matching on normalized names
        if let match = breedExercise.first(where: {
            let exerciseBreedClean = normalizeBreedName($0.key)
            return exerciseBreedClean.contains(cleanBreed) || cleanBreed.contains(exerciseBreedClean)
        }) {
            return match.value
        }
        
        // 3. Try word-set intersection (if all words of one breed are in the other)
        let breedWords = Set(cleanBreed.components(separatedBy: " "))
        if let match = breedExercise.first(where: {
            let exerciseBreedWords = Set(normalizeBreedName($0.key).components(separatedBy: " "))
            return breedWords.isSubset(of: exerciseBreedWords) || exerciseBreedWords.isSubset(of: breedWords)
        }) {
            return match.value
        }
        
        return Self.defaultGoalMinutes
    }
    
    /// Applies an age-based modifier to the breed's recommended exercise.
    /// Puppies (<1 year) and seniors (>8 years) get 75% of the breed default.
    func ageAdjustedWalkMinutes(for breed: String, birthday: Date?) -> Int {
        let baseMinutes = recommendedWalkMinutes(for: breed)
        
        guard let birthday else { return baseMinutes }
        
        let ageInYears = Calendar.current.dateComponents([.year], from: birthday, to: Date()).year ?? 0
        
        if ageInYears < 1 || ageInYears > 8 {
            // Puppy or senior — reduce to 75%
            return max(15, Int(Double(baseMinutes) * 0.75))
        }
        
        return baseMinutes
    }
    
    /// Resolves the walk goal for a pet: custom override → breed+age default → fallback.
    func resolveWalkGoal(for pet: Pet) -> Int {
        // 1. User-set custom goal takes priority
        if let custom = pet.walkGoalMinutes {
            return custom
        }
        
        // 2. Breed-based with age adjustment
        return ageAdjustedWalkMinutes(for: pet.breed, birthday: pet.birthdayDate)
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
