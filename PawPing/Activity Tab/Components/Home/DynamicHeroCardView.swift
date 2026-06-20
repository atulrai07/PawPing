//
//  DynamicHeroCardView.swift
//  PawPing
//

import SwiftUI

struct DynamicHeroCardView: View {
    @Environment(ActivityStore.self) var activityStore
    @Environment(MedicationStore.self) var medicationStore
    @Environment(HealthStore.self) var healthStore
    @Environment(PetStore.self) var petStore
    
    @State private var showWalkFlow = false
    @State private var showMealsLog = false
    @State private var showMedications = false
    @State private var showVaccines = false
    
    var body: some View {
        Group {
            let priority = computePriority()
            
            switch priority {
            case .walkDueSoon:
                heroCard(
                    title: "Time for a Walk",
                    subtitle: "\(petStore.activePet?.name ?? "Your pet") needs \(activityStore.walkActivity.goalMinutes) min of activity today.",
                    statusText: "Due now",
                    statusIcon: "clock",
                    statusColor: Color(hex: "E06722") ?? .orange,
                    buttonTitle: "Start Walk",
                    iconName: "pawprint.fill",
                    imageName: "walkCard_Image",
                    action: { showWalkFlow = true }
                )
                
            case .mealDueSoon(let meal):
                heroCard(
                    title: "\(meal.mealType.rawValue) Time",
                    subtitle: "Scheduled for \(meal.time) \(meal.meridian)\n\(petStore.activePet?.name ?? "Your pet") is waiting for their meal ❤️",
                    statusText: "Due soon",
                    statusIcon: "clock",
                    statusColor: .orange,
                    buttonTitle: "Feed \(petStore.activePet?.name ?? "Pet")",
                    iconName: "dog.fill", // Changed from bowl to dog icon since bowl isn't standard SF Symbol
                    imageName: "foodCard_Image",
                    action: { showMealsLog = true }
                )
                
            case .overdueMedication(let med):
                heroCard(
                    title: "Medication Overdue",
                    subtitle: "\(petStore.activePet?.name ?? "Your pet") missed their \(med.name).",
                    statusText: "Overdue",
                    statusIcon: "exclamationmark.circle",
                    statusColor: .red,
                    buttonTitle: "Mark as Given",
                    iconName: "pills.fill",
                    imageName: "foodCard_Image", // Placeholder if no med image
                    action: { showMedications = true }
                )
                
            case .medicationDueToday(let med):
                heroCard(
                    title: "Medication Reminder",
                    subtitle: "\(petStore.activePet?.name ?? "Your pet") needs their \(med.name).",
                    statusText: "Due today",
                    statusIcon: "clock",
                    statusColor: .orange,
                    buttonTitle: "Mark as Given",
                    iconName: "pills.fill",
                    imageName: "foodCard_Image", // Placeholder
                    action: { showMedications = true }
                )
                
            case .vaccineDue(let record):
                heroCard(
                    title: "Vaccine Reminder",
                    subtitle: "\(record.name) is due soon.",
                    statusText: "Upcoming",
                    statusIcon: "calendar",
                    statusColor: .homePurple,
                    buttonTitle: "View Vaccine",
                    iconName: "syringe.fill",
                    imageName: "walkCard_Image", // Placeholder
                    action: { showVaccines = true }
                )
                
            case .allCompleted:
                heroCard(
                    title: "Great job!",
                    subtitle: "\(petStore.activePet?.name ?? "Your pet") has completed today's care activities.",
                    statusText: "All done",
                    statusIcon: "checkmark.circle.fill",
                    statusColor: .green,
                    buttonTitle: "View Profile",
                    iconName: "star.fill",
                    imageName: "walkCard_Image",
                    action: { } // Action handled externally or just no-op
                )
            }
        }
        .fullScreenCover(isPresented: $showWalkFlow) {
            WalkFlowContainer(store: activityStore, startWithTracking: activityStore.isWalking, onDismiss: { showWalkFlow = false })
        }
        .navigationDestination(isPresented: $showMealsLog) {
            MealLogView(store: activityStore)
        }
    }
    
    // MARK: - Priority Engine
    
    enum CarePriority {
        case overdueMedication(Medication)
        case medicationDueToday(Medication)
        case mealDueSoon(Meal)
        case walkDueSoon
        case vaccineDue(HealthRecord)
        case allCompleted
    }
    
