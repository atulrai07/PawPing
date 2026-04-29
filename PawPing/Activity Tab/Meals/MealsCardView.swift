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
                .fill(Color("cardBackground"))
                .frame(width: 175, height: 190)
            
            VStack(alignment: .leading) {
                // MARK: - Header (Aligned with Vaccine Card)
                HStack {
                    Text("Meals")
                        .font(.system(size: 22, weight: .regular))
                    
                    Spacer()
                    
                    Circle()
                        .fill(Color("baseColor").opacity(0.2))
                        .frame(width: 22, height: 22)
                        .overlay(
                            Image(systemName: "chevron.right")
                                .foregroundStyle(.primary)
                                .font(.system(size: 12))
                        )
                }
                
                Spacer()
                
                // MARK: - Meal List (Centered to match Vaccine card balance)
                VStack(spacing: 12) {
                    ForEach(store.meals, id: \.id) { meal in
                        HStack(spacing: 8) {
                            // Meal Icon (SF Symbol)
                            Image(systemName: meal.mealType.icon)
                                .font(.system(size: 14))
                                .foregroundStyle(Color("baseColor"))
                                .frame(width: 18)
                            
                            // Meal Details
                            VStack(alignment: .leading, spacing: 0) {
                                Text(meal.mealType.rawValue)
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundStyle(.primary)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.8)
                                
                                Text("\(meal.time) \(meal.meridian)")
                                    .font(.system(size: 10))
                                    .foregroundStyle(Color("secondaryText"))
                            }
                            
                            Spacer()
                            
                            // Completion Status
                            if meal.isTaken {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(Color("baseColor"))
                                    .font(.system(size: 18))
                            } else {
                                Circle()
                                    .stroke(Color.secondary.opacity(0.3), lineWidth: 1.5)
                                    .frame(width: 18, height: 18)
                            }
                        }
                    }
                }
                
                Spacer()
            }
            .padding(16)
            .frame(width: 175, height: 190, alignment: .leading)
        }
    }
}

#Preview {
    MealsCardView(store: ActivityStore())
}
