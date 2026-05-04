//
//  DietAssistantView.swift
//  PawPing
//

import SwiftUI

struct DietAssistantView: View {
    @Environment(DietAssistantStore.self) var store
    @State private var inputText: String = ""
    @FocusState private var inputFocused: Bool

    var body: some View {
        NavigationStack {
            Group {
                if store.availability == .available {
                    chatView
                } else {
                    unavailableView
                }
            }
            .navigationTitle("Diet & Health Assistant")
            .navigationBarTitleDisplayMode(.inline)
            .background(Color("baseBackground"))
        }
    }

    // MARK: - Chat View

    private var chatView: some View {
        VStack(spacing: 0) {
            // Message list
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(store.messages) { message in
                            ChatBubbleView(message: message)
                                .id(message.id)
                        }

                        if store.isTyping {
                            HStack(alignment: .bottom, spacing: 8) {
                                ZStack {
                                    Circle()
                                        .fill(Color("baseColor").opacity(0.12))
                                        .frame(width: 32, height: 32)
                                    Image(systemName: "sparkles")
                                        .font(.system(size: 14))
                                        .foregroundStyle(Color("baseColor"))
                                }
                                TypingIndicatorView()
                                Spacer()
                            }
                            .padding(.horizontal, 16)
                            .id("typing")
                        }
                    }
                    .padding(.vertical, 16)
                }
                .onChange(of: store.messages.count) {
                    withAnimation(.spring(response: 0.3)) {
                        if store.isTyping {
                            proxy.scrollTo("typing", anchor: .bottom)
                        } else if let last = store.messages.last {
                            proxy.scrollTo(last.id, anchor: .bottom)
                        }
                    }
                }
                .onChange(of: store.isTyping) {
                    withAnimation(.spring(response: 0.3)) {
                        proxy.scrollTo("typing", anchor: .bottom)
                    }
                }
                .onTapGesture { inputFocused = false }
            }

            // Suggested prompts — hide after the user sends their first message
            if store.messages.count <= 1 {
                suggestedPromptsBar
            }

            Divider()

            // Input bar
            inputBar
        }
    }

    // MARK: - Suggested Prompts

    private var suggestedPromptsBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(store.suggestedPrompts, id: \.self) { prompt in
                    Button {
                        store.sendMessage(prompt)
                    } label: {
                        Text(prompt)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(Color("baseColor"))
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .stroke(Color("baseColor").opacity(0.4), lineWidth: 1)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
        }
    }

    // MARK: - Input Bar

    private var inputBar: some View {
        HStack(spacing: 12) {
            TextField("Ask about diet or health...", text: $inputText, axis: .vertical)
                .font(.system(size: 15))
                .lineLimit(1...5)
                .focused($inputFocused)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(Color("cardBackground"))
                .clipShape(Capsule())

            Button {
                let text = inputText
                inputText = ""
                inputFocused = false
                store.sendMessage(text)
            } label: {
                Image(systemName: "arrow.up")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 38, height: 38)
                    .background(
                        inputText.trimmingCharacters(in: .whitespaces).isEmpty
                            ? Color("secondaryText").opacity(0.3)
                            : Color("baseColor")
                    )
                    .clipShape(Circle())
            }
            .disabled(inputText.trimmingCharacters(in: .whitespaces).isEmpty || store.isTyping)
            .animation(.easeInOut(duration: 0.2), value: inputText.isEmpty)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color("baseBackground"))
    }

    // MARK: - Unavailable View

    private var unavailableView: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "sparkles")
                .font(.system(size: 64))
                .foregroundStyle(Color("baseColor").opacity(0.35))

            VStack(spacing: 10) {
                Text(unavailableTitle)
                    .font(.system(size: 22, weight: .bold))
                    .multilineTextAlignment(.center)

                Text(unavailableMessage)
                    .font(.system(size: 14))
                    .foregroundStyle(Color("secondaryText"))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .lineSpacing(4)
            }

            if store.availability == .appleIntelligenceDisabled {
                Button {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                } label: {
                    Text("Open Settings")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 32)
                        .padding(.vertical, 14)
                        .background(Color("baseColor"))
                        .clipShape(Capsule())
                }
            }

            if store.availability == .modelDownloading {
                HStack(spacing: 8) {
                    ProgressView()
                        .scaleEffect(0.8)
                    Text("Downloading AI model...")
                        .font(.system(size: 13))
                        .foregroundStyle(Color("secondaryText"))
                }
            }

            Spacer()
        }
    }

    private var unavailableTitle: String {
        switch store.availability {
        case .unsupportedDevice:         return "Device Not Supported"
        case .appleIntelligenceDisabled: return "Apple Intelligence is Off"
        case .modelDownloading:          return "Almost Ready"
        default:                         return "Assistant Unavailable"
        }
    }

    private var unavailableMessage: String {
        switch store.availability {
        case .unsupportedDevice:
            return "The Diet Assistant uses Apple's on-device AI which requires an iPhone 15 Pro, iPhone 15 Pro Max, or any iPhone 16 model."
        case .appleIntelligenceDisabled:
            return "Turn on Apple Intelligence in Settings to use the Diet Assistant. Everything runs on your device — private, fast, and free."
        case .modelDownloading:
            return "Apple Intelligence is enabled but the AI model is still downloading. Connect to Wi-Fi and try again in a few minutes."
        default:
            return "The Diet Assistant is not available right now. Please try again later."
        }
    }
}
