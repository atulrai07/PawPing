//
//  DailyTimelineView.swift
//  PawPing
//

import SwiftUI

struct DailyTimelineView: View {
    @Environment(ActivityStore.self) var activityStore
    @Environment(MedicationStore.self) var medicationStore
    @Environment(HealthStore.self) var healthStore
    @Environment(PetStore.self) var petStore
    
    @State private var showFullTimeline = false
    @State private var showWalkFlow = false
    @State private var showMealsLog = false
    @State private var showMedications = false
    
    // Derived state for the timeline
    private var timelineEvents: [DailyEvent] {
        var events: [DailyEvent] = []
        let now = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        let activeId = petStore.activePetId ?? UUID()
        
        // Meals
        for meal in activityStore.meals {
            if let time = formatter.date(from: "\(meal.time) \(meal.meridian)") {
                let status: EventStatus = meal.isTaken ? .completed : (time < now ? .overdue : (time.timeIntervalSince(now) < 7200 ? .upcoming : .future))
                
                events.append(DailyEvent(
                    id: meal.id.uuidString,
                    time: time,
                    title: "\(meal.mealType.rawValue)",
                    subtitle: "\(meal.time) \(meal.meridian) • \(status.text)",
                    status: status,
                    categoryColor: .orange,
                    categoryIcon: "dog.fill",
                    actionType: .meal
                ))
            }
        }
        
        // Walks
        let walkedMins = activityStore.walkActivity.currentMinutes
        let goalMins = activityStore.walkActivity.goalMinutes
        let morningWalkTime = Calendar.current.date(bySettingHour: 7, minute: 30, second: 0, of: now)!
        let eveningWalkTime = Calendar.current.date(bySettingHour: 18, minute: 0, second: 0, of: now)!
        
        if walkedMins >= goalMins {
            events.append(DailyEvent(id: "walk_m", time: morningWalkTime, title: "Morning Walk", subtitle: "7:30 AM • \(walkedMins / 2) min", status: .completed, categoryColor: .green, categoryIcon: "figure.walk.motion", actionType: .walk))
            events.append(DailyEvent(id: "walk_e", time: eveningWalkTime, title: "Evening Walk", subtitle: "6:00 PM • \(walkedMins / 2) min", status: .completed, categoryColor: .purple, categoryIcon: "figure.walk.motion", actionType: .walk))
        } else if walkedMins > 0 {
            events.append(DailyEvent(id: "walk_m", time: morningWalkTime, title: "Morning Walk", subtitle: "7:30 AM • \(walkedMins) min", status: .completed, categoryColor: .green, categoryIcon: "figure.walk.motion", actionType: .walk))
            events.append(DailyEvent(id: "walk_e", time: eveningWalkTime, title: "Evening Walk", subtitle: "6:00 PM • \(goalMins - walkedMins) min", status: .future, categoryColor: .purple, categoryIcon: "figure.walk.motion", actionType: .walk))
        } else {
            let mStatus: EventStatus = morningWalkTime < now ? .overdue : .upcoming
            events.append(DailyEvent(id: "walk_m", time: morningWalkTime, title: "Morning Walk", subtitle: "7:30 AM • \(goalMins / 2) min", status: mStatus, categoryColor: .green, categoryIcon: "figure.walk.motion", actionType: .walk))
            events.append(DailyEvent(id: "walk_e", time: eveningWalkTime, title: "Evening Walk", subtitle: "6:00 PM • \(goalMins / 2) min", status: .future, categoryColor: .purple, categoryIcon: "figure.walk.motion", actionType: .walk))
        }
        
        // Medications
        let meds = medicationStore.medications(for: activeId).filter { $0.isActive(on: now) }
        for med in meds {
            for slot in med.doseSlots(for: now) {
                if slot.time != "As Needed", let time = formatter.date(from: slot.time) {
                    let status: EventStatus
                    if slot.completedDate != nil {
                        status = .completed
                    } else if time < now {
                        status = .overdue
                    } else if time.timeIntervalSince(now) < 7200 {
                        status = .upcoming
                    } else {
                        status = .future
                    }
                    
                    events.append(DailyEvent(
                        id: "\(med.id)-\(slot.id)",
                        time: time,
                        title: med.name,
                        subtitle: "\(slot.time) • \(status.text)",
                        status: status,
                        categoryColor: Color(hex: "6E54D7") ?? .purple,
                        categoryIcon: "pills.fill",
                        actionType: .medication
                    ))
                }
            }
        }
        
        return Array(events.sorted { $0.time < $1.time }.prefix(4)) // Limited to 4
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Today's Timeline")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(Color(hex: "1C1B1F") ?? .black)
                
                Spacer()
                
                Button(action: { showFullTimeline = true }) {
                    HStack(spacing: 4) {
                        Text("See full day")
                        Image(systemName: "chevron.right")
                    }
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.orange)
                }
            }
            .padding(.horizontal)
            
            VStack(spacing: 0) {
                let evts = timelineEvents
                ForEach(Array(evts.enumerated()), id: \.element.id) { index, event in
                    Button(action: { handleEventTap(event) }) {
                        TimelineRowView(event: event, isLast: index == evts.count - 1)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(24)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 28))
            .shadow(color: .black.opacity(0.04), radius: 10, x: 0, y: 4)
            .padding(.horizontal)
        }
        .fullScreenCover(isPresented: $showWalkFlow) {
            WalkFlowContainer(store: activityStore, startWithTracking: activityStore.isWalking, onDismiss: { showWalkFlow = false })
        }
        .navigationDestination(isPresented: $showMealsLog) {
            MealLogView(store: activityStore)
        }
        .navigationDestination(isPresented: $showMedications) {
            MedicationListView() // Or appropriate view
        }
        .navigationDestination(isPresented: $showFullTimeline) {
            FullDailyTimelineView(events: timelineEvents)
        }
    }
    
    private func handleEventTap(_ event: DailyEvent) {
        switch event.actionType {
        case .walk: showWalkFlow = true
        case .meal: showMealsLog = true
        case .medication: showMedications = true
        }
    }
}

