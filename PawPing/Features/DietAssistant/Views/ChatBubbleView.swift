//
//  ChatBubbleView.swift
//  PawPing
//

import SwiftUI

// MARK: - Bubble Shape

struct ChatBubbleShape: Shape {
    var isUser: Bool

    func path(in rect: CGRect) -> Path {
        let corners: UIRectCorner = isUser
            ? [.topLeft, .topRight, .bottomLeft]
            : [.topLeft, .topRight, .bottomRight]
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: 18, height: 18)
        )
        return Path(path.cgPath)
    }
}

// MARK: - Bubble View

struct ChatBubbleView: View {
    let message: DietChatMessage

    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            if message.isUser {
                Spacer(minLength: 0)
            }
            
            if !message.isUser {
                // Assistant avatar
                ZStack {
                    Circle()
                        .fill(Color("baseColor").opacity(0.12))
                        .frame(width: 32, height: 32)
                    Image(systemName: "sparkles")
                        .font(.system(size: 14))
                        .foregroundStyle(Color("baseColor"))
                }
            }

            Text(.init(message.text))
                .font(.system(size: 15))
                .foregroundStyle(message.isUser ? .white : .primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    message.isUser
                        ? Color("baseColor")
                        : Color("cardBackground")
                )
                .clipShape(ChatBubbleShape(isUser: message.isUser))
                .shadow(
                    color: message.isUser ? Color("baseColor").opacity(0.3) : .black.opacity(0.06),
                    radius: 6, x: 0, y: 3
                )
                .frame(
                    maxWidth: 280,
                    alignment: message.isUser ? .trailing : .leading
                )

            if !message.isUser {
                Spacer(minLength: 0)
            }
        }
        .frame(maxWidth: .infinity, alignment: message.isUser ? .trailing : .leading)
        .padding(.horizontal, 16)
    }
}
