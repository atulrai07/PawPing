//
//  MealDietStore.swift
//  PawPing
//
//  Created by Atul on 25/04/26.
//
//  Business logic store for the Meals & Diet system.
//  Handles: food calorie dataset, calorie calculation, diet plan (RER-based),
//  daily calorie aggregation, rule-based insights, and UserDefaults persistence.
//
//  This store is owned by ActivityStore as a sub-store.
//  It does NOT manage UI state — only domain logic and data.
//
//  FIX: All UserDefaults keys are now scoped per-pet to prevent
//  data leaking between different user accounts.
//

import Foundation
import Observation
import Supabase

// MARK: - Persistence Keys (now per-pet)

private enum MealDietKeys {
    static func dietPlanKey(for petId: UUID) -> String {
        "pawping_diet_plan_\(petId.uuidString)"
    }
    static func mealLogsKey(for petId: UUID) -> String {
        "pawping_meal_logs_\(petId.uuidString)"
    }
}

// MARK: - Persisted Meal Log Entry

/// Lightweight Codable struct for persisting meal logs to UserDefaults.
/// Separate from the `Meal` view-model struct to keep persistence clean.
struct MealLogEntry: Codable, Identifiable {
    let id: UUID
    var mealType: MealType
    var foodTypeRawValue: String?      // FoodType.rawValue, nil if not logged
    var quantity: Double?              // Now a Double instead of enum
    var unit: String?
    var calories: Double
    var ingredients: [MealIngredient]?
    var time: String
    var meridian: String
    var date: Date
    var isTaken: Bool

    var foodType: FoodType? {
        guard let raw = foodTypeRawValue else { return nil }
        return FoodType(rawValue: raw)
    }
}

// MARK: - MealDietStore

@Observable
class MealDietStore {

    // MARK: - Food Calorie Database (loaded from JSON)

    private(set) var foodDatabase: [String: FoodCalorieEntry] = [:]

    // MARK: - Diet Plan

    var dietPlan: DietPlan = DietPlan()

    // MARK: - Meal Logs (persisted per-date)

    private(set) var mealLogs: [MealLogEntry] = []

    // MARK: - USDA Food Database (parsed and cached)

    private(set) var usdaFoods: [USDAFood] = []

    // MARK: - Current Pet ID (for scoped persistence)

    /// The pet ID used to scope UserDefaults keys.
    /// Call `switchPet(to:)` whenever the active pet changes.
    private var currentPetId: UUID?

    // MARK: - Init

    init() {
        loadFoodDatabase()
        loadOrParseUSDAFoods()
        // Diet plan and meal logs are loaded when switchPet(to:) is called
    }

    // MARK: - Pet Switching

    /// Call this whenever the active pet changes. Saves the current pet's
    /// data and loads the new pet's data from UserDefaults.
    func switchPet(to petId: UUID?) {
        guard let petId else {
            mealLogs = []
            dietPlan = DietPlan()
            currentPetId = nil
            return
        }

        // Don't reload if already on this pet
        guard petId != currentPetId else { return }

        currentPetId = petId
        loadPersistedDietPlan()
        loadPersistedMealLogs()
    }

    // MARK: - Food Database

    /// Loads the bundled food_calories.json into memory
    func loadFoodDatabase() {
        guard let url = Bundle.main.url(forResource: "food_calories", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            print("[MealDietStore] Failed to load food_calories.json")
            return
        }

        do {
            foodDatabase = try JSONDecoder().decode([String: FoodCalorieEntry].self, from: data)
        } catch {
            print("[MealDietStore] JSON decode error: \(error)")
        }
    }

    // MARK: - Calorie Calculation

    /// Returns calories for a given food type and quantity.
    /// Formula: base_calories × quantity_multiplier
    func caloriesFor(food: FoodType, quantity: Double) -> Double {
        guard !food.isEstimateOnly else { return 0 }
        guard let entry = foodDatabase[food.rawValue] else { return 0 }
        return entry.calories * quantity
    }

    /// Returns the unit string for a food type (e.g., "cup", "100g", "unit")
    func unitFor(food: FoodType) -> String {
        foodDatabase[food.rawValue]?.unit ?? "serving"
    }

