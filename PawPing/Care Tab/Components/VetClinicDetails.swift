//
//  VetClinicDetails.swift
//  PawPing
//
//  Created by Atul on 23/03/26.
//

import SwiftUI
import UIKit
import MapKit

struct BusinessHours {
    let isOpen: Bool
    let statusText: String
    let statusColor: Color
    let todayHoursText: String
    let schedule: [String: String]
}

struct VetClinicDetails: View {
    let item: PlaceModel

    @Environment(PetStore.self) var petStore
    @Environment(\.dismiss) private var dismiss
    
    @State private var showNormalHours = false
    
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
    
    private var businessHours: BusinessHours {
        let calendar = Calendar.current
        let now = Date()
        let currentHour = calendar.component(.hour, from: now)
        let weekday = calendar.component(.weekday, from: now) // 1 = Sunday, 2 = Monday, ...
        
        let openHour: Int
        let closeHour: Int
        
        switch item.category {
        case .vet:
            openHour = 9
            closeHour = 18 // 9:00 AM - 6:00 PM
        case .dayCare:
            openHour = 8
            closeHour = 18 // 8:00 AM - 6:00 PM
        case .grooming:
            openHour = 10
            closeHour = 19 // 10:00 AM - 7:00 PM
        case .petStore:
            openHour = 10
            closeHour = 21 // 10:00 AM - 9:00 PM
        case .outdoor:
            openHour = 6
            closeHour = 22 // 6:00 AM - 10:00 PM
        case .all:
            openHour = 9
            closeHour = 18
        }
        
        let isSundayClosed = (item.category != .outdoor && item.category != .petStore)
        let isSaturdayClosed = (item.category == .vet)
        
        let isClosedToday: Bool
        if weekday == 1 { // Sunday
            isClosedToday = isSundayClosed
        } else if weekday == 7 { // Saturday
            isClosedToday = isSaturdayClosed
        } else {
            isClosedToday = false
        }
        
        let isOpen = !isClosedToday && (currentHour >= openHour && currentHour < closeHour)
        
        let statusText = isOpen ? "Open" : "Closed"
        let statusColor = isOpen ? Color.green : Color.red
        
        let todayHoursText: String
        if isClosedToday {
            todayHoursText = "Closed"
        } else {
            todayHoursText = "\(formatHour(openHour)) – \(formatHour(closeHour))"
        }
        
        var schedule: [String: String] = [:]
        schedule["Sunday"] = isSundayClosed ? "Closed" : "\(formatHour(openHour)) – \(formatHour(closeHour))"
        schedule["Mon – Fri"] = "\(formatHour(openHour)) – \(formatHour(closeHour))"
        schedule["Saturday"] = isSaturdayClosed ? "Closed" : "\(formatHour(openHour)) – \(formatHour(closeHour - 2 >= openHour ? closeHour - 2 : closeHour))"
        
        return BusinessHours(
            isOpen: isOpen,
            statusText: statusText,
            statusColor: statusColor,
            todayHoursText: todayHoursText,
            schedule: schedule
        )
    }
    
    private func formatHour(_ hour: Int) -> String {
        if hour == 12 { return "12:00 PM" }
        if hour > 12 { return "\(hour - 12):00 PM" }
        return "\(hour):00 AM"
    }
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // MARK: - Header
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
                                    .foregroundStyle(item.category.displayColor)
                                
                                Text("\(mockRating)")
                                    .font(.system(size: 14))
                                    .foregroundStyle(.gray)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 48)
                    .padding(.top, 16)
                    
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
                                Image(systemName: "safari")
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
                    
                    // MARK: - Hours Section
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Hours")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundStyle(.primary)
                            
                            Spacer()
                        }
                        
                        let hours = businessHours
                        
                        HStack {
                            Text(hours.statusText)
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(hours.statusColor)
                            
                            Spacer()
                            
                            Text(hours.todayHoursText)
                                .font(.system(size: 16))
                                .foregroundStyle(.primary)
                        }
                        .padding(.top, 4)
                        
                        Button {
                            withAnimation {
                                showNormalHours.toggle()
                            }
                        } label: {
                            HStack {
                                Text("Normal Hours")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundStyle(.secondary)
                                
                                Image(systemName: showNormalHours ? "chevron.up" : "chevron.down")
                                    .font(.system(size: 12))
                                    .foregroundStyle(.secondary)
                                
                                Spacer()
                            }
                        }
                        .buttonStyle(.plain)
                        .padding(.top, 8)
                        
                        if showNormalHours {
                            VStack(spacing: 12) {
                                ForEach(["Sunday", "Mon – Fri", "Saturday"], id: \.self) { day in
                                    HStack {
                                        Text(day)
                                            .font(.system(size: 14))
                                            .foregroundStyle(.secondary)
                                        
                                        Spacer()
                                        
                                        Text(hours.schedule[day] ?? "")
                                            .font(.system(size: 14))
                                            .foregroundStyle(.primary)
                                    }
                                }
                            }
                            .padding(.leading, 8)
                            .padding(.top, 4)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // MARK: - Details Section
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Details")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundStyle(.primary)
                            
                            Spacer()
                        }
                        
                        VStack(spacing: 0) {
                            detailRow(
                                title: "Phone",
                                value: item.phone ?? "Not available",
                                isLink: isCallEnabled
                            ) {
                                if let phone = item.phone {
                                    let cleanedPhone = phone.filter { "+0123456789".contains($0) }
                                    if let url = URL(string: "tel://\(cleanedPhone)") {
                                        UIApplication.shared.open(url)
                                    }
                                }
                            }
                            detailRow(
                                title: "Website",
                                value: item.websiteURL?.absoluteString ?? "Not available",
                                isLink: item.websiteURL != nil
                            ) {
                                if let url = item.websiteURL {
                                    UIApplication.shared.open(url)
                                }
                            }
                            detailRow(
                                title: "Address",
                                value: item.address ?? "Not available",
                                isLast: true
                            )
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 20)
            }
            .background(Color(uiColor: .systemBackground))
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
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
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }
                }
            }
        }
        .presentationDragIndicator(.visible)
        .presentationDetents([.large, .fraction(0.75)])
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

    private func detailRow(
        title: String,
        value: String,
        isLink: Bool = false,
        isLast: Bool = false,
        action: (() -> Void)? = nil
    ) -> some View {
        VStack(spacing: 16) {
            HStack(alignment: .top) {
                Text(title)
                    .font(.system(size: 16))
                    .foregroundStyle(.secondary)
                    .frame(width: 80, alignment: .leading)
                
                Spacer()
                
                if isLink, let action = action {
                    Button(action: action) {
                        Text(value)
                            .font(.system(size: 16))
                            .foregroundStyle(Color.blue)
                            .multilineTextAlignment(.trailing)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .buttonStyle(.plain)
                } else {
                    Text(value)
                        .font(.system(size: 16))
                        .foregroundStyle(.primary)
                        .multilineTextAlignment(.trailing)
                        .fixedSize(horizontal: false, vertical: true)
                }
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
