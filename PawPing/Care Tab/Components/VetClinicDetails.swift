//
//  VetClinicDetails.swift
//  PawPing
//
//  Created by Atul on 23/03/26.
//


//
//  VetClinicDetails.swift
//  PawPing
//
//  Created by SidMoon on 23/03/26.
//
//  A detail sheet that pops up when you tap on a vet/daycare card.
//  Shows stats, quick actions (call, navigate), gallery, about, and contact info.
//

import SwiftUI
import UIKit

struct VetClinicDetails: View {
    let item: CareLocation

    // @Environment(\.dismiss) gives us a handle to close this sheet.
    // It works because CareView presents this via .sheet(item:),
    // so SwiftUI automatically provides a dismiss action in the environment.
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                // MARK: - Drag Indicator & Header
                VStack(spacing: 8) {
                    ZStack(alignment: .topTrailing) {
                        
                        // Center Titles
                        VStack(spacing: 4) {
                            Text(item.name)
                                .font(.system(size: 20, weight: .bold))
                                .foregroundStyle(.primary)
                            
                            Text(item.subType ?? "Veterinary Clinic")
                                .font(.system(size: 14))
                                .foregroundStyle(.gray)
                        } // VStack — titles
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 40)
                        
                        // Close Button — calls dismiss() to close the sheet
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "xmark")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundStyle(.primary)
                                .frame(width: 36, height: 36)
                                .background(Color(.systemGray6))
                                .clipShape(Circle())
                        }
                    } // ZStack — header
                } // VStack — drag indicator + header
                .padding(.top, 24)
                
                // MARK: - Stats Row
                HStack {
                    Spacer()
                    
                    VStack(spacing: 4) {
                        HStack(spacing: 2) {
                            Text(String(format: "%.1f", item.rating))
                                .font(.system(size: 16, weight: .bold))
                                .foregroundStyle(Color("baseColor"))
                            Image(systemName: "star.fill")
                                .font(.system(size: 12))
                                .foregroundStyle(.yellow)
                        } // HStack — rating
                        Text("Rating")
                            .font(.system(size: 14))
                            .foregroundStyle(.gray)
                    } // VStack — rating column
                    
                    Spacer()
                    
                    VStack(spacing: 4) {
                        Text(item.petSeen ?? "N/A")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(Color("baseColor"))
                        Text("Pet Seen")
                            .font(.system(size: 14))
                            .foregroundStyle(.gray)
                    } // VStack — pets seen column
                    
                    Spacer()
                    
                    VStack(spacing: 4) {
                        Text(item.experience ?? "N/A")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(Color("baseColor"))
                        Text("Experience")
                            .font(.system(size: 14))
                            .foregroundStyle(.gray)
                    } // VStack — experience column
                    
                    Spacer()
                } // HStack — stats row
                
                // MARK: - Quick Action Buttons
                HStack(spacing: 12) {
                    // Distance Button (Solid Blue)
                    Button {
                        print("Navigate to \(item.name)")
                    } label: {
                        VStack(spacing: 6) {
                            Image(systemName: "location.fill")
                                .font(.system(size: 20))
                            Text(item.distanceString)
                                .font(.system(size: 14))
                        } // VStack — distance button
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color("baseColor"))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    
                    // Call Button (Light Blue)
                    Button {
                        print("Call \(item.contactNumber ?? "")")
                    } label: {
                        VStack(spacing: 6) {
                            Image(systemName: "phone.fill")
                                .font(.system(size: 20))
                            Text("Call")
                                .font(.system(size: 14))
                        } // VStack — call button
                        .foregroundStyle(Color("baseColor"))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color("baseColor").opacity(0.15))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    
                    // Website Button (Light Blue)
                    Button {
                        print("Visit \(item.email ?? "")")
                    } label: {
                        VStack(spacing: 6) {
                            Image(systemName: "globe")
                                .font(.system(size: 20))
                            Text("Website")
                                .font(.system(size: 14))
                        } // VStack — website button
                        .foregroundStyle(Color("baseColor"))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color("baseColor").opacity(0.15))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                } // HStack — quick actions
                
                // MARK: - Image Gallery
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        // Using the same image twice as a placeholder gallery
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
                    } // HStack — gallery images
                    .padding(.horizontal, 20)
                } // ScrollView — horizontal gallery
                .frame(height: 170)
                .padding(.horizontal, -20) // cancels out the main padding for edge-to-edge scroll
                
                // MARK: - About Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("About")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(.primary)
                    
                    Text("\(item.about ?? "No description available.") [MORE...](#)")
                        .foregroundStyle(.primary)
                        .font(.system(size: 15))
                        .lineSpacing(4)
                        .tint(Color("baseColor"))
                } // VStack — about
                .frame(maxWidth: .infinity, alignment: .leading)
                
                // MARK: - Details Section
                VStack(alignment: .leading, spacing: 16) {
                    Text("Details")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(.primary)
                    
                    VStack(spacing: 0) {
                        detailRow(title: "Phone", value: item.contactNumber ?? "N/A")
                        detailRow(title: "Website", value: item.email ?? "N/A")
                        detailRow(title: "Address", value: item.address ?? "N/A")
                        detailRow(title: "Timing", value: "\(item.openingTime ?? "") - \(item.closingTime ?? "")", isLast: true)
                    } // VStack — detail rows
                } // VStack — details section
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Spacer(minLength: 40)
            } // VStack — main content
            .padding(.horizontal, 20)
        } // ScrollView
        .background(Color(uiColor: .systemBackground))
        // presentationDragIndicator shows the little gray bar at the top of the sheet
        .presentationDragIndicator(.visible)
        // presentationDetents controls how tall the sheet can be
        .presentationDetents([.large, .fraction(0.9)])
    }
    
    // MARK: - Helper Views

    /// A single row in the Details section with a title on the left and value on the right.
    private func detailRow(title: String, value: String, isLast: Bool = false) -> some View {
        VStack(spacing: 16) {
            HStack {
                Text(title)
                    .font(.system(size: 16))
                    .foregroundStyle(.gray)
                
                Spacer()
                
                Text(value)
                    .font(.system(size: 16))
                    .foregroundStyle(Color("baseColor"))
            } // HStack — detail row content
            
            if !isLast {
                Divider()
            }
        } // VStack — detail row
        .padding(.top, isLast ? 0 : 8)
    }
} // VetClinicDetails

#Preview {
    VetClinicDetails(item: CareLocation(
        id: UUID(),
        name: "PupiLife Pet Clinic",
        subType: nil,
        rating: 4.8, distance: 4.5, imageName: "vet1",
        latitude: 28.6139, longitude: 77.2090,
        contactNumber: "+91 8456789027",
        email: "petcare.in",
        address: "New Delhi ,India",
        openingTime: "9 AM", closingTime: "9 PM",
        petSeen: "850+", experience: "12 Years",
        about: "PupiLife Pet Clinic is a premium center dedicated to advanced pet care. Our specialists bring years of expertise in surgical and diagnostic services, ensuring your pet gets the best treatment available in Dankaur."
    ))
}