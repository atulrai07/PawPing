//
//  EmergencyHelpView.swift
//  PawPing
//
//  Created by Atul on 24/04/26.
//
//  Emergency guidance screen shown when critical symptoms are detected.
//  Provides immediate action steps and a quick-call button.
//

import SwiftUI

struct EmergencyHelpView: View {
    @Environment(\.dismiss) var dismiss

    /// Emergency steps to display
    private let emergencySteps = [
        EmergencyStep(icon: "1.circle.fill", title: "Stay Calm", description: "Your pet needs you to be composed. Take a deep breath."),
        EmergencyStep(icon: "2.circle.fill", title: "Keep Your Dog Still", description: "Minimize movement. If there's a seizure, do not restrain — clear the area of objects."),
        EmergencyStep(icon: "3.circle.fill", title: "Call Your Vet", description: "Contact your nearest emergency veterinary clinic immediately."),
        EmergencyStep(icon: "4.circle.fill", title: "Note the Symptoms", description: "Write down the time symptoms started, what you observed, and anything your dog may have eaten."),
        EmergencyStep(icon: "5.circle.fill", title: "Transport Safely", description: "Use a pet carrier or support your dog gently. Avoid sudden movements during transport."),
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {

                // MARK: - Emergency Header
                emergencyHeader

                // MARK: - Call Vet Button
                callVetButton

                // MARK: - Emergency Steps
                stepsSection

                // MARK: - Important Notes
                notesSection

                // MARK: - Disclaimer
                disclaimerSection
            }
            .padding(.bottom, 40)
        }
        .navigationTitle("Emergency Help")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Subviews

    private var emergencyHeader: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.red.opacity(0.15))
                    .frame(width: 90, height: 90)

                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 42))
                    .foregroundStyle(.red)
            }

            Text("Emergency Detected")
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(.red)

            Text("Your dog may need immediate veterinary attention.\nFollow these steps while you prepare to visit the vet.")
                .font(.system(size: 14))
                .foregroundStyle(Color("secondaryText"))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.red.opacity(0.05))
        )
        .padding(.horizontal)
        .padding(.top, 8)
    }

    private var callVetButton: some View {
        Button {
            // Opens phone dialer with a placeholder emergency number
            if let url = URL(string: "tel://911") {
                UIApplication.shared.open(url)
            }
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "phone.fill")
                    .font(.system(size: 20, weight: .bold))

                Text("Call Emergency Vet")
                    .font(.system(size: 18, weight: .bold))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.red)
            )
        }
        .padding(.horizontal)
    }

    private var stepsSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("What To Do Right Now")
                .font(.system(size: 18, weight: .bold))
                .padding(.horizontal)
                .padding(.bottom, 4)

            ForEach(emergencySteps) { step in
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: step.icon)
                        .font(.system(size: 24))
                        .foregroundStyle(.red)
                        .frame(width: 30)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(step.title)
                            .font(.system(size: 15, weight: .bold))

                        Text(step.description)
                            .font(.system(size: 13))
                            .foregroundStyle(Color("secondaryText"))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .padding(14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color("cardBackground"))
                )
                .padding(.horizontal)
            }
        }
    }

    private var notesSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: "square.and.pencil")
                    .foregroundStyle(Color("baseColor"))
                Text("Before You Leave")
                    .font(.system(size: 16, weight: .bold))
            }

            VStack(alignment: .leading, spacing: 6) {
                bulletPoint("Bring any packaging of substances your dog may have ingested")
                bulletPoint("Note the time symptoms first appeared")
                bulletPoint("Bring your dog's vaccination records if available")
                bulletPoint("Keep your dog warm during transport")
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color("cardBackground"))
        )
        .padding(.horizontal)
    }

    private func bulletPoint(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Text("•")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(Color("baseColor"))
            Text(text)
                .font(.system(size: 13))
                .foregroundStyle(Color("secondaryText"))
        }
    }

    private var disclaimerSection: some View {
        HStack(spacing: 8) {
            Image(systemName: "info.circle")
                .foregroundStyle(Color("secondaryText"))
                .font(.system(size: 14))

            Text("This app provides general guidance only. It is not a substitute for professional veterinary care.")
                .font(.system(size: 12))
                .foregroundStyle(Color("secondaryText"))
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color("secondaryCardBackground"))
        )
        .padding(.horizontal)
    }
}

// MARK: - Emergency Step Model

private struct EmergencyStep: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let description: String
}

#Preview {
    NavigationStack {
        EmergencyHelpView()
    }
}
