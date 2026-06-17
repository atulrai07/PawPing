//
//  HealthSummaryCard.swift
//  PawPing
//
//  Created by Atul on 15/03/26.
//  Updated for Health system on 27/04/26.
//

import SwiftUI

struct HealthSummaryCard: View {
    let summary: HealthSummary
    let petName: String
    
    var body: some View {
        VStack(spacing: 0) {
            // Top Content
            HStack(alignment: .center, spacing: 12) {
                // Large Shield
                ZStack {
                    Image(systemName: "shield.fill")
                        .font(.system(size: 50))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color(hex: "8A72F6") ?? .purple, Color(hex: "6E54D7") ?? .purple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
                    Image(systemName: "checkmark")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(.white)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(petName) is Protected")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(Color(hex: "1C1B1F") ?? .black)
                    
                    Text("Great job! You're keeping\n\(petName) healthy and safe.")
                        .font(.system(size: 13))
                        .foregroundStyle(.gray)
                        .lineSpacing(2)
                }
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 16)
            
            // Bottom Metrics
            HStack(spacing: 0) {
                summaryColumn(title: "Completed", count: summary.doneCount, color: .green)
                
                Divider()
                    .frame(height: 24)
                
                summaryColumn(title: "Upcoming", count: summary.upcomingCount, color: Color(hex: "6E54D7") ?? .purple)
                
                Divider()
                    .frame(height: 24)
                
                summaryColumn(title: "Overdue", count: summary.overdueCount, color: .red)
            }
            .padding(.bottom, 16)
        }
        .background(
            ZStack(alignment: .topTrailing) {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(hex: "F8F6FF") ?? .purple.opacity(0.05))
                
                // Decorative Paw Print
                Image(systemName: "pawprint.fill")
                    .font(.system(size: 90))
                    .foregroundStyle(Color(hex: "6E54D7") ?? .purple)
                    .opacity(0.06)
                    .rotationEffect(.degrees(15))
                    .offset(x: 20, y: -10)
            }
            .clipShape(RoundedRectangle(cornerRadius: 20))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color(hex: "6E54D7")?.opacity(0.1) ?? .purple.opacity(0.1), lineWidth: 1)
        )
        .shadow(color: Color(hex: "6E54D7")?.opacity(0.05) ?? .clear, radius: 15, x: 0, y: 10)
    }
    
    private func summaryColumn(title: String, count: Int, color: Color) -> some View {
        VStack(spacing: 4) {
            Text("\(count)")
                .font(.system(size: 24, weight: .semibold))
                .foregroundStyle(color)
            
            Text(title)
                .font(.system(size: 12, weight: .regular))
                .foregroundStyle(.gray)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    HealthSummaryCard(summary: HealthSummary.sample, petName: "Luna")
        .padding()
}
