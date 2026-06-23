//
//  VetClinicDetails.swift
//  PawPing
//
//  Created by Atul on 23/03/26.
//

import SwiftUI
import UIKit
import MapKit

struct VetClinicDetails: View {
    let item: PlaceModel

    @Environment(PetStore.self) var petStore
    @Environment(\.dismiss) private var dismiss
    
    private var isSaved: Bool {
        petStore.savedVets.contains { $0.name == item.name }
    }
    
    private var isCallEnabled: Bool {
        if let phone = item.phone {
            let cleaned = phone.filter { "+0123456789".contains($0) }
            return !cleaned.isEmpty
        }
        return false
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
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                // MARK: - Header
                ZStack(alignment: .center) {
                    // Center Titles
                    VStack(spacing: 6) {
                        Text(item.name)
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(.primary)
                            .multilineTextAlignment(.center)
                        
                        HStack(spacing: 8) {
                            Text(item.displayCategoryName)
                                .font(.system(size: 14))
                                .foregroundStyle(.gray)
                            
                            Text("•")
                                .font(.system(size: 14))
                                .foregroundStyle(.gray)
                            
                            HStack(spacing: 4) {
                                Image(systemName: "star.fill")
                                    .font(.system(size: 12))
                                    .foregroundStyle(Color(hex: "6E54D7") ?? .purple)
                                
                                Text("\(mockRating)")
                                    .font(.system(size: 14))
                                    .foregroundStyle(.gray)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 48)
                    
                    // Buttons Row
                    HStack {
                        // Bookmark / Save Button
                        Button {
                            Task {
                                await petStore.toggleSaveVet(
                                    name: item.name,
                                    address: item.address ?? "",
                                    phone: item.phone ?? "",
                                    latitude: item.latitude,
                                    longitude: item.longitude
                                )
                            }
                        } label: {
                            Image(systemName: isSaved ? "bookmark.fill" : "bookmark")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundStyle(isSaved ? Color("baseColor") : .primary)
                                .frame(width: 36, height: 36)
                                .background(Color(.systemGray6))
                                .clipShape(Circle())
                        }
                        
                        Spacer()
                        
                        // Close / Dismiss Button
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "xmark")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundStyle(.secondary)
                                .frame(width: 36, height: 36)
                                .background(Color(.systemGray6))
                                .clipShape(Circle())
                        }
                    }
                }
                .padding(.top, 24)
                
                // MARK: - Quick Action Buttons
                HStack(spacing: 12) {
                    // Direction Button
                    Button {
                        openMapsForDirections()
                    } label: {
                        VStack(spacing: 6) {
                            Image(systemName: "location.fill")
                                .font(.system(size: 20))
                            Text(item.distanceString)
                                .font(.system(size: 14))
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color("baseColor"))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    
                    // Call Button
                    Button {
                        if let phone = item.phone {
                            let cleanedPhone = phone.filter { "+0123456789".contains($0) }
                            if let url = URL(string: "tel://\(cleanedPhone)") {
                                UIApplication.shared.open(url)
                            }
                        }
                    } label: {
                        VStack(spacing: 6) {
                            Image(systemName: "phone.fill")
                                .font(.system(size: 20))
                            Text(isCallEnabled ? "Call" : "Unavailable")
                                .font(.system(size: 14))
                        }
                        .foregroundStyle(Color("baseColor"))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color("baseColor").opacity(0.15))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .disabled(!isCallEnabled)
                    .opacity(isCallEnabled ? 1.0 : 0.6)
                    
                    // Website Button
                    Button {
                        if let url = item.websiteURL {
                            UIApplication.shared.open(url)
                        }
                    } label: {
                        VStack(spacing: 6) {
                            Image(systemName: "globe")
                                .font(.system(size: 20))
                            Text(item.websiteURL != nil ? "Website" : "Unavailable")
                                .font(.system(size: 14))
                        }
                        .foregroundStyle(Color("baseColor"))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color("baseColor").opacity(0.15))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .disabled(item.websiteURL == nil)
                    .opacity(item.websiteURL != nil ? 1.0 : 0.6)
                }
                
                // MARK: - Details Section
                VStack(alignment: .leading, spacing: 16) {
                    Text("Details")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(.primary)
                    
                    VStack(spacing: 0) {
                        detailRow(title: "Phone", value: item.phone ?? "Not available")
                        detailRow(title: "Website", value: item.websiteURL?.absoluteString ?? "Not available")
                        detailRow(title: "Address", value: item.address ?? "Not available")
                        detailRow(title: "Timing", value: "Not available", isLast: true)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Spacer(minLength: 40)
            }
            .padding(.horizontal, 20)
        }
        .background(Color(uiColor: .systemBackground))
        .presentationDragIndicator(.visible)
        .presentationDetents([.large, .fraction(0.9)])
    }
    
    // MARK: - Helpers

    private func openMapsForDirections() {
        if let mapItem = item.mapItem {
            mapItem.openInMaps(launchOptions: [
                MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving
            ])
        } else {
            // Fallback using modern iOS 26.0+ API
            let location = CLLocation(latitude: item.latitude, longitude: item.longitude)
            let destination = MKMapItem(location: location, address: nil)
            destination.name = item.name
            destination.openInMaps(launchOptions: [
                MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving
            ])
        }
    }

    private func detailRow(title: String, value: String, isLast: Bool = false) -> some View {
        VStack(spacing: 16) {
            HStack(alignment: .top) {
                Text(title)
                    .font(.system(size: 16))
                    .foregroundStyle(.gray)
                    .frame(width: 80, alignment: .leading)
                
                Spacer()
                
                Text(value)
                    .font(.system(size: 16))
                    .foregroundStyle(Color("baseColor"))
                    .multilineTextAlignment(.trailing)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            if !isLast {
                Divider()
            }
        }
        .padding(.top, isLast ? 0 : 8)
    }
}

#Preview {
    VetClinicDetails(item: PlaceModel(
        name: "PupiLife Pet Clinic",
        latitude: 28.6139,
        longitude: 77.2090,
        distance: 4.5,
        category: .vet,
        address: "Netaji Subhash Marg, Jama Masjid Area, New Delhi"
    ))
}
