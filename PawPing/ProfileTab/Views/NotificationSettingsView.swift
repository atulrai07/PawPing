//
//  NotificationSettingsView.swift
//  PawPing
//
//  Created by Atul on 24/06/26.
//

import SwiftUI
import UserNotifications

struct NotificationSettingsView: View {
    @Environment(PetStore.self) var petStore
    @Environment(ActivityStore.self) var activityStore
    @Environment(AuthStore.self) var authStore

    @State private var isPushEnabled = false
    @State private var medicationReminders = true
    @State private var vaccineAlerts = true
    @State private var mealReminders = true
    @State private var walkReminders = true
    @State private var weightReminders = false
    @State private var showPermissionDeniedAlert = false
    
    // UserDefaults keys
    private let kMedication = "pawping_notif_medication"
    private let kVaccine = "pawping_notif_vaccine"
    private let kMeals = "pawping_notif_meals"
    private let kWalk = "pawping_notif_walk"
    private let kWeight = "pawping_notif_weight"
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                // Info Card
                VStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(Color.green.opacity(0.15))
                            .frame(width: 60, height: 60)
                        
                        Image(systemName: "bell.badge.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(.green)
                    }
                    
                    Text("Stay Updated")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(Color.textPrimary)
                    
                    Text("Enable notifications to receive timely reminders for your pet's vaccines, medications, and general health checkups.")
                        .font(.system(size: 13))
                        .foregroundStyle(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 16)
                }
                .padding(24)
                .frame(maxWidth: .infinity)
                .background(Color.cardIvory)
                .clipShape(RoundedRectangle(cornerRadius: 24))
                .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 4)
                
                // Settings Section
                VStack(alignment: .leading, spacing: 16) {
                    Text("Preference Settings")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(Color.textPrimary)
                    
                    VStack(spacing: 0) {
                        // Main Push Toggle
                        notificationRow(
                            icon: "app.badge.fill",
                            iconColor: .blue,
                            title: "Push Notifications",
                            subtitle: "Master toggle for all alerts",
                            isOn: $isPushEnabled,
                            isEnabled: true
                        )
                        .onChange(of: isPushEnabled) { _, newValue in
                            if newValue {
                                requestNotificationPermission()
                            }
                        }
                        
                        Divider().padding(.leading, 76)
                        
                        // Medication Toggle
                        notificationRow(
                            icon: "pills.fill",
                            iconColor: .orange,
                            title: "Medications",
                            subtitle: "Reminders to give daily doses",
                            isOn: $medicationReminders,
                            isEnabled: isPushEnabled
                        )
                        .onChange(of: medicationReminders) { _, newValue in
                            UserDefaults.standard.set(newValue, forKey: kMedication)
                        }
                        
                        Divider().padding(.leading, 76)
                        
                        // Vaccine Toggle
                        notificationRow(
                            icon: "syringe.fill",
                            iconColor: .purple,
                            title: "Vaccine Alerts",
                            subtitle: "Dose and booster reminders",
                            isOn: $vaccineAlerts,
                            isEnabled: isPushEnabled
                        )
                        .onChange(of: vaccineAlerts) { _, newValue in
                            UserDefaults.standard.set(newValue, forKey: kVaccine)
                            if !newValue {
                                Task { await NotificationManager.shared.cancelReminders(withPrefix: "health_") }
                            }
                        }
                        
                        Divider().padding(.leading, 76)
                        
                        // Meal Reminders Toggle
                        notificationRow(
                            icon: "fork.knife",
                            iconColor: .pink,
                            title: "Meal Reminders",
                            subtitle: "Reminders for feeding times",
                            isOn: $mealReminders,
                            isEnabled: isPushEnabled
                        )
                        .onChange(of: mealReminders) { _, newValue in
                            UserDefaults.standard.set(newValue, forKey: kMeals)
                            if !newValue {
                                Task { await NotificationManager.shared.cancelReminders(withPrefix: "meal_") }
                            } else {
                                if let pet = petStore.activePet {
                                    Task {
                                        let timing = MealTimingSettings.load(for: authStore.appState?.currentUserId)
                                        await NotificationManager.shared.scheduleMealReminders(
                                            petName: pet.name,
                                            petId: pet.id,
                                            timing: timing
                                        )
                                    }
                                }
                            }
                        }
                        
                        Divider().padding(.leading, 76)
                        
                        // Walk Reminders Toggle
                        notificationRow(
                            icon: "figure.walk",
                            iconColor: .green,
                            title: "Walk Reminders",
                            subtitle: "Morning & evening walk nudges",
                            isOn: $walkReminders,
                            isEnabled: isPushEnabled
                        )
                        .onChange(of: walkReminders) { _, newValue in
                            UserDefaults.standard.set(newValue, forKey: kWalk)
                            if !newValue {
                                Task { await NotificationManager.shared.cancelReminders(withPrefix: "walk_") }
                            } else {
                                if let pet = petStore.activePet {
                                    Task {
                                        await NotificationManager.shared.scheduleWalkReminders(petName: pet.name, petId: pet.id)
                                        let goalMet = activityStore.liveWalkedMinutes >= activityStore.walkActivity.goalMinutes && activityStore.walkActivity.goalMinutes > 0
                                        await NotificationManager.shared.rescheduleEveningWalkIfNeeded(
                                            petName: pet.name,
                                            petId: pet.id,
                                            goalMet: goalMet
                                        )
                                    }
                                }
                            }
                        }
                        
                        Divider().padding(.leading, 76)
                        
                        // Weight Tracking Toggle
                        notificationRow(
                            icon: "scalemass.fill",
                            iconColor: .teal,
                            title: "Weight Logs",
                            subtitle: "Reminders to log pet weight monthly",
                            isOn: $weightReminders,
                            isEnabled: isPushEnabled
                        )
                        .onChange(of: weightReminders) { _, newValue in
                            UserDefaults.standard.set(newValue, forKey: kWeight)
                            if !newValue {
                                Task { await NotificationManager.shared.cancelReminders(withPrefix: "weight_") }
                            } else {
                                if let pet = petStore.activePet {
                                    Task {
                                        await NotificationManager.shared.scheduleWeightLogReminder(petName: pet.name, petId: pet.id)
                                    }
                                }
                            }
                        }
                    }
                    .background(Color.cardIvory)
                    .clipShape(RoundedRectangle(cornerRadius: 24))
                    .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 4)
                }
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
        }
        .background(
            LinearGradient(
                colors: [.bgWarmTop, .bgWarmBottom],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
        )
        .navigationTitle("Notifications")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            checkCurrentNotificationStatus()
            loadToggleStates()
        }
        .alert("Permission Denied", isPresented: $showPermissionDeniedAlert) {
            Button("Settings") {
                if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsUrl)
                }
            }
            Button("Cancel", role: .cancel) {
                isPushEnabled = false
            }
        } message: {
            Text("Please enable notification permissions in your iOS Settings to configure alerts.")
        }
    }
    
    // MARK: - Reusable Row
    
    private func notificationRow(icon: String, iconColor: Color, title: String, subtitle: String, isOn: Binding<Bool>, isEnabled: Bool) -> some View {
        Toggle(isOn: isOn) {
            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(iconColor.opacity(0.1))
                        .frame(width: 40, height: 40)
                    Image(systemName: icon)
                        .font(.system(size: 18))
                        .foregroundStyle(iconColor)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Color.textPrimary)
                    Text(subtitle)
                        .font(.system(size: 12))
                        .foregroundStyle(.gray)
                }
            }
        }
        .disabled(!isEnabled)
        .tint(Color("baseColor"))
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }
    
    // MARK: - Helpers
    
    private func loadToggleStates() {
        medicationReminders = UserDefaults.standard.object(forKey: kMedication) as? Bool ?? true
        vaccineAlerts = UserDefaults.standard.object(forKey: kVaccine) as? Bool ?? true
        mealReminders = UserDefaults.standard.object(forKey: kMeals) as? Bool ?? true
        walkReminders = UserDefaults.standard.object(forKey: kWalk) as? Bool ?? true
        weightReminders = UserDefaults.standard.object(forKey: kWeight) as? Bool ?? false
    }
    
    private func checkCurrentNotificationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                isPushEnabled = (settings.authorizationStatus == .authorized)
            }
        }
    }
    
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
            DispatchQueue.main.async {
                if granted {
                    isPushEnabled = true
                    let generator = UINotificationFeedbackGenerator()
                    generator.notificationOccurred(.success)
                } else {
                    isPushEnabled = false
                    showPermissionDeniedAlert = true
                }
            }
        }
    }
}

// MARK: - Meal Time Picker Sheet

struct MealTimePickerSheet: View {
    let mealType: MealType
    @State var currentDate: Date
    var onSave: (Date) -> Void
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text("Set \(mealType.rawValue) Time")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(Color.textPrimary)
                    .padding(.top, 24)
                
                DatePicker(
                    "Time",
                    selection: $currentDate,
                    displayedComponents: .hourAndMinute
                )
                .datePickerStyle(.wheel)
                .labelsHidden()
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave(currentDate)
                        dismiss()
                    }
                    .fontWeight(.bold)
                }
            }
        }
        .presentationDetents([.medium])
    }
}

#Preview {
    NavigationStack {
        NotificationSettingsView()
            .environment(PetStore())
            .environment(ActivityStore())
            .environment(AuthStore())
    }
}
