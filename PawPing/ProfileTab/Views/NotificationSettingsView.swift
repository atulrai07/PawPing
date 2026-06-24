//
//  NotificationSettingsView.swift
//  PawPing
//
//  Created by Atul on 24/06/26.
//

import SwiftUI
import UserNotifications

struct NotificationSettingsView: View {
    @State private var isPushEnabled = false
    @State private var medicationReminders = true
    @State private var vaccineAlerts = true
    @State private var weightReminders = false
    @State private var showPermissionDeniedAlert = false
    
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
                        Toggle(isOn: $isPushEnabled) {
                            HStack(spacing: 16) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.blue.opacity(0.1))
                                        .frame(width: 40, height: 40)
                                    Image(systemName: "app.badge.fill")
                                        .font(.system(size: 18))
                                        .foregroundStyle(.blue)
                                }
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Push Notifications")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundStyle(Color.textPrimary)
                                    Text("Master toggle for all alerts")
                                        .font(.system(size: 12))
                                        .foregroundStyle(.gray)
                                }
                            }
                        }
                        .tint(Color("baseColor"))
                        .onChange(of: isPushEnabled) { _, newValue in
                            if newValue {
                                requestNotificationPermission()
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                        
                        Divider().padding(.leading, 76)
                        
                        // Medication Toggle
                        Toggle(isOn: $medicationReminders) {
                            HStack(spacing: 16) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.orange.opacity(0.1))
                                        .frame(width: 40, height: 40)
                                    Image(systemName: "pills.fill")
                                        .font(.system(size: 18))
                                        .foregroundStyle(.orange)
                                }
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Medications")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundStyle(Color.textPrimary)
                                    Text("Reminders to give daily doses")
                                        .font(.system(size: 12))
                                        .foregroundStyle(.gray)
                                }
                            }
                        }
                        .disabled(!isPushEnabled)
                        .tint(Color("baseColor"))
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                        
                        Divider().padding(.leading, 76)
                        
                        // Vaccine Toggle
                        Toggle(isOn: $vaccineAlerts) {
                            HStack(spacing: 16) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.purple.opacity(0.1))
                                        .frame(width: 40, height: 40)
                                    Image(systemName: "syringe.fill")
                                        .font(.system(size: 18))
                                        .foregroundStyle(.purple)
                                }
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Vaccine Alerts")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundStyle(Color.textPrimary)
                                    Text("Dose and booster reminders")
                                        .font(.system(size: 12))
                                        .foregroundStyle(.gray)
                                }
                            }
                        }
                        .disabled(!isPushEnabled)
                        .tint(Color("baseColor"))
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                        
                        Divider().padding(.leading, 76)
                        
                        // Weight Tracking Toggle
                        Toggle(isOn: $weightReminders) {
                            HStack(spacing: 16) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.teal.opacity(0.1))
                                        .frame(width: 40, height: 40)
                                    Image(systemName: "scalemass.fill")
                                        .font(.system(size: 18))
                                        .foregroundStyle(.teal)
                                }
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Weight Logs")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundStyle(Color.textPrimary)
                                    Text("Reminders to log pet weight monthly")
                                        .font(.system(size: 12))
                                        .foregroundStyle(.gray)
                                }
                            }
                        }
                        .disabled(!isPushEnabled)
                        .tint(Color("baseColor"))
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
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

#Preview {
    NavigationStack {
        NotificationSettingsView()
    }
}
