//
//  VaccineSummaryCard.swift
//  PawPing
//
//  Created by Atul on 15/03/26.
//

import SwiftUI

struct VaccineSummaryCard: View {
    let summary: VaccineSummary
    
    var body: some View {
        HStack(spacing: 0) {
            summaryColumn(title: "Done", count: summary.doneCount, color: Color("baseRed"))
            
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
                .fill(.gray.opacity(0.1))
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

#Preview {
    VaccineSummaryCard(summary: VaccineStore().summary)
        .padding()
        .background(Color("baseBackground"))
}
