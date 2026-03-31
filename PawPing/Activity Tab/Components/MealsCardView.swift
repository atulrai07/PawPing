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
            RoundedRectangle(cornerRadius: 34)
                .fill(Color("cardBackground"))
                .frame(width: 175, height: 190)
            
            VStack(alignment: .leading) {
                HStack (spacing:60) {
                    Text("Meals")
                        .font(.system(size: 22, weight: .regular))
                    
                    Circle()
                        .fill(Color("baseColor").opacity(0.2))
                        .frame(width: 22, height: 22)
                        .overlay(
                            Image(systemName: "chevron.right")
                                .foregroundStyle(.primary)
                                .font(.system(size: 12))
                        )
                }
                
                // Meals
                HStack(spacing: 11) {
                    ForEach(store.meals, id: \.id) { (meal: Meal) in
                        Capsule()
                            .fill(Color("secondaryCardBackground"))
                            .frame(width: 40, height: 105)
                            .overlay(
                                VStack {
                                    Circle()
                                        .fill(Color("baseColor"))
                                        .overlay(
                                            Image(systemName: String(meal.icon))
                                                .foregroundStyle(.white)
                                                .font(.system(size: 21, weight: .medium))
                                        )
                                    
                                    HStack(alignment: .lastTextBaseline, spacing: 1) {
                                        Text(meal.time)
                                            .font(.system(size: 10, weight: .medium))
                                        Text(meal.meridian)
                                            .font(.system(size: 5, weight: .medium))
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: meal.isTaken ? "checkmark.circle" : "circle")
                                        .font(.system(size: 16, weight: .regular))
                                        .padding(.bottom, 10)
                                }
                            )
                    }
                }
            }
            .frame(height: 175)
        }
    }
}

#Preview {
    MealsCardView(store: ActivityStore())
}
