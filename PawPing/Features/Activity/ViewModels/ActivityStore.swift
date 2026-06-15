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

/// `ActivityStore` manages all pet activity data, including real-time walk tracking,
/// historical walk sessions, and data processing for activity graphs.
@Observable
class ActivityStore {

    // MARK: - Dependencies
    private let client = SupabaseConfig.client
    
    // MARK: - UI Models
    /// Daily progress data (e.g., "45/60 min")
    var walkActivity: WalkActivity
    /// Data for the weekly "Time Walked" bar chart
    var timeWalkedGraph: TimeWalkedGraphModel
    /// Statistical summary for distance (Week/Month)
    var distanceSummary: DistanceSummaryModel
    /// Raw list of all fetched walk sessions
    var walkSessions: [WalkSession] = []

    /// Set of dates (year, month, day) that have a recorded walk with path data
    var walkedDates: Set<DateComponents> {
        Set(walkSessions.compactMap { session in
            guard !session.routePoints.isEmpty && session.distanceMetres > 0 else { return nil }
            return Calendar.current.dateComponents([.year, .month, .day], from: session.date)
        })
    }

    // MARK: - Tracking State
    /// Indicates if a walk is currently active
    var isWalking: Bool = false
    /// Precise timer for the walk duration display
    var elapsedSeconds: TimeInterval = 0
    /// Indicates if the active walk is paused
    var isPaused: Bool = false
    /// Manages GPS coordinates and distance calculations
    var locationManager = LocationManager()
    
    // MARK: - Private State
    private var walkTimer: Timer?

    // MARK: - Initialization
    init() {
        // Initialize with default/empty states
        walkActivity = WalkActivity(currentMinutes: 0, goalMinutes: 60)
        
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
        
        // Setup initial distance summary with current week dates
        let calendar = Calendar.current
        let today = Date()
        var components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today)
        components.weekday = 2 // Monday
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

    // MARK: - Data Persistence (Supabase)

    /// Fetches all walk sessions for a pet and processes them for UI display
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
            
            // 1. Update Daily Totals
            let todaySessions = sessions.filter { calendar.isDateInToday($0.date) }
            self.walkActivity.currentMinutes = todaySessions.reduce(0) { $0 + $1.durationMinutes }
            
            // 2. Update Weekly Graph Data
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
            
            // 3. Update Weekly Distance Summary
            var weekData: [DistanceData] = []
            let weekComponents = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date())
            let monday = calendar.date(from: weekComponents)!
            
            for i in 0..<7 {
                let date = calendar.date(byAdding: .day, value: i, to: monday)!
                let daySessions = sessions.filter { calendar.isDate($0.date, inSameDayAs: date) }
                let dailyKm = daySessions.reduce(0) { $0 + $1.distanceMetres } / 1000.0
                weekData.append(DistanceData(date: date, distanceInKm: dailyKm))
            }
            
            // 4. Update Last 30 Days Summary
            var monthData: [DistanceData] = []
            for i in (0..<30).reversed() {
                let date = calendar.date(byAdding: .day, value: -i, to: Date())!
                let daySessions = sessions.filter { calendar.isDate($0.date, inSameDayAs: date) }
                let dailyKm = daySessions.reduce(0) { $0 + $1.distanceMetres } / 1000.0
                monthData.append(DistanceData(date: date, distanceInKm: dailyKm))
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

    // MARK: - Walk Lifecycle Controls

    /// Initializes and starts a new walk session
    func startWalk() {
        isWalking = true
        isPaused = false
        elapsedSeconds = 0
        locationManager.requestPermission()
        locationManager.startTracking()
        startTimer()
    }

    /// Ends the current walk and saves the session to Supabase
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
                await fetchWalks(for: petId) // Refresh local state
            } catch {
                print("❌ Error saving walk: \(error)")
            }
        }
        
        // Reset local state
        isWalking = false
        isPaused = false
        elapsedSeconds = 0
        locationManager.totalDistance = 0
    }

    /// Toggles between paused and active tracking states
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

    // MARK: - Private Helpers

    /// Starts the high-precision timer for the walk dashboard
    private func startTimer() {
        walkTimer?.invalidate()
        // Using 0.01s interval for smooth UI updates (centiseconds)
        walkTimer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { [weak self] _ in
            self?.elapsedSeconds += 0.01
        }
    }
}
