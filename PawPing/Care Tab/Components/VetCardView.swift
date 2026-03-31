//
//  VetCardView.swift
//  PawPing
//

import SwiftUI
import CoreLocation

struct VetCardView: View {
    let vet: CareLocation   // ✅ FIXED
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .top, spacing: 14) {
                
                Image(vet.imageName) // ✅ FIXED
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 70, height: 70)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .background(Color.gray.opacity(0.1))
                
                VStack(alignment: .leading, spacing: 4) {
                    
                    Text(vet.name) // ✅ FIXED
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
                    
                    Text("\(vet.distance, specifier: "%.1f") km away") // ✅ FIXED
                        .font(.system(size: 13))
                        .foregroundStyle(.gray)
                        .padding(.top, 2)
                }
                
                Spacer()
            }
            .padding(12)
            
            HStack(spacing: 12) {
                
                Button {
                    print("Calling \(vet.name)")
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
                
                Button {
                    print("Directions to \(vet.name)")
                } label: {
                    Image(systemName: "arrow.triangle.turn.up.right.diamond.fill")
                        .font(.system(size: 18))
                        .foregroundStyle(.black)
                        .padding(10)
                        .background(Color.gray.opacity(0.1))
                        .clipShape(Circle())
                }
                
                Button {
                    print("Website of \(vet.name)")
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
    VetCardView(vet: CareLocation(   // ✅ FIXED
        id: UUID(),
        name: "PupiLife Pet Clinic",
        rating: 4.8,
        distance: 1.2,
        imageName: "profilePhoto",
        latitude: 28.6139,
        longitude: 77.2090
    ))
    .padding()
    .background(Color("baseBackground"))
}
