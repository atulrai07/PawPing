//
//  HealthTimelineView.swift
//  PawPing
//

import SwiftUI

struct HealthTimelineView: View {
    var events: [TimelineEvent]
    var limit: Int? = nil
    
    // Group events by Month and Year
    var groupedEvents: [(String, [TimelineEvent])] {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        
        var sorted = events.sorted { $0.eventDate > $1.eventDate }
        if let limit = limit {
            sorted = Array(sorted.prefix(limit))
        }
        
        let dict = Dictionary(grouping: sorted) { formatter.string(from: $0.eventDate) }
        
        // Sort keys to maintain chronological order (newest first)
        let sortedKeys = dict.keys.sorted { key1, key2 in
            guard let date1 = formatter.date(from: key1),
                  let date2 = formatter.date(from: key2) else { return false }
            return date1 > date2
        }
        
        return sortedKeys.map { ($0, dict[$0]!) }
    }
    
    var body: some View {
        if events.isEmpty {
            ContentUnavailableView("No Health Events", systemImage: "clock.arrow.circlepath", description: Text("Your pet's health journey will appear here."))
        } else {
            LazyVStack(spacing: 16) {
                ForEach(groupedEvents, id: \.0) { month, monthEvents in
                    Section {
                        VStack(spacing: 0) {
                            ForEach(Array(monthEvents.enumerated()), id: \.element.id) { index, event in
                                TimelineRow(event: event, isLast: index == monthEvents.count - 1)
                            }
                        }
                        .padding(.top, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color("cardBackground"))
                                .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 4)
                        )
                    } header: {
                        Text(month)
                            .font(.headline)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top, 8)
                    }
                }
            }
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
            
            if event.isCompleted {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
                    .padding(.top, 12)
            }
        }
        .padding(.horizontal, 16)
    }
}

#Preview {
    HealthTimelineView(events: [])
}
