//
//  DietAssistantView.swift
//  PawPing
//

import SwiftUI

struct DietAssistantView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(DietAssistantStore.self) var store
    
    @State private var inputText: String = ""
    @FocusState private var isInputFocused: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(.primary)
                }
                
                Spacer()
                
                Text("Diet & Health Assistant")
                    .font(.system(size: 18, weight: .bold))
                
                Spacer()
                
                // Invisible placeholder to center title
                Image(systemName: "chevron.left")
                    .font(.system(size: 20, weight: .semibold))
                    .opacity(0)
            }
            .padding()
            .background(Color("baseBackground"))
            
            // Chat Area
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(store.messages) { message in
                            ChatBubbleView(message: message)
                                .id(message.id)
                        }
                        
                        if store.isTyping {
                            TypingIndicatorView()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.leading, 16)
                                .id("TypingIndicator")
                        }
                    }
                    .padding()
                }
                .onChange(of: store.messages.count) {
                    if let lastId = store.messages.last?.id {
                        withAnimation {
                            proxy.scrollTo(lastId, anchor: .bottom)
                        }
                    }
                }
                .onChange(of: store.isTyping) {
                    if store.isTyping {
                        withAnimation {
                            proxy.scrollTo("TypingIndicator", anchor: .bottom)
                        }
                    }
                }
            }
            
            // Suggested Prompts
            if store.messages.count < 3 {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(store.suggestedPrompts, id: \.self) { prompt in
                            Button {
                                store.sendMessage(prompt)
                            } label: {
                                Text(prompt)
                                    .font(.system(size: 13, weight: .medium))
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(Color("cardBackground"))
                                    .clipShape(Capsule())
                                    .overlay(
                                        Capsule()
                                            .stroke(Color("baseColor").opacity(0.3), lineWidth: 1)
                                    )
                                    .foregroundStyle(Color("baseColor"))
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 8)
                }
            }
            
            // Input Area
            VStack {
                Divider()
                HStack(alignment: .bottom, spacing: 12) {
                    TextField("Ask about diet or health...", text: $inputText, axis: .vertical)
                        .font(.system(size: 16))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(Color("cardBackground"))
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .focused($isInputFocused)
                        .lineLimit(1...5)
                    
                    Button {
                        let text = inputText
                        inputText = ""
                        store.sendMessage(text)
                    } label: {
                        Circle()
                            .fill(inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Color.gray.opacity(0.3) : Color("baseColor"))
                            .frame(width: 44, height: 44)
                            .overlay(
                                Image(systemName: "arrow.up")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundStyle(.white)
                            )
                    }
                    .disabled(inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                .padding()
            }
            .background(Color("baseBackground"))
        }
        .navigationBarHidden(true)
        .background(Color("secondaryCardBackground").ignoresSafeArea())
    }
}

struct ChatBubbleView: View {
    let message: ChatMessage
    
    var body: some View {
        HStack {
            if message.isUser {
                Spacer()
            } else {
                Circle()
                    .fill(Color("baseColor").opacity(0.2))
                    .frame(width: 32, height: 32)
                    .overlay(
                        Image(systemName: "sparkles")
                            .font(.system(size: 14))
                            .foregroundStyle(Color("baseColor"))
                    )
            }
            
            Text(message.text)
                .font(.system(size: 15))
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(message.isUser ? Color("baseColor") : Color("cardBackground"))
                .foregroundStyle(message.isUser ? .white : .primary)
                .clipShape(ChatBubbleShape(isUser: message.isUser))
                .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
            
            if !message.isUser {
                Spacer()
            }
        }
    }
}

struct ChatBubbleShape: Shape {
    var isUser: Bool
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: [
                .topLeft,
                .topRight,
                isUser ? .bottomLeft : .bottomRight
            ],
            cornerRadii: CGSize(width: 16, height: 16)
        )
        return Path(path.cgPath)
    }
}

struct TypingIndicatorView: View {
    @State private var dot1 = false
    @State private var dot2 = false
    @State private var dot3 = false
    
    var body: some View {
        HStack {
            Circle()
                .fill(Color("baseColor").opacity(0.2))
                .frame(width: 32, height: 32)
                .overlay(
                    Image(systemName: "sparkles")
                        .font(.system(size: 14))
                        .foregroundStyle(Color("baseColor"))
                )
            
            HStack(spacing: 4) {
                Circle().fill(Color.gray).frame(width: 6, height: 6).opacity(dot1 ? 1 : 0.3)
                Circle().fill(Color.gray).frame(width: 6, height: 6).opacity(dot2 ? 1 : 0.3)
                Circle().fill(Color.gray).frame(width: 6, height: 6).opacity(dot3 ? 1 : 0.3)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color("cardBackground"))
            .clipShape(ChatBubbleShape(isUser: false))
            .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
        }
        .onAppear {
            animate()
        }
    }
    
    private func animate() {
        withAnimation(.easeInOut(duration: 0.4).repeatForever()) { dot1 = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.easeInOut(duration: 0.4).repeatForever()) { dot2 = true }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            withAnimation(.easeInOut(duration: 0.4).repeatForever()) { dot3 = true }
        }
    }
}