    private func computePriority() -> CarePriority {
        let activeId = petStore.activePetId ?? UUID()
        let now = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        
        // 1: Walk (Highest Priority)
        if activityStore.walkActivity.currentMinutes < activityStore.walkActivity.goalMinutes {
            return .walkDueSoon
        }
        
        // 2 & 3: Medications
        let meds = medicationStore.medications(for: activeId).filter { $0.isActive(on: now) }
        var dueMeds: [Medication] = []
        var overdueMeds: [Medication] = []
        
        for med in meds {
            let slots = med.doseSlots(for: now)
            for slot in slots where slot.completedDate == nil {
                if slot.time == "As Needed" { continue }
                if let slotDate = formatter.date(from: slot.time) {
                    // Combine today's date with slot's time
                    let calendar = Calendar.current
                    var comps = calendar.dateComponents([.year, .month, .day], from: now)
                    let timeComps = calendar.dateComponents([.hour, .minute], from: slotDate)
                    comps.hour = timeComps.hour
                    comps.minute = timeComps.minute
                    
                    if let fullSlotDate = calendar.date(from: comps) {
                        if fullSlotDate < now {
                            overdueMeds.append(med)
                        } else {
                            dueMeds.append(med)
                        }
                    }
                }
            }
        }
        
        if let firstOverdue = overdueMeds.first {
            return .overdueMedication(firstOverdue)
        }
        if let firstDue = dueMeds.first {
            return .medicationDueToday(firstDue)
        }
        
        // 4: Meals
        // Find first meal today not taken
        if let nextMeal = activityStore.meals.sorted(by: { m1, m2 in
            let t1 = formatter.date(from: "\(m1.time) \(m1.meridian)") ?? Date.distantFuture
            let t2 = formatter.date(from: "\(m2.time) \(m2.meridian)") ?? Date.distantFuture
            return t1 < t2
        }).first(where: { !$0.isTaken }) {
            return .mealDueSoon(nextMeal)
        }
        
        // 4: Walk
        if activityStore.walkActivity.currentMinutes < activityStore.walkActivity.goalMinutes {
            return .walkDueSoon
        }
        
        // 5: Vaccine
        let upcomingVaccines = healthStore.healthRecords.filter { record in
            guard record.status == .upcoming || record.status == .overdue, let nextDate = record.nextDoseDate else { return false }
            let daysUntil = Calendar.current.dateComponents([.day], from: now, to: nextDate).day ?? 0
            return daysUntil <= 7
        }.sorted { ($0.nextDoseDate ?? Date.distantFuture) < ($1.nextDoseDate ?? Date.distantFuture) }
        
        if let nextVaccine = upcomingVaccines.first {
            return .vaccineDue(nextVaccine)
        }
        
        // 7: All Completed
        return .allCompleted
    }
    
    // MARK: - UI Components
    
    @ViewBuilder
    private func heroCard(
        title: String,
        subtitle: String,
        statusText: String,
        statusIcon: String,
        statusColor: Color,
        buttonTitle: String,
        iconName: String,
        imageName: String,
        action: @escaping () -> Void
    ) -> some View {
        ZStack {
            // Background Base Color
            Color(hex: "FCF6F0") ?? .white
            
            // Image with fade effect
            GeometryReader { geo in
                HStack(spacing: 0) {
                    Spacer()
                    Image(imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: geo.size.width * 0.75, height: geo.size.height, alignment: .bottomTrailing)
                        .clipped()
                        .mask(
                            LinearGradient(
                                stops: [
                                    .init(color: .clear, location: 0.0),
                                    .init(color: .black.opacity(0.6), location: 0.25),
                                    .init(color: .black, location: 0.55)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                }
            }
            
            // Left Content Overlay
            HStack {
                VStack(alignment: .leading, spacing: 14) {
                    // Category Icon
                    Circle()
                        .fill(Color(hex: "FDE8DC") ?? Color.orange.opacity(0.15))
                        .frame(width: 44, height: 44)
                        .overlay(
                            Image(systemName: iconName)
                                .foregroundColor(Color(hex: "E06722") ?? .orange)
                                .font(.system(size: 18, weight: .bold))
                        )
                    
                    Spacer().frame(height: 2)
                    
                    Text(title)
                        .font(.system(size: 26, weight: .heavy))
                        .foregroundColor(Color(hex: "1C1B1F") ?? .black)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                    
                    Text(subtitle)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor((Color(hex: "1C1B1F") ?? .black).opacity(0.75))
                        .lineLimit(2)
                        .lineSpacing(4)
                        .padding(.bottom, 6)
                    
                    // Status
                    HStack(spacing: 6) {
                        Image(systemName: statusIcon)
                            .font(.system(size: 15, weight: .semibold))
                        Text(statusText)
                            .font(.system(size: 15, weight: .medium))
                    }
                    .foregroundColor(statusColor)
                    .padding(.bottom, 12)
                    
                    // CTA Button
                    Button(action: action) {
                        HStack {
                            Text(buttonTitle)
                                .font(.system(size: 15, weight: .bold))
                            Image(systemName: "chevron.right")
                                .font(.system(size: 13, weight: .bold))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 28)
                        .padding(.vertical, 14)
                        .background(Color(hex: "EA7230") ?? .orange)
                        .clipShape(Capsule())
                    }
                }
                .padding(.leading, 24)
                .padding(.vertical, 32)
                
                Spacer()
            }
        }
        .frame(height: 260)
        .background(Color(hex: "FCF6F0") ?? .white)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .shadow(color: .black.opacity(0.08), radius: 15, x: 0, y: 5)
        .padding(.horizontal)
    }
}

// Shape to only round the right corners of the image
struct CustomRightCornerShape: Shape {
    var cornerRadius: CGFloat
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let tr = CGPoint(x: rect.maxX, y: rect.minY)
        let br = CGPoint(x: rect.maxX, y: rect.maxY)
        let bl = CGPoint(x: rect.minX, y: rect.maxY)
        let tl = CGPoint(x: rect.minX, y: rect.minY)
        
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX - cornerRadius, y: rect.minY))
        path.addArc(center: CGPoint(x: rect.maxX - cornerRadius, y: rect.minY + cornerRadius), radius: cornerRadius, startAngle: .degrees(-90), endAngle: .degrees(0), clockwise: false)
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - cornerRadius))
        path.addArc(center: CGPoint(x: rect.maxX - cornerRadius, y: rect.maxY - cornerRadius), radius: cornerRadius, startAngle: .degrees(0), endAngle: .degrees(90), clockwise: false)
        path.addLine(to: bl)
        path.addLine(to: tl)
        
        return path
    }
}

// Reusing WalkFlowContainer here locally for the Dynamic Hero Card since it is private in ActivityView currently,
// or we can make it accessible. I'll define a quick wrapper or we can rely on the ActivityView one.
// Let's use the one in ActivityView by lifting it to public or re-creating it if needed.
// For now, I'll put it here.
