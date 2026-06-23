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
                title: "Overdue",
                recordName: overdue.name,
                recordDate: overdue.nextDoseDate,
                iconName: "syringe.fill",
                accentColor: .red,
                bottomMessage: "Please schedule this vaccine as soon as possible."
            )
        } else if let upcoming = nearestUpcoming {
            // Upcoming Vaccine State (Within 30 days)
            heroCardBase(
                title: "Upcoming",
                recordName: upcoming.name,
                recordDate: upcoming.nextDoseDate,
                iconName: "syringe.fill",
                accentColor: Color.homePurple,
                bottomMessage: "Keep it up! We'll remind you before it's due."
            )
        } else {
            // Protected State (Default Experience)
            heroCardBase(
                title: "Protected",
                recordName: "All Caught Up!",
                recordDate: nil,
                iconName: "shield.fill",
                accentColor: .green,
                bottomMessage: "Great job keeping \(petName) healthy."
            )
        }
    }
    
    @ViewBuilder
    private func heroCardBase(
        title: String,
        recordName: String,
        recordDate: Date?,
        iconName: String,
        accentColor: Color,
        bottomMessage: String
    ) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            // Top Section
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(title)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(accentColor)
                    
                    Text(recordName)
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(Color.textPrimary)
                        .lineLimit(1)
                    
                    if let recordDate {
                        HStack(spacing: 6) {
                            Image(systemName: "calendar")
                                .font(.system(size: 13))
                            Text(recordDate.formatted(.dateTime.day().month(.wide).year()))
                                .font(.system(size: 13))
                        }
                        .foregroundStyle(.gray)
                        .padding(.top, 2)
                    }
                }
                
                Spacer()
                
                ZStack {
                    Circle()
                        .fill(accentColor)
                        .frame(width: 56, height: 56)
                    
                    Image(systemName: iconName)
                        .font(.system(size: 26))
                        .foregroundStyle(.white)
                        .rotationEffect(.degrees(iconName == "syringe.fill" ? -45 : 0))
                }
            }
            
            if !bottomMessage.isEmpty {
                Divider()
                    .background(Color.gray.opacity(0.1))
                
                Text(bottomMessage)
                    .font(.system(size: 14))
                    .foregroundStyle(Color.textPrimary)
                    .fontWeight(.medium)
                    .lineSpacing(2)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.cardIvory)
                .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 4)
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
