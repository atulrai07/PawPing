//
//  TypingIndicatorView.swift
//  PawPing
//

import SwiftUI

struct TypingIndicatorView: View {
    @State private var animate = false

    var body: some View {
        HStack(spacing: 5) {
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .fill(Color("secondaryText").opacity(0.5))
                    .frame(width: 8, height: 8)
                    .scaleEffect(animate ? 1.0 : 0.5)
                    .animation(
                        .easeInOut(duration: 0.5)
                        .repeatForever()
                        .delay(Double(index) * 0.18),
                        value: animate
                    )
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color("cardBackground"))
        .clipShape(ChatBubbleShape(isUser: false))
        .shadow(color: .black.opacity(0.06), radius: 5, x: 0, y: 2)
        .onAppear { animate = true }
    }
}
