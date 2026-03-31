//
//  ActivityView.swift
//  PawPing
//
//  Created by Atul on 19/01/26.
//

import SwiftUI

struct ActivityView: View {
    var store: ActivityStore

    @State private var showWalkFlow = false
    @State private var countdownFinished = false
    @State private var showProfile = false
    @State private var showMealsLog = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {

                // MARK: - Walked Card
                ZStack {
                    RoundedRectangle(cornerRadius: 34)
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
                    ZStack {
                        RoundedRectangle(cornerRadius: 34)
                            .fill(Color("cardBackground"))
                            .frame(width: 175, height: 190)
                        VStack(alignment: .leading) {
                            HStack(spacing: 15) {
                                Text("Upcoming")
                                    .font(.system(size: 22, weight: .regular))
                                Button {
                                    // workflow pending
                                } label: {
                                    Circle()
                                        .fill(Color("baseColor").opacity(0.2))
                                        .frame(width: 22, height: 22)
                                        .overlay(
                                            Image(systemName: "chevron.right")
                                                .foregroundStyle(.primary)
                                                .font(.system(size: 12))
                                        )
                                }
                            }
                            Image(systemName: "syringe")
                                .foregroundStyle(Color("baseColor"))
                                .rotationEffect(.degrees(270))
                                .font(.system(size: 65))
                            Text(store.vaccines.first?.name ?? "No vaccine")
                                .font(.system(size: 18, weight: .medium))
                            Text("\(store.vaccines.first?.daysLeft ?? 0) days left")
                                .font(.system(size: 12, weight: .semibold))
                        }
                        .frame(height: 175)
                    }

                    // Meals Card
                    Button {
                        showMealsLog = true
                    } label: {
                        MealsCardView(store: store)
                    }
                    .buttonStyle(.plain)
                }

                // MARK: - Allergies Card
                ZStack {
                    RoundedRectangle(cornerRadius: 23)
                        .fill(Color("cardBackground"))
                        .frame(width: 370, height: 95)
                    HStack(spacing: 20) {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color("secondaryCardBackground"))
                            .frame(width: 78, height: 78)
                            .overlay(
                                Image("allergiesIcon")
                                    .resizable()
                                    .frame(width: 66, height: 63)
                            )
                        VStack(alignment: .leading, spacing: 10) {
                            HStack(spacing: 130) {
                                Text("Allergies")
                                    .font(.system(size: 24, weight: .regular))
                                    .padding(.top, 5)
                                Button {
                                    // workflow pending
                                } label: {
                                    Circle()
                                        .fill(Color("baseColor").opacity(0.2))
                                        .frame(width: 22, height: 22)
                                        .overlay(
                                            Image(systemName: "chevron.right")
                                                .foregroundStyle(.primary)
                                                .font(.system(size: 12))
                                        )
                                }
                            }
                            HStack {
                                ForEach(store.allergies.prefix(3)) { allergies in
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 6)
                                            .fill(Color("baseColor"))
                                            .frame(width: 62, height: 27)
                                        RoundedRectangle(cornerRadius: 5)
                                            .fill(Color("secondaryCardBackground"))
                                            .frame(width: 60, height: 25)
                                            .overlay(
                                                Text(allergies.allergen ?? "none")
                                                    .font(.system(size: 10, weight: .medium))
                                            )
                                    }
                                }
                            }
                        }
                    }
                }

                // MARK: - Graph Card
                WalkTimeGraphView(model: store.timeWalkedGraph)
            }
            .padding(.top, 10)
            .padding(.bottom, 80)
            .customNavigationScroll(
                title: "Activity",
                profileImage: store.dogProfile.dogImage,
                onProfileTap: { showProfile = true }
            )
            .navigationDestination(isPresented: $showProfile) {
                ProfileView(store: store)
            }
            .navigationDestination(isPresented: $showMealsLog) {
                MealLogView(store: store)
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

#Preview {
    ActivityView(store: ActivityStore())
}
