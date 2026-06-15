//
//  ActivityView.swift
//  PawPing
//

import SwiftUI

/// The main dashboard for the Activity tab.
/// Displays daily walk progress, health alerts, meal status, and weekly trends.
struct ActivityView: View {
    // MARK: - Dependencies
    @Environment(ActivityStore.self) var store
    @Environment(PetStore.self) var petStore
    @Environment(MealStore.self) var mealStore
    @Environment(HealthStore.self) var healthStore
    @Environment(DietAssistantStore.self) var dietAssistantStore

    // MARK: - Navigation State
    @State private var showWalkFlow = false
    @State private var countdownFinished = false
    @State private var showMealsLog = false
    @State private var showDistanceSummary = false
    @State private var showDietAssistant = false
    @State private var showHealthView = false
    @State private var showEmergencyGuide = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                // MARK: - Daily Walk Progress
                walkProgressCard
                
                // MARK: - Vaccine & Meals Section
                atAGlanceSection
                
                // MARK: - Diet Assistant Shortcut
                dietAssistantShortcut
                
                // MARK: - Emergency Guide Shortcut
                emergencyGuideShortcut
                
                // MARK: - Activity Trend Graph
                activityTrendSection
            }
            .padding(.top, 10)
            .padding(.bottom, 80)
            .customNavigationScroll(
                title: "Activity",
                petStore: petStore
            )
            // MARK: - Navigation Destinations
            .navigationDestination(isPresented: $showMealsLog) {
                MealLogView(store: mealStore)
            }
            .navigationDestination(isPresented: $showDistanceSummary) {
                DistanceSummaryView(store: store)
            }
            .navigationDestination(isPresented: $showDietAssistant) {
                DietAssistantView()
            }
            .navigationDestination(isPresented: $showHealthView) {
                HealthView()
            }
            .navigationDestination(isPresented: $showEmergencyGuide) {
                EmergencyGuideView()
            }
            // MARK: - Data Refresh
            .task(id: petStore.activePetId) {
                if let petId = petStore.activePetId {
                    await store.fetchWalks(for: petId)
                    await mealStore.fetchMeals(for: petId)
                }
            }
        }
        // MARK: - Modal Overlays
        .fullScreenCover(isPresented: $showWalkFlow) {
            WalkFlowContainer(
                store: store,
                petId: petStore.activePetId ?? UUID(),
                startWithTracking: countdownFinished,
                onDismiss: {
                    showWalkFlow = false
                }
            )
        }
    }
}

// MARK: - Subviews Extension
extension ActivityView {
    
