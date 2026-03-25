//
//  WalkTrackingView.swift
//  PawPing
//
//  Created by Atul on 21/03/26.
//
//  The full-screen walk tracking UI — shows distance, timer, goal progress,
//  and pause/stop controls. Presented as a .fullScreenCover from ActivityView.
//

import SwiftUI
import UIKit

struct WalkTrackingView: View {

    // The shared store — same instance as ActivityView, so changes
    // here (like stopping the walk) are reflected everywhere.
    var store: ActivityStore
    // Called when we want to close this full-screen cover
    var onDismiss: () -> Void

    // MARK: - Computed helpers (no @State needed, these just format data)

    private var distanceText: String {
        let d = store.locationManager.totalDistance
        if d >= 1000 {
            return String(format: "%.1fKM", d / 1000)
        }
        return "\(Int(d))M"
    }

    private var timerText: String {
        let total = store.elapsedSeconds
        let mins = Int(total) / 60
        let secs = Int(total) % 60
        let centis = Int((total.truncatingRemainder(dividingBy: 1)) * 100)
        return String(format: "%02d:%02d.%02d", mins, secs, centis)
    }

    private var progressPercent: Int {
        guard store.walkActivity.goalMinutes > 0 else { return 0 }
        let pct = (store.elapsedSeconds / 60.0) / Double(store.walkActivity.goalMinutes) * 100
        return min(Int(pct), 100)
    }

    var body: some View {
        ZStack {
            Color(uiColor: .systemGroupedBackground)
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {

                // Minimize — doesn't stop the walk, just hides this view
                HStack {
                    Button(action: onDismiss) {
                        Image(systemName: "chevron.down")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(.secondary)
                            .padding(12)
                            .background(Circle().fill(.ultraThinMaterial))
                    }
                    .padding(.leading, 20)
                    .padding(.top, 10)
                    Spacer()
                } // HStack — minimize button

                Spacer()

                // MARK: - Distance
                VStack(alignment: .leading, spacing: 4) {
                    Text("TOTAL DISTANCE")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(Color.pawTertiary)
                        .tracking(1.5)

                    Text(distanceText)
                        .font(.system(size: 80, weight: .black, design: .rounded))
                        .foregroundStyle(.pawSecondary)
                        .minimumScaleFactor(0.5)
                        .lineLimit(1)
                } // VStack — distance
                .padding(.horizontal, 30)

                Spacer().frame(height: 30)

                // MARK: - Goal + Progress
                HStack(spacing: 40) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("TIME OBJECTIVE")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(.secondary)
                            .tracking(1)
                        Text("\(store.walkActivity.goalMinutes) MIN")
                            .font(.system(size: 28, weight: .black, design: .rounded))
                        Text("GOAL")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(.secondary)
                            .tracking(1)
                    } // VStack — goal

                    VStack(alignment: .leading, spacing: 4) {
                        Text("CURRENT PROGRESS")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(.secondary)
                            .tracking(1)
                        Text("\(progressPercent)%")
                            .font(.system(size: 28, weight: .black, design: .rounded))
                        Text("COMPLETED")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(.secondary)
                            .tracking(1)
                    } // VStack — progress
                } // HStack — goal + progress
                .padding(.horizontal, 30)

                Spacer()

                // MARK: - Timer Card
                VStack(spacing: 20) {
                    Text(timerText)
                        .font(.system(size: 56, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.pawTertiary)
                        .monospacedDigit()

                    // Pause/Play + Stop
                    HStack(spacing: 24) {
                        Button {
                            store.togglePause()
                        } label: {
                            Circle()
                                .fill(Color(uiColor: .systemGray2))
                                .frame(width: 64, height: 64)
                                .overlay(
                                    Image(systemName: store.isPaused ? "play.fill" : "pause.fill")
                                        .font(.system(size: 24, weight: .bold))
                                        .foregroundStyle(.white)
                                )
                        } // Pause/Play button

                        Button {
                            store.stopWalk()
                            onDismiss()
                        } label: {
                            Circle()
                                .fill(Color.pawTertiary)
                                .frame(width: 64, height: 64)
                                .overlay(
                                    Image(systemName: "stop.fill")
                                        .font(.system(size: 24, weight: .bold))
                                        .foregroundStyle(.white)
                                )
                        } // Stop button
                    } // HStack — controls
                } // VStack — timer card
                .frame(maxWidth: .infinity)
                .padding(.vertical, 30)
                .background(
                    RoundedRectangle(cornerRadius: 28)
                        .fill(Color.pawNeutral)
                )
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            } // VStack — main layout
        } // ZStack — background + content
    }
} // WalkTrackingView

#Preview {
    WalkTrackingView(store: ActivityStore(), onDismiss: {})
}
