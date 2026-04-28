import SwiftUI
import MapKit

struct FacilityRowView: View {
    let item: NearbyFacilityViewModel.FacilityItem
    var onTap: () -> Void
    
    // Mock data for UI demo as in screenshot (Apple MapKit does not provide ratings)
    private let mockRating: String = String(format: "%.1f", Double.random(in: 4.5...5.0))
    
    private var realDistance: String {
        item.distance ?? "Distance unknown"
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // MARK: Content Area (Tappable)
            Button(action: onTap) {
                VStack(alignment: .leading, spacing: 0) {
                    // MARK: Header with Badges
                    HStack {
                        Text(item.mapItem.name ?? "Facility")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(.primary)
                            .lineLimit(1)
                        
                        Spacer()
                        
                        // Real Distance Badge
                        HStack(spacing: 4) {
                            Image(systemName: "location.fill")
                                .font(.system(size: 10))
                            Text(realDistance)
                                .font(.system(size: 11, weight: .bold))
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.blue.opacity(0.1))
                        .foregroundStyle(Color.blue)
                        .clipShape(Capsule())
                    }
                    .padding([.horizontal, .top], 16)
                    
                    // MARK: Address & Info
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(alignment: .top, spacing: 6) {
                            Image(systemName: "mappin.and.ellipse")
                                .font(.system(size: 14))
                                .foregroundStyle(.secondary)
                            
                            Text(item.mapItem.placemark.title ?? "Nearby location")
                                .font(.system(size: 13))
                                .foregroundStyle(.secondary)
                                .lineLimit(2)
                                .multilineTextAlignment(.leading)
                        }
                        
                        HStack(spacing: 12) {
                            // Rating UI
                            HStack(spacing: 3) {
                                Image(systemName: "star.fill")
                                    .foregroundStyle(.orange)
                                Text(mockRating)
                                    .fontWeight(.semibold)
                            }
                            .font(.system(size: 13))
                            
                            if let phone = item.mapItem.phoneNumber {
                                HStack(spacing: 4) {
                                    Image(systemName: "phone.fill")
                                    Text(phone)
                                }
                                .font(.system(size: 13))
                                .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .padding(.bottom, 16)
                }
            }
            .buttonStyle(.plain)
            
            // MARK: Action Footer
            Divider()
            
            HStack(spacing: 0) {
                // Call Button
                if let phone = item.mapItem.phoneNumber, let url = URL(string: "tel://\(phone.replacingOccurrences(of: " ", with: ""))") {
                    Link(destination: url) {
                        HStack {
                            Image(systemName: "phone.circle.fill")
                            Text("Call")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(Color.blue)
                    
                    Divider().frame(height: 24)
                }
                
                // Directions Button
                Button {
                    item.mapItem.openInMaps(launchOptions: [
                        MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving
                    ])
                } label: {
                    HStack {
                        Image(systemName: "arrow.triangle.turn.up.right.circle.fill")
                        Text("Directions")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                }
                .buttonStyle(.plain)
                .foregroundStyle(.primary)
            }
            .background(Color(.systemGray6).opacity(0.5))
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: Color.black.opacity(0.06), radius: 10, x: 0, y: 4)
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }
}
