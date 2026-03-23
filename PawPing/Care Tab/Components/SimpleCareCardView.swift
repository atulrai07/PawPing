//
//  SimpleCareCardView.swift
//  PawPing
//

import SwiftUI

struct SimpleCareCardView: View {
    let item: CareLocation
    
    var body: some View {
        HStack(spacing: 12) {
            // Image from assets
            Image(item.imageName)
                .resizable()
                .scaledToFill()
                .frame(width: 80, height: 80)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            
            VStack(alignment: .leading, spacing: 4) {
                // Name
                Text(item.name)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.pawPrimary)   // ✅ kept your version
                
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
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(.gray.opacity(0.5))
        }
        .padding(12)
        .background(Color.pawNeutral)   // ✅ kept your version
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
