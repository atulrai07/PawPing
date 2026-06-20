//
//  VaccineHeroCard.swift
//  PawPing
//
//  Created by SidMoon on 23/03/26.
//

import SwiftUI

struct VaccineHeroCard: View {
    let petName: String
    let overdueRecords: [HealthRecord]
    let upcomingRecords: [HealthRecord]
    
    // Nearest upcoming vaccine within 30 days
    private var nearestUpcoming: HealthRecord? {
        let upcoming = upcomingRecords.sorted { ($0.nextDoseDate ?? Date()) < ($1.nextDoseDate ?? Date()) }
        if let first = upcoming.first, let nextDate = first.nextDoseDate {
            let daysUntil = Calendar.current.dateComponents([.day], from: Date(), to: nextDate).day ?? 0
            if daysUntil <= 30 {
                return first
            }
        }
        return nil
    }
    
    // Highest priority overdue vaccine
    private var primaryOverdue: HealthRecord? {
        return overdueRecords.sorted { ($0.nextDoseDate ?? Date()) < ($1.nextDoseDate ?? Date()) }.first
    }
    
    var body: some View {
        if let overdue = primaryOverdue {
            // Overdue State (Highest Priority)
            heroCardBase(
                title: "Vaccination",
                subtitle: "Action Required",
                recordName: overdue.name,
                recordDate: overdue.nextDoseDate,
                iconName: "syringe.fill",
                accentColor: .red,
                bottomMessage: "Please schedule this vaccine as soon as possible.",
                highlightValue: overdue.timeRemainingText,
                highlightLabel: "Past due"
            )
        } else if let upcoming = nearestUpcoming {
            // Upcoming Vaccine State (Within 30 days)
            heroCardBase(
                title: "Next Vaccine",
                subtitle: upcoming.type == "vaccine" ? "Vaccination" : "Deworming",
                recordName: upcoming.name,
                recordDate: upcoming.nextDoseDate,
                iconName: "syringe.fill",
                accentColor: Color(hex: "8A72F6") ?? .purple,
                bottomMessage: "Keep it up!\nWe'll remind you before\nit's due.",
                highlightValue: upcoming.timeRemainingValue,
                highlightLabel: upcoming.timeRemainingUnit
            )
        } else {
            // Protected State (Default Experience)
            heroCardBase(
                title: "All Caught Up!",
                subtitle: "Protected",
                recordName: "\(petName) is fully protected.",
                recordDate: nil,
                iconName: "shield.fill",
                accentColor: .green,
                bottomMessage: "Great job keeping \(petName) healthy.",
                highlightValue: nil,
                highlightLabel: nil
            )
        }
    }
    
    @ViewBuilder
    private func heroCardBase(
        title: String,
        subtitle: String,
        recordName: String,
        recordDate: Date?,
        iconName: String,
        accentColor: Color,
        bottomMessage: String,
        highlightValue: String?,
        highlightLabel: String?
    ) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            // Top Section
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(accentColor)
                    
                    Text(recordName)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(Color(hex: "1C1B1F") ?? .black)
                        .lineLimit(1)
                    
                    if let recordDate {
                        HStack(spacing: 6) {
                            Image(systemName: "calendar")
                                .font(.system(size: 13))
                            Text(recordDate.formatted(.dateTime.day().month(.wide).year()))
                                .font(.system(size: 13))
                        }
                        .foregroundStyle(.gray)
                        .padding(.top, 4)
                    }
                }
                
                Spacer()
                
                ZStack {
                    Circle()
                        .fill(accentColor.opacity(0.8))
                        .frame(width: 48, height: 48)
                    
                    Image(systemName: iconName)
                        .font(.system(size: 24))
                        .foregroundStyle(.white)
                        .rotationEffect(.degrees(iconName == "syringe.fill" ? -45 : 0))
                }
            }
            
            // Bottom Section (Countdown & Message)
            if highlightValue != nil || !bottomMessage.isEmpty {
                HStack(spacing: 24) {
                    if let highlightValue, let highlightLabel {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(highlightValue)
                                .font(.system(size: 28, weight: .medium))
                                .foregroundStyle(accentColor)
                            
                            Text(highlightLabel)
                                .font(.system(size: 12))
                                .foregroundStyle(.gray)
                        }
                        
                        Divider()
                            .frame(height: 36)
                    }
                    
                    Text(bottomMessage)
                        .font(.system(size: 13))
                        .foregroundStyle(Color(hex: "1C1B1F") ?? .black)
                        .fontWeight(.medium)
                        .lineSpacing(2)
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.cardIvory)
                .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.gray.opacity(0.1), lineWidth: 1)
        )
    }
}

// MARK: - Extension for time extraction
extension HealthRecord {
    var timeRemainingValue: String {
        let components = timeRemainingText.split(separator: " ")
        if let first = components.first, let value = Int(first) {
            return "\(value)"
        }
        // Fallback if formatting is weird
        if timeRemainingText == "Due today" { return "0" }
        return "1"
    }
    
    var timeRemainingUnit: String {
        let components = timeRemainingText.split(separator: " ")
        if components.count > 1 {
            let unit = components[1...].joined(separator: " ")
            return unit.replacingOccurrences(of: "left", with: "left")
        }
        if timeRemainingText == "Due today" { return "Days left" }
        return "Month left"
    }
}

#Preview {
    VStack(spacing: 20) {
        VaccineHeroCard(petName: "Luna", overdueRecords: [], upcomingRecords: [
            HealthRecord(
                id: UUID(),
                petId: UUID(),
                type: "vaccine",
                name: "Leptospirosis",
                dateGiven: Calendar.current.date(byAdding: .day, value: -300, to: Date())!,
                nextDoseDate: Calendar.current.date(byAdding: .day, value: 11, to: Date())!,
                notes: "",
                isCompleted: false
            )
        ])
    }
    .padding()
    .background(Color(.systemGray6))
}
