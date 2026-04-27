//
//  MealStore.swift
//  PawPing
//
//  Created by Atul on 25/04/26.
//

import Foundation
import Observation
import Supabase

// MARK: - Persistence Keys
private enum MealStoreKeys {
    static let dietPlan = "pawping_diet_plan"
}

@Observable
class MealStore {
    private let client = SupabaseConfig.client
    
    // MARK: - State
    var meals: [Meal] = []
    var dietPlan: DietPlan = DietPlan()
    private(set) var foodDatabase: [String: FoodCalorieEntry] = [:]
    private(set) var usdaFoods: [USDAFood] = []
    
    // MARK: - Init
    init() {
        // Show the 3 meal slots immediately — replaced with real data once fetchMeals completes
        meals = Self.defaultMeals(for: UUID())
        loadFoodDatabase()
        loadPersistedDietPlan()
        loadOrParseUSDAFoods()
    }
    
    /// Builds the default breakfast / lunch / dinner template for a given petId.
    static func defaultMeals(for petId: UUID) -> [Meal] {
        [
            Meal(id: UUID(), petId: petId, icon: "sun.max",     time: "8:00", meridian: "AM", mealType: .breakfast, isTaken: false),
            Meal(id: UUID(), petId: petId, icon: "sunset.fill", time: "1:00", meridian: "PM", mealType: .lunch,     isTaken: false),
            Meal(id: UUID(), petId: petId, icon: "moon",        time: "8:00", meridian: "PM", mealType: .dinner,    isTaken: false)
        ]
    }
    
    // MARK: - Supabase Actions
    
    @MainActor
    func fetchMeals(for petId: UUID) async {
        // Update petId on any placeholder meals immediately so logging works
        for i in meals.indices where meals[i].petId != petId {
            meals[i].petId = petId
        }
        
        do {
            let fetched: [Meal] = try await client
                .from("meals")
                .select()
                .eq("pet_id", value: petId)
                .order("date", ascending: false)
                .execute()
                .value
            
            if fetched.isEmpty {
                // Keep / refresh the default template with the correct petId
                self.meals = Self.defaultMeals(for: petId)
            } else {
                // Merge fetched meals with defaults to ensure all 3 types are present in dashboard
                var merged: [Meal] = []
                for type in [MealType.breakfast, .lunch, .dinner] {
                    if let existing = fetched.first(where: { $0.mealType == type && Calendar.current.isDateInToday($0.date) }) {
                        merged.append(existing)
                    } else {
                        merged.append(Meal(
                            id: UUID(),
                            petId: petId,
                            icon: type == .breakfast ? "sun.max" : (type == .lunch ? "sunset.fill" : "moon"),
                            time: type == .breakfast ? "8:00" : (type == .lunch ? "1:00" : "8:00"),
                            meridian: type == .breakfast ? "AM" : "PM",
                            mealType: type,
                            isTaken: false
                        ))
                    }
                }
                self.meals = merged
            }
        } catch {
            // On error, ensure defaults are shown with the correct petId
            self.meals = Self.defaultMeals(for: petId)
            print("❌ Error fetching meals: \(error)")
        }
    }
    
