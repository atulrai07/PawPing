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
    
    // MARK: - Cancellation
    func cancelReminders(for id: UUID) async {
        let center = UNUserNotificationCenter.current()
        let requests = await center.pendingNotificationRequests()
        let identifiersToCancel = requests.filter { $0.identifier.contains(id.uuidString) }.map { $0.identifier }
        center.removePendingNotificationRequests(withIdentifiers: identifiersToCancel)
    }
}
