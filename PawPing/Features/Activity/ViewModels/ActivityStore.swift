//
//  ActivityStore.swift
//  PawPing
//
//  Created by SidMoon on 16/03/26.
//

import Foundation
import Observation
import Supabase
import CoreLocation

@Observable
class ActivityStore {

    private let client = SupabaseConfig.client
    
    // MARK: - Activity Properties
    var walkActivity: WalkActivity
    var timeWalkedGraph: TimeWalkedGraphModel
    var distanceSummary: DistanceSummaryModel
    var walkSessions: [WalkSession] = []

    // MARK: - Walk Session State
    var isWalking: Bool = false
    var elapsedSeconds: TimeInterval = 0
    var isPaused: Bool = false
    var locationManager = LocationManager()
    private var walkTimer: Timer?

    init() {
        walkActivity = WalkActivity(
            currentMinutes: 0,
            goalMinutes: 60
        )
        
        timeWalkedGraph = TimeWalkedGraphModel(
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
        
        // Default week data
        var components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today)
        components.weekday = 2
        let monday = calendar.date(from: components)!
        
        var weekData: [DistanceData] = []
        for i in 0..<7 {
            let date = calendar.date(byAdding: .day, value: i, to: monday)!
            weekData.append(DistanceData(date: date, distanceInKm: 0))
        }
        
        distanceSummary = DistanceSummaryModel(
            weekData: weekData,
            monthData: [],
            weekRange: "Current Week",
            monthName: "Current Month"
        )
    }

    // MARK: - Fetching

    @MainActor
    func fetchWalks(for petId: UUID) async {
        do {
            let sessions: [WalkSession] = try await client
                .from("walk_sessions")
                .select()
                .eq("pet_id", value: petId)
                .order("date")
                .execute()
                .value
            
            self.walkSessions = sessions
            let calendar = Calendar.current
            
            // Recalculate daily totals
            let todaySessions = sessions.filter { calendar.isDateInToday($0.date) }
            self.walkActivity.currentMinutes = todaySessions.reduce(0) { $0 + $1.durationMinutes }
            
            // Update weekly graph
            var newGraphData: [TimeWalkedData] = [
                TimeWalkedData(day: "MON", minutes: 0),
                TimeWalkedData(day: "TUE", minutes: 0),
                TimeWalkedData(day: "WED", minutes: 0),
                TimeWalkedData(day: "THU", minutes: 0),
                TimeWalkedData(day: "FRI", minutes: 0),
                TimeWalkedData(day: "SAT", minutes: 0),
                TimeWalkedData(day: "SUN", minutes: 0)
            ]
            let weekDaysShort = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"]
            for session in sessions {
                let weekdayIndex = calendar.component(.weekday, from: session.date) - 1
                let dayName = weekDaysShort[weekdayIndex]
                if let idx = newGraphData.firstIndex(where: { $0.day == dayName }) {
                    newGraphData[idx].minutes += session.durationMinutes
                }
            }
            self.timeWalkedGraph.data = newGraphData
            
            // Update Distance Summary
            var weekData: [DistanceData] = []
            let weekComponents = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date())
            let monday = calendar.date(from: weekComponents)!
            for i in 0..<7 {
                let date = calendar.date(byAdding: .day, value: i, to: monday)!
                let daySessions = sessions.filter { calendar.isDate($0.date, inSameDayAs: date) }
                weekData.append(DistanceData(date: date, distanceInKm: daySessions.reduce(0) { $0 + $1.distanceMetres } / 1000.0))
            }
            
            var monthData: [DistanceData] = []
            for i in (0..<30).reversed() {
                let date = calendar.date(byAdding: .day, value: -i, to: Date())!
                let daySessions = sessions.filter { calendar.isDate($0.date, inSameDayAs: date) }
                monthData.append(DistanceData(date: date, distanceInKm: daySessions.reduce(0) { $0 + $1.distanceMetres } / 1000.0))
            }
            
            self.distanceSummary = DistanceSummaryModel(
                weekData: weekData,
                monthData: monthData,
                weekRange: "Current Week",
                monthName: "Last 30 Days"
            )
        } catch {
            print("❌ Error fetching walks: \(error)")
        }
    }

    // MARK: - Walk Controls

    func startWalk() {
        isWalking = true
        isPaused = false
        elapsedSeconds = 0
        locationManager.requestPermission()
        locationManager.startTracking()
        startTimer()
    }

    func stopWalk(petId: UUID) {
        walkTimer?.invalidate()
        walkTimer = nil
        locationManager.stopTracking()
        let walkedMinutes = Int(elapsedSeconds / 60)
        let session = WalkSession(
            id: UUID(),
            petId: petId,
            date: Date(),
            durationMinutes: walkedMinutes,
            distanceMetres: locationManager.totalDistance,
            routePoints: locationManager.routeLocations.map { WalkPoint(latitude: $0.latitude, longitude: $0.longitude) }
        )
        Task {
            do {
                try await client.from("walk_sessions").insert(session).execute()
                await fetchWalks(for: petId)
            } catch {
                print("❌ Error saving walk: \(error)")
            }
        }
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

    private func startTimer() {
        walkTimer?.invalidate()
        walkTimer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { [weak self] _ in
            self?.elapsedSeconds += 0.01
        }
    }
}
