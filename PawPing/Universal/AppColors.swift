//
//  AppColors.swift
//  PawPing
//
//  Created by SidMoon on 16/03/26.
//
//  Custom color palette for the PawPing app.
//  This is the single source of truth for all app colors.
//  If you need a color anywhere, grab it from here — don't hardcode hex values.
//

import SwiftUI

// MARK: - PawPing Color Palette
// Primary:   #486AF2 → Buttons, links, active icons, map markers
// Secondary: #1E293B → Headlines, bold titles, navigation text
// Tertiary:  #FF8C69 → Badges, labels, secondary CTAs
extension Color {

    // The main brand blue — used for interactive elements
    static let pawPrimary = Color(red: 72/255.0, green: 106/255.0, blue: 242/255.0)

    // Dark navy slate — used for headlines and strong text
    static let pawSecondary = Color(red: 30/255.0, green: 41/255.0, blue: 59/255.0)

    // Warm coral/salmon — used for badges and secondary accents
    static let pawTertiary = Color(red: 255/255.0, green: 140/255.0, blue: 105/255.0)

    // Apple's built-in grouped-background gray — gives us a native iOS feel
    static let pawBackground = Color(uiColor: .systemGroupedBackground)

    // Pure white — used for card surfaces so they "pop" against the gray background
    static let pawNeutral = Color.white
}

// MARK: - ShapeStyle Extension
// Without this, you'd have to write .foregroundStyle(Color.pawPrimary) every time.
// This extension lets you just write .foregroundStyle(.pawPrimary) — much cleaner.
extension ShapeStyle where Self == Color {
    static var pawPrimary: Color { .pawPrimary }
    static var pawSecondary: Color { .pawSecondary }
    static var pawTertiary: Color { .pawTertiary }
    static var pawBackground: Color { .pawBackground }
    static var pawNeutral: Color { .pawNeutral }
}