    // MARK: - USDA Dataset Parsing & Caching

    private func loadOrParseUSDAFoods() {
        let cacheURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("usda_foods_cache.json")
        
        // Try loading from cache
        if let data = try? Data(contentsOf: cacheURL),
           let cached = try? JSONDecoder().decode([USDAFood].self, from: data) {
            self.usdaFoods = cached
            return
        }
        
        // Parse in background
        Task {
            let parsed = await parseUSDAFoods()
            DispatchQueue.main.async {
                self.usdaFoods = parsed
                // Save to cache
                if let data = try? JSONEncoder().encode(parsed) {
                    try? data.write(to: cacheURL)
                }
            }
        }
    }

    private func parseUSDAFoods() async -> [USDAFood] {
        guard let bundleURL = Bundle.main.url(forResource: "FINAL FOOD DATASET", withExtension: nil) else {
            // Provide a fallback hardcoded list if dataset not accessible in bundle during preview/dev
            return [
                USDAFood(name: "Rice, white, cooked", caloriesPer100g: 130),
                USDAFood(name: "Chicken breast, cooked", caloriesPer100g: 165),
                USDAFood(name: "Carrots, raw", caloriesPer100g: 41),
                USDAFood(name: "Sweet potato, cooked", caloriesPer100g: 90),
                USDAFood(name: "Egg, whole, raw", caloriesPer100g: 143),
                USDAFood(name: "Salmon, cooked", caloriesPer100g: 206),
                USDAFood(name: "Yogurt, plain", caloriesPer100g: 61),
                USDAFood(name: "Cheese, cheddar", caloriesPer100g: 402),
                USDAFood(name: "Peas, green, cooked", caloriesPer100g: 81)
            ]
        }
        
        let targetKeywords = ["chicken", "rice", "carrot", "salmon", "sweet potato", "lamb", "turkey", "egg", "apple", "banana", "blueberry", "pumpkin", "yogurt", "curd", "cheese", "pork", "peas", "oats", "broccoli", "spinach", "peanut butter", "tuna"]
        let excludedKeywords = ["beef", "steak"]
        
        var results: [USDAFood] = []
        var seenNames: Set<String> = []
        
        let fileManager = FileManager.default
        guard let files = try? fileManager.contentsOfDirectory(at: bundleURL, includingPropertiesForKeys: nil) else { return [] }
        
        for file in files where file.pathExtension == "csv" {
            guard let content = try? String(contentsOf: file, encoding: .utf8) else { continue }
            let lines = content.components(separatedBy: .newlines)
            
            for line in lines.dropFirst() {
                let columns = line.components(separatedBy: ",")
                guard columns.count > 3 else { continue }
                
                let foodName = columns[2].trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
                let caloriesStr = columns[3].trimmingCharacters(in: .whitespacesAndNewlines)
                
                guard let calories = Double(caloriesStr) else { continue }
                
                // Filter by dog-safe keywords and exclude restricted ones
                if targetKeywords.contains(where: { foodName.contains($0) }) && 
                   !excludedKeywords.contains(where: { foodName.contains($0) }) {
                    if !seenNames.contains(foodName) {
                        seenNames.insert(foodName)
                        results.append(USDAFood(name: foodName.capitalized, caloriesPer100g: calories))
                    }
                }
                
                if results.count >= 100 { break }
            }
            if results.count >= 100 { break }
        }
        
        return results.sorted { $0.name < $1.name }
    }

    /// Live search from the parsed USDA dataset
    func searchUSDA(query: String) -> [USDAFood] {
        let excludedKeywords = ["beef", "steak"]
        let filtered = usdaFoods.filter { food in
            !excludedKeywords.contains(where: { food.name.lowercased().contains($0) })
        }
        
        guard !query.isEmpty else { return filtered }
        return filtered.filter { $0.name.localizedCaseInsensitiveContains(query) }
    }

    // MARK: - Meal Logging

