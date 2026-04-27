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
    @Environment(SymptomStore.self) var symptomStore

    @State private var showWalkFlow = false
    @State private var countdownFinished = false
    @State private var showMealsLog = false
    @State private var showDistanceSummary = false
    @State private var showSymptomChecker = false

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

                // MARK: - Symptom Checker Card
                Button {
                    symptomStore.reset()
                    showSymptomChecker = true
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
                                    Image(systemName: "stethoscope")
                                        .font(.system(size: 32))
                                        .foregroundStyle(Color("baseColor"))
                                )
                                .padding(.leading, 8)

                            VStack(alignment: .leading, spacing: 6) {
                                Text("Check Symptoms")
                                    .font(.system(size: 20, weight: .semibold))

                                Text("Get guidance")
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
                title: "Activity",
                petStore: petStore
            )
            .navigationDestination(isPresented: $showMealsLog) {
                MealLogView(store: store)
            }
            .navigationDestination(isPresented: $showDistanceSummary) {
                DistanceSummaryView(store: store)
            }
            .navigationDestination(isPresented: $showSymptomChecker) {
                SymptomCheckerView()
                    .environment(symptomStore)
                    .environment(store)
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
    @State private var symptomStore = SymptomStore()
    @StateObject private var authStore = AuthStore()
    @StateObject private var appState = AppState()
    
    var body: some View {
        ActivityView()
            .environment(store)
            .environment(petStore)
            .environment(symptomStore)
            .environmentObject(authStore)
            .environmentObject(appState)
    }
}

#Preview {
    ActivityViewPreviewWrapper()
}
