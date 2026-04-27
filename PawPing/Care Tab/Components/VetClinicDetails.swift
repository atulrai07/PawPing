//
//  VetClinicDetails.swift
//  PawPing
//
//  Created by Atul on 23/03/26.
//
 
//  A detail sheet that pops up when you tap on a vet/daycare card.
//  Shows stats, quick actions (call, navigate), gallery, about, and contact info.
//

import SwiftUI
import UIKit

struct VetClinicDetails: View {
    let item: PlaceModel

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
                            
                            Text(item.category.rawValue)
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
                

                
                // MARK: - Quick Action Buttons
                HStack(spacing: 12) {
                    // Distance Button (Solid Blue)
                    Button {
                        if let url = URL(string: "http://maps.apple.com/?daddr=\(item.latitude),\(item.longitude)") {
                            UIApplication.shared.open(url)
                        }
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
                    
                    // Call Button (Disabled)
                    Button {
                    } label: {
                        VStack(spacing: 6) {
                            Image(systemName: "phone.fill")
                                .font(.system(size: 20))
                            Text("Unavailable")
                                .font(.system(size: 14))
                        } // VStack — call button
                        .foregroundStyle(Color("baseColor"))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color("baseColor").opacity(0.15))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .disabled(true)
                    .opacity(0.6)
                    
                    // Website Button (Disabled)
                    Button {
                    } label: {
                        VStack(spacing: 6) {
                            Image(systemName: "globe")
                                .font(.system(size: 20))
                            Text("Unavailable")
                                .font(.system(size: 14))
                        } // VStack — website button
                        .foregroundStyle(Color("baseColor"))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color("baseColor").opacity(0.15))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .disabled(true)
                    .opacity(0.6)
                } // HStack — quick actions
                

                
                // MARK: - About Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("About")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(.primary)
                    
                    Text("This \(item.category.rawValue.lowercased()) is located \(item.distanceString) from you.")
                        .foregroundStyle(.primary)
                        .font(.system(size: 15))
                        .lineSpacing(4)
                } // VStack — about
                .frame(maxWidth: .infinity, alignment: .leading)
                
                // MARK: - Details Section
                VStack(alignment: .leading, spacing: 16) {
                    Text("Details")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(.primary)
                    
                    VStack(spacing: 0) {
                        detailRow(title: "Phone", value: "Not available")
                        detailRow(title: "Website", value: "Not available")
                        detailRow(title: "Address", value: "Not available")
                        detailRow(title: "Timing", value: "Not available", isLast: true)
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
    VetClinicDetails(item: PlaceModel(
        name: "PupiLife Pet Clinic",
        latitude: 28.6139,
        longitude: 77.2090,
        distance: 4.5,
        category: .vet
    ))
}