    /// Logs or updates a meal for the given date and type.
    /// Calculates calories automatically from the food database.
    func logMeal(
        mealType: MealType,
        foodType: FoodType,
        quantity: Double,
        unit: String,
        ingredients: [MealIngredient],
        time: String,
        meridian: String,
        date: Date
    ) {
        let dayStart = Calendar.current.startOfDay(for: date)

        let calculatedCalories: Double
        if foodType.isEstimateOnly {
            calculatedCalories = ingredients.reduce(0) { $0 + $1.calculatedCalories }
        } else {
            calculatedCalories = caloriesFor(food: foodType, quantity: quantity)
        }

        let entry = MealLogEntry(
            id: UUID(),
            mealType: mealType,
            foodTypeRawValue: foodType.rawValue,
            quantity: quantity,
            unit: unit,
            calories: calculatedCalories,
            ingredients: ingredients,
            time: time,
            meridian: meridian,
            date: dayStart,
            isTaken: true
        )

        // Replace existing log for same type + date, or add new
        if let index = mealLogs.firstIndex(where: {
            $0.mealType == mealType &&
            Calendar.current.isDate($0.date, inSameDayAs: dayStart)
        }) {
            mealLogs[index] = entry
        } else {
            mealLogs.append(entry)
        }

        persistMealLogs()
    }

    /// Returns the meal log for a specific type and date, if it exists
    func mealLog(for type: MealType, on date: Date) -> MealLogEntry? {
        let dayStart = Calendar.current.startOfDay(for: date)
        return mealLogs.first(where: {
            $0.mealType == type &&
            Calendar.current.isDate($0.date, inSameDayAs: dayStart)
        })
    }

    // MARK: - Daily Calorie Aggregation

    /// Total calories consumed on a given date
    func totalCalories(on date: Date) -> Double {
        let dayStart = Calendar.current.startOfDay(for: date)
        return mealLogs
            .filter { Calendar.current.isDate($0.date, inSameDayAs: dayStart) }
            .reduce(0) { $0 + $1.calories }
    }

    /// Remaining calories for the day (only meaningful when diet is active)
    func remainingCalories(on date: Date) -> Double {
        guard dietPlan.isActive else { return 0 }
        return max(0, dietPlan.dailyCalorieTarget - totalCalories(on: date))
    }

    /// Number of meals logged on a given date
    func mealsLoggedCount(on date: Date) -> Int {
        let dayStart = Calendar.current.startOfDay(for: date)
        return mealLogs
            .filter {
                Calendar.current.isDate($0.date, inSameDayAs: dayStart) && $0.isTaken
            }
            .count
    }

    // MARK: - Diet Plan Management

    /// Starts a diet plan with the given parameters. Calculates RER-based target.
    func startDiet(goal: DietGoal, weightKg: Double) {
        dietPlan.isActive = true
        dietPlan.goal = goal
        dietPlan.weightKg = weightKg
        dietPlan.calculateTarget()
        persistDietPlan()
    }

    /// Cancels the active diet plan
    func cancelDiet() {
        dietPlan.isActive = false
        dietPlan.dailyCalorieTarget = 0
        persistDietPlan()
    }

    // MARK: - Insights (Rule-Based)

    /// Returns a daily insight string based on today's consumption vs target
    func dailyInsight(on date: Date) -> String? {
        guard dietPlan.isActive else { return nil }
        let total = totalCalories(on: date)
        let target = dietPlan.dailyCalorieTarget

        if total > target * 1.1 {
            return " Overfeeding detected today"
        } else if total > 0 && total < target * 0.5 {
            return "📉 Low appetite detected"
        } else if total >= target * 0.9 && total <= target * 1.1 {
            return " On track today!"
        }
        return nil
    }

    /// Returns a weekly insight by checking the last 7 days
    func weeklyInsight(on date: Date) -> String? {
        guard dietPlan.isActive else { return nil }
        let calendar = Calendar.current
        let target = dietPlan.dailyCalorieTarget

        var highDays = 0
        var lowDays = 0
        var daysWithData = 0

        for offset in 0..<7 {
            guard let day = calendar.date(byAdding: .day, value: -offset, to: date) else { continue }
            let total = totalCalories(on: day)
            guard total > 0 else { continue }
            daysWithData += 1
            if total > target * 1.1 { highDays += 1 }
            if total < target * 0.5 { lowDays += 1 }
        }

        guard daysWithData >= 3 else { return nil } // need enough data

        if highDays >= 3 {
            return "📈 High calorie intake this week"
        } else if lowDays >= 3 {
            return "📉 Consistently low intake this week"
        }
        return nil
    }

