//
//  CategoryCardView.swift
//  PawPing
//
//  Created by Antigravity on 24/04/26.
//
//  A large, guided health flow card for symptom categories.
//

import SwiftUI

struct CategoryCardView: View {
    let category: SymptomCategory
    @ViewBuilder
    var iconView: some View {
        if category == .digestive {
            Image("stomach")
                .resizable()
                .renderingMode(.template)
                .scaledToFit()
                .frame(width: 24, height: 24)
        } else {
            Image(systemName: category.systemImage)
                .font(.system(size: 24))
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            iconView
                .foregroundStyle(Color("baseColor"))
                .padding(12)
                .background(Color("baseColor").opacity(0.1))
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 4) {
                Text(category.rawValue)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(Color("baseColor"))
                
                Text(category.description)
                    .font(.system(size: 13))
                    .foregroundStyle(Color("secondaryText"))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color("cardBackground"))
        )
    }
}

#Preview {
    HStack(spacing: 16) {
        CategoryCardView(category: .digestive)
        CategoryCardView(category: .neurological)
    }
    .padding()
}
