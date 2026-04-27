//
//  WalkTrackingView.swift
//  PawPing
//
//  Created by Atul on 21/03/26.
//

import SwiftUI

struct WalkTrackingView: View {

    var store: ActivityStore
    var petId: UUID
    var onDismiss: () -> Void

    
    private var distanceText: String {
        let d = store.locationManager.totalDistance
        if (d >= 1000) {
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
            Color(.systemGroupedBackground)
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {

                // Minimize button (go back to activity tab, walk keeps running)
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
            }

            WalkMapView(routeLocations: store.locationManager.routeLocations)
                .clipShape(RoundedRectangle(cornerRadius: 28))
                .padding(.horizontal, 20)
                .padding(.top, 10)
                .padding(.bottom, 20)

            // MARK: - Distance
                VStack(alignment: .leading, spacing: 4) {
                    Text("TOTAL DISTANCE")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(Color("baseColor"))
                        .tracking(1.5)

                    Text(distanceText)
                        .font(.system(size: 80, weight: .bold))
                        .foregroundStyle(.primary)
                        .minimumScaleFactor(0.5)
                        .lineLimit(1)
                }
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
                            .font(.system(size: 28, weight: .bold))
                        Text("GOAL")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(.secondary)
                            .tracking(1)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text("CURRENT PROGRESS")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(.secondary)
                            .tracking(1)
                        Text("\(progressPercent)%")
                            .font(.system(size: 28, weight: .bold))
                        Text("COMPLETED")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(.secondary)
                            .tracking(1)
                    }
                }
                .padding(.horizontal, 30)

                Spacer()

                // MARK: - Timer Card
                VStack(spacing: 20) {
                    Text(timerText)
                        .font(.system(size: 56, weight: .bold, design: .rounded))
                        .foregroundStyle(Color("baseColor"))
                        .monospacedDigit()

                    // Pause/Play + Stop buttons
                    HStack(spacing: 24) {
                        // Pause / Play
                        Button {
                            store.togglePause()
                        } label: {
                            Circle()
                                .fill(Color(.systemGray2))
                                .frame(width: 64, height: 64)
                                .overlay(
                                    Image(systemName: store.isPaused ? "play.fill" : "pause.fill")
                                        .font(.system(size: 24, weight: .bold))
                                        .foregroundStyle(.white)
                                )
                        }

                        // Stop
                        Button {
                            store.stopWalk(petId: petId)
                            onDismiss()
                        } label: {
                            Circle()
                                .fill(Color("baseColor"))
                                .frame(width: 64, height: 64)
                                .overlay(
                                    Image(systemName: "stop.fill")
                                        .font(.system(size: 24, weight: .bold))
                                        .foregroundStyle(.white)
                                )
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 30)
                .background(
                    RoundedRectangle(cornerRadius: 28)
                        .fill(.gray.opacity(0.12))
                )
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
        }
    }
}

#Preview {
    WalkTrackingView(store: ActivityStore(), petId: UUID(), onDismiss: {})
}
