//
//  AppColors.swift
//  PawPing
//
//  Created by SidMoon on 16/03/26.
//
//

import SwiftUI

// MARK: - PawPing Color Palette
// Primary:   #486AF2 → Buttons, links, active icons, map markers
// Secondary: #1E293B → Headlines, bold titles, navigation text
// Tertiary:  #FF8C69 → Badges, labels, secondary CTAs
extension Color {

    static let pawPrimary = Color(red: 72/255.0, green: 106/255.0, blue: 242/255.0)

    static let pawSecondary = Color(red: 30/255.0, green: 41/255.0, blue: 59/255.0)

    static let pawTertiary = Color(red: 255/255.0, green: 140/255.0, blue: 105/255.0)

    static let pawBackground = Color(uiColor: .systemGroupedBackground)

    static let pawNeutral = Color.white
    
    // Home Screen Colors
    static let homePurple = Color(hex: "6E54D7") ?? .purple
    static let homeLightPurple = Color(hex: "F3F0FF") ?? .purple.opacity(0.1)
    static let homeTextDark = Color(hex: "1C1B1F") ?? .primary
    static let homeTextGray = Color(hex: "8B8A91") ?? .secondary
    static let homeGreen = Color(hex: "5AC98C") ?? .green
    static let homeBlue = Color(hex: "5C9CFF") ?? .blue
    static let homeYellow = Color(hex: "FFCC00") ?? .yellow
}

// MARK: - Hex Initializer
extension Color {
    init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0

        var r: CGFloat = 0.0
        var g: CGFloat = 0.0
        var b: CGFloat = 0.0
        var a: CGFloat = 1.0

        let length = hexSanitized.count

        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }

        if length == 6 {
            r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
            g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
            b = CGFloat(rgb & 0x0000FF) / 255.0
        } else if length == 8 {
            r = CGFloat((rgb & 0xFF000000) >> 24) / 255.0
            g = CGFloat((rgb & 0x00FF0000) >> 16) / 255.0
            b = CGFloat((rgb & 0x0000FF00) >> 8) / 255.0
            a = CGFloat(rgb & 0x000000FF) / 255.0
        } else {
            return nil
        }

        self.init(red: r, green: g, blue: b, opacity: a)
    }
}
// MARK: - ShapeStyle Extension
extension ShapeStyle where Self == Color {
    static var pawPrimary: Color { .pawPrimary }
    static var pawSecondary: Color { .pawSecondary }
    static var pawTertiary: Color { .pawTertiary }
    static var pawBackground: Color { .pawBackground }
    static var pawNeutral: Color { .pawNeutral }
}
