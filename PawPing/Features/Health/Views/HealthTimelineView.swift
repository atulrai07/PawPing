//
//  HealthTimelineView.swift
//  PawPing
//
//  Created by Atul on 15/03/26.
//

import SwiftUI

struct HealthTimelineView: View {
    @Environment(HealthStore.self) var healthStore
    @Environment(MedicationStore.self) var medicationStore
    
    var events: [TimelineEvent]
    var limit: Int? = nil
    
    var sortedEvents: [TimelineEvent] {
        // Sort descending to show latest records first
        let sorted = events.sorted { $0.eventDate > $1.eventDate }
        if let limit = limit {
            return Array(sorted.prefix(limit))
        }
        return sorted
    }
    
    var body: some View {
        if events.isEmpty {
            ContentUnavailableView("No Health Events", systemImage: "clock.arrow.circlepath", description: Text("Your pet's health journey will appear here."))
        } else {
            VStack(spacing: 0) {
                ForEach(Array(sortedEvents.enumerated()), id: \.element.id) { index, event in
                    let isLast = index == sortedEvents.count - 1
                    TimelineRow(event: event, isLast: isLast)
                }
            }
        }
    }
}

struct TimelineRow: View {
    @Environment(HealthStore.self) var healthStore
    @Environment(MedicationStore.self) var medicationStore
    
    let event: TimelineEvent
    let isLast: Bool
    
    private var healthRecord: HealthRecord? {
        healthStore.healthRecords.first(where: { $0.id == event.id })
    }
    
    private var medication: Medication? {
        medicationStore.medications.first(where: { $0.id == event.id })
    }
    
    var body: some View {
        if let healthRecord = healthRecord {
            NavigationLink(destination: HealthRecordDetailView(record: healthRecord)) {
                rowContent
            }
            .buttonStyle(.plain)
        } else if let medication = medication {
            NavigationLink(destination: MedicationDetailView(medication: medication)) {
                rowContent
            }
            .buttonStyle(.plain)
        } else {
            rowContent
        }
    }
    
    private var rowContent: some View {
        HStack(alignment: .top, spacing: 16) {
            // Left Column: Circle & Line
            ZStack(alignment: .top) {
                if !isLast {
                    Rectangle()
                        .fill(Color.homePurple.opacity(0.3))
                        .frame(width: 1)
                        .padding(.top, 44) // Start drawing line from bottom of 44x44 circle
                }
                
                Circle()
                    .fill(event.type.color.opacity(0.15))
                    .frame(width: 44, height: 44)
                    .overlay(
                        Image(systemName: event.type.iconName)
                            .font(.system(size: 18))
                            .foregroundStyle(event.type.color)
                            .rotationEffect(.degrees(event.type.iconName == "syringe.fill" ? -45 : 0))
                    )
            }
            .frame(maxHeight: .infinity, alignment: .top)
            
            // Content Column
            VStack(alignment: .leading, spacing: 4) {
                Text(event.title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(Color.textPrimary)
                
                Text(event.subtitle)
                    .font(.system(size: 13))
                    .foregroundStyle(.gray)
                
                Text(event.eventDate.formatted(.dateTime.day().month(.wide).year()))
                    .font(.system(size: 12))
                    .foregroundStyle(.gray.opacity(0.8))
            }
            .padding(.bottom, 20) // Spacing between rows
            
            Spacer()
            
            // Right Column: Checkmark & Chevron
            HStack(spacing: 12) {
                if event.isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(.green)
                }
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.secondary)
            }
            .padding(.top, 12) // Align with vertical center of the 44x44 circle
        }
    }
}

#Preview {
    let mockRecords = [
        HealthRecord(id: UUID(), petId: UUID(), type: "vaccine", name: "Puppy Core", dateGiven: Date().addingTimeInterval(-86400 * 100), nextDoseDate: nil, notes: "", isCompleted: true),
        HealthRecord(id: UUID(), petId: UUID(), type: "vaccine", name: "Leptospirosis", dateGiven: Date().addingTimeInterval(-86400 * 300), nextDoseDate: Date().addingTimeInterval(86400 * 5), notes: "", isCompleted: false),
        HealthRecord(id: UUID(), petId: UUID(), type: "vaccine", name: "Booster", dateGiven: Date().addingTimeInterval(-86400 * 300), nextDoseDate: Date().addingTimeInterval(86400 * 45), notes: "", isCompleted: false)
    ]
    let mockEvents = mockRecords.map { TimelineEvent(from: $0) }
    
    let healthStore = HealthStore()
    healthStore.healthRecords = mockRecords
    
    return HealthTimelineView(events: mockEvents)
        .environment(healthStore)
        .environment(MedicationStore())
        .padding()
}
