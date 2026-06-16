//
//  TraitBarView.swift
//  PawPing
//

import SwiftUI

struct TraitBarView: View {
    let title: String
    let lowLabel: String
    let highLabel: String
    let score: Int
    
    @State private var animatedScore: Int = 0
    
    private let segmentHeight: CGFloat = 10
    private let cornerRadius: CGFloat = 8
    private let spacing: CGFloat = 6
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundStyle(.primary)
            
            HStack {
                Text(lowLabel)
                Spacer()
                Text(highLabel)
            }
            .font(.caption)
            .foregroundStyle(.secondary)
            
            HStack(spacing: spacing) {
                ForEach(1...5, id: \.self) { index in
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(index <= animatedScore ? Color("baseColor") : Color("baseColor").opacity(0.2))
                        .frame(height: segmentHeight)
                        .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(.vertical, 4)
        .onAppear {
            // HIG: Animate the bar fill on appear for a premium feel
            withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                animatedScore = score
            }
        }
    }
}

#Preview {
    TraitBarView(
        title: "Energy Level",
        lowLabel: "Couch Potato",
        highLabel: "High Energy",
        score: 4
    )
    .padding()
}
