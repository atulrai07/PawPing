//
//  CountdownView.swift
//  PawPing
//
//  Created by Atul on 21/03/26.
//

import SwiftUI
import Combine

struct CountdownView: View {

    var onComplete: () -> Void
    var onCancel: () -> Void

    @State private var count = 3
    @State private var ringProgress: CGFloat = 0
    @State private var numberScale: CGFloat = 0.5
    @State private var numberOpacity: Double = 0

    // Drives a per-second ring animation
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()

            VStack(spacing: 30) {
                // Person walking dog icon
                HStack(spacing: -4) {
                    Image(systemName: "figure.walk")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundStyle(Color("baseColor"))
                    Image(systemName: "dog.fill")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(Color("baseColor"))
                }

                // Circular ring + number
                ZStack {
                    Circle()
                        .stroke(Color("baseColor").opacity(0.15), lineWidth: 14)

                    Circle()
                        .trim(from: 0, to: ringProgress)
                        .stroke(
                            Color("baseColor"),
                            style: StrokeStyle(lineWidth: 14, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))

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

            // X (close) button — top leading
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

    private func animateNumber() {
        numberScale = 0.5
        numberOpacity = 0
        withAnimation(.spring(response: 0.4, dampingFraction: 0.5)) {
            numberScale = 1.0
            numberOpacity = 1.0
        }
    }

    private func animateRing(for remaining: Int) {
        let target: CGFloat = CGFloat(4 - remaining) / 3.0
        withAnimation(.easeInOut(duration: 0.9)) {
            ringProgress = target
        }
    }
}

#Preview {
    CountdownView(onComplete: {}, onCancel: {})
}
