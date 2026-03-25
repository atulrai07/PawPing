//
//  ActivityStore.swift
//  PawPing
//
//  Created by SidMoon on 16/03/26.
//
//  This is the "brain" behind the Activity tab.
//  It holds all the data (meals, vaccines, walk stats, etc.) and
//  exposes methods to control a walk session (start, stop, pause).
//

import Foundation
import Observation

// @Observable is Apple's newer (iOS 17+) replacement for ObservableObject.
// Any property you change inside this class will automatically
// trigger a UI update in any SwiftUI view that reads it — no need
// for @Published or Combine. Just change the var and SwiftUI reacts.
@Observable
class ActivityStore {

    var dogProfile: DogProfile
    var meals: [Meal] = []
    var vaccines: [Vaccine] = []
    var allergies: [Allergy] = []
    var walkActivity: WalkActivity
    var timeWalkedGraph: TimeWalkedGraphModel

    // MARK: - Walk Session State
    // These persist across view appearances so if you leave the tab
    // and come back, your walk is still going.
    var isWalking: Bool = false
    var elapsedSeconds: TimeInterval = 0
    var isPaused: Bool = false
    var locationManager = LocationManager()
    private var walkTimer: Timer?

    // MARK: - Init (Mock Data)
    // Right now everything is hardcoded. When we hook up a real backend,
    // this init will be replaced with a network fetch or CoreData load.
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
                mealName: .chickenAndRice,
                isTaken: false
            ),

            Meal(
                id: UUID(),
                dogId: sampleDogId,
                icon: "moon",
                time: "8:30",
                meridian: "PM",
                mealType: .dinner,
                mealName: .eggAndRice,
                isTaken: false
            )
        ] // meals

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
        ] // vaccines

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
        ] // allergies

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
    } // init

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

        // Convert elapsed seconds into minutes and add to daily total
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

    // Fires every 10ms for a smooth stopwatch display
    private func startTimer() {
        walkTimer?.invalidate()
        walkTimer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { [weak self] _ in
            guard let self else { return }
            self.elapsedSeconds += 0.01
        }
    }
} // ActivityStore
