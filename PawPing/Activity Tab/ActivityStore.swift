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
    var activePet: Pet?
    var meals: [Meal] = []
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

    /// Total walked minutes today, including the active walk session in real-time
    var liveWalkedMinutes: Int {
        let todaysMinutes = walkActivity.currentMinutes
        if isWalking {
            return todaysMinutes + Int(elapsedSeconds / 60)
        }
        return todaysMinutes
    }
    
    /// Progress today, including the active walk session in real-time
    var liveProgress: Double {
        guard walkActivity.goalMinutes > 0 else { return 0 }
        return Double(liveWalkedMinutes) / Double(walkActivity.goalMinutes)
    }

    // MARK: - Meal & Diet Sub-Store
    var mealDietStore = MealDietStore()

    // MARK: - Walk Session (persists across view appearances)
    var isWalking: Bool = false
    var elapsedSeconds: TimeInterval = 0
    var isPaused: Bool = false
    var locationManager = LocationManager()
    private var walkTimer: Timer?
    private var walkStartTime: Date?
    private var accumulatedSeconds: TimeInterval = 0

    init() {
        let defaultGoal = BreedDataService.defaultGoalMinutes
        self.walkActivity = WalkActivity(currentMinutes: 0, goalMinutes: defaultGoal)
        self.timeWalkedGraph = TimeWalkedGraphModel(data: [], goalMinutes: defaultGoal)
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
    
    private struct DBActivityRecord: Codable {
        let id: UUID
        let pet_id: UUID
        let owner_id: String
        let duration_minutes: Int
        let distance_km: Double
        let date: Date
        let route_points: [CoordinateModel]
    }

    func switchPet(to pet: Pet?) {
        self.activePetId = pet?.id
        self.activePet = pet
        // Sync sub-stores
        mealDietStore.switchPet(to: pet?.id)
        
        guard let pet else { return }
        let petId = pet.id
        let resolvedGoal = BreedDataService.shared.resolveWalkGoal(for: pet)
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
            
            // Override goalMinutes with the dynamically resolved value
            var restoredWalk = storedData.walkActivity
            restoredWalk.goalMinutes = resolvedGoal
            self.walkActivity = restoredWalk
            self.timeWalkedGraph = TimeWalkedGraphModel(data: storedData.timeWalkedGraph.data, goalMinutes: resolvedGoal)
            self.distanceSummary = storedData.distanceSummary
            
            let walksKey = "walk_activities_\(petId.uuidString)"
            if let walksData = UserDefaults.standard.data(forKey: walksKey),
               let cachedWalks = try? JSONDecoder().decode([Activity].self, from: walksData) {
                self.activities = cachedWalks
            } else {
                self.activities = storedData.activities ?? []
            }
        } else {
            // New pet, initialize default state
            self.meals = Self.defaultMeals(for: petId)
            self.walkActivity = WalkActivity(currentMinutes: 0, goalMinutes: resolvedGoal)
            
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
                goalMinutes: resolvedGoal
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
            saveActivitiesLocally(for: petId)
        }
        
        rebuildStats()
        
        // After loading local cache, fetch from cloud
        Task {
            await mealDietStore.fetchFromSupabase()
            await fetchFromSupabase(for: petId)
            await fetchWalksFromSupabase(for: petId)
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
            activities: nil
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
                    
                    // Override goalMinutes with the dynamically resolved value
                    var restoredWalk = storedData.walkActivity
                    if let pet = self.activePet {
                        restoredWalk.goalMinutes = BreedDataService.shared.resolveWalkGoal(for: pet)
                    }
                    self.walkActivity = restoredWalk
                    self.timeWalkedGraph = storedData.timeWalkedGraph
                    self.distanceSummary = storedData.distanceSummary
                    // self.activities = storedData.activities ?? []
                    
                    // Update local cache
                    let key = "activity_store_data_\(petId.uuidString)"
                    UserDefaults.standard.set(data, forKey: key)
                }
            }
        } catch {
            print(" No cloud activity state found or failed to fetch: \(error)")
        }
    }
    
    func rebuildStats() {
        let calendar = Calendar.current
        let today = Date()
        
        // 1. Recalculate Today's Walk Minutes
        let todayStart = calendar.startOfDay(for: today)
        let todaysMinutes = activities
            .filter { calendar.isDate($0.date, inSameDayAs: todayStart) }
            .reduce(0) { $0 + $1.durationMinutes }
        self.walkActivity.currentMinutes = todaysMinutes
        
        // 2. Recalculate current week's Time Walked Graph (MON - SUN)
        var weekComps = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today)
        weekComps.weekday = 2 // Monday
        guard let monday = calendar.date(from: weekComps) else { return }
        
        let dayLabels = ["MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"]
        let weekDates = (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: monday) }
        
        var timeGraphData: [TimeWalkedData] = []
        var distanceWeekData: [DistanceData] = []
        
        for (idx, wDate) in weekDates.enumerated() {
            let dayLabel = dayLabels[idx]
            let dayStart = calendar.startOfDay(for: wDate)
            
            // Sum minutes & distance for this day
            let dayActivities = activities.filter { calendar.isDate($0.date, inSameDayAs: dayStart) }
            let mins = dayActivities.reduce(0) { $0 + $1.durationMinutes }
            let dist = dayActivities.reduce(0) { $0 + $1.distanceInKm }
            
            timeGraphData.append(TimeWalkedData(day: dayLabel, minutes: mins))
            distanceWeekData.append(DistanceData(date: dayStart, distanceInKm: dist))
        }
        
        self.timeWalkedGraph = TimeWalkedGraphModel(data: timeGraphData, goalMinutes: walkActivity.goalMinutes)
        
        // 3. Recalculate Current Month's Distance Data
        var distanceMonthData: [DistanceData] = []
        if let monthRange = calendar.range(of: .day, in: .month, for: today),
           let firstOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: today)) {
            
            for day in monthRange {
                if let dayDate = calendar.date(byAdding: .day, value: day - 1, to: firstOfMonth) {
                    let dayStart = calendar.startOfDay(for: dayDate)
                    let dist = activities
                        .filter { calendar.isDate($0.date, inSameDayAs: dayStart) }
                        .reduce(0) { $0 + $1.distanceInKm }
                    
                    distanceMonthData.append(DistanceData(date: dayStart, distanceInKm: dist))
                }
            }
        }
        
        // Format week range and month name
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        let startStr = formatter.string(from: monday)
        let endStr = formatter.string(from: weekDates.last ?? today)
        let weekRangeStr = "\(startStr) - \(endStr)"
        
        formatter.dateFormat = "MMMM yyyy"
        let monthNameStr = formatter.string(from: today)
        
        self.distanceSummary = DistanceSummaryModel(
            weekData: distanceWeekData,
            monthData: distanceMonthData,
            weekRange: weekRangeStr,
            monthName: monthNameStr
        )
    }
    
    private func saveActivitiesLocally(for petId: UUID) {
        let walksKey = "walk_activities_\(petId.uuidString)"
        if let encoded = try? JSONEncoder().encode(activities) {
            UserDefaults.standard.set(encoded, forKey: walksKey)
        }
    }
    
    private func uploadWalkActivityToSupabase(_ activity: Activity, for petId: UUID) async {
        do {
            let session = try await SupabaseConfig.client.auth.session
            let ownerId = session.user.id.uuidString.lowercased()
            
            let record = DBActivityRecord(
                id: activity.id,
                pet_id: petId,
                owner_id: ownerId,
                duration_minutes: activity.durationMinutes,
                distance_km: activity.distanceInKm,
                date: activity.date,
                route_points: activity.routePoints
            )
            
            try await SupabaseConfig.client
                .from("walk_activities")
                .insert(record)
                .execute()
            print("Successfully uploaded walk activity \(activity.id) to Supabase")
        } catch {
            print("Failed to upload walk activity to Supabase: \(error)")
        }
    }
    
    private func fetchWalksFromSupabase(for petId: UUID) async {
        do {
            let fetched: [DBActivityRecord] = try await SupabaseConfig.client
                .from("walk_activities")
                .select()
                .eq("pet_id", value: petId.uuidString)
                .order("date", ascending: false)
                .execute()
                .value
            
            await MainActor.run {
                self.activities = fetched.map { rec in
                    Activity(
                        id: rec.id,
                        date: rec.date,
                        routePoints: rec.route_points,
                        distanceInKm: rec.distance_km,
                        durationMinutes: rec.duration_minutes
                    )
                }
                // Update local cache
                saveActivitiesLocally(for: petId)
                rebuildStats()
                print("Successfully fetched \(self.activities.count) walk activities from Supabase")
            }
        } catch {
            print("Failed to fetch walk activities from Supabase: \(error)")
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
        accumulatedSeconds = 0
        walkStartTime = Date()
        elapsedSeconds = 0
        locationManager.requestPermission()
        locationManager.startTracking()
        startTimer()
    }

    func stopWalk() {
        walkTimer?.invalidate()
        walkTimer = nil
        locationManager.stopTracking()

        if let start = walkStartTime {
            elapsedSeconds = accumulatedSeconds + Date().timeIntervalSince(start)
        } else {
            elapsedSeconds = accumulatedSeconds
        }
        
        let walkedMinutes = Int(elapsedSeconds / 60)
        
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
        
        isWalking = false
        isPaused = false
        elapsedSeconds = 0
        accumulatedSeconds = 0
        walkStartTime = nil
        locationManager.totalDistance = 0
        
        rebuildStats()
        saveData(for: activePetId)
        
        if let activePetId {
            saveActivitiesLocally(for: activePetId)
            Task {
                await uploadWalkActivityToSupabase(newActivity, for: activePetId)
            }
        }
    }

    func togglePause() {
        isPaused.toggle()
        if isPaused {
            walkTimer?.invalidate()
            walkTimer = nil
            locationManager.stopTracking()
            if let start = walkStartTime {
                accumulatedSeconds += Date().timeIntervalSince(start)
            }
            walkStartTime = nil
            elapsedSeconds = accumulatedSeconds
        } else {
            locationManager.startTracking()
            walkStartTime = Date()
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
        walkTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
            guard let self else { return }
            self.updateElapsedSeconds()
        }
    }

    private func updateElapsedSeconds() {
        guard isWalking, !isPaused, let walkStartTime else { return }
        self.elapsedSeconds = self.accumulatedSeconds + Date().timeIntervalSince(walkStartTime)
    }
}
