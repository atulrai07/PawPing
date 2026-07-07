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
    var messages: [DietChatMessage] = []
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
        You are PawPing's dog diet and health assistant.
        
        CRITICAL RULES:
        1. Only answer questions related to dog food, dog nutrition, diet plans, feeding schedules, safe and unsafe foods for dogs, and general dog health habits.
        2. If a question is completely unrelated to dogs or pets, simply state that you can only assist with topics related to dog diet, nutrition, and health.
        3. Never write programming code, scripts, or solve non-dog-related tasks.
        4. Keep answers friendly, warm, structured, and easy to read. Use Markdown formatting like **bolding** and bullet points where appropriate.
        5. Never give medical diagnoses. Always refer serious health concerns to a veterinarian.
        """

    private func isQueryRelevant(_ query: String) -> Bool {
        let lowercased = query.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard !lowercased.isEmpty else { return false }
        
        // Block obvious programming, math, code, calculators, and unrelated tech tasks
        let codingKeywords = [
            "python", "javascript", "html", "css", "c++", "c#", "java", "coding", 
            "calculator", "write a code", "write code", "programming", "software", 
            "program", "develop an app", "create a website", "run a script", "github", 
            "algorithm", "fibonacci", "loop in swift", "class in swift"
        ]
        for keyword in codingKeywords {
            if lowercased.contains(keyword) {
                return false
            }
        }
        
        // Define relevant dog/pet diet, nutrition, feeding, health keywords
        let relevantKeywords = [
            "dog", "pup", "canine", "pet", "vet", "veterinarian", "animal",
            "diet", "food", "eat", "feed", "nutrition", "meal", "recipe", "toxic", "safe", 
            "unsafe", "healthy", "health", "habit", "allergy", "allergies", "vomit", 
            "diarrhea", "sick", "sickness", "drink", "water", "weight", "calorie", 
            "calories", "treat", "treats"
        ]
        if relevantKeywords.contains(where: { lowercased.contains($0) }) {
            return true
        }
        
        // Define common foods to allow questions like "Is chocolate bad?" or "Can they have grapes?"
        let commonFoods = [
            "chicken", "rice", "banana", "apple", "grape", "chocolate", "onion", "garlic", 
            "avocado", "carrot", "broccoli", "meat", "beef", "pork", "fish", "salmon", 
            "egg", "milk", "cheese", "yogurt", "peanut butter", "strawberry", "blueberry", 
            "watermelon", "potato", "sweet potato", "turkey", "oatmeal", "bread", "butter", 
            "honey", "nut", "nuts", "almond", "walnut", "macadamia"
        ]
        if commonFoods.contains(where: { lowercased.contains($0) }) {
            return true
        }
        
        // Allow common greetings
        let greetings = ["hi", "hello", "hey", "greetings", "how are you", "good morning", "good afternoon", "good evening"]
        if greetings.contains(where: { lowercased.contains($0) }) {
            return true
        }
        
        return false
    }

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
                messages.append(DietChatMessage(
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

        messages.append(DietChatMessage(text: trimmed, isUser: true))

        guard isQueryRelevant(trimmed) else {
            messages.append(DietChatMessage(
                text: "I'm sorry, I cannot answer that question. I can only assist with topics related to dog diet, nutrition, and health.",
                isUser: false
            ))
            return
        }

        isTyping = true

        Task {
            defer {
                Task { @MainActor in self.isTyping = false }
            }

            do {
                let response = try await session.respond(to: trimmed)
                await MainActor.run {
                    messages.append(DietChatMessage(text: response.content, isUser: false))
                }

            } catch let error as LanguageModelSession.GenerationError {
                await MainActor.run {
                    messages.append(DietChatMessage(text: friendlyError(for: error), isUser: false))
                }
                print("❌ GenerationError: \(error)")

            } catch {
                await MainActor.run {
                    messages.append(DietChatMessage(
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
