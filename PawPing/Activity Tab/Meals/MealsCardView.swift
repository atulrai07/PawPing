//
//  MealsCardView.swift
//  PawPing
//
//  Created by Atul on 01/02/26.
//

import SwiftUI

struct MealsCardView: View {
    
    var store: ActivityStore

    var body: some View {
        ZStack {
            // MARK: - Card Background
            RoundedRectangle(cornerRadius: 28)
                .fill(Color(red: 0.12, green: 0.12, blue: 0.12)) // Premium dark background
                .frame(width: 175, height: 190)
            
            VStack(alignment: .leading, spacing: 0) {
                // MARK: - Header (Title & Chevron)
                HStack {
                    Text("Meals")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.white.opacity(0.9))
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundStyle(.white.opacity(0.6))
                        .frame(width: 18, height: 18)
                        .background(.white.opacity(0.1))
                        .clipShape(Circle())
                }
                .padding(.bottom, 8)

                // MARK: - Calorie Display
                HStack(alignment: .lastTextBaseline, spacing: 5) {
                    Text("\(Int(store.totalCaloriesToday))")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundStyle(.white)
                    
                    Text("kcal today")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(.white.opacity(0.4))
                }
                .padding(.bottom, 10)
                
                // MARK: - Divider
                Rectangle()
                    .fill(.white.opacity(0.08))
                    .frame(height: 1)
                    .padding(.bottom, 10)

                // MARK: - Meal List
                VStack(spacing: 12) {
                    ForEach(store.meals, id: \.id) { meal in
                        HStack(spacing: 8) {
                            // Status Dot
                            Circle()
                                .fill(colorForMeal(meal.mealType))
                                .frame(width: 6, height: 6)
                            
                            // Meal Info
                            VStack(alignment: .leading, spacing: 0) {
                                Text(meal.mealType.rawValue)
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundStyle(.white)
                                Text("\(meal.time) \(meal.meridian)")
                                    .font(.system(size: 10))
                                    .foregroundStyle(.white.opacity(0.4))
                            }
                            
                            Spacer()
                            
                            // Checkmark Status
                            ZStack {
                                if meal.isTaken {
                                    Circle()
                                        .fill(Color.green)
                                        .frame(width: 18, height: 18)
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundStyle(.white)
                                } else {
                                    Circle()
                                        .stroke(.white.opacity(0.15), lineWidth: 1.5)
                                        .frame(width: 18, height: 18)
                                }
                            }
                        }
                    }
                }
            }
            .padding(16)
            .frame(width: 175, height: 190, alignment: .leading)
        }
    }

    private func colorForMeal(_ type: MealType) -> Color {
        switch type {
        case .breakfast: return .orange
        case .lunch:     return .blue
        case .dinner:    return .gray
        }
    }
}

#Preview {
    MealsCardView(store: ActivityStore())
}
