//
//  ActivityView.swift
//  PawPing
//
//  Created by Atul on 19/01/26.
//
//  The home screen of the app — shows walk progress, upcoming vaccines,
//  meals, allergies, and a weekly walk graph.
//

import SwiftUI
import Combine
import UIKit   // needed for UIFont in textWidth() at the bottom

struct ActivityView: View {
    // Not @State because we don't own the store — ContentView does.
    // We just read from it. Since ActivityStore is @Observable,
    // SwiftUI still picks up changes automatically.
    var store: ActivityStore

    // @State = local UI state that only this view cares about.
    // These control whether the walk flow sheet is showing.
    @State private var showWalkFlow = false
    @State private var countdownFinished = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {

                // MARK: - Walked Card
                ZStack {
                    RoundedRectangle(cornerRadius: 34)
                        .fill(Color.pawNeutral)
                        .frame(height: 160)

                    HStack(spacing: 20) {
                        CircularProgressView(progress: store.walkActivity.progress)
                            .frame(width: 100, height: 100)
                            .padding(.leading, 20)

                        Spacer()

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Walked")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundStyle(.pawPrimary)

                            Text("\(store.walkActivity.currentMinutes)/\(store.walkActivity.goalMinutes)min")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundStyle(.pawSecondary)

                            if store.isWalking {
                                // Walk is active — tapping reopens the tracking view (skips countdown)
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
                                        .foregroundStyle(.pawPrimary)
                                        .padding(.horizontal, 24)
                                        .padding(.vertical, 8)
                                        .background(
                                            Capsule()
                                                .stroke(Color.pawPrimary, lineWidth: 1.5)
                                        )
                                } // START button
                                .padding(.top, 4)
                            }
                        } // VStack — walk stats
                        Spacer()
                    } // HStack — progress ring + stats
                } // ZStack — Walked Card
                .frame(height: 160)
                .padding(.horizontal)

                // MARK: - Vaccine & Meals Row
                HStack(spacing: 16) {
                    // Upcoming Vaccine mini-card
                    ZStack {
                        RoundedRectangle(cornerRadius: 34)
                            .fill(Color.pawNeutral)
                            .frame(width: 175, height: 190)
                        VStack(alignment: .leading) {
                            HStack(spacing: 15) {
                                Text("Upcoming")
                                    .font(.system(size: 22, weight: .regular))
                                Button {
                                    // TODO: navigate to vaccine detail
                                } label: {
                                    Circle()
                                        .fill(Color.pawPrimary.opacity(0.15))
                                        .frame(width: 22, height: 22)
                                        .overlay(
                                            Image(systemName: "chevron.right")
                                                .foregroundStyle(.pawSecondary)
                                                .font(.system(size: 12))
                                        )
                                }
                            } // HStack — title + chevron
                            Image(systemName: "syringe")
                                .foregroundStyle(.pawPrimary)
                                .rotationEffect(.degrees(270))
                                .font(.system(size: 65))
                            Text(store.vaccines.first?.name ?? "No vaccine")
                                .font(.system(size: 18, weight: .medium))
                            Text("\(store.vaccines.first?.daysLeft ?? 0) days left")
                                .font(.system(size: 12, weight: .semibold))
                        } // VStack — vaccine info
                        .frame(height: 175)
                    } // ZStack — vaccine mini-card

                    // Meals Card (separate component)
                    MealsCardView(store: store)
                } // HStack — vaccine + meals row

                // MARK: - Allergies Card
                ZStack {
                    RoundedRectangle(cornerRadius: 23)
                        .fill(Color.pawNeutral)
                        .frame(width: 370, height: 95)
                    HStack(spacing: 20) {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.pawNeutral)
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
                                    // TODO: navigate to allergies detail
                                } label: {
                                    Circle()
                                        .fill(Color.pawPrimary.opacity(0.15))
                                        .frame(width: 22, height: 22)
                                        .overlay(
                                            Image(systemName: "chevron.right")
                                                .foregroundStyle(.pawSecondary)
                                                .font(.system(size: 12))
                                        )
                                }
                            } // HStack — allergies title + chevron
                            HStack {
                                // Show up to 3 allergy badges
                                ForEach(store.allergies.prefix(3)) { allergies in
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 6)
                                            .fill(.pawPrimary)
                                            .frame(width: 62, height: 27)
                                        RoundedRectangle(cornerRadius: 5)
                                            .fill(Color.pawNeutral)
                                            .frame(width: 60, height: 25)
                                            .overlay(
                                                Text(allergies.allergen ?? "none")
                                                    .font(.system(size: 10, weight: .medium))
                                            )
                                    } // ZStack — single badge
                                }
                            } // HStack — allergy badges
                        } // VStack — allergies content
                    } // HStack — icon + allergies
                } // ZStack — Allergies Card

                // MARK: - Graph Card
                WalkTimeGraphView(model: store.timeWalkedGraph)
            } // VStack — main content
            .padding(.top, 10)
            .padding(.bottom, 80)
            .customNavigationScroll(title: "Activity", profileImage: store.dogProfile.dogImage)
        } // NavigationStack
        // fullScreenCover shows the walk flow as a modal over everything
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
} // ActivityView

// MARK: - Walk Flow Container (Countdown → Tracking)
// Decides whether to show the 3-2-1 countdown or jump straight
// to the walk tracking screen (if user tapped "WALKING..." to reopen).

private struct WalkFlowContainer: View {
    var store: ActivityStore
    var startWithTracking: Bool
    var onDismiss: () -> Void

    // We initialise @State in the init so it picks up startWithTracking
    // before the first render. You can't set @State in the body.
    @State private var showTracking: Bool

    init(store: ActivityStore, startWithTracking: Bool, onDismiss: @escaping () -> Void) {
        self.store = store
        self.startWithTracking = startWithTracking
        self.onDismiss = onDismiss
        // _showTracking accesses the underlying State wrapper directly
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
} // WalkFlowContainer

// MARK: - Animated "WALKING..." Label (fixed width)
// The dots animate (. → .. → ...) on a timer.
// We pre-measure the widest text ("WALKING...") so the button
// doesn't jump around as dots change.

private struct WalkingLabel: View {
    @State private var dotCount = 0
    // Combine timer that fires every 0.5s on the main thread
    private let timer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()

    private var dots: String {
        String(repeating: ".", count: dotCount + 1)
    }

    // We measure this string to keep the button width constant
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
                    .fill(Color.pawPrimary)
            )
            .onReceive(timer) { _ in
                dotCount = (dotCount + 1) % 3
            }
    }

    /// Uses UIKit to measure the exact pixel width of a string.
    /// This way the capsule button stays the same size no matter how many dots.
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
} // WalkingLabel

#Preview {
    ActivityView(store: ActivityStore())
}
