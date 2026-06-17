//
//  RecentMemoriesView.swift
//  PawPing
//

import SwiftUI

struct RecentMemoriesView: View {
    // Hardcoded placeholder images for demo purposes
    private let placeholderImages = ["memory1", "memory2", "memory3"]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Recent Memories")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(Color(hex: "1C1B1F") ?? .black)
                
                Spacer()
                
                Text("View All")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.orange)
            }
            .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(0..<placeholderImages.count, id: \.self) { index in
                        Image(placeholderImages[index])
                            .resizable()
                            .scaledToFill()
                            .frame(width: 140, height: 120)
                            .clipShape(RoundedRectangle(cornerRadius: 24))
                            .overlay(alignment: .topTrailing) {
                                Image(systemName: "heart")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.white)
                                    .padding(12)
                            }
                    }
                    
                    // Add Memory Button/Card
                    Button {
                        // Action to add memory
                    } label: {
                        VStack(spacing: 8) {
                            Image(systemName: "camera.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.orange)
                            
                            Text("Add")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.orange)
                        }
                        .frame(width: 140, height: 120)
                        .background(Color.orange.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

#Preview {
    RecentMemoriesView()
}
