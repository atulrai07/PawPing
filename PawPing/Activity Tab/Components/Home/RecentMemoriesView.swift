//
//  RecentMemoriesView.swift
//  PawPing
//

import SwiftUI

struct MemoryItem: Identifiable {
    var id = UUID()
    var title: String
    var description: String
    var dateString: String
    var images: [String]
    var displayType: MemoryDisplayType
    var totalPhotos: Int
}

enum MemoryDisplayType {
    case collage
    case cards
}

struct RecentMemoriesView: View {
    // Hardcoded placeholder memories for demo purposes
    private let memories: [MemoryItem] = [
        MemoryItem(
            title: "Central Park",
            description: "Morning walk",
            dateString: "Yesterday",
            images: ["memory1", "memory2", "memory3"],
            displayType: .collage,
            totalPhotos: 23
        ),
        MemoryItem(
            title: "Sunny Beach",
            description: "Afternoon run",
            dateString: "2 days ago",
            images: ["memory2", "memory1", "memory3"],
            displayType: .cards,
            totalPhotos: 8
        ),
        MemoryItem(
            title: "Vet Visit",
            description: "Routine checkup",
            dateString: "Last week",
            images: [], // Empty state
            displayType: .collage,
            totalPhotos: 0
        )
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Recent Memories")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(Color(hex: "1C1B1F") ?? .black)
                
                Spacer()
                
                Button {
                    // View all action
                } label: {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(Color(hex: "6E54D7") ?? .orange)
                }
            }
            .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(memories) { memory in
                        MemoryCard(memory: memory)
                    }
                    
                    // Add Memory Button/Card
                    Button {
                        // Action to add memory
                    } label: {
                        VStack(spacing: 8) {
                            Image(systemName: "camera.fill")
                                .font(.system(size: 24))
                                .foregroundColor(Color(hex: "6E54D7") ?? .orange)
                            
                            Text("Add")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(Color(hex: "6E54D7") ?? .orange)
                        }
                        .frame(width: 140, height: 140)
                        .background((Color(hex: "6E54D7") ?? .orange).opacity(0.08))
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

struct MemoryCard: View {
    let memory: MemoryItem
    
    var body: some View {
        HStack(spacing: 12) {
            // Left Side: Image/Collage/Card Stack area
            Group {
                if memory.images.isEmpty {
                    // Empty State/No Pic Message - centered horizontally and vertically
                    VStack(spacing: 6) {
                        Image(systemName: "photo.on.rectangle.angled")
                            .font(.system(size: 24))
                            .foregroundColor(.gray.opacity(0.8))
                        Text("No pic")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.gray.opacity(0.8))
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    .background(Color(hex: "F2F2F7") ?? Color(.systemGray6))
                } else if memory.displayType == .collage && memory.images.count >= 3 {
                    // Collage Layout
                    HStack(spacing: 2) {
                        Image(memory.images[0])
                            .resizable()
                            .scaledToFill()
                            .frame(width: 80, height: 140)
                            .clipped()
                        
                        VStack(spacing: 2) {
                            Image(memory.images[1])
                                .resizable()
                                .scaledToFill()
                                .frame(width: 58, height: 69)
                                .clipped()
                            Image(memory.images[2])
                                .resizable()
                                .scaledToFill()
                                .frame(width: 58, height: 69)
                                .clipped()
                        }
                    }
                } else if memory.displayType == .cards {
                    // Cards Stack Layout
                    ZStack {
                        Color.clear // Container boundaries
                        
                        ForEach(0..<min(memory.images.count, 3), id: \.self) { idx in
                            Image(memory.images[idx])
                                .resizable()
                                .scaledToFill()
                                .frame(width: 105, height: 105)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                .shadow(color: .black.opacity(0.12), radius: 4, x: 0, y: 2)
                                .rotationEffect(.degrees(Double(idx - 1) * 8.0))
                                .offset(x: CGFloat(idx - 1) * 8, y: CGFloat(idx - 1) * 2)
                        }
                    }
                } else {
                    // Fallback Single Image Layout
                    Image(memory.images[0])
                        .resizable()
                        .scaledToFill()
                        .frame(width: 140, height: 140)
                        .clipped()
                }
            }
            .frame(width: 140, height: 140)
            .clipShape(RoundedRectangle(cornerRadius: 24))
            
            // Right Side: Info Details
            VStack(alignment: .leading, spacing: 6) {
                Text(memory.dateString)
                    .font(.system(size: 13))
                    .foregroundColor(Color.homeTextGray)
                
                Text(memory.title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Color.homeTextDark)
                    .lineLimit(1)
                
                Text(memory.description)
                    .font(.system(size: 13))
                    .foregroundColor(Color.homeTextGray)
                    .lineLimit(1)
                
                Spacer(minLength: 0)
                
                HStack(spacing: 4) {
                    Image(systemName: "photo.stack")
                        .font(.system(size: 14))
                    Text(memory.totalPhotos > 0 ? "\(memory.totalPhotos) photos" : "0 photos")
                        .font(.system(size: 13, weight: .medium))
                    Image(systemName: "chevron.right")
                        .font(.system(size: 11, weight: .bold))
                }
                .foregroundColor(Color.homeTextDark.opacity(0.8))
                .padding(.top, 4)
            }
            .frame(width: 130, alignment: .leading)
            .padding(.vertical, 14)
            .padding(.trailing, 14)
        }
        .frame(width: 296, height: 140)
        .background(Color(hex: "F8F9FB") ?? Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }
}

#Preview {
    RecentMemoriesView()
}

