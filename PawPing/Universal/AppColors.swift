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
}

// MARK: - ShapeStyle Extension
extension ShapeStyle where Self == Color {
    static var pawPrimary: Color { .pawPrimary }
    static var pawSecondary: Color { .pawSecondary }
    static var pawTertiary: Color { .pawTertiary }
    static var pawBackground: Color { .pawBackground }
    static var pawNeutral: Color { .pawNeutral }
}
