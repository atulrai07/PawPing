import SwiftUI
import MapKit

struct FacilityDetailSheet: View {
    let item: MKMapItem
    let accentColor: Color
    @State private var isShowingMore = false
    @Environment(\.dismiss) private var dismiss
    
    // Mock data for UI demo (Apple MapKit does not provide ratings)
    private let mockRating: String = String(format: "%.1f", Double.random(in: 4.5...5.0))
    private let mockPetSeen: String = "\(Int.random(in: 100...999))+"
    private let mockExp: String = "\(Int.random(in: 2...15)) Years"
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // MARK: High-Res Map Snapshot Header
                    ZStack(alignment: .bottomTrailing) {
                        Map(initialPosition: .region(MKCoordinateRegion(
                            center: item.placemark.coordinate,
                            latitudinalMeters: 300,
                            longitudinalMeters: 300
                        ))) {
                            Marker(item.name ?? "Facility", coordinate: item.placemark.coordinate)
                                .tint(.red)
                        }
                        .mapStyle(.standard(emphasis: .muted))
                        .frame(height: 200)
                        .allowsHitTesting(false)
                        
                        Button {
                            item.openInMaps()
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "photo.on.rectangle.angled")
                                Text("View Photos in Maps")
                            }
                            .font(.system(size: 10, weight: .bold))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(.ultraThinMaterial)
                            .clipShape(Capsule())
                            .padding(12)
                        }
                    }
                    
                    // MARK: Header Info
                    VStack(spacing: 4) {
                        Text(item.name ?? "Facility")
                            .font(.system(size: 22, weight: .bold))
                            .multilineTextAlignment(.center)
                        
                        Text(item.pointOfInterestCategory?.rawValue.replacingOccurrences(of: "MKPOICategory", with: "") ?? "Services")
                            .font(.system(size: 14))
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, 20)
                    
                    // MARK: Stats Row
                    HStack(spacing: 0) {
                        statItem(label: "Rating", value: "\(mockRating) ★", color: .orange)
                        Divider().frame(height: 30)
                        statItem(label: "Pet Seen", value: mockPetSeen, color: .primary)
                        Divider().frame(height: 30)
                        statItem(label: "Experience", value: mockExp, color: .primary)
                    }
                    
                    // MARK: Action Buttons
                    HStack(spacing: 12) {
                        // Directions Button
                        Button {
                            item.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
                        } label: {
                            VStack(spacing: 4) {
                                Image(systemName: "location.north.fill")
                                Text("Directions")
                            }
                            .font(.system(size: 13, weight: .bold))
                            .frame(maxWidth: .infinity)
                            .frame(height: 60)
                            .background(Color.blue.opacity(0.8))
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                        
                        // Call Button
                        Button {
                            if let phone = item.phoneNumber, let url = URL(string: "tel://\(phone.replacingOccurrences(of: " ", with: ""))") {
                                UIApplication.shared.open(url)
                            }
                        } label: {
                            VStack(spacing: 4) {
                                Image(systemName: "phone.fill")
                                Text("Call")
                            }
                            .font(.system(size: 13, weight: .bold))
                            .frame(maxWidth: .infinity)
                            .frame(height: 60)
                            .background(Color.blue.opacity(0.1))
                            .foregroundStyle(Color.blue)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // MARK: Full Address Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Full Address")
                            .font(.system(size: 18, weight: .bold))
                        
                        Text(item.placemark.title ?? "Address not available")
                            .font(.system(size: 14))
                            .foregroundStyle(.secondary)
                            .lineLimit(isShowingMore ? nil : 3)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                    
                    // MARK: Details List
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Details")
                            .font(.system(size: 18, weight: .bold))
                            .padding(.bottom, 4)
                        
                        if let phone = item.phoneNumber {
                            detailRow(label: "Phone", value: phone)
                        }
                        
                        if let url = item.url {
                            detailRow(label: "Website", value: url.host() ?? "Visit Website")
                        }
                        
                        detailRow(label: "Category", value: item.pointOfInterestCategory?.rawValue.replacingOccurrences(of: "MKPOICategory", with: "") ?? "Services")
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
            }
            .background(Color.white)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .bold))
                            .padding(8)
                            .background(Color(.systemGray6))
                            .clipShape(Circle())
                    }
                }
            }
        }
    }
    
    private func statItem(label: String, value: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(color)
            Text(label)
                .font(.system(size: 12))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
    
    private func detailRow(label: String, value: String) -> some View {
        VStack(spacing: 12) {
            HStack {
                Text(label)
                    .foregroundStyle(.secondary.opacity(0.6))
                Spacer()
                Text(value)
                    .foregroundStyle(Color.blue.opacity(0.8))
            }
            .font(.system(size: 15, weight: .medium))
            
            Divider()
        }
    }
}

extension MKMapItem: @retroactive Identifiable {
    public var id: String {
        self.placemark.title ?? self.name ?? UUID().uuidString
    }
}
