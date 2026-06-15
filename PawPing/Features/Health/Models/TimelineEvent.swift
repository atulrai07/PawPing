//
//  TimelineEvent.swift
//  PawPing
//

import Foundation
import SwiftUI

/// Defines the category of a timeline event to provide consistent iconography and color.
enum TimelineEventType: Equatable {
    case vaccination
    case medication
    case preventiveCare(type: String)
    case vetVisit
    
    var iconName: String {
        switch self {
        case .vaccination: return "syringe.fill"
        case .medication: return "pills.fill"
        case .preventiveCare(let type):
            if type.lowercased().contains("flea") { return "ant.fill" }
            return "cross.case.fill"
        case .vetVisit: return "stethoscope"
        }
    }
    
    var color: Color {
        switch self {
        case .vaccination: return .blue
        case .medication: return .purple
        case .preventiveCare: return .green
        case .vetVisit: return .orange
        }
    }
}

/// A unified protocol for any event that can appear on the Health Timeline.
protocol TimelineEventProtocol: Identifiable {
    var id: UUID { get }
    var eventDate: Date { get }
    var title: String { get }
    var subtitle: String { get }
    var eventType: TimelineEventType { get }
    var isCompleted: Bool { get }
}

/// A concrete wrapper for rendering in the Timeline list without needing to know the underlying type.
struct TimelineEvent: Identifiable {
    let id: UUID
    let eventDate: Date
    let title: String
    let subtitle: String
    let type: TimelineEventType
    let isCompleted: Bool
    
    init(from protocolEvent: any TimelineEventProtocol) {
        self.id = protocolEvent.id
        self.eventDate = protocolEvent.eventDate
        self.title = protocolEvent.title
        self.subtitle = protocolEvent.subtitle
        self.type = protocolEvent.eventType
        self.isCompleted = protocolEvent.isCompleted
    }
}
