//
//  ActivityView.swift
//  PawPing
//
//  Created by Atul on 19/01/26.
//

import SwiftUI

struct ActivityView: View {
    @Environment(ActivityStore.self) var store
    @Environment(PetStore.self) var petStore
    @Environment(HealthStore.self) var healthStore
    @Environment(DietAssistantStore.self) var dietAssistantStore
    @Environment(MedicationStore.self) var medicationStore
    @Environment(AppState.self) var appState

    @State private var showWalkFlow = false
    @State private var countdownFinished = false
    @State private var showMealsLog = false
    @State private var showDistanceSummary = false
    @State private var showDietChat = false
    @State private var showEmergencyGuide = false

    var body: some View {
        NavigationStack {
            Group {
                if petStore.pets.isEmpty {
                    ContentUnavailableView(
                        "No Pets Added",
                        systemImage: "pawprint.fill",
                        description: Text("Add a pet from your Profile to start tracking activity.")
                    )
                    .navigationTitle("Home")
                } else {
                    VStack(spacing: 24) {
                        headerSection
                        heroSection
                        mealsSection
                        quickActionsSection
                        highlightsSection
                    }
                    .padding(.top, -30)
                    .padding(.bottom, 80)
                    .background(Color.white)
                    .customNavigationScroll(
                        title: "", // Removed "Home" title
                        petStore: petStore,
                        refreshAction: {
                            await petStore.fetchPets()
                            if let activeId = petStore.activePetId {
                                store.switchPet(to: petStore.activePet)
                                await healthStore.fetchVaccines(for: activeId)
                                await medicationStore.fetchMedications(for: activeId)
                            }
                        },
                        backgroundColor: .white
                    )
                    .navigationDestination(isPresented: $showMealsLog) {
                        MealLogView(store: store)
                    }
                    .navigationDestination(isPresented: $showDistanceSummary) {
                        DistanceSummaryView(store: store)
                    }
                    .navigationDestination(isPresented: $showEmergencyGuide) {
                        EmergencyGuideView()
                    }
                }
            }
        }
        .fullScreenCover(isPresented: $showWalkFlow) {
            WalkFlowContainer(
                store: store,
                startWithTracking: countdownFinished,
                onDismiss: {
                    showWalkFlow = false
                }
            )
        }
    }

