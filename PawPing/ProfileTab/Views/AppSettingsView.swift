//
//  AppSettingsView.swift
//  PawPing
//
//  Created by Antigravity on 26/06/25.
//

import SwiftUI
import UserNotifications

struct AppSettingsView: View {
    @Environment(PetStore.self) var petStore
    @Environment(ActivityStore.self) var activityStore
    @Environment(AuthStore.self) var authStore
    
    @State private var mealTimingSettings = MealTimingSettings.load()
    @State private var editingMealType: MealType? = nil
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                // Info Header Card
                VStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(Color.teal.opacity(0.15))
                            .frame(width: 60, height: 60)
                        
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(.teal)
                    }
                    
                    Text("App Settings")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(Color.textPrimary)
                    
                    Text("Configure your pet's schedule, meal timings, and general application preferences.")
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
                
                // Meal Timing Section
                VStack(alignment: .leading, spacing: 16) {
                    Text("Meal Schedule")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(Color.textPrimary)
                    
                    VStack(spacing: 0) {
                        mealTimeRow(mealType: .breakfast, icon: "sun.max.fill", iconColor: .orange)
                        Divider().padding(.leading, 76)
                        mealTimeRow(mealType: .lunch, icon: "sun.haze.fill", iconColor: .yellow)
                        Divider().padding(.leading, 76)
                        mealTimeRow(mealType: .dinner, icon: "moon.stars.fill", iconColor: .indigo)
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
        .navigationTitle("App Settings")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            loadSettings()
        }
        .sheet(item: $editingMealType) { mealType in
            MealTimePickerSheet(
                mealType: mealType,
                currentDate: mealTimingSettings.date(for: mealType)
            ) { newDate in
                mealTimingSettings.update(for: mealType, from: newDate)
                
                // Update ActivityStore's meal list
                activityStore.updateMealTimings(with: mealTimingSettings)
                
                // Update settings in Supabase profile and local user-scoped cache
                Task {
                    await petStore.updateMealTimingSettings(mealTimingSettings)
                }
                
                // Reschedule meal notifications with new timing
                let mealReminders = UserDefaults.standard.object(forKey: "pawping_notif_meals") as? Bool ?? true
                Task {
                    await NotificationManager.shared.cancelReminders(withPrefix: "meal_")
                    if mealReminders {
                        if let pet = petStore.activePet {
                            await NotificationManager.shared.scheduleMealReminders(
                                petName: pet.name,
                                petId: pet.id,
                                timing: mealTimingSettings
                            )
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Meal Time Row
    
    private func mealTimeRow(mealType: MealType, icon: String, iconColor: Color) -> some View {
        Button {
            editingMealType = mealType
        } label: {
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
                    Text(mealType.rawValue)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Color.textPrimary)
                    Text("Reminder at \(mealTimingSettings.displayTime(for: mealType))")
                        .font(.system(size: 12))
                        .foregroundStyle(.gray)
                }
                
                Spacer()
                
                Text(mealTimingSettings.displayTime(for: mealType))
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.homePurple)
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.gray.opacity(0.5))
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Helpers
    
    private func loadSettings() {
        let userId = authStore.appState?.currentUserId
        mealTimingSettings = MealTimingSettings.load(for: userId)
    }
}

#Preview {
    NavigationStack {
        AppSettingsView()
            .environment(PetStore())
            .environment(ActivityStore())
            .environment(AuthStore())
    }
}
