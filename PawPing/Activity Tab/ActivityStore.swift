//
//  ActivityStore.swift
//  PawPing
//
//  Created by SidMoon on 16/03/26.
//

import Foundation

@Observable
class ActivityStore {

    var dogProfile: DogProfile
    var meals: [Meal] = []
    var vaccines: [Vaccine] = []
    var allergies: [Allergy] = []
    var walkActivity: WalkActivity
    var timeWalkedGraph: TimeWalkedGraphModel
    var distanceSummary: DistanceSummaryModel

    // MARK: - Meal & Diet Sub-Store
    var mealDietStore = MealDietStore()

    // MARK: - Walk Session (persists across view appearances)
    var isWalking: Bool = false
    var elapsedSeconds: TimeInterval = 0
    var isPaused: Bool = false
    var locationManager = LocationManager()
    private var walkTimer: Timer?

    init() {

        let sampleDogId = UUID()

        dogProfile = DogProfile(
            id: sampleDogId,
            ownerId: UUID(),
            dogName: "Buddy",
            breed: "Labrador",
            gender: .male,
            age: "2",
            weightKg: 25.0
        )

        meals = [
            Meal(
                id: UUID(),
                dogId: sampleDogId,
                icon: "sun.max",
                time: "8:00",
                meridian: "AM",
                mealType: .breakfast,
                foodType: .dryDogFood,
                quantity: 1.0,
                unit: "cup",
                calories: 350,
                isTaken: true
            ),

            Meal(
                id: UUID(),
                dogId: sampleDogId,
                icon: "sunset.fill",
                time: "12:30",
                meridian: "PM",
                mealType: .lunch,
                foodType: nil,
                isTaken: false
            ),
            
            Meal(
                id: UUID(),
                dogId: sampleDogId,
                icon: "moon",
                time: "8:30",
                meridian: "PM",
                mealType: .dinner,
                foodType: nil,
                isTaken: false
            )
        ]

        vaccines = [
            Vaccine(
                id: UUID(),
                dogId: sampleDogId,
                name: "Rabies Booster",
                givenDate: Date(),
                daysLeft: 3,
                frequency: 12,
                frequencyType: .monthly,
                vaccineNotes: "N/A"
            )
        ]

        allergies = [
            Allergy(
                id: UUID(),
                dogId: sampleDogId,
                allergyName: "Flea Dermatitis",
                allergyType: .environmental,
                allergyNotes: "N/A",
                allergen: "Gluten"
            ),

            Allergy(
                id: UUID(),
                dogId: sampleDogId,
                allergyName: "Flea Dermatitis",
                allergyType: .environmental,
                allergyNotes: "N/A",
                allergen: "Lactose"
            )
        ]

        walkActivity = WalkActivity(
            currentMinutes: 23,
            goalMinutes: 60
        )

        timeWalkedGraph = TimeWalkedGraphModel(
            data: [
                TimeWalkedData(day: "MON", minutes: 10),
                TimeWalkedData(day: "TUE", minutes: 28),
                TimeWalkedData(day: "WED", minutes: 18),
                TimeWalkedData(day: "THU", minutes: 42),
                TimeWalkedData(day: "FRI", minutes: 38),
                TimeWalkedData(day: "SAT", minutes: 0),
                TimeWalkedData(day: "SUN", minutes: 0)
            ],
            goalMinutes: 60
        )
        
        let calendar = Calendar.current
        let today = Date()
        
        // Sample week data
        var components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today)
        components.weekday = 2 // chart will start from Monday
        let monday = calendar.date(from: components)!
        
        let weekDates = (0..<7).map { calendar.date(byAdding: .day, value: $0, to: monday)! }
        let weekDistances = [0.8, 3.2, 2.1, 1.2, 2.4, 0.0, 0.5] //distances for graph in weekly walk activity
        
        var weekData: [DistanceData] = []
        for i in 0..<weekDistances.count {
            weekData.append(DistanceData(date: Array(weekDates)[i], distanceInKm: weekDistances[i]))
        }
        
        // Sample month data
        let monthDistances = [
            0, 0, 0, 0, 0, 0, 0, 1.1, 0.7, 1.3, 1.7, 1.2, 1.6, 0.6, 0, 0, 1.1, 0, 0, 0, 0, 0, 0
        ]
        
        var monthData: [DistanceData] = []
        for i in 0..<monthDistances.count {
            if let date = calendar.date(byAdding: .day, value: i - 20, to: today) {
                monthData.append(DistanceData(date: date, distanceInKm: monthDistances[i]))
            }
        }
        
        distanceSummary = DistanceSummaryModel(
            weekData: weekData,
            monthData: monthData,
            weekRange: "02-09 Sep",
            monthName: "September"
        )
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

        isWalking = false
        isPaused = false
        elapsedSeconds = 0
        locationManager.totalDistance = 0
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

    func updateMeal(type: MealType, foodType: FoodType?, quantity: Double, unit: String, ingredients: [MealIngredient], time: Date, isTaken: Bool) {
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

            // Calculate calories via MealDietStore or ingredients
            if let food = foodType {
                if food.isEstimateOnly {
                    let sum = ingredients.reduce(0) { $0 + $1.calculatedCalories }
                    meals[index].calories = sum
                } else {
                    meals[index].calories = mealDietStore.caloriesFor(food: food, quantity: quantity)
                }

                // Also persist to MealDietStore
                if isTaken {
                    mealDietStore.logMeal(
                        mealType: type,
                        foodType: food,
                        quantity: quantity,
                        unit: unit,
                        ingredients: ingredients,
                        time: timeStr,
                        meridian: meridianStr,
                        date: Date()
                    )
                }
            } else {
                meals[index].calories = 0
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
