//
//  HealthTimelineView.swift
//  PawPing
//

import SwiftUI

struct HealthTimelineView: View {
    @Environment(HealthStore.self) var healthStore
    @Environment(MedicationStore.self) var medicationStore
    
    var events: [TimelineEvent]
    var limit: Int? = nil
    
    var sortedEvents: [TimelineEvent] {
        var sorted = events.sorted { $0.eventDate > $1.eventDate }
        if let limit = limit {
            sorted = Array(sorted.prefix(limit))
        }
        return sorted
    }
    
    var body: some View {
        if events.isEmpty {
            ContentUnavailableView("No Health Events", systemImage: "clock.arrow.circlepath", description: Text("Your pet's health journey will appear here."))
        } else {
            VStack(spacing: 0) {
                ForEach(Array(sortedEvents.enumerated()), id: \.element.id) { index, event in
                    Group {
                        if event.type == .medication {
                            if let med = medicationStore.medications.first(where: { $0.id == event.id }) {
                                NavigationLink(destination: MedicationDetailView(medication: med)) {
                                    TimelineRow(event: event, isLast: index == sortedEvents.count - 1)
                                }
                            } else {
                                TimelineRow(event: event, isLast: index == sortedEvents.count - 1)
                            }
                        } else {
                            if let record = healthStore.healthRecords.first(where: { $0.id == event.id }) {
                                NavigationLink(destination: HealthRecordDetailView(record: record)) {
                                    TimelineRow(event: event, isLast: index == sortedEvents.count - 1)
                                }
                            } else {
                                TimelineRow(event: event, isLast: index == sortedEvents.count - 1)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color("cardBackground"))
                    .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 4)
            )
        }
    }
}

struct TimelineRow: View {
    let event: TimelineEvent
    let isLast: Bool
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // Icon Column
            VStack {
                ZStack {
                    Circle()
                        .fill(event.type.color.opacity(0.2))
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: event.type.iconName)
                        .foregroundStyle(event.type.color)
                        .font(.system(size: 20))
                }
                
                if !isLast {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 2)
                        .padding(.vertical, 4)
                }
            }
            
            // Content Column
            VStack(alignment: .leading, spacing: 4) {
                Text(event.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text(event.subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Text(event.eventDate, style: .date)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
            .padding(.top, 8)
            .padding(.bottom, isLast ? 16 : 8)
            
            Spacer()
            
            HStack(spacing: 10) {
                if event.isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                }
                
                Image(systemName: "chevron.right")
                    .foregroundStyle(.secondary.opacity(0.5))
                    .font(.system(size: 14, weight: .bold))
            }
            .padding(.top, 12)
        }
        .padding(.horizontal, 16)
    }
}

#Preview {
    HealthTimelineView(events: [])
}
