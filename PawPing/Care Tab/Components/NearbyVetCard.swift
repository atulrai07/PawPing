//
//  NearbyVetCard.swift
//  PawPing
//
//  Created by Atul on 24/04/26.
//

import SwiftUI
import MapKit

struct NearbyVetCard: View {
    let vet: NearbyVet

    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text(vet.name)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(Color("baseColor"))
                
                Text("Veterinary Clinic • 4.8★")
                    .font(.system(size: 14))
                    .foregroundStyle(Color("secondaryText"))
                
                Text(vet.distanceText)
                    .font(.system(size: 14))
                    .foregroundStyle(Color("secondaryText"))
                
                if let phone = vet.phoneNumber {
                    Button {
                        let telephone = "tel://" + phone.replacingOccurrences(of: " ", with: "")
                        if let url = URL(string: telephone) {
                            UIApplication.shared.open(url)
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "phone.fill")
                                .font(.system(size: 12))
                            Text("Call Now")
                                .font(.system(size: 13, weight: .bold))
                        }
                        .padding(.vertical, 6)
                        .padding(.horizontal, 12)
                        .background(Color("baseColor").opacity(0.1))
                        .clipShape(Capsule())
                        .padding(.top, 4)
                    }
                }
            }
            
            Spacer()
            
            // Clinic Image Placeholder (Aesthetic matching the user's provided image)
            ZStack {
                Color("secondaryCardBackground")
                Image(systemName: "dog.fill")
                    .font(.system(size: 24))
                    .foregroundStyle(Color("baseColor").opacity(0.3))
            }
            .frame(width: 80, height: 80)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color("cardBackground"))
        )
    }
}

#Preview {
    NearbyVetCard(vet: NearbyVet(
        name: "PupiLife Pet Clinic",
        phoneNumber: "1234567890",
        address: "123 Dog St",
        distance: 1.2,
        coordinate: .init(latitude: 0, longitude: 0)
    ))
    .padding()
}
