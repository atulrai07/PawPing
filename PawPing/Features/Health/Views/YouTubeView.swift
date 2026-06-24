//
//  VideoTutorialCard.swift
//  PawPing
//

import SwiftUI

struct VideoTutorialCard: View {
    let videoID: String
    let title: String
    let accentColor: Color
    
    
    
    private var youtubeWebURL: URL? {
        URL(string: "https://www.youtube.com/watch?v=\(videoID)")
    }
    
    private var thumbnailURL: URL? {
        URL(string: "https://img.youtube.com/vi/\(videoID)/maxresdefault.jpg")
    }
    
    var body: some View {
        Button {
            openVideo()
        } label: {
            VStack(spacing: 0) {
                // Thumbnail with play overlay
                ZStack {
                    // Thumbnail image
                    AsyncImage(url: thumbnailURL) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(height: 175)
                                .clipped()
                        case .failure:
                            thumbnailPlaceholder
                        case .empty:
                            thumbnailPlaceholder
                                .overlay(
                                    ProgressView()
                                        .tint(.white)
                                )
                        @unknown default:
                            thumbnailPlaceholder
                        }
                    }
                    
                    // Dark gradient overlay for readability
                    LinearGradient(
                        colors: [.clear, .black.opacity(0.5)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    
                    // Play button
                    Circle()
                        .fill(.ultraThinMaterial)
                        .frame(width: 60, height: 60)
                        .overlay(
                            Image(systemName: "play.fill")
                                .font(.system(size: 24))
                                .foregroundStyle(.white)
                                .padding(.leading, 4) // Optical centering
                        )
                        .shadow(color: .black.opacity(0.3), radius: 8, y: 4)
                }
                .frame(height: 175)
                .clipped()
                
                // Bottom info bar
                HStack(spacing: 12) {
                    Image(systemName: "play.rectangle.fill")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(accentColor)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Watch: \(title)")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.primary)
                            .lineLimit(1)
                        
                        Text("Opens in YouTube")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "arrow.up.right.square")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color("cardBackground"))
            }
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.08), radius: 6, y: 3)
        }
        .buttonStyle(ScaleButtonStyle())
    }
    
    // MARK: - Placeholder
    
    private var thumbnailPlaceholder: some View {
        Rectangle()
            .fill(
                LinearGradient(
                    colors: [accentColor.opacity(0.3), accentColor.opacity(0.1)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .frame(height: 175)
            .overlay(
                VStack(spacing: 8) {
                    Text("Video Tutorial")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(.white.opacity(0.6))
                }
            )
    }
    
    // MARK: - Actions
    
    private func openVideo() {
        // Open via web URL — Safari/iOS will automatically redirect
        // to the YouTube app if it's installed on the device
        if let webURL = youtubeWebURL {
            UIApplication.shared.open(webURL)
        }
    }
}

#Preview {
    VideoTutorialCard(
        videoID: "0AFrTNK0Xck",
        title: "Dog CPR Tutorial",
        accentColor: .red
    )
    .padding()
}

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.spring(response: 0.3), value: configuration.isPressed)
    }
}
