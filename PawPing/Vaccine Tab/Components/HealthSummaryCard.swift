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
    
    var body: some View {
        HStack(spacing: 0) {
            summaryColumn(title: "Completed", count: summary.doneCount, color: .green)
            
            Divider()
                .frame(height: 24)
            
            summaryColumn(title: "Upcoming", count: summary.upcomingCount, color: Color(hex: "6E54D7") ?? .purple)
            
            Divider()
                .frame(height: 24)
            
            summaryColumn(title: "Overdue", count: summary.overdueCount, color: .red)
        }
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(hex: "F8F6FF") ?? .purple.opacity(0.05))
                .overlay(
                    ZStack(alignment: .topTrailing) {
                        Color.clear
                        
                        // Decorative Paw Print
                        Image(systemName: "pawprint.fill")
                            .font(.system(size: 90))
                            .foregroundStyle(Color(hex: "6E54D7") ?? .purple)
                            .opacity(0.06)
                            .rotationEffect(.degrees(15))
                            .offset(x: 20, y: -10)
                    }
                )
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
    HealthSummaryCard(summary: HealthSummary.sample)
        .padding()
}
