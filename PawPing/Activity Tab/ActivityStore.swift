//
//  ActivityStore.swift
//  PawPing
//
//  Created by SidMoon on 16/03/26.
//

import Foundation
import Supabase
import CoreLocation

@Observable
class ActivityStore {

    var activePetId: UUID?
    var meals: [Meal] = []
    var vaccines: [Vaccine] = []
    var allergies: [Allergy] = []
    var walkActivity: WalkActivity
    var timeWalkedGraph: TimeWalkedGraphModel
    var distanceSummary: DistanceSummaryModel
    var activities: [Activity] = []
    
    var walkedDates: Set<DateComponents> {
        Set(activities.compactMap { activity in
            guard !activity.routePoints.isEmpty else { return nil }
            return Calendar.current.dateComponents([.year, .month, .day], from: activity.date)
        })
    }

    // MARK: - Meal & Diet Sub-Store
    var mealDietStore = MealDietStore()

    // MARK: - Walk Session (persists across view appearances)
    var isWalking: Bool = false
    var elapsedSeconds: TimeInterval = 0
    var isPaused: Bool = false
    var locationManager = LocationManager()
    private var walkTimer: Timer?

    init() {
        // Initialize with empty defaults to satisfy the compiler.
        // The actual data will be loaded via `switchPet(to:)` once a pet is selected.
        self.walkActivity = WalkActivity(currentMinutes: 0, goalMinutes: 60)
        self.timeWalkedGraph = TimeWalkedGraphModel(data: [], goalMinutes: 60)
        self.distanceSummary = DistanceSummaryModel(weekData: [], monthData: [], weekRange: "", monthName: "")
    }

    /// Helper struct for persisting ActivityStore UI state
    private struct ActivityStoreData: Codable {
        var meals: [Meal]
        var walkActivity: WalkActivity
        var timeWalkedGraph: TimeWalkedGraphModel
        var distanceSummary: DistanceSummaryModel
        var activities: [Activity]?
    }
    
    private struct PetAppStateUpload: Codable {
        let pet_id: UUID
        let activity_data: String
    }
    
    private struct PetAppStateDownload: Codable {
        let activity_data: String?
    }

    func switchPet(to petId: UUID?) {
        self.activePetId = petId
        // Sync sub-stores
        mealDietStore.switchPet(to: petId)
        
        guard let petId else { return }
        let key = "activity_store_data_\(petId.uuidString)"
        
        if let data = UserDefaults.standard.data(forKey: key),
           let storedData = try? JSONDecoder().decode(ActivityStoreData.self, from: data) {
            
            // Check if meals are from a previous day. If so, reset them.
            let today = Calendar.current.startOfDay(for: Date())
            var loadedMeals = storedData.meals
            if let firstMealDate = loadedMeals.first?.date, 
               !Calendar.current.isDate(firstMealDate, inSameDayAs: today) {
                loadedMeals = Self.defaultMeals(for: petId)
            }
            
            if loadedMeals.isEmpty {
                loadedMeals = Self.defaultMeals(for: petId)
            }
            
            self.meals = loadedMeals
            self.walkActivity = storedData.walkActivity
            self.timeWalkedGraph = storedData.timeWalkedGraph
            self.distanceSummary = storedData.distanceSummary
            self.activities = storedData.activities ?? []
        } else {
            // New pet, initialize default state
            self.meals = Self.defaultMeals(for: petId)
            self.walkActivity = WalkActivity(currentMinutes: 0, goalMinutes: 60)
            
            self.timeWalkedGraph = TimeWalkedGraphModel(
                data: [
                    TimeWalkedData(day: "MON", minutes: 0),
                    TimeWalkedData(day: "TUE", minutes: 0),
                    TimeWalkedData(day: "WED", minutes: 0),
                    TimeWalkedData(day: "THU", minutes: 0),
                    TimeWalkedData(day: "FRI", minutes: 0),
                    TimeWalkedData(day: "SAT", minutes: 0),
                    TimeWalkedData(day: "SUN", minutes: 0)
                ],
                goalMinutes: 60
            )
            
            let calendar = Calendar.current
            let today = Date()
            var components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today)
            components.weekday = 2
            let monday = calendar.date(from: components)!
            
            let weekDates = (0..<7).map { calendar.date(byAdding: .day, value: $0, to: monday)! }
            let weekDistances = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
            
            var weekData: [DistanceData] = []
            for i in 0..<weekDistances.count {
                weekData.append(DistanceData(date: Array(weekDates)[i], distanceInKm: weekDistances[i]))
            }
            
            self.distanceSummary = DistanceSummaryModel(
                weekData: weekData,
                monthData: [],
                weekRange: "Current Week",
                monthName: "Current Month"
            )
            
            saveData(for: petId)
        }
        
