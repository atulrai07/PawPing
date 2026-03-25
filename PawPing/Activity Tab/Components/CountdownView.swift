//
//  CountdownView.swift
//  PawPing
//
//  Created by Atul on 21/03/26.
//
//  The 3-2-1 countdown screen before a walk starts.
//  Uses a Combine Timer publisher to tick every second,
//  with spring animations for the number pop-in effect.
//

import SwiftUI
import Combine  // for Timer.publish
import UIKit

struct CountdownView: View {

    // Closures passed from the parent — called when countdown finishes or user cancels
    var onComplete: () -> Void
    var onCancel: () -> Void

    // @State = local animation state, only this view needs to know about these
    @State private var count = 3
    @State private var ringProgress: CGFloat = 0
    @State private var numberScale: CGFloat = 0.5
    @State private var numberOpacity: Double = 0

    // Combine timer — fires every second on the main run loop.
    // .autoconnect() starts it immediately when the view appears.
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            Color(uiColor: .systemGroupedBackground)
                .ignoresSafeArea()

            VStack(spacing: 30) {
                // Walking dog icon
                HStack(spacing: -4) {
                    Image(systemName: "figure.walk")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundStyle(Color.pawTertiary)
                    Image(systemName: "dog.fill")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(Color.pawTertiary)
                } // HStack — walking icons

                // Circular ring that fills as the countdown progresses
                ZStack {
                    Circle()
                        .stroke(Color.pawTertiary.opacity(0.15), lineWidth: 14)

                    Circle()
                        .trim(from: 0, to: ringProgress)
                        .stroke(
                            Color.pawTertiary,
                            style: StrokeStyle(lineWidth: 14, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90)) // start from 12 o'clock

                    Text("\(count)")
                        .font(.system(size: 100, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.pawTertiary)
                        .scaleEffect(numberScale)
                        .opacity(numberOpacity)
                } // ZStack — countdown ring
                .frame(width: 220, height: 220)

                Text("Starting Walk")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(.pawSecondary)
            } // VStack — countdown content

            // Cancel (X) button in the top-left corner
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
                } // HStack — cancel button
                Spacer()
            } // VStack — cancel overlay
        } // ZStack — full screen
        .onAppear {
            animateNumber()
            animateRing(for: count)
        }
        // .onReceive listens to the Combine timer publisher
        .onReceive(timer) { _ in
            if count > 1 {
                count -= 1
                animateNumber()
                animateRing(for: count)
            } else {
                onComplete()
            }
        }
    }

    // MARK: - Animations

    /// Spring animation that makes each number "pop" into view
    private func animateNumber() {
        numberScale = 0.5
        numberOpacity = 0
        withAnimation(.spring(response: 0.4, dampingFraction: 0.5)) {
            numberScale = 1.0
            numberOpacity = 1.0
        }
    }

    /// Smoothly fills the ring from 0 → 1 over the 3 seconds
    private func animateRing(for remaining: Int) {
        let target: CGFloat = CGFloat(4 - remaining) / 3.0
        withAnimation(.easeInOut(duration: 0.9)) {
            ringProgress = target
        }
    }
} // CountdownView

#Preview {
    CountdownView(onComplete: {}, onCancel: {})
}
