//
//  DietAssistantStore.swift
//  PawPing
//

import Foundation
import Observation
import FoundationModels

struct ChatMessage: Identifiable {
    let id = UUID()
    let text: String
    let isUser: Bool
}

@Observable
@available(iOS 26.0, macOS 15.0, *)
class DietAssistantStore {

    // MARK: - State (unchanged)
    var messages: [ChatMessage] = []
    var isTyping: Bool = false
    var suggestedPrompts: [String] = [
        "What vegetables are safe for dogs?",
        "How much water should my dog drink?",
        "Can dogs eat rice and chicken daily?",
        "What foods are toxic to dogs?"
    ]

    // MARK: - Foundation Models Session
    // Created once and reused — constructing a session is expensive.
    private let session: LanguageModelSession = {
        let instructions = """
        You are PawPing's dog diet and nutrition assistant.
        You only answer questions about dog food, nutrition, diet plans,
        feeding schedules, safe and unsafe foods, and general dog health habits.
        Keep answers concise (3–5 sentences max), friendly, and practical.
        If a question is unrelated to dogs or dog nutrition, politely say
        you can only help with dog diet and health topics.
        Never give emergency medical diagnoses — refer serious health concerns to a vet.
        """
        return LanguageModelSession(instructions: instructions)
    }()

    // MARK: - Send Message
    @MainActor
    func sendMessage(_ text: String) {
        guard !text.trimmingCharacters(in: .whitespaces).isEmpty else { return }

        // Append user message
        messages.append(ChatMessage(text: text, isUser: true))
        isTyping = true

        Task {
            defer { isTyping = false }     // Always clears, even on error

            do {
                let response = try await session.respond(to: text)
                messages.append(ChatMessage(text: response.content, isUser: false))
            } catch {
                messages.append(ChatMessage(
                    text: "Sorry, I'm having trouble responding right now. Please try again.",
                    isUser: false
                ))
            }
        }
    }
}
