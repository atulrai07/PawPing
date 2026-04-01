//
//  VaccineCardView.swift
//  PawPing
//
//  Created by Antigravity on 01/04/26.
//

import SwiftUI

struct VaccineCardView: View {
    var store: ActivityStore
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 28)
                .fill(Color("cardBackground"))
                .frame(width: 175, height: 190)
            
            VStack(alignment: .leading) {
                HStack {
                    Text("Upcoming")
                        .font(.system(size: 22, weight: .regular))
                    
                    Spacer()
                }
                .padding(.trailing, 4) // Slight adjustment for chevron
                
                Spacer()
                
                Image(systemName: "syringe")
                    .foregroundStyle(Color("baseColor"))
                    .rotationEffect(.degrees(270))
                    .font(.system(size: 65))
                
                Spacer()
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(store.vaccines.first?.name ?? "No vaccine")
                        .font(.system(size: 18, weight: .medium))
                    
                    Text("\(store.vaccines.first?.daysLeft ?? 0) days left")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Color("secondaryText"))
                }
            }
            .padding(16)
            .frame(width: 175, height: 190, alignment: .leading)
        }
    }
}

#Preview {
    VaccineCardView(store: ActivityStore())
}
