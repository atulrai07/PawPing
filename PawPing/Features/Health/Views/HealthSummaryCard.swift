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
            summaryColumn(title: "Done", count: summary.doneCount, color: Color.green)
            
            Divider()
                .frame(height: 40)
            
            summaryColumn(title: "Upcoming", count: summary.upcomingCount, color: .blue)
            
            Divider()
                .frame(height: 40)
            
            summaryColumn(title: "Overdue", count: summary.overdueCount, color: .red)
        }
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color("cardBackground"))
        )
    }
    
    private func summaryColumn(title: String, count: Int, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(color)
            
            Text("\(count)")
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(.primary)
        }
        .frame(maxWidth: .infinity)
    }
}
