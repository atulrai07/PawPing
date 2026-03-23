//
//  MealsCardView.swift
//  PawPing
//
//  Created by Atul on 01/02/26.
//
//  Shows the day's 3 meals (breakfast, lunch, dinner) as vertical capsules
//  with icons, times, and checkmarks. Lives inside the Activity tab.
//

import SwiftUI

struct MealsCardView: View {
    
    var store: ActivityStore

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 34)
                .fill(Color.pawNeutral)
                .frame(width: 175, height: 190)
            
            VStack(alignment: .leading) {
                HStack (spacing: 60) {
                    Text("Meals")
                        .font(.system(size: 22, weight: .regular))
                    
                    Button {
                        // TODO: navigate to meal detail/logging
                    } label: {
                        Circle()
                            .fill(Color("baseColor").opacity(0.2))
                            .frame(width: 22, height: 22)
                            .overlay(
                                Image(systemName: "chevron.right")
                                    .foregroundStyle(.pawSecondary)
                                    .font(.system(size: 12))
                            )
                    }
                } // HStack — title + chevron
                
                // One capsule per meal (breakfast, lunch, dinner)
                HStack(spacing: 11) {
                    ForEach(store.meals, id: \.id) { (meal: Meal) in
                        Capsule()
                            .fill(Color.pawNeutral)
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
                                    } // HStack — time label
                                    
                                    Spacer()
                                    
                                    // Checkmark if meal was taken
                                    Image(systemName: meal.isTaken ? "checkmark.circle" : "circle")
                                        .font(.system(size: 16, weight: .regular))
                                        .padding(.bottom, 10)
                                } // VStack — meal capsule content
                            )
                    }
                } // HStack — meal capsules
            } // VStack — card content
            .frame(height: 175)
        } // ZStack — card
    }
} // MealsCardView

#Preview {
    MealsCardView(store: ActivityStore())
}
