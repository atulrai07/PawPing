//
//  WellnessInsightCardView.swift
//  PawPing
//

import SwiftUI

struct WellnessInsightCardView: View {
    @Environment(ActivityStore.self) var activityStore
    
    var body: some View {
        let current = activityStore.walkActivity.currentMinutes
        let goal = max(activityStore.walkActivity.goalMinutes, 1)
        let percent = min(Int((Double(current) / Double(goal)) * 100), 100)
        
        let statusText = percent >= 100 ? "Excellent" : (percent >= 50 ? "Good" : "Needs Work")
        
        HStack(spacing: 16) {
            // Icon
            Circle()
                .fill(Color.orange.opacity(0.15))
                .frame(width: 48, height: 48)
                .overlay(
                    Image(systemName: "flame.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.orange)
                )
            
            // Text Content
            VStack(alignment: .leading, spacing: 2) {
                Text("Activity")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(Color(hex: "1C1B1F") ?? .black)
                
                Text(statusText)
                    .font(.system(size: 20, weight: .heavy))
                    .foregroundColor(Color(hex: "1C1B1F") ?? .black)
                
                Text("\(percent)% of daily goal")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            // Visualization (Bar Chart)
            HStack(alignment: .bottom, spacing: 6) {
                ForEach(0..<6) { i in
                    Capsule()
                        .fill(Color.orange.opacity(i == 5 ? 1.0 : 0.2))
                        .frame(width: 4, height: CGFloat.random(in: 10...36))
                }
            }
            .padding(.trailing, 8)
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.gray.opacity(0.5))
        }
        .padding(20)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 28))
        .shadow(color: .black.opacity(0.04), radius: 10, x: 0, y: 4)
        .padding(.horizontal)
    }
}
