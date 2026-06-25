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
    var onTapRecord: ((HealthRecord) -> Void)? = nil
    
    struct HeroCardItem: Identifiable {
        let id: String
        let title: String
        let recordName: String
        let recordDate: Date?
        let iconName: String
        let accentColor: Color
        let bottomMessage: String
        let associatedRecord: HealthRecord?
    }
    
    private var cardItems: [HeroCardItem] {
        var items: [HeroCardItem] = []
        
        // 1. Overdue records sorted by date
        let sortedOverdue = overdueRecords.sorted { ($0.nextDoseDate ?? Date()) < ($1.nextDoseDate ?? Date()) }
        for record in sortedOverdue {
            items.append(HeroCardItem(
                id: record.id.uuidString,
                title: "Overdue",
                recordName: record.name,
                recordDate: record.nextDoseDate,
                iconName: "syringe.fill",
                accentColor: .red,
                bottomMessage: "Please schedule this vaccine as soon as possible.",
                associatedRecord: record
            ))
        }
        
        // 2. Upcoming records sorted by date
        let sortedUpcoming = upcomingRecords.sorted { ($0.nextDoseDate ?? Date()) < ($1.nextDoseDate ?? Date()) }
        for record in sortedUpcoming {
            items.append(HeroCardItem(
                id: record.id.uuidString,
                title: "Upcoming",
                recordName: record.name,
                recordDate: record.nextDoseDate,
                iconName: "syringe.fill",
                accentColor: Color.homePurple,
                bottomMessage: "Keep it up! We'll remind you before it's due.",
                associatedRecord: record
            ))
        }
        
        // 3. Fallback to Protected if empty
        if items.isEmpty {
            items.append(HeroCardItem(
                id: "protected",
                title: "Protected",
                recordName: "All Caught Up!",
                recordDate: nil,
                iconName: "shield.fill",
                accentColor: .green,
                bottomMessage: "Great job keeping \(petName) healthy.",
                associatedRecord: nil
            ))
        }
        
        return items
    }
    
    var body: some View {
        let items = cardItems
        if items.count > 1 {
            TabView {
                ForEach(items) { item in
                    Button {
                        if let record = item.associatedRecord {
                            onTapRecord?(record)
                        }
                    } label: {
                        heroCardBase(item: item)
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, 4)
                    .padding(.bottom, 36) // space for page indicators
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .frame(height: 190)
            .onAppear {
                UIPageControl.appearance().currentPageIndicatorTintColor = UIColor(Color.homePurple)
                UIPageControl.appearance().pageIndicatorTintColor = UIColor.gray.withAlphaComponent(0.3)
            }
        } else if let first = items.first {
            Button {
                if let record = first.associatedRecord {
                    onTapRecord?(record)
                }
            } label: {
                heroCardBase(item: first)
            }
            .buttonStyle(.plain)
        }
    }
    
    @ViewBuilder
    private func heroCardBase(item: HeroCardItem) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            // Top Section
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.title)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(item.accentColor)
                    
                    Text(item.recordName)
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(Color.textPrimary)
                        .lineLimit(1)
                    
                    if let recordDate = item.recordDate {
                        HStack(spacing: 6) {
                            Image(systemName: "calendar")
                                .font(.system(size: 13))
                            Text(recordDate.formatted(.dateTime.day().month(.wide).year()))
                                .font(.system(size: 13))
                        }
                        .foregroundStyle(.gray)
                        .padding(.top, 2)
                    } else {
                        Color.clear.frame(height: 18)
                    }
                }
                
                Spacer()
                
                ZStack {
                    Circle()
                        .fill(item.accentColor)
                        .frame(width: 56, height: 56)
                    
                    Image(systemName: item.iconName)
                        .font(.system(size: 26))
                        .foregroundStyle(.white)
                        .rotationEffect(.degrees(item.iconName == "syringe.fill" ? -45 : 0))
                }
            }
            
            Spacer(minLength: 0)
            
            if !item.bottomMessage.isEmpty {
                Divider()
                    .background(Color.gray.opacity(0.1))
                    .padding(.vertical, 10)
                
                Text(item.bottomMessage)
                    .font(.system(size: 13))
                    .foregroundStyle(Color.textPrimary)
                    .fontWeight(.medium)
                    .lineLimit(2)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .frame(height: 154)
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
