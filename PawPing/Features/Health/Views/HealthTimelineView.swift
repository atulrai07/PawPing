//
//  HealthTimelineView.swift
//  PawPing
//

import SwiftUI

struct HealthTimelineView: View {
    var events: [TimelineEvent]
    var limit: Int? = nil
    
    var sortedEvents: [TimelineEvent] {
        var sorted = events.sorted { $0.eventDate < $1.eventDate }
        if let limit = limit {
            sorted = Array(sorted.suffix(limit))
        }
        return sorted
    }
    
    var body: some View {
        if events.isEmpty {
            ContentUnavailableView("No Health Events", systemImage: "clock.arrow.circlepath", description: Text("Your pet's health journey will appear here."))
        } else {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 0) {
                    ForEach(Array(sortedEvents.enumerated()), id: \.element.id) { index, event in
                        let isLast = index == sortedEvents.count - 1
                        TimelineNodeView(event: event, isLast: isLast)
                    }
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 16)
            }
        }
    }
}

struct TimelineNodeView: View {
    let event: TimelineEvent
    let isLast: Bool
    
    // Status Logic for the UI
    // If it's done -> Completed
    // If it's upcoming and the nearest one -> Upcoming
    // Else -> Planned
    private var nodeState: NodeState {
        if event.isCompleted {
            return .completed
        } else {
            // A simple approximation: if it's overdue or within 30 days, it's Upcoming. Otherwise, Planned.
            let daysUntil = Calendar.current.dateComponents([.day], from: Date(), to: event.eventDate).day ?? 0
            if daysUntil <= 30 {
                return .upcoming
            } else {
                return .planned
            }
        }
    }
    
    var body: some View {
        HStack(spacing: 0) {
            VStack(spacing: 8) {
                // Circle Node
                ZStack {
                    Circle()
                        .fill(nodeState.fillColor)
                        .frame(width: 50, height: 50)
                        .overlay(
                            Circle()
                                .stroke(nodeState.strokeColor, lineWidth: nodeState == .completed ? 0 : 2)
                        )
                    
                    Image(systemName: nodeState.iconName)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(nodeState.iconColor)
                        .rotationEffect(.degrees(nodeState.iconName == "syringe.fill" ? -45 : 0))
                }
                
                // Labels
                VStack(spacing: 2) {
                    Text(event.title)
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(Color(hex: "1C1B1F") ?? .black)
                        .lineLimit(1)
                    
                    Text(nodeState.label)
                        .font(.system(size: 11, weight: nodeState == .upcoming ? .semibold : .regular))
                        .foregroundStyle(nodeState.labelColor)
                }
                .frame(width: 80) // Fixed width to keep alignment clean
            }
            
            // Connector Line
            if !isLast {
                Rectangle()
                    .fill(nodeState == .completed ? .green.opacity(0.3) : .gray.opacity(0.2))
                    .frame(width: 30, height: 2)
                    .padding(.bottom, 32) // Align with the center of the 50x50 circle
                    .padding(.horizontal, -10)
                    .zIndex(-1)
            }
        }
    }
    
    enum NodeState {
        case completed
        case upcoming
        case planned
        
        var fillColor: Color {
            switch self {
            case .completed: return Color.green.opacity(0.15)
            case .upcoming: return Color.white
            case .planned: return Color.white
            }
        }
        
        var strokeColor: Color {
            switch self {
            case .completed: return .clear
            case .upcoming: return Color(hex: "6E54D7") ?? .purple
            case .planned: return Color.gray.opacity(0.3)
            }
        }
        
        var iconColor: Color {
            switch self {
            case .completed: return .green
            case .upcoming: return Color(hex: "6E54D7") ?? .purple
            case .planned: return .gray
            }
        }
        
        var iconName: String {
            switch self {
            case .completed: return "checkmark"
            case .upcoming: return "syringe.fill"
            case .planned: return "syringe.fill"
            }
        }
        
        var label: String {
            switch self {
            case .completed: return "Completed"
            case .upcoming: return "Upcoming"
            case .planned: return "Planned"
            }
        }
        
        var labelColor: Color {
            switch self {
            case .completed: return .gray
            case .upcoming: return Color(hex: "6E54D7") ?? .purple
            case .planned: return .gray
            }
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
    HealthTimelineView(events: mockEvents)
        .padding()
}
