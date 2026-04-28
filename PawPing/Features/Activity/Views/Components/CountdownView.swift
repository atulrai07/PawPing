//
//  CountdownView.swift
//  PawPing
//

import SwiftUI
import Combine

/// A fullscreen countdown view (3-2-1) displayed before a walk session begins.
struct CountdownView: View {
    // MARK: - Actions
    var onComplete: () -> Void
    var onCancel: () -> Void

    // MARK: - Internal State
    @State private var count = 3
    @State private var ringProgress: CGFloat = 0
    @State private var numberScale: CGFloat = 0.5
    @State private var numberOpacity: Double = 0

    /// Timer to drive the 1-second ticks
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            // MARK: - Background
            Color(.systemGroupedBackground)
                .ignoresSafeArea()

            VStack(spacing: 30) {
                // MARK: - Branding Icon
                HStack(spacing: -4) {
                    Image(systemName: "figure.walk")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundStyle(Color("baseColor"))
                    Image(systemName: "dog.fill")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(Color("baseColor"))
                }

                // MARK: - Animated Progress Ring
                ZStack {
                    // Background track
                    Circle()
                        .stroke(Color("baseColor").opacity(0.15), lineWidth: 14)

                    // Growing progress arc
                    Circle()
                        .trim(from: 0, to: ringProgress)
                        .stroke(
                            Color("baseColor"),
                            style: StrokeStyle(lineWidth: 14, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))

                    // Pulsing countdown number
                    Text("\(count)")
                        .font(.system(size: 100, weight: .bold, design: .rounded))
                        .foregroundStyle(Color("baseColor"))
                        .scaleEffect(numberScale)
                        .opacity(numberOpacity)
                }
                .frame(width: 220, height: 220)

                Text("Starting Walk")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(.primary)
            }

            // MARK: - Cancel Button
            VStack {
                HStack {
                    Button(action: onCancel) {
                        Image(systemName: "xmark")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(.secondary)
                            .padding(12)
                            .background(Circle().fill(.ultraThinMaterial))
                    }
                    .padding(.leading, 20)
                    .padding(.top, 10)
                    Spacer()
                }
                Spacer()
            }
        }
        .onAppear {
            animateNumber()
            animateRing(for: count)
        }
        .onReceive(timer) { _ in
            handleTimerTick()
        }
    }

    // MARK: - Logic
    
    private func handleTimerTick() {
        if count > 1 {
            count -= 1
            animateNumber()
            animateRing(for: count)
        } else {
            onComplete()
        }
    }

    // MARK: - Animations

    /// Creates a pulsing pop-in effect for the number
    private func animateNumber() {
        numberScale = 0.5
        numberOpacity = 0
        withAnimation(.spring(response: 0.4, dampingFraction: 0.5)) {
            numberScale = 1.0
            numberOpacity = 1.0
        }
    }

    /// Animates the progress ring completion percentage
    private func animateRing(for remaining: Int) {
        let totalTime: CGFloat = 3.0
        let target: CGFloat = CGFloat(Int(totalTime) + 1 - remaining) / totalTime
        withAnimation(.easeInOut(duration: 0.9)) {
            ringProgress = target
        }
    }
}

#Preview {
    CountdownView(onComplete: {}, onCancel: {})
}