    // MARK: - Header
    private var headerSection: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                let userName = appState.currentUserName.split(separator: " ").first ?? "Sarah"
                Text("Hey, \(userName)! 👋")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.homeTextGray)
                
                let petName = petStore.activePet?.name ?? "Luna"
                
                HStack(alignment: .center, spacing: 8) {
                    Text("Good morning,\n\(petName)")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.homeTextDark)
                        .lineSpacing(4)
                    
                    Image(systemName: "heart")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(.pink)
                        .padding(.top, 28) // Align with the second line
                }
            }
            
            Spacer()
        }
        .padding(.horizontal)
    }

    // MARK: - Hero Section (Today's Walk)
    private var heroSection: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24)
                .fill(LinearGradient(gradient: Gradient(colors: [Color.homeLightPurple, Color.white]), startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(height: 200) // Increased height for breathing room
            
            HStack {
                VStack(alignment: .leading, spacing: 14) { // Increased spacing
                    HStack(spacing: 8) {
                        Circle()
                            .fill(Color.homePurple.opacity(0.1))
                            .frame(width: 40, height: 40)
                            .overlay(
                                Image(systemName: "pawprint.fill")
                                    .foregroundColor(.homePurple)
                            )
                        
                        Text("Today's Walk")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.homeTextGray)
                    }
                    
                    HStack(alignment: .lastTextBaseline, spacing: 4) {
                        Text("\(store.liveWalkedMinutes)")
                            .font(.system(size: 38, weight: .bold)) // Slightly larger
                            .foregroundColor(.homePurple)
                        
                        Text("/\(store.walkActivity.goalMinutes) min")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.homeTextGray)
                    }
                    
                    // Progress Bar
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(Color.homePurple.opacity(0.2))
                                .frame(height: 8) // Slightly thicker
                            
                            let progress = min(CGFloat(store.liveWalkedMinutes) / CGFloat(max(store.walkActivity.goalMinutes, 1)), 1.0)
                            Capsule()
                                .fill(Color.homePurple)
                                .frame(width: geo.size.width * progress, height: 8)
                        }
                    }
                    .frame(height: 8)
                    .padding(.bottom, 6)
                    
                    Button {
                        countdownFinished = false
                        showWalkFlow = true
                    } label: {
                        HStack {
                            Text("Let's go!")
                            Image(systemName: "arrow.right")
                        }
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(Color.homePurple)
                        .clipShape(Capsule())
                        .shadow(color: Color.homePurple.opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                }
                .padding(.leading, 24)
                .padding(.vertical, 24) // Added vertical padding
                
                Spacer()
            }
            
            // Hero Image
            HStack {
                Spacer()
                Image("hero_dog")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 170, height: 200, alignment: .top) // Align to top to save the head, clip the legs
                    .clipped()
                    .padding(.top, 10) // Push down slightly from the absolute top boundary for breathing space
                    .mask(
                        LinearGradient(gradient: Gradient(colors: [.black, .black, .clear]), startPoint: .leading, endPoint: .trailing)
                    )
            }
        }
        .padding(.horizontal)
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
    }

    // MARK: - Meals Section
    private var mealsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Meals")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.homeTextDark)
                
                Spacer()
                
                Button {
                    showMealsLog = true
                } label: {
                    HStack(spacing: 4) {
                        Text("See full plan")
                        Image(systemName: "arrow.right")
                    }
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.homePurple)
                }
            }
            .padding(.horizontal)
            
            HStack(spacing: 12) {
                MealCardView(title: "Breakfast", time: "8:00 AM", iconName: "sun.max.fill", iconColor: .homeYellow, imageName: "bowl_pink", isCompleted: true) {
                    showMealsLog = true
                }
                MealCardView(title: "Lunch", time: "12:30 PM", iconName: "sun.min.fill", iconColor: .orange, imageName: "bowl_yellow", isCompleted: false) {
                    showMealsLog = true
                }
                MealCardView(title: "Dinner", time: "8:30 PM", iconName: "moon.fill", iconColor: .homePurple, imageName: "bowl_blue", isCompleted: false) {
                    showMealsLog = true
                }
            }
            .padding(.horizontal)
        }
    }

    // MARK: - Quick Actions Section
    private var quickActionsSection: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
            QuickActionView(title: "Health", subtitle: "Checkups & stats", iconName: "heart.text.square.fill", iconColor: .red) {
                // Navigate to Health
            }
            QuickActionView(title: "Reminders", subtitle: "Medications & more", iconName: "calendar.badge.clock", iconColor: .homePurple) {
                // Navigate to Reminders
            }
            QuickActionView(title: "Safety", subtitle: "Emergency help", iconName: "shield.fill", iconColor: .orange) {
                showEmergencyGuide = true
            }
            QuickActionView(title: "Diary", subtitle: "Notes & moments", iconName: "book.closed.fill", iconColor: .teal) {
                // Navigate to Diary
            }
        }
        .padding(.horizontal)
    }

    // MARK: - Highlights Section
    private var highlightsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Luna's Highlights")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.homeTextDark)
                
                Spacer()
                
                HStack(spacing: 4) {
                    Text("This week")
                    Image(systemName: "chevron.down")
                }
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.homeTextGray)
            }
            .padding(.horizontal)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                StatCardView(title: "Avg. Walk", value: "28", unit: "min", subtitle: "", iconName: "flame.fill", iconColor: .homeGreen, graphType: .line(Color.homeGreen))
                StatCardView(title: "Weight", value: "24.5", unit: "kg", subtitle: "", iconName: "scalemass.fill", iconColor: .homePurple, graphType: .line(Color.homePurple))
                StatCardView(title: "Hydration", value: "Great", unit: "", subtitle: "Keep it up!", iconName: "drop.fill", iconColor: .homeBlue, graphType: .bar(Color.homeBlue))
                StatCardView(title: "Mood", value: "Happy", unit: "", subtitle: "Very active", iconName: "face.smiling.fill", iconColor: .homeYellow, graphType: .bar(Color.homeYellow))
            }
            .padding(.horizontal)
        }
    }
}

// MARK: - Helper Views

struct MealCardView: View {
    let title: String
    let time: String
    let iconName: String
    let iconColor: Color
    let imageName: String
    let isCompleted: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .center, spacing: 8) {
                HStack(alignment: .top) {
                    Image(systemName: iconName)
                        .foregroundColor(iconColor)
                        .font(.system(size: 14))
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(title)
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.homeTextDark)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                        Text(time)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.homeTextGray)
                            .lineLimit(1)
                    }
                    
                    Spacer()
                    
                    Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(isCompleted ? .homePurple : .homeTextGray.opacity(0.3))
                        .font(.system(size: 18))
                }
                
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 70)
            }
            .padding(12)
            .frame(maxWidth: .infinity)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 3)
        }
        .buttonStyle(.plain)
    }
}

