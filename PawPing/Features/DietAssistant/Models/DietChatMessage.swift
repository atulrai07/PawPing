//
//  DietChatMessage.swift
//  PawPing
//

import Foundation

struct DietChatMessage: Identifiable {
    let id = UUID()
    let text: String
    let isUser: Bool
}