    // MARK: - Persistence (UserDefaults + Supabase Sync)
    
    // Helper model to combine state for Supabase
    private struct CombinedState: Codable {
        let dietPlan: DietPlan
        let mealLogs: [MealLogEntry]
    }
    
    private struct PetAppStateUpload: Codable {
        let pet_id: UUID
        let meal_diet_data: String
    }
    
    private struct PetAppStateDownload: Codable {
        let meal_diet_data: String?
    }

    private func persistDietPlan() {
        guard let petId = currentPetId else { return }
        if let data = try? JSONEncoder().encode(dietPlan) {
            UserDefaults.standard.set(data, forKey: MealDietKeys.dietPlanKey(for: petId))
        }
        syncToSupabase()
    }

    private func loadPersistedDietPlan() {
        guard let petId = currentPetId else {
            dietPlan = DietPlan()
            return
        }
        guard let data = UserDefaults.standard.data(forKey: MealDietKeys.dietPlanKey(for: petId)),
              let plan = try? JSONDecoder().decode(DietPlan.self, from: data) else {
            dietPlan = DietPlan()
            return
        }
        dietPlan = plan
    }

    private func persistMealLogs() {
        guard let petId = currentPetId else { return }
        if let data = try? JSONEncoder().encode(mealLogs) {
            UserDefaults.standard.set(data, forKey: MealDietKeys.mealLogsKey(for: petId))
        }
        syncToSupabase()
    }

    private func loadPersistedMealLogs() {
        guard let petId = currentPetId else {
            mealLogs = []
            return
        }
        guard let data = UserDefaults.standard.data(forKey: MealDietKeys.mealLogsKey(for: petId)),
              let logs = try? JSONDecoder().decode([MealLogEntry].self, from: data) else {
            mealLogs = []
            return
        }
        mealLogs = logs
    }
    
    // MARK: - Supabase Cloud Sync
    
    private var syncTask: Task<Void, Never>?
    
    private func syncToSupabase() {
        guard let petId = currentPetId else { return }
        let state = CombinedState(dietPlan: dietPlan, mealLogs: mealLogs)
        
        guard let data = try? JSONEncoder().encode(state),
              let jsonString = String(data: data, encoding: .utf8) else { return }
        
        syncTask?.cancel()
        syncTask = Task {
            do {
                let payload = PetAppStateUpload(pet_id: petId, meal_diet_data: jsonString)
                // Use update for partial column update to avoid wiping activity_data
                try await SupabaseConfig.client
                    .from("pet_app_state")
                    .update(payload)
                    .eq("pet_id", value: petId.uuidString)
                    .execute()
            } catch {
                print("  Failed to sync meal state to Supabase: \(error)")
            }
        }
    }
    
    func fetchFromSupabase() async {
        guard let petId = currentPetId else { return }
        
        do {
            let response: PetAppStateDownload = try await SupabaseConfig.client
                .from("pet_app_state")
                .select("meal_diet_data")
                .eq("pet_id", value: petId.uuidString)
                .single()
                .execute()
                .value
            
            if let jsonString = response.meal_diet_data,
               let data = jsonString.data(using: .utf8),
               let state = try? JSONDecoder().decode(CombinedState.self, from: data) {
                
                await MainActor.run {
                    self.dietPlan = state.dietPlan
                    self.mealLogs = state.mealLogs
                    
                    // Update local UserDefaults cache
                    if let dietData = try? JSONEncoder().encode(state.dietPlan) {
                        UserDefaults.standard.set(dietData, forKey: MealDietKeys.dietPlanKey(for: petId))
                    }
                    if let logsData = try? JSONEncoder().encode(state.mealLogs) {
                        UserDefaults.standard.set(logsData, forKey: MealDietKeys.mealLogsKey(for: petId))
                    }
                }
            }
        } catch {
            print(" No cloud meal state found or failed to fetch: \(error)")
        }
    }
}