        // After loading local cache, fetch from cloud
        Task {
            await mealDietStore.fetchFromSupabase()
            await fetchFromSupabase(for: petId)
        }
    }

    private var syncTask: Task<Void, Never>?

    private func saveData(for petId: UUID?) {
        guard let petId else { return }
        let key = "activity_store_data_\(petId.uuidString)"
        
        let dataToSave = ActivityStoreData(
            meals: meals,
            walkActivity: walkActivity,
            timeWalkedGraph: timeWalkedGraph,
            distanceSummary: distanceSummary,
            activities: activities
        )
        
        if let encoded = try? JSONEncoder().encode(dataToSave) {
            UserDefaults.standard.set(encoded, forKey: key)
            
            // Sync to Supabase
            if let jsonString = String(data: encoded, encoding: .utf8) {
                syncTask?.cancel()
                syncTask = Task {
                    do {
                        let payload = PetAppStateUpload(pet_id: petId, activity_data: jsonString)
                        // Use update instead of upsert to perform a partial update (PATCH)
                        // this prevents overwriting the meal_diet_data column.
                        try await SupabaseConfig.client
                            .from("pet_app_state")
                            .update(payload)
                            .eq("pet_id", value: petId.uuidString)
                            .execute()
                    } catch {
                        print("  Failed to sync activity state to Supabase: \(error)")
                    }
                }
            }
        }
    }
    
    private func fetchFromSupabase(for petId: UUID) async {
        do {
            let response: PetAppStateDownload = try await SupabaseConfig.client
                .from("pet_app_state")
                .select("activity_data")
                .eq("pet_id", value: petId.uuidString)
                .single()
                .execute()
                .value
            
            if let jsonString = response.activity_data,
               let data = jsonString.data(using: .utf8),
               let storedData = try? JSONDecoder().decode(ActivityStoreData.self, from: data) {
                
                await MainActor.run {
                    let today = Calendar.current.startOfDay(for: Date())
                    var loadedMeals = storedData.meals
                    if let firstMealDate = loadedMeals.first?.date, 
                       !Calendar.current.isDate(firstMealDate, inSameDayAs: today) {
                        loadedMeals = Self.defaultMeals(for: petId)
                    }
                    
                    
                    if loadedMeals.isEmpty {
                        loadedMeals = Self.defaultMeals(for: petId)
                    }
                    
                    self.meals = loadedMeals
                    self.walkActivity = storedData.walkActivity
                    self.timeWalkedGraph = storedData.timeWalkedGraph
                    self.distanceSummary = storedData.distanceSummary
                    self.activities = storedData.activities ?? []
                    
                    // Update local cache
                    let key = "activity_store_data_\(petId.uuidString)"
                    UserDefaults.standard.set(data, forKey: key)
                }
            }
        } catch {
            print(" No cloud activity state found or failed to fetch: \(error)")
        }
    }

    private static func defaultMeals(for petId: UUID) -> [Meal] {
        return [
            Meal(id: UUID(), petId: petId, icon: "sun.max", time: "8:00", meridian: "AM", mealType: .breakfast, isTaken: false),
            Meal(id: UUID(), petId: petId, icon: "sunset.fill", time: "12:30", meridian: "PM", mealType: .lunch, isTaken: false),
            Meal(id: UUID(), petId: petId, icon: "moon", time: "8:30", meridian: "PM", mealType: .dinner, isTaken: false)
        ]
    }

    // MARK: - Walk Session Controls

    func startWalk() {
        isWalking = true
        isPaused = false
        elapsedSeconds = 0
        locationManager.requestPermission()
        locationManager.startTracking()
        startTimer()
    }

    func stopWalk() {
        walkTimer?.invalidate()
        walkTimer = nil
        locationManager.stopTracking()

        let walkedMinutes = Int(elapsedSeconds / 60)
        walkActivity.currentMinutes += walkedMinutes
        
        let routeCoordinates = locationManager.routeLocations.map {
            CoordinateModel(latitude: $0.latitude, longitude: $0.longitude)
        }
        let distanceKm = locationManager.totalDistance / 1000.0
        
        let newActivity = Activity(
            date: Date(),
            routePoints: routeCoordinates,
            distanceInKm: distanceKm,
            durationMinutes: walkedMinutes
        )
        activities.append(newActivity)
        
        // Update graph for current day
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        let currentDay = formatter.string(from: Date()).uppercased()
        
        if let index = timeWalkedGraph.data.firstIndex(where: { $0.day == currentDay }) {
            timeWalkedGraph.data[index].minutes += walkedMinutes
        }

        isWalking = false
        isPaused = false
        elapsedSeconds = 0
        locationManager.totalDistance = 0
        
        saveData(for: activePetId)
    }

    func togglePause() {
        isPaused.toggle()
        if isPaused {
            walkTimer?.invalidate()
            walkTimer = nil
            locationManager.stopTracking()
        } else {
            locationManager.startTracking()
            startTimer()
        }
    }
    
    // MARK: - Meal Update (delegates calorie calculation to MealDietStore)
    
    func updateMeal(type: MealType, foodType: FoodType?, quantity: Double, unit: String, ingredients: [MealIngredient], time: Date, isTaken: Bool, forDate: Date = Date()) {
        let isToday = Calendar.current.isDateInToday(forDate)
        
        // 1. If it's today, update the "live" meals array for the Home tab
        if isToday {
            if let index = meals.firstIndex(where: { $0.mealType == type }) {
                let formatter = DateFormatter()
                formatter.dateFormat = "h:mm"
                let timeStr = formatter.string(from: time)
                
                formatter.dateFormat = "a"
                let meridianStr = formatter.string(from: time)
                
                meals[index].foodType = foodType
                meals[index].quantity = quantity
                meals[index].unit = unit
                meals[index].ingredients = ingredients
                meals[index].time = timeStr
                meals[index].meridian = meridianStr
                meals[index].isTaken = isTaken
                
                // Calculate calories
                if let food = foodType {
                    if food.isEstimateOnly {
                        meals[index].calories = ingredients.reduce(0) { $0 + $1.calculatedCalories }
                    } else {
                        meals[index].calories = mealDietStore.caloriesFor(food: food, quantity: quantity)
                    }
                } else {
                    meals[index].calories = 0
                }
                
                saveData(for: activePetId)
            }
        }
        
        // 2. Persist to historical mealLogs in MealDietStore
        if let food = foodType {
            let formatter = DateFormatter()
            formatter.dateFormat = "h:mm"
            let timeStr = formatter.string(from: time)
            
            formatter.dateFormat = "a"
            let meridianStr = formatter.string(from: time)
            
            mealDietStore.logMeal(
                mealType: type,
                foodType: food,
                quantity: quantity,
                unit: unit,
                ingredients: ingredients,
                time: timeStr,
                meridian: meridianStr,
                date: forDate
            )
        }
    }
    
    /// Reconstructs a list of Meal objects for a specific date from persisted logs.
    func getMeals(for date: Date) -> [Meal] {
        if Calendar.current.isDateInToday(date) {
            return meals
        }
        
        return MealType.allCases.map { type in
            if let log = mealDietStore.mealLog(for: type, on: date) {
                return Meal(
                    id: log.id,
                    petId: activePetId ?? UUID(),
                    icon: type.icon,
                    time: log.time,
                    meridian: log.meridian,
                    date: log.date,
                    mealType: log.mealType,
                    foodType: log.foodType,
                    quantity: log.quantity ?? 0,
                    unit: log.unit ?? "",
                    calories: log.calories,
                    ingredients: log.ingredients ?? [],
                    isTaken: log.isTaken
                )
            } else {
                return Meal(
                    id: UUID(),
                    petId: activePetId ?? UUID(),
                    icon: type.icon,
                    time: type.defaultTime,
                    meridian: type.defaultMeridian,
                    date: date,
                    mealType: type,
                    isTaken: false
                )
            }
        }
    }

    /// Total calories across all meals today (from the in-memory meals array)
    var totalCaloriesToday: Double {
        meals.filter { $0.isTaken }.reduce(0) { $0 + $1.calories }
    }

    /// Number of meals logged today
    var mealsLoggedToday: Int {
        meals.filter { $0.isTaken }.count
    }

    private func startTimer() {
        walkTimer?.invalidate()
        walkTimer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { [weak self] _ in
            guard let self else { return }
            self.elapsedSeconds += 0.01
        }
    }
}
