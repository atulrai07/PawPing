//
//  ActivityView.swift
//  PawPing
//

import SwiftUI
import Combine
import UIKit

struct ActivityView: View {
    var store: ActivityStore
    
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
                                }
                                .padding(.top, 4)
                            }
                        }
                        
                        Spacer()
                    }
                }
                .padding(.horizontal)
                
                // MARK: - Vaccine & Meals Row
                HStack(spacing: 16) {
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 34)
                            .fill(Color.pawNeutral)
                            .frame(width: 175, height: 190)
                        
                        VStack(alignment: .leading) {
                            HStack(spacing: 15) {
                                Text("Upcoming")
                                    .font(.system(size: 22, weight: .regular))
                                
                                Button {} label: {
                                    Circle()
                                        .fill(Color.pawPrimary.opacity(0.15))
                                        .frame(width: 22, height: 22)
                                        .overlay(
                                            Image(systemName: "chevron.right")
                                                .foregroundStyle(.pawSecondary)
                                                .font(.system(size: 12))
                                        )
                                }
                            }
                            
                            Image(systemName: "syringe")
                                .foregroundStyle(.pawPrimary)
                                .rotationEffect(.degrees(270))
                                .font(.system(size: 65))
                            
                            Text(store.vaccines.first?.name ?? "No vaccine")
                                .font(.system(size: 18, weight: .medium))
                            
                            Text("\(store.vaccines.first?.daysLeft ?? 0) days left")
                                .font(.system(size: 12, weight: .semibold))
                        }
                        .frame(height: 175)
                    }
                    
                    MealsCardView(store: store)
                }
                
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
                                
                                Button {} label: {
                                    Circle()
                                        .fill(Color.pawPrimary.opacity(0.15))
                                        .frame(width: 22, height: 22)
                                        .overlay(
                                            Image(systemName: "chevron.right")
                                                .foregroundStyle(.pawSecondary)
                                                .font(.system(size: 12))
                                        )
                                }
                            }
                            
                            HStack {
                                ForEach(store.allergies.prefix(3)) { allergy in
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 6)
                                            .fill(.pawPrimary)
                                            .frame(width: 62, height: 27)
                                        
                                        RoundedRectangle(cornerRadius: 5)
                                            .fill(Color.pawNeutral)
                                            .frame(width: 60, height: 25)
                                            .overlay(
                                                Text(allergy.allergen ?? "none")
                                                    .font(.system(size: 10, weight: .medium))
                                            )
                                    }
                                }
                            }
                        }
                    }
                }
                
                // MARK: - Graph
                WalkTimeGraphView(model: store.timeWalkedGraph)
            }
            .padding(.top, 10)
            .padding(.bottom, 80)
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
}

// MARK: - Walking Label

private struct WalkingLabel: View {
    @State private var dotCount = 0
    private let timer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()
    
    private var dots: String {
        String(repeating: ".", count: dotCount + 1)
    }
    
    var body: some View {
        Text("WALKING\(dots)")
            .font(.system(size: 14, weight: .medium))
            .foregroundStyle(.white)
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
}

// MARK: - Walk Flow Container

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
        } else {
            CountdownView(
                onComplete: {
                    store.startWalk()
                    showTracking = true
                },
                onCancel: {
                    onDismiss()
                }
            )
        }
    }
}

// MARK: - Preview

#Preview {
    ActivityView(store: ActivityStore())
}
