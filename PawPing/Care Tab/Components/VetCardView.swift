//
//  VetCardView.swift
//  PawPing
//
//  Created by Atul on 04/02/26.
//

import SwiftUI
import CoreLocation

struct VetCardView: View {
    let vet: Vet
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .top, spacing: 14) {
                // Image
                Image(vet.image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 70, height: 70)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .background(Color.gray.opacity(0.1))
                
                // Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(vet.vetName)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(Color("baseColor"))
                    
                    HStack(spacing: 6) {
                        Image(systemName: "star.fill")
                            .foregroundStyle(.black)
                            .font(.system(size: 10))
                        
                        Text(String(format: "%.1f", vet.rating))
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(.primary)
                    }
                    
                    Text(vet.distanceString)
                        .font(.system(size: 13))
                        .foregroundStyle(.gray)
                        .padding(.top, 2)
                }
                
                Spacer()
            }
            .padding(12)
            
            // Buttons Row
            HStack(spacing: 12) {
                Button {
                    print("Calling \(vet.vetName)")
                } label: {
                    HStack {
                        Image(systemName: "phone.fill")
                        Text("Call")
                    }
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(Color.green)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                
                // Direction Button
                Button {
                    print("Directions to \(vet.vetName)")
                } label: {
                    Image(systemName: "arrow.triangle.turn.up.right.diamond.fill")
                        .font(.system(size: 18))
                        .foregroundStyle(.black)
                        .padding(10)
                        .background(Color.gray.opacity(0.1))
                        .clipShape(Circle())
                }
                
                // Web Button
                Button {
                    print("Website of \(vet.vetName)")
                } label: {
                    Image(systemName: "globe")
                        .font(.system(size: 18))
                        .foregroundStyle(.black)
                        .padding(10)
                        .background(Color.gray.opacity(0.1))
                        .clipShape(Circle())
                }
            }
            .padding(.horizontal, 12)
            .padding(.bottom, 12)
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

#Preview {
    VetCardView(vet: Vet(
        id: UUID(),
        vetName: "PupiLife Pet Clinic",
        rating: 4.8,
        distance: 1.2,
        image: "profilePhoto",
        latitude: 28.6139,
        longitude: 77.2090
    ))
    .padding()
    .background(Color("baseBackground"))
}
