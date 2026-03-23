//
//  VetClinicDetails.swift
//  PawPing
//

import SwiftUI
import UIKit

struct VetClinicDetails: View {
    let item: CareLocation

    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {

                // MARK: - Header
                VStack(spacing: 8) {
                    ZStack(alignment: .topTrailing) {
                        
                        VStack(spacing: 4) {
                            Text(item.name)
                                .font(.system(size: 20, weight: .bold))
                                .foregroundStyle(.pawSecondary)
                            
                            Text(item.subType ?? "Veterinary Clinic")
                                .font(.system(size: 14))
                                .foregroundStyle(.gray)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 40)
                        
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "xmark")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundStyle(.pawSecondary)
                                .frame(width: 36, height: 36)
                                .background(Color.pawNeutral)
                                .clipShape(Circle())
                        }
                    }
                }
                .padding(.top, 24)
                
                // MARK: - Stats
                HStack {
                    Spacer()
                    
                    VStack(spacing: 4) {
                        HStack(spacing: 2) {
                            Text(String(format: "%.1f", item.rating))
                                .font(.system(size: 16, weight: .bold))
                                .foregroundStyle(.pawSecondary)
                            Image(systemName: "star.fill")
                                .font(.system(size: 12))
                                .foregroundStyle(.yellow)
                        }
                        Text("Rating")
                            .foregroundStyle(.gray)
                    }
                    
                    Spacer()
                    
                    VStack(spacing: 4) {
                        Text(item.petSeen ?? "N/A")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(.pawSecondary)
                        Text("Pet Seen")
                            .foregroundStyle(.gray)
                    }
                    
                    Spacer()
                    
                    VStack(spacing: 4) {
                        Text(item.experience ?? "N/A")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(.pawSecondary)
                        Text("Experience")
                            .foregroundStyle(.gray)
                    }
                    
                    Spacer()
                }
                
                // MARK: - Actions
                HStack(spacing: 12) {
                    Button {
                        print("Navigate to \(item.name)")
                    } label: {
                        VStack(spacing: 6) {
                            Image(systemName: "location.fill")
                            Text(item.distanceString)
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.pawPrimary)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    
                    Button {
                        print("Call \(item.contactNumber ?? "")")
                    } label: {
                        VStack(spacing: 6) {
                            Image(systemName: "phone.fill")
                            Text("Call")
                        }
                        .foregroundStyle(.pawPrimary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.pawPrimary.opacity(0.15))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    
                    Button {
                        print("Visit \(item.email ?? "")")
                    } label: {
                        VStack(spacing: 6) {
                            Image(systemName: "globe")
                            Text("Website")
                        }
                        .foregroundStyle(.pawPrimary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.pawPrimary.opacity(0.15))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                }
                
                // MARK: - Gallery
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        Image(item.imageName)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 170, height: 170)
                            .clipShape(RoundedRectangle(cornerRadius: 24))
                        
                        Image(item.imageName)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 170, height: 170)
                            .clipShape(RoundedRectangle(cornerRadius: 24))
                    }
                    .padding(.horizontal, 20)
                }
                .frame(height: 170)
                .padding(.horizontal, -20)
                
                // MARK: - About
                VStack(alignment: .leading, spacing: 12) {
                    Text("About")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(.pawSecondary)
                    
                    Text("\(item.about ?? "No description available.")")
                        .foregroundStyle(.pawSecondary)
                        .font(.system(size: 15))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                // MARK: - Details
                VStack(alignment: .leading, spacing: 16) {
                    Text("Details")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(.pawSecondary)
                    
                    VStack(spacing: 0) {
                        detailRow(title: "Phone", value: item.contactNumber ?? "N/A")
                        detailRow(title: "Website", value: item.email ?? "N/A")
                        detailRow(title: "Address", value: item.address ?? "N/A")
                        detailRow(title: "Timing", value: "\(item.openingTime ?? "") - \(item.closingTime ?? "")", isLast: true)
                    }
                }
                
                Spacer(minLength: 40)
            }
            .padding(.horizontal, 20)
        }
        .background(Color(uiColor: .systemBackground))
        .presentationDragIndicator(.visible)
        .presentationDetents([.large, .fraction(0.9)])
    }
    
    private func detailRow(title: String, value: String, isLast: Bool = false) -> some View {
        VStack(spacing: 16) {
            HStack {
                Text(title)
                    .foregroundStyle(.gray)
                
                Spacer()
                
                Text(value)
                    .foregroundStyle(.pawPrimary)
            }
            
            if !isLast {
                Divider()
            }
        }
        .padding(.top, isLast ? 0 : 8)
    }
}

#Preview {
    VetClinicDetails(item: CareLocation(
        id: UUID(),
        name: "PupiLife Pet Clinic",
        subType: nil,
        rating: 4.8,
        distance: 4.5,
        imageName: "vet1",
        latitude: 28.6139,
        longitude: 77.2090,
        contactNumber: "+91 8456789027",
        email: "petcare.in",
        address: "New Delhi, India",
        openingTime: "9 AM",
        closingTime: "9 PM",
        petSeen: "850+",
        experience: "12 Years",
        about: "PupiLife Pet Clinic is a premium center dedicated to advanced pet care."
    ))
}
