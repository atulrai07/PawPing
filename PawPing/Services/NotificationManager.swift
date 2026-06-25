//
//  NotificationManager.swift
//  PawPing
//

import Foundation
import UserNotifications

actor NotificationManager {
    static let shared = NotificationManager()
    
    private init() {}
    
    func requestPermission() async -> Bool {
        do {
            let options: UNAuthorizationOptions = [.alert, .sound, .badge]
            return try await UNUserNotificationCenter.current().requestAuthorization(options: options)
        } catch {
            print("Error requesting notification permission: \(error)")
            return false
        }
    }
    
    // MARK: - Medications
    func scheduleMedicationReminders(for medication: Medication) async {
        guard await requestPermission() else { return }
        
        // Simplified scheduling for demonstration
        // In a real app, we'd schedule based on frequency, start date, and end date
        // E.g., for Once Daily, schedule at 9 AM every day until end date.
        
        let content = UNMutableNotificationContent()
        content.title = "Time for \(medication.name)!"
        content.body = "Dosage: \(medication.dosage) \(medication.unit.rawValue)"
        content.sound = .default
        
        // Schedule a sample notification 10 seconds from now (for testing), or daily
        // We'll use calendar triggers for daily
        
        var dateComponents = DateComponents()
        dateComponents.hour = 9 // 9 AM
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        let request = UNNotificationRequest(identifier: "med_\(medication.id.uuidString)", content: content, trigger: trigger)
        
        do {
            try await UNUserNotificationCenter.current().add(request)
        } catch {
            print("Failed to schedule medication reminder: \(error)")
        }
    }
    
    // MARK: - Health Records (Vaccines, Deworming, Flea & Tick)
    
    /// Schedules reminders 1 day before and on the day of the nextDoseDate.
    func scheduleHealthRecordReminder(for record: HealthRecord, petName: String) async {
        guard await requestPermission() else { return }
        guard let nextDose = record.nextDoseDate else { return }
        guard !record.isCompleted else { return }
        
        let calendar = Calendar.current
        let typeName: String = {
            switch HealthRecordType(rawValue: record.type) {
            case .vaccine: return "Vaccine"
            case .deworming: return "Deworming"
            case .fleaTick: return "Tick & Flea"
            case .none: return "Health"
            }
        }()
        
        // Reminder 1: 1 day before
        if let dayBefore = calendar.date(byAdding: .day, value: -1, to: nextDose) {
            let comps = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: dayBefore)
            var triggerComps = comps
            triggerComps.hour = 9
            triggerComps.minute = 0
            
            let content = UNMutableNotificationContent()
            content.title = "Upcoming: \(record.name)"
            content.body = "\(petName)'s \(typeName.lowercased()) is due tomorrow."
            content.sound = .default
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: triggerComps, repeats: false)
            let request = UNNotificationRequest(
                identifier: "health_1d_\(record.id.uuidString)",
                content: content,
                trigger: trigger
            )
            
            do {
                try await UNUserNotificationCenter.current().add(request)
            } catch {
                print("Failed to schedule health reminder (1d): \(error)")
            }
        }
        
        // Reminder 2: On the due date
        let dueDayComps = calendar.dateComponents([.year, .month, .day], from: nextDose)
        var triggerComps = dueDayComps
        triggerComps.hour = 9
        triggerComps.minute = 0
        
        let content = UNMutableNotificationContent()
        content.title = "Due Today: \(record.name)"
        content.body = "\(petName)'s \(typeName.lowercased()) is due today. Don't forget to visit the vet!"
        content.sound = .default
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerComps, repeats: false)
        let request = UNNotificationRequest(
            identifier: "health_0d_\(record.id.uuidString)",
            content: content,
            trigger: trigger
        )
        
        do {
            try await UNUserNotificationCenter.current().add(request)
        } catch {
            print("Failed to schedule health reminder (0d): \(error)")
        }
    }
    
    // MARK: - Meal Reminders
    
    /// Schedules 3 daily recurring notifications at the user's configured meal times.
    func scheduleMealReminders(petName: String, petId: UUID, timing: MealTimingSettings) async {
        guard await requestPermission() else { return }
        
        let meals: [(MealType, String)] = [
            (.breakfast, "Breakfast"),
            (.lunch, "Lunch"),
            (.dinner, "Dinner")
        ]
        
        for (mealType, label) in meals {
            let hour: Int
            let minute: Int
            switch mealType {
            case .breakfast: hour = timing.breakfastHour; minute = timing.breakfastMinute
            case .lunch: hour = timing.lunchHour; minute = timing.lunchMinute
            case .dinner: hour = timing.dinnerHour; minute = timing.dinnerMinute
            }
            
            let content = UNMutableNotificationContent()
            content.title = "Time for \(petName)'s \(label)! 🍽️"
            content.body = "Don't forget to log the meal in PawPing."
            content.sound = .default
            
            var dateComponents = DateComponents()
            dateComponents.hour = hour
            dateComponents.minute = minute
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            let request = UNNotificationRequest(
                identifier: "meal_\(petId.uuidString)_\(mealType.rawValue.lowercased())",
                content: content,
                trigger: trigger
            )
            
            do {
                try await UNUserNotificationCenter.current().add(request)
            } catch {
                print("Failed to schedule meal reminder for \(label): \(error)")
            }
        }
    }
    
    // MARK: - Walk Reminders
    
    /// Schedules two walk reminders:
    /// 1. Morning at 7:00 AM — general encouragement.
    /// 2. Evening at 6:00 PM — only triggers daily (the app can't conditionally suppress,
    ///    so the message is phrased as a gentle goal check).
    func scheduleWalkReminders(petName: String, petId: UUID) async {
        guard await requestPermission() else { return }
        
        // Morning reminder — 7:00 AM daily
        let morningContent = UNMutableNotificationContent()
        morningContent.title = "Walk time! 🐾"
        morningContent.body = "\(petName) is waiting for today's walk. Let's hit the goal!"
        morningContent.sound = .default
        
        var morningComps = DateComponents()
        morningComps.hour = 7
        morningComps.minute = 0
        
        let morningTrigger = UNCalendarNotificationTrigger(dateMatching: morningComps, repeats: true)
        let morningRequest = UNNotificationRequest(
            identifier: "walk_morning_\(petId.uuidString)",
            content: morningContent,
            trigger: morningTrigger
        )
        
        do {
            try await UNUserNotificationCenter.current().add(morningRequest)
        } catch {
            print("Failed to schedule morning walk reminder: \(error)")
        }
        
        // Evening reminder — 6:00 PM daily
        // Since local notifications cannot check app state at fire time,
        // we schedule this daily and reschedule/cancel from the app
        // when the goal is met. The message is phrased as a gentle nudge.
        let eveningContent = UNMutableNotificationContent()
        eveningContent.title = "Evening Walk Check 🌇"
        eveningContent.body = "Has \(petName) met today's walk goal? There's still time for an evening stroll!"
        eveningContent.sound = .default
        
        var eveningComps = DateComponents()
        eveningComps.hour = 18
        eveningComps.minute = 0
        
        let eveningTrigger = UNCalendarNotificationTrigger(dateMatching: eveningComps, repeats: true)
        let eveningRequest = UNNotificationRequest(
            identifier: "walk_evening_\(petId.uuidString)",
            content: eveningContent,
            trigger: eveningTrigger
        )
        
        do {
            try await UNUserNotificationCenter.current().add(eveningRequest)
        } catch {
            print("Failed to schedule evening walk reminder: \(error)")
        }
    }
    
    /// Cancels the evening walk reminder when the user meets the goal for today.
    func cancelEveningWalkReminder(petId: UUID) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: ["walk_evening_\(petId.uuidString)"]
        )
    }
    
    /// Re-schedules the evening walk reminder (called the next day or on app launch).
    func rescheduleEveningWalkIfNeeded(petName: String, petId: UUID, goalMet: Bool) async {
        if goalMet {
            cancelEveningWalkReminder(petId: petId)
        } else {
            // Re-schedule to ensure it fires today if it was previously cancelled
            let eveningContent = UNMutableNotificationContent()
            eveningContent.title = "Evening Walk Check 🌇"
            eveningContent.body = "Has \(petName) met today's walk goal? There's still time for an evening stroll!"
            eveningContent.sound = .default
            
            var eveningComps = DateComponents()
            eveningComps.hour = 18
            eveningComps.minute = 0
            
            let eveningTrigger = UNCalendarNotificationTrigger(dateMatching: eveningComps, repeats: true)
            let eveningRequest = UNNotificationRequest(
                identifier: "walk_evening_\(petId.uuidString)",
                content: eveningContent,
                trigger: eveningTrigger
            )
            
            do {
                try await UNUserNotificationCenter.current().add(eveningRequest)
            } catch {
                print("Failed to reschedule evening walk reminder: \(error)")
            }
        }
    }
    
    // MARK: - Weight Log Reminder
    
    /// Schedules a monthly reminder on the 1st of each month at 10:00 AM.
    func scheduleWeightLogReminder(petName: String, petId: UUID) async {
        guard await requestPermission() else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "Monthly Weight Check ⚖️"
        content.body = "It's time to log \(petName)'s weight. Track trends to keep them healthy!"
        content.sound = .default
        
        var dateComponents = DateComponents()
        dateComponents.day = 1
        dateComponents.hour = 10
        dateComponents.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(
            identifier: "weight_\(petId.uuidString)",
            content: content,
            trigger: trigger
        )
        
        do {
            try await UNUserNotificationCenter.current().add(request)
        } catch {
            print("Failed to schedule weight log reminder: \(error)")
        }
    }
    
    // MARK: - Cancellation
    
    func cancelReminders(for id: UUID) async {
        let center = UNUserNotificationCenter.current()
        let requests = await center.pendingNotificationRequests()
        let identifiersToCancel = requests.filter { $0.identifier.contains(id.uuidString) }.map { $0.identifier }
        center.removePendingNotificationRequests(withIdentifiers: identifiersToCancel)
    }
    
    /// Cancels all notifications matching a given prefix.
    func cancelReminders(withPrefix prefix: String) async {
        let center = UNUserNotificationCenter.current()
        let requests = await center.pendingNotificationRequests()
        let identifiersToCancel = requests.filter { $0.identifier.hasPrefix(prefix) }.map { $0.identifier }
        center.removePendingNotificationRequests(withIdentifiers: identifiersToCancel)
    }
    
    /// Cancels all scheduled/pending and delivered notifications on the device.
    func cancelAllReminders() async {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
        center.removeAllDeliveredNotifications()
    }
}