    /// Top card showing the current daily walk minutes vs goal
    private var walkProgressCard: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 28)
                .fill(Color("cardBackground"))
                .frame(height: 160)

            HStack(spacing: 20) {
                CircularProgressView(progress: store.walkActivity.progress)
                    .frame(width: 100, height: 100)
                    .padding(.leading, 20)

                Spacer()

                VStack(alignment: .leading, spacing: 8) {
                    Text("Walked")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(Color("secondaryText"))
                    
                    HStack(spacing: 0) {
                        Text("\(store.walkActivity.currentMinutes)/")
                        Text("\(store.walkActivity.goalMinutes)min")
                            .foregroundStyle(Color("baseColor"))
                    }
                    .bold()
                    .font(.system(size: 28, weight: .bold))

                    if store.isWalking {
                        activeWalkButton
                    } else {
                        startWalkButton
                    }
                }
                Spacer()
            }
        }
        .frame(height: 160)
        .padding(.horizontal)
    }
    
    private var activeWalkButton: some View {
        Button {
            countdownFinished = true
            showWalkFlow = true
        } label: {
            WalkingLabel()
        }
        .padding(.top, 4)
    }
    
    private var startWalkButton: some View {
        Button {
            countdownFinished = false
            showWalkFlow = true
        } label: {
            Text("START")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(Color("baseColor"))
                .padding(.horizontal, 24)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .stroke(Color("baseColor"), lineWidth: 1.5)
                )
        }
        .padding(.top, 4)
    }
    
    /// Middle section for Vaccine and Meals cards
    private var atAGlanceSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("At a glance")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.primary)
                .padding(.horizontal)
            
            HStack(spacing: 16) {
                // Vaccine Card
                Button {
                    showHealthView = true
                } label: {
                    HealthCardView()
                }
                .buttonStyle(.plain)

                // Meals Card
                Button {
                    showMealsLog = true
                } label: {
                    MealsCardView()
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal)
        }
    }
    
    /// Quick access to the AI Diet & Health Assistant
    private var dietAssistantShortcut: some View {
        Button {
            showDietAssistant = true
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 24)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color("baseColor").opacity(0.12),
                                Color("baseColor").opacity(0.04)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(height: 95)

                HStack(spacing: 16) {
                    // Icon Container
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color("baseColor").opacity(0.15))
                        .frame(width: 78, height: 78)
                        .overlay(
                            Image(systemName: "sparkles.rectangle.stack.fill")
                                .font(.system(size: 32))
                                .foregroundStyle(Color("baseColor"))
                        )
                        .padding(.leading, 8)

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Diet Assistant")
                            .font(.system(size: 20, weight: .semibold))

                        Text("Ask nutrition & health questions")
                            .font(.system(size: 12))
                            .foregroundStyle(Color("secondaryText"))
                    }

                    Spacer()

                    Circle()
                        .fill(Color("baseColor").opacity(0.2))
                        .frame(width: 28, height: 28)
                        .overlay(
                            Image(systemName: "chevron.right")
                                .foregroundStyle(Color("baseColor"))
                                .font(.system(size: 12, weight: .bold))
                        )
                        .padding(.trailing, 12)
                }
            }
        }
        .buttonStyle(.plain)
        .padding(.horizontal)
    }
    
    /// Quick access to the Emergency SOP & First Aid guides
    private var emergencyGuideShortcut: some View {
        Button {
            showEmergencyGuide = true
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 24)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.red.opacity(0.12),
                                Color.red.opacity(0.04)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(height: 95)

                HStack(spacing: 16) {
                    // Icon Container
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.red.opacity(0.15))
                        .frame(width: 78, height: 78)
                        .overlay(
                            Image(systemName: "heart.text.square.fill")
                                .font(.system(size: 32))
                                .foregroundStyle(.red)
                        )
                        .padding(.leading, 8)

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Emergency Guide")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(.primary)

                        Text("CPR, choking, poisoning SOPs")
                            .font(.system(size: 12))
                            .foregroundStyle(Color("secondaryText"))
                    }

                    Spacer()

                    Circle()
                        .fill(Color.red.opacity(0.2))
                        .frame(width: 28, height: 28)
                        .overlay(
                            Image(systemName: "chevron.right")
                                .foregroundStyle(.red)
                                .font(.system(size: 12, weight: .bold))
                        )
                        .padding(.trailing, 12)
                }
            }
        }
        .buttonStyle(.plain)
        .padding(.horizontal)
    }
    
    /// Bottom section showing the weekly activity graph
    private var activityTrendSection: some View {
        WalkTimeGraphView(model: store.timeWalkedGraph)
            .onTapGesture {
                showDistanceSummary = true
            }
    }
}

// MARK: - Walk Flow Container (Countdown → Tracking)

private struct WalkFlowContainer: View {
    var store: ActivityStore
    var petId: UUID
    var startWithTracking: Bool
    var onDismiss: () -> Void

    @State private var showTracking: Bool

    init(store: ActivityStore, petId: UUID, startWithTracking: Bool, onDismiss: @escaping () -> Void) {
        self.store = store
        self.petId = petId
        self.startWithTracking = startWithTracking
        self.onDismiss = onDismiss
        _showTracking = State(initialValue: startWithTracking)
    }

    var body: some View {
        if showTracking {
            WalkTrackingView(store: store, petId: petId, onDismiss: onDismiss)
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

// MARK: - Animated "WALKING..." Label

private struct WalkingLabel: View {
    @State private var dotCount = 0

    private var dots: String {
        String(repeating: ".", count: dotCount + 1)
    }

    private var hiddenText: String { "WALKING..." }

    var body: some View {
        Text("WALKING\(dots)")
            .font(.system(size: 14, weight: .medium))
            .foregroundStyle(.white)
            .frame(width: textWidth(hiddenText))
            .padding(.horizontal, 24)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(Color("baseColor"))
            )
            .task {
                while !Task.isCancelled {
                    try? await Task.sleep(for: .seconds(0.5))
                    dotCount = (dotCount + 1) % 3
                }
            }
    }

    private func textWidth(_ text: String) -> CGFloat {
        let font = UIFont.systemFont(ofSize: 14, weight: .medium)
        let attributes: [NSAttributedString.Key: Any] = [.font: font]
        let size = (text as NSString).boundingRect(
            with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude),
            options: .usesLineFragmentOrigin,
            attributes: attributes,
            context: nil
        ).size
        return ceil(size.width)
    }
}