struct QuickActionView: View {
    let title: String
    let subtitle: String
    let iconName: String
    let iconColor: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                RoundedRectangle(cornerRadius: 12)
                    .fill(iconColor.opacity(0.1))
                    .frame(width: 44, height: 44)
                    .overlay(
                        Image(systemName: iconName)
                            .foregroundColor(iconColor)
                            .font(.system(size: 18))
                    )
                
                VStack(spacing: 2) {
                    Text(title)
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.homeTextDark)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                    Text(subtitle)
                        .font(.system(size: 9, weight: .medium))
                        .foregroundColor(.homeTextGray)
                        .multilineTextAlignment(.center)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 4)
            .frame(maxWidth: .infinity)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 2)
        }
        .buttonStyle(.plain)
    }
}

enum StatGraphType {
    case line(Color)
    case bar(Color)
}

struct StatCardView: View {
    let title: String
    let value: String
    let unit: String
    let subtitle: String
    let iconName: String
    let iconColor: Color
    let graphType: StatGraphType
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 4) {
                Image(systemName: iconName)
                    .foregroundColor(iconColor)
                    .font(.system(size: 10))
                Text(title)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.homeTextDark)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            
            HStack(alignment: .lastTextBaseline, spacing: 2) {
                Text(value)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.homeTextDark)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                if !unit.isEmpty {
                    Text(unit)
                        .font(.system(size: 9, weight: .medium))
                        .foregroundColor(.homeTextGray)
                        .lineLimit(1)
                }
            }
            
            if !subtitle.isEmpty {
                Text(subtitle)
                    .font(.system(size: 9, weight: .medium))
                    .foregroundColor(.homeTextGray)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            
            Spacer(minLength: 4)
            
            // Mock Graph
            GeometryReader { geo in
                switch graphType {
                case .line(let color):
                    Path { path in
                        path.move(to: CGPoint(x: 0, y: geo.size.height))
                        path.addLine(to: CGPoint(x: geo.size.width * 0.25, y: geo.size.height * 0.6))
                        path.addLine(to: CGPoint(x: geo.size.width * 0.5, y: geo.size.height * 0.8))
                        path.addLine(to: CGPoint(x: geo.size.width * 0.75, y: geo.size.height * 0.4))
                        path.addLine(to: CGPoint(x: geo.size.width, y: geo.size.height * 0.2))
                    }
                    .stroke(color, lineWidth: 2)
                    
                    // Dots
                    ForEach(0..<5, id: \.self) { i in
                        Circle()
                            .fill(color)
                            .frame(width: 4, height: 4)
                            .position(x: geo.size.width * CGFloat(i) * 0.25, y: i == 0 ? geo.size.height : (i == 1 ? geo.size.height * 0.6 : (i == 2 ? geo.size.height * 0.8 : (i == 3 ? geo.size.height * 0.4 : geo.size.height * 0.2))))
                    }
                case .bar(let color):
                    HStack(alignment: .bottom, spacing: 4) {
                        ForEach(0..<7, id: \.self) { i in
                            Capsule()
                                .fill(i == 6 ? color : color.opacity(0.3))
                                .frame(width: 4, height: CGFloat.random(in: geo.size.height * 0.4...geo.size.height))
                        }
                    }
                }
            }
            .frame(height: 20)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: 110)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 2)
    }
}

// MARK: - Walk Flow Container (Countdown → Tracking)

private struct WalkFlowContainer: View {
    var store: ActivityStore
    var startWithTracking: Bool
    var onDismiss: () -> Void

    @State private var showTracking: Bool

    init(store: ActivityStore, startWithTracking: Bool, onDismiss: @escaping () -> Void) {
        self.store = store
        self.startWithTracking = startWithTracking
        self.onDismiss = onDismiss
        _showTracking = State(initialValue: startWithTracking)
    }

    var body: some View {
        if showTracking {
            WalkTrackingView(store: store, onDismiss: onDismiss)
                .transition(.opacity)
        } else {
            CountdownView(
                onComplete: {
                    store.startWalk()
                    withAnimation {
                        showTracking = true
                    }
                },
                onCancel: {
                    store.isWalking = false
                    onDismiss()
                }
            )
            .transition(.opacity)
        }
    }
}

struct ActivityViewPreviewWrapper: View {
    @State private var store = ActivityStore()
    @State private var petStore = PetStore()
    @State private var healthStore = HealthStore()
    @State private var authStore = AuthStore()
    @State private var appState = AppState()
    @State private var dietAssistantStore = DietAssistantStore()
    
    var body: some View {
        ActivityView()
            .environment(store)
            .environment(petStore)
            .environment(healthStore)
            .environment(authStore)
            .environment(appState)
            .environment(dietAssistantStore)
    }
}

#Preview {
    ActivityViewPreviewWrapper()
}
