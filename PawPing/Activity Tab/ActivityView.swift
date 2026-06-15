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

    @State private var showWalkFlow = false
    @State private var countdownFinished = false
    @State private var showMealsLog = false
    @State private var showDistanceSummary = false
    @State private var showDietChat = false
    @State private var showEmergencyGuide = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {

                // MARK: - Walked Card
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
                            
                            HStack (spacing:0){
                                Text("\(store.walkActivity.currentMinutes)/")
                                Text("\(store.walkActivity.goalMinutes)min")
                                    .foregroundStyle(Color("baseColor"))
                            }
                            .bold()
                            .font(.system(size: 28, weight: .bold))

                            if store.isWalking {
                                // reopens the tracking view (no countdown)
                                Button {
                                    countdownFinished = true
                                    showWalkFlow = true
                                } label: {
                                    WalkingLabel()
                                }
                                .padding(.top, 4)
                            } else {
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
                        }
                        Spacer()
                    }
                }
                .frame(height: 160)
                .padding(.horizontal)

                // MARK: - Vaccine & Meals Row
                HStack(spacing: 16) {
                    // Vaccine Card
                    Button {
                        // TODO: Direct navigation to Vaccine Tab
                    } label: {
                        VaccineCardView()
                    }
                    .buttonStyle(.plain)

                    // Meals Card
                    Button {
                        showMealsLog = true
                    } label: {
                        MealsCardView(store: store)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal)

                // MARK: - Diet Assistant Card
                Button {
                    showDietChat = true
                } label: {
                    HStack(spacing: 14) {
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color("baseColor").opacity(0.12))
                            .frame(width: 52, height: 52)
                            .overlay(
                                Image(systemName: "sparkles")
                                    .font(.system(size: 22))
                                    .foregroundStyle(Color("baseColor"))
                            )

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Diet & Health Assistant")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundStyle(.primary)
                            Text(chatCardSubtitle)
                                .font(.system(size: 12))
                                .foregroundStyle(Color("secondaryText"))
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(Color("secondaryText").opacity(0.4))
                    }
                    .padding(16)
                    .background(Color("cardBackground"))
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 4)
                }
                .buttonStyle(.plain)
                .padding(.horizontal)
                .sheet(isPresented: $showDietChat) {
                    DietAssistantView()
                        .environment(dietAssistantStore)
                }

                // MARK: - Emergency Guide Card
                emergencyGuideShortcut

                // MARK: - Graph Card
                Button {
                    showDistanceSummary = true
                } label: {
                    WalkTimeGraphView(model: store.timeWalkedGraph)
                }
                .buttonStyle(.plain)
            }
            .padding(.top, 10)
            .padding(.bottom, 80)
            .customNavigationScroll(
                title: "Home",
                petStore: petStore,
                refreshAction: {
                    // Pull to Refresh Logic
                    await petStore.fetchPets()
                    if let activeId = petStore.activePetId {
                        // Re-sync all stores for the active pet
                        store.switchPet(to: activeId)
                        await healthStore.fetchVaccines(for: activeId)
                    }
                }
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

    // Computed subtitle
    private var chatCardSubtitle: String {
        switch dietAssistantStore.availability {
        case .available:                 return "Ask anything about your dog's diet"
        case .unsupportedDevice:         return "Requires iPhone 15 Pro or iPhone 16"
        case .appleIntelligenceDisabled: return "Enable Apple Intelligence in Settings"
        case .modelDownloading:          return "AI model is downloading..."
        case .unknown:                   return "Currently unavailable"
        }
    }

    /// Quick access to the Emergency SOP & First Aid guides
    private var emergencyGuideShortcut: some View {
        Button {
            showEmergencyGuide = true
        } label: {
            HStack(spacing: 14) {
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.red.opacity(0.12))
                    .frame(width: 52, height: 52)
                    .overlay(
                        Image(systemName: "heart.text.square.fill")
                            .font(.system(size: 22))
                            .foregroundStyle(.red)
                    )

                VStack(alignment: .leading, spacing: 4) {
                    Text("Emergency Guide")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.primary)
                    Text("CPR, choking, poisoning SOPs")
                        .font(.system(size: 12))
                        .foregroundStyle(Color("secondaryText"))
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color("secondaryText").opacity(0.4))
            }
            .padding(16)
            .background(Color("cardBackground"))
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(.plain)
        .padding(.horizontal)
    }
}


// MARK: - Walk Flow Container (Countdown → Tracking)

private struct WalkFlowContainer: View {
    var store: ActivityStore
    var startWithTracking: Bool
    var onDismiss: () -> Void //what does this do ?

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
