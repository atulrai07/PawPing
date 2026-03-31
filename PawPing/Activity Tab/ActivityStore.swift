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
            age: "2"
        )

        meals = [
            Meal(
                id: UUID(),
                dogId: sampleDogId,
                icon: "sun.max",
                time: "8:00",
                meridian: "AM",
                mealType: .breakfast,
                mealName: .dogFood,
                isTaken: true
            ),

            Meal(
                id: UUID(),
                dogId: sampleDogId,
                icon: "sunset.fill",
                time: "12:30",
                meridian: "PM",
                mealType: .lunch,
                mealName: .select,
                isTaken: false
            ),
            
            Meal(
                id: UUID(),
                dogId: sampleDogId,
                icon: "moon",
                time: "8:30",
                meridian: "PM",
                mealType: .dinner,
                mealName: .select,
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

    func updateMeal(type: MealType, name: MealName, time: Date, isTaken: Bool) {
        if let index = meals.firstIndex(where: { $0.mealType == type }) {
            let formatter = DateFormatter()
            formatter.dateFormat = "h:mm"
            let timeStr = formatter.string(from: time)
            
            formatter.dateFormat = "a"
            let meridianStr = formatter.string(from: time)
            
            meals[index].mealName = name
            meals[index].time = timeStr
            meals[index].meridian = meridianStr
            meals[index].isTaken = isTaken
        }
    }

    private func startTimer() {
        walkTimer?.invalidate()
        walkTimer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { [weak self] _ in
            guard let self else { return }
            self.elapsedSeconds += 0.01
        }
    }
}