struct FullDailyTimelineView: View {
    let events: [DailyEvent]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                ForEach(Array(events.enumerated()), id: \.element.id) { index, event in
                    TimelineRowView(event: event, isLast: index == events.count - 1)
                }
            }
            .padding(24)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 28))
            .shadow(color: .black.opacity(0.04), radius: 10, x: 0, y: 4)
            .padding()
        }
        .background(Color("baseBackground").ignoresSafeArea())
        .navigationTitle("Today's Full Timeline")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Models

struct DailyEvent: Identifiable {
    let id: String
    let time: Date
    let title: String
    let subtitle: String
    let status: EventStatus
    let categoryColor: Color
    let categoryIcon: String
    let actionType: EventActionType
}

enum EventActionType {
    case walk
    case meal
    case medication
}

enum EventStatus {
    case completed
    case upcoming
    case overdue
    case future
    
    var text: String {
        switch self {
        case .completed: return "Completed"
        case .upcoming: return "Upcoming"
        case .overdue: return "Overdue"
        case .future: return "Upcoming"
        }
    }
}

// MARK: - Subviews

struct TimelineRowView: View {
    let event: DailyEvent
    let isLast: Bool
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // Status Indicator & Line
            VStack(spacing: 0) {
                statusIndicator(for: event.status)
                    .frame(width: 24, height: 24)
                    .background(Color.white)
                    .zIndex(1)
                
                if !isLast {
                    Line()
                        .stroke(style: StrokeStyle(lineWidth: 1, dash: [4]))
                        .foregroundColor(lineColor(for: event.status))
                        .frame(width: 1)
                        .padding(.vertical, 4)
                }
            }
            .frame(width: 24)
            
            // Category Icon
            Circle()
                .fill(event.categoryColor.opacity(0.15))
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: event.categoryIcon)
                        .font(.system(size: 18))
                        .foregroundColor(event.categoryColor)
                )
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(event.title)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(Color(hex: "1C1B1F") ?? .black)
                
                Text(event.subtitle)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(subtitleColor(for: event.status))
            }
            .padding(.top, 4)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.gray.opacity(0.5))
                .padding(.top, 14)
        }
        // Minimal height constraint to ensure line renders appropriately
        .frame(minHeight: isLast ? 40 : 70)
    }
    
    @ViewBuilder
    private func statusIndicator(for status: EventStatus) -> some View {
        switch status {
        case .completed:
            Circle()
                .fill(Color.green)
                .overlay(
                    Image(systemName: "checkmark")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white)
                )
        case .upcoming, .overdue:
            Circle()
                .stroke(Color.orange, lineWidth: 2)
                .overlay(
                    Image(systemName: "clock")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.orange)
                )
        case .future:
            Circle()
                .stroke(Color.gray.opacity(0.4), lineWidth: 2)
        }
    }
    
    private func lineColor(for status: EventStatus) -> Color {
        switch status {
        case .completed: return .green
        case .upcoming, .overdue: return .orange
        case .future: return .gray.opacity(0.4)
        }
    }
    
    private func subtitleColor(for status: EventStatus) -> Color {
        switch status {
        case .completed: return .green
        case .upcoming: return .orange
        case .overdue: return .red
        case .future: return .gray
        }
    }
}

// Line shape for dashed path
struct Line: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        return path
    }
}
