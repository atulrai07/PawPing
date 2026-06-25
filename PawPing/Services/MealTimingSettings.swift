//
//  MealTimingSettings.swift
//  PawPing
//
//  Persists user-customizable meal reminder times.
//  Defaults match the app's existing meal schedule:
//  Breakfast 8:00 AM, Lunch 12:30 PM, Dinner 8:30 PM.
//

import Foundation

struct MealTimingSettings: Codable, Equatable {
    var breakfastHour: Int
    var breakfastMinute: Int
    var lunchHour: Int
    var lunchMinute: Int
    var dinnerHour: Int
    var dinnerMinute: Int
    
    static let `default` = MealTimingSettings(
        breakfastHour: 8,  breakfastMinute: 0,
        lunchHour: 12,     lunchMinute: 30,
        dinnerHour: 20,    dinnerMinute: 30
    )
    
    // MARK: - Display Helpers
    
    func displayTime(for mealType: MealType) -> String {
        let (hour, minute) = components(for: mealType)
        let period = hour >= 12 ? "PM" : "AM"
        let displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour)
        return String(format: "%d:%02d", displayHour, minute) + " " + period
    }
    
    func timeString(for mealType: MealType) -> String {
        let (hour, minute) = components(for: mealType)
        let displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour)
        return String(format: "%d:%02d", displayHour, minute)
    }
    
    func meridian(for mealType: MealType) -> String {
        let (hour, _) = components(for: mealType)
        return hour >= 12 ? "PM" : "AM"
    }
    
    func date(for mealType: MealType) -> Date {
        let (hour, minute) = components(for: mealType)
        var comps = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        comps.hour = hour
        comps.minute = minute
        return Calendar.current.date(from: comps) ?? Date()
    }
    
    mutating func update(for mealType: MealType, from date: Date) {
        let comps = Calendar.current.dateComponents([.hour, .minute], from: date)
        let hour = comps.hour ?? 0
        let minute = comps.minute ?? 0
        
        switch mealType {
        case .breakfast:
            breakfastHour = hour
            breakfastMinute = minute
        case .lunch:
            lunchHour = hour
            lunchMinute = minute
        case .dinner:
            dinnerHour = hour
            dinnerMinute = minute
        }
    }
    
    func components(for mealType: MealType) -> (hour: Int, minute: Int) {
        switch mealType {
        case .breakfast: return (breakfastHour, breakfastMinute)
        case .lunch:     return (lunchHour, lunchMinute)
        case .dinner:    return (dinnerHour, dinnerMinute)
        }
    }
    
    // MARK: - Persistence
    
    private static func key(for userId: String?) -> String {
        if let userId = userId, !userId.isEmpty {
            return "pawping_meal_timing_settings_\(userId.lowercased())"
        }
        return "pawping_meal_timing_settings"
    }
    
    func save() {
        save(for: nil)
    }
    
    func save(for userId: String?) {
        if let data = try? JSONEncoder().encode(self) {
            UserDefaults.standard.set(data, forKey: Self.key(for: userId))
        }
    }
    
    static func load() -> MealTimingSettings {
        load(for: nil)
    }
    
    static func load(for userId: String?) -> MealTimingSettings {
        guard let data = UserDefaults.standard.data(forKey: key(for: userId)),
              let settings = try? JSONDecoder().decode(MealTimingSettings.self, from: data)
        else { return .default }
        return settings
    }
}
