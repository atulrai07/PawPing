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
            RoundedRectangle(cornerRadius: 28)
                .fill(Color("cardBackground"))
                .frame(width: 175, height: 190)
            
            VStack(alignment: .leading) {
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
                
                // Meals
                HStack(spacing: 8) {
                    ForEach(store.meals, id: \.id) { (meal: Meal) in
                        Capsule()
                            .fill(Color("secondaryCardBackground"))
                            .frame(width: 40, height: 105)
                            .overlay(
                                VStack {
                                    Circle()
                                        .fill(Color("baseColor"))
                                        .frame(width: 28, height: 28)
                                        .overlay(
                                            Image(systemName: String(meal.icon))
                                                .foregroundStyle(.white)
                                                .font(.system(size: 14, weight: .medium))
                                        )
                                        .padding(.top, 8)
                                    
                                    HStack(alignment: .lastTextBaseline, spacing: 1) {
                                        Text(meal.time)
                                            .font(.system(size: 10, weight: .medium))
                                        Text(meal.meridian)
                                            .font(.system(size: 6, weight: .medium))
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: meal.isTaken ? "checkmark.circle.fill" : "circle")
                                        .foregroundStyle(meal.isTaken ? Color("baseColor") : .secondary)
                                        .font(.system(size: 16, weight: .regular))
                                        .padding(.bottom, 10)
                                }
                            )
                    }
                }
            }
            .padding(16)
            .frame(width: 175, height: 190, alignment: .leading)
        }
    }
}

#Preview {
    MealsCardView(store: ActivityStore())
}
