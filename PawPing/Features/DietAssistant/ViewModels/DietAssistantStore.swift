//
//  DietAssistantStore.swift
//  PawPing
//

import Foundation
import Observation
import FoundationModels

// MARK: - Model Availability

enum ModelAvailability: Equatable {
    case available
    case unsupportedDevice         // iPhone 15 standard or older
    case appleIntelligenceDisabled // Supported device, setting is off
    case modelDownloading          // Enabled but model not ready yet
    case unknown
}

// MARK: - Store

@Observable
class DietAssistantStore {

    // MARK: - State
    var messages: [ChatMessage] = []
    var isTyping: Bool = false
    var availability: ModelAvailability = .unknown

    var suggestedPrompts: [String] = [
        "What vegetables are safe for dogs?",
        "How much water should my dog drink?",
        "Can dogs eat rice and chicken daily?",
        "What foods are toxic to dogs?",
        "Is home-cooked food good for dogs?"
    ]

    // MARK: - Private
    private var session: LanguageModelSession?

    private let systemInstructions = """
        You are PawPing's dog diet and nutrition assistant.
        Only answer questions about dog food, nutrition, diet plans, feeding schedules, safe and unsafe foods, and general dog health habits.
        Keep answers highly readable and structured. Use Markdown formatting like **bolding** for key terms, and use bullet points where appropriate to make information easy to scannable and digestible.
        Be friendly, warm, and practical.
        If a question is unrelated to dogs or dog nutrition, politely say you can only help with dog diet and health topics.
        Never give medical diagnoses. Always refer serious health concerns to a vet.
        """

    // MARK: - Init
    init() {
        setupModel()
    }

    // MARK: - Setup

    private func setupModel() {
        let model = SystemLanguageModel.default

        switch model.availability {
        case .available:
            availability = .available
            session = LanguageModelSession(instructions: systemInstructions)
            
            // Add initial greeting message
            if messages.isEmpty {
                messages.append(ChatMessage(
                    text: "Hi there! 👋 I'm your PawPing Diet Assistant.\n\nI can help you build the perfect meal plan, check if certain human foods are safe, or answer general nutrition questions.\n\nHow can I help your pup today?",
                    isUser: false
                ))
            }

        case .unavailable(let reason):
            switch reason {
            case .deviceNotEligible:
                availability = .unsupportedDevice
            case .appleIntelligenceNotEnabled:
                availability = .appleIntelligenceDisabled
            case .modelNotReady:
                availability = .modelDownloading
            default:
                availability = .unknown
            }

        @unknown default:
            availability = .unknown
        }
    }

    // MARK: - Send Message

    @MainActor
    func sendMessage(_ text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        guard availability == .available, let session else { return }

        messages.append(ChatMessage(text: trimmed, isUser: true))
        isTyping = true

        Task {
            defer {
                Task { @MainActor in self.isTyping = false }
            }

            do {
                let response = try await session.respond(to: trimmed)
                await MainActor.run {
                    messages.append(ChatMessage(text: response.content, isUser: false))
                }

            } catch let error as LanguageModelSession.GenerationError {
                await MainActor.run {
                    messages.append(ChatMessage(text: friendlyError(for: error), isUser: false))
                }
                print("❌ GenerationError: \(error)")

            } catch {
                await MainActor.run {
                    messages.append(ChatMessage(
                        text: "Something went wrong. Please try again.",
                        isUser: false
                    ))
                }
                print("❌ Unexpected error: \(error)")
            }
        }
    }

    // MARK: - Error Messages

    private func friendlyError(for error: LanguageModelSession.GenerationError) -> String {
        switch error {
        case .guardrailViolation:
            return "I can only help with dog diet and nutrition topics. Try asking about your dog's food or feeding schedule."
        case .exceededContextWindowSize:
            return "Our conversation is getting too long! Could you start a fresh question?"
        case .unsupportedLanguageOrLocale:
            return "I work best in English right now. Please try asking in English."
        default:
            return "I couldn't process that. Please try rephrasing your question."
        }
    }
}