    @MainActor
    func updateMeal(
        type: MealType,
        foodType: FoodType?,
        quantity: Double,
        unit: String,
        ingredients: [MealIngredient],
        time: Date,
        isTaken: Bool,
        petId: UUID
    ) async {
        var mealToUpdate: Meal
        if let index = meals.firstIndex(where: { $0.mealType == type }) {
            mealToUpdate = meals[index]
        } else {
            mealToUpdate = Meal(
                id: UUID(),
                petId: petId,
                icon: type == .breakfast ? "sun.max" : (type == .lunch ? "sunset.fill" : "moon"),
                time: "",
                meridian: "",
                mealType: type,
                isTaken: false
            )
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm"
        mealToUpdate.time = formatter.string(from: time)
        formatter.dateFormat = "a"
        mealToUpdate.meridian = formatter.string(from: time)
        
        mealToUpdate.foodType = foodType
        mealToUpdate.quantity = quantity
        mealToUpdate.unit = unit
        mealToUpdate.ingredients = ingredients
        mealToUpdate.isTaken = isTaken
        mealToUpdate.petId = petId
        mealToUpdate.date = Date()
        
        if let food = foodType {
            if food.isEstimateOnly {
                mealToUpdate.calories = ingredients.reduce(0) { $0 + $1.calculatedCalories }
            } else {
                mealToUpdate.calories = caloriesFor(food: food, quantity: quantity)
            }
        } else {
            mealToUpdate.calories = 0
        }
        
        do {
            try await client
                .from("meals")
                .upsert(mealToUpdate)
                .execute()
            
            await fetchMeals(for: petId)
        } catch {
            print("❌ Error updating meal: \(error)")
        }
    }

    // MARK: - Calculations
    
    func caloriesFor(food: FoodType, quantity: Double) -> Double {
        guard !food.isEstimateOnly else { return 0 }
        guard let entry = foodDatabase[food.rawValue] else { return 0 }
        return entry.calories * quantity
    }
    
    func unitFor(food: FoodType) -> String {
        foodDatabase[food.rawValue]?.unit ?? "serving"
    }
    
    var totalCaloriesToday: Double {
        meals.filter { $0.isTaken && Calendar.current.isDateInToday($0.date) }.reduce(0) { $0 + $1.calories }
    }
    
    var mealsLoggedToday: Int {
        meals.filter { $0.isTaken && Calendar.current.isDateInToday($0.date) }.count
    }
    
    func remainingCalories(on date: Date) -> Double {
        guard dietPlan.isActive else { return 0 }
        let total = totalCaloriesToday
        return max(0, dietPlan.dailyCalorieTarget - total)
    }

    // MARK: - Food Database & USDA
    
    private func loadFoodDatabase() {
        guard let url = Bundle.main.url(forResource: "food_calories", withExtension: "json", subdirectory: "Meals"),
              let data = try? Data(contentsOf: url) else {
            // Try without subdirectory if that fails (in case it's in the root)
            if let url = Bundle.main.url(forResource: "food_calories", withExtension: "json") {
                if let data = try? Data(contentsOf: url) {
                    foodDatabase = (try? JSONDecoder().decode([String: FoodCalorieEntry].self, from: data)) ?? [:]
                    return
                }
            }
            return
        }
        foodDatabase = (try? JSONDecoder().decode([String: FoodCalorieEntry].self, from: data)) ?? [:]
    }
    
    private func loadOrParseUSDAFoods() {
        let cacheURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("usda_foods_cache.json")
        if let data = try? Data(contentsOf: cacheURL),
           let cached = try? JSONDecoder().decode([USDAFood].self, from: data) {
            self.usdaFoods = cached
            return
        }
        Task {
            let parsed = await parseUSDAFoods()
            DispatchQueue.main.async {
                self.usdaFoods = parsed
                if let data = try? JSONEncoder().encode(parsed) {
                    try? data.write(to: cacheURL)
                }
            }
        }
    }

    private func parseUSDAFoods() async -> [USDAFood] {
        guard let bundleURL = Bundle.main.url(forResource: "FINAL FOOD DATASET", withExtension: nil, subdirectory: "Meals") ?? Bundle.main.url(forResource: "FINAL FOOD DATASET", withExtension: nil) else {
            return [
                USDAFood(name: "Rice, white, cooked", caloriesPer100g: 130),
                USDAFood(name: "Chicken breast, cooked", caloriesPer100g: 165),
                USDAFood(name: "Carrots, raw", caloriesPer100g: 41),
                USDAFood(name: "Sweet potato, cooked", caloriesPer100g: 90),
                USDAFood(name: "Egg, whole, raw", caloriesPer100g: 143)
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
                if targetKeywords.contains(where: { foodName.contains($0) }) && !excludedKeywords.contains(where: { foodName.contains($0) }) {
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

    func searchUSDA(query: String) -> [USDAFood] {
        let filtered = usdaFoods.filter { food in
            !["beef", "steak"].contains(where: { food.name.lowercased().contains($0) })
        }
        guard !query.isEmpty else { return filtered }
        return filtered.filter { $0.name.localizedCaseInsensitiveContains(query) }
    }

    // MARK: - Diet Plan
    
    func startDiet(goal: DietGoal, weightKg: Double) {
        dietPlan.isActive = true
        dietPlan.goal = goal
        dietPlan.weightKg = weightKg
        dietPlan.calculateTarget()
        persistDietPlan()
    }
    
    func cancelDiet() {
        dietPlan.isActive = false
        dietPlan.dailyCalorieTarget = 0
        persistDietPlan()
    }
    
    private func persistDietPlan() {
        if let data = try? JSONEncoder().encode(dietPlan) {
            UserDefaults.standard.set(data, forKey: MealStoreKeys.dietPlan)
        }
    }
    
    private func loadPersistedDietPlan() {
        guard let data = UserDefaults.standard.data(forKey: MealStoreKeys.dietPlan),
              let plan = try? JSONDecoder().decode(DietPlan.self, from: data) else { return }
        dietPlan = plan
    }
}
