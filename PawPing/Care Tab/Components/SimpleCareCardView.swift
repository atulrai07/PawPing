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
    let item: CareLocation
    
    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                // Name
                Text(item.name)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(Color("baseColor"))
                
                // Subtype & Rating
                Text("\(item.subType ?? "Veterinary Clinic") • \(String(format: "%.1f", item.rating))★")
                    .font(.system(size: 14))
                    .foregroundStyle(.gray)
                
                // Distance
                Text(item.distanceString)
                    .font(.system(size: 14))
                    .foregroundStyle(.gray)
            }
            
            Spacer()
            
            // Image from assets
            Image(item.imageName)
                .resizable()
                .scaledToFill()
                .frame(width: 80, height: 80)
                .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .padding(12)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

#Preview {
    SimpleCareCardView(item: CareLocation(
        id: UUID(),
        name: "PupiLife Pet Clinic",
        subType: "Veterinary Clinic",
        rating: 4.8,
        distance: 1.2,
        imageName: "profilePhoto",
        latitude: 28.525211,
        longitude: 77.218489
    ))
    .padding()
}
