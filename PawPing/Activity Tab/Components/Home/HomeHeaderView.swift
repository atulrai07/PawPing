//
//  HomeHeaderView.swift
//  PawPing
//

import SwiftUI

struct HomeHeaderView: View {
    @Environment(PetStore.self) var petStore
    var onPetSelect: () -> Void = {}
    
    var body: some View {
        HStack(alignment: .center) {
            Button(action: onPetSelect) {
                HStack(alignment: .center, spacing: 8) {
                    Text(petStore.activePet?.name ?? "Luna")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundColor(Color(hex: "1C1B1F") ?? .black)
                    
                    Image(systemName: "chevron.down")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(Color.gray)
                        .padding(.top, 4)
                }
            }
            .buttonStyle(.plain)
            
            Spacer()

            
            HStack(spacing: 20) {
                // Notification Bell
                ZStack(alignment: .topTrailing) {
                    Image(systemName: "bell")
                        .font(.system(size: 22))
                        .foregroundColor(.black)
                    
                    Circle()
                        .fill(Color.red)
                        .frame(width: 8, height: 8)
                        .offset(x: 1, y: -1)
                }
                
                // Avatar
                Group {
                    if let avatarUrl = petStore.activePet?.profileImageUrl, let url = URL(string: avatarUrl) {
                        AsyncImage(url: url) { image in
                            image.resizable().scaledToFill()
                        } placeholder: {
                            Color.gray.opacity(0.2)
                        }
                    } else {
                        Image("placeholder_dog")
                            .resizable()
                            .scaledToFill()
                    }
                }
                .frame(width: 56, height: 56)
                .clipShape(Circle())
            }
            .padding(.top, 4)
        }
    }
}

#Preview {
    HomeHeaderView()
        .environment(PetStore())
        .padding()
}
