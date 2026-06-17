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
    
    // Graceful fallbacks for missing MapKit data
    private var defaultTags: String {
        switch item.category {
        case .vet: return "General Checkup, Vaccination"
        case .dayCare: return "Boarding, Daycare"
        case .grooming: return "Bath, Haircut, Spa"
        case .petStore: return "Food, Toys, Supplies"
        case .outdoor: return "Park, Trails, Play"
        case .all: return "Pet Services"
        }
    }
    
    // Generating consistent pseudo-random rating based on name length to simulate data
    private var mockRating: String {
        let ratings = ["4.5", "4.6", "4.7", "4.8", "4.9", "5.0"]
        let index = item.name.count % ratings.count
        return ratings[index]
    }
    
    private var mockReviews: Int {
        return (item.name.count * 13) % 250 + 40
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Left Image Area
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(item.category.displayColor.opacity(0.1))
                
                Image(systemName: item.category.iconName)
                    .font(.system(size: 28))
                    .foregroundStyle(item.category.displayColor)
            }
            .frame(width: 72, height: 72)
            
            // Middle Content Area
            VStack(alignment: .leading, spacing: 6) {
                // Title
                Text(item.name)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.black)
                    .lineLimit(1)
                
                // Tags Row
                HStack(spacing: 6) {
                    Text(item.displayCategoryName)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(item.category.displayColor)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(item.category.displayColor.opacity(0.1))
                        .clipShape(Capsule())
                }
                
                // Ratings and Distance Row
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 11))
                        .foregroundStyle(Color(hex: "6E54D7") ?? .purple)
                    
                    Text(mockRating)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(.gray)
                    
                    Text("|")
                        .font(.system(size: 12))
                        .foregroundStyle(.gray.opacity(0.4))
                        .padding(.horizontal, 4)
                    
                    Image(systemName: "mappin.and.ellipse")
                        .font(.system(size: 11))
                        .foregroundStyle(Color(hex: "6E54D7") ?? .purple)
                    
                    // Removing " away" from the string
                    Text(item.distanceString.replacingOccurrences(of: " away", with: ""))
                        .font(.system(size: 12))
                        .foregroundStyle(.gray)
                }
            }
            
            Spacer(minLength: 0)
            
            // Right Call Button
            if let phone = item.phone, !phone.isEmpty {
                let cleanedPhone = phone.filter { "+0123456789".contains($0) }
                Button {
                    if let url = URL(string: "tel://\(cleanedPhone)") {
                        UIApplication.shared.open(url)
                    }
                } label: {
                    ZStack {
                        Circle()
                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                            .frame(width: 44, height: 44)
                        
                        Image(systemName: "phone")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundStyle(Color(hex: "6E54D7") ?? .purple)
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.03), radius: 8, x: 0, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.gray.opacity(0.1), lineWidth: 1)
        )
    }
}

#Preview {
    VStack(spacing: 16) {
        SimpleCareCardView(item: PlaceModel(
            name: "Dr. Maliks Pet Clinic",
            latitude: 28.525211,
            longitude: 77.218489,
            distance: 9.2,
            category: .vet,
            phone: "+1 234 567 8900"
        ))
        
        SimpleCareCardView(item: PlaceModel(
            name: "Happy Tails Grooming Salon & Spa",
            latitude: 28.525211,
            longitude: 77.218489,
            distance: 2.4,
            category: .grooming
        ))
    }
    .padding()
    .background(Color(.systemGray6))
}
