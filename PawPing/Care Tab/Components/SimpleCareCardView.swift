//
//  SimpleCareCardView.swift
//  PawPing
//
//  Created by SidMoon on 23/03/26.
//
//  The unified card used in the Care tab list — works for both vets and day cares.
//  Shows the location image, name, rating, and distance.
//

import SwiftUI

struct SimpleCareCardView: View {
    let item: PlaceModel
    
    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                // Name
                Text(item.name)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(Color("baseColor"))
                
                Text(item.category.rawValue)
                    .font(.system(size: 14))
                    .foregroundStyle(.gray)
                
                // Distance
                Text(item.distanceString)
                    .font(.system(size: 14))
                    .foregroundStyle(.gray)
            }
            
            Spacer()
            
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color("baseColor").opacity(0.1))
                    .frame(width: 80, height: 80)
                
                Image(systemName: item.category == .vet ? "cross.case.fill" : "pawprint.fill")
                    .font(.system(size: 32))
                    .foregroundStyle(Color("baseColor"))
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color("cardBackground"))
                .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 4)
        )
    }
}

#Preview {
    SimpleCareCardView(item: PlaceModel(
        name: "PupiLife Pet Clinic",
        latitude: 28.525211,
        longitude: 77.218489,
        distance: 1.2,
        category: .vet
    ))
    .padding()
}
