//
//  DietSetupSheet.swift
//  PawPing
//
//  Created by Atul on 25/04/26.
//
//

import SwiftUI

struct DietSetupSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(PetStore.self) var petStore
    @Environment(\.colorScheme) var colorScheme

    var store: ActivityStore

    // MARK: - Local State

    @State private var weightInput: String = ""
    @State private var weightUnit: WeightUnit = .kg
    @State private var selectedGoal: DietGoal = .maintain

    // Derived weight in kg for calculation
    private var weightKg: Double {
        let raw = Double(weightInput) ?? 0
        return weightUnit.toKg(raw)
    }

    // Live RER calculation
    private var previewRER: Double {
        guard weightKg > 0 else { return 0 }
        return 70.0 * pow(weightKg, 0.75)
    }

    private var previewTarget: Double {
        previewRER * selectedGoal.rerMultiplier
    }

    private var canStart: Bool {
        weightKg > 1 && weightKg < 150 // reasonable range for dogs
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                headerSection
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 24) {
                        // Pet Info (read-only)
                        petInfoCard

                        // Weight Input
                        weightSection

                        // Goal Picker
                        goalSection

                        // Live Target Preview & Meal Preview
                        if canStart {
                            targetPreview
                                .transition(.scale.combined(with: .opacity))
                            
                            mealPlanPreview
                                .transition(.opacity.combined(with: .move(edge: .bottom)))
                            
                            startButton
                                .transition(.opacity.combined(with: .move(edge: .bottom)))
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    .padding(.bottom, 40)
                    .animation(.spring(response: 0.4, dampingFraction: 0.8), value: canStart)
                    .animation(.easeInOut(duration: 0.3), value: previewTarget)
                }
            }
            .background(Color("baseBackground"))
            .toolbar(.hidden, for: .navigationBar)
        }
        .onAppear {
            // Pre-fill with existing weight
            let currentKg = petStore.activePet?.weightKg ?? 10.0
            weightInput = String(format: "%.1f", weightUnit.fromKg(currentKg))
        }
    }

    // MARK: - Header Section

    private var headerSection: some View {
        HStack {
            Spacer()
            Text("Diet Plan Setup")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.primary)
            Spacer()
        }
        .overlay(alignment: .trailing) {
            Button {
                dismiss()
            } label: {
                Circle()
                    .fill(Color("cardBackground"))
                    .frame(width: 36, height: 36)
                    .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                    .overlay(
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(Color(hex: "6E54D7") ?? .purple)
                    )
            }
        }
        .padding(.horizontal)
        .padding(.top, 16)
        .padding(.bottom, 8)
    }

    // MARK: - Pet Info Card (read-only)

    private var petInfoCard: some View {
        let isDark = colorScheme == .dark
        return ZStack(alignment: .trailing) {
            HStack(spacing: 16) {
                if let urlString = petStore.activePet?.profileImageUrl, let url = URL(string: urlString) {
                    AsyncImage(url: url) { image in
                        image.resizable().scaledToFill()
                    } placeholder: {
                        ProgressView()
                    }
                    .frame(width: 60, height: 60)
                    .clipShape(Circle())
                } else {
                    Image(petStore.activePet?.imageName ?? Pet.defaultImageName)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 60, height: 60)
                        .clipShape(Circle())
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(petStore.activePet?.name ?? "Pet")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.primary)

                    VStack(alignment: .leading, spacing: 4) {
                        Label(petStore.activePet?.breed ?? "—", systemImage: "pawprint.fill")
                        Label("\(petStore.activePet?.age ?? "?") years old", systemImage: "birthday.cake.fill")
                    }
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Color("secondaryText"))
                }

                Spacer()
            }
            .padding(16)
            
            // Pawprint watermark
            Image(systemName: "pawprint.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 64, height: 64)
                .foregroundColor(Color(hex: "6E54D7")?.opacity(isDark ? 0.08 : 0.04) ?? .purple.opacity(0.04))
                .rotationEffect(.degrees(15))
                .offset(x: -16)
        }
        .background(Color("cardBackground"))
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .shadow(color: .black.opacity(0.02), radius: 8, x: 0, y: 4)
    }

    // MARK: - Weight Section

    private var weightSection: some View {
        let isDark = colorScheme == .dark
        return VStack(alignment: .leading, spacing: 12) {
            Text("Current Weight")
                .font(.system(size: 16, weight: .bold))

            HStack(spacing: 12) {
                // Weight Display/Input Card
                HStack {
                    TextField("e.g. 25", text: $weightInput)
                        .keyboardType(.decimalPad)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(Color(hex: "6E54D7") ?? .purple)
                        .frame(width: 80)
                    
                    Spacer()
                    
                    Text(weightUnit.rawValue)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(Color("secondaryText"))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color("cardBackground"))
                .clipShape(RoundedRectangle(cornerRadius: 18))
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(Color.gray.opacity(isDark ? 0.25 : 0.12), lineWidth: 1.5)
                )

                // Custom segmented control matching image
                HStack(spacing: 0) {
                    ForEach(WeightUnit.allCases, id: \.self) { unit in
                        let isSelected = weightUnit == unit
                        Button {
                            withAnimation(.spring(response: 0.25, dampingFraction: 0.75)) {
                                let oldUnit = weightUnit
                                weightUnit = unit
                                if let raw = Double(weightInput) {
                                    let kg = oldUnit.toKg(raw)
                                    weightInput = String(format: "%.1f", newUnitFromKg(kg, for: unit))
                                }
                            }
                        } label: {
                            Text(unit.rawValue)
                                .font(.system(size: 14, weight: isSelected ? .bold : .medium))
                                .foregroundColor(isSelected ? (Color(hex: "6E54D7") ?? .purple) : Color("secondaryText"))
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                                .background(
                                    Group {
                                        if isSelected {
                                            Capsule()
                                                .fill(Color("cardBackground"))
                                                .shadow(color: .black.opacity(isDark ? 0.16 : 0.08), radius: 4, x: 0, y: 2)
                                        } else {
                                            Color.clear
                                        }
                                    }
                                )
                        }
                    }
                }
                .padding(4)
                .background(isDark ? Color.gray.opacity(0.12) : (Color(hex: "F2F2F7") ?? Color(.systemGray6)))
                .clipShape(Capsule())
            }
        }
    }
        
    private func newUnitFromKg(_ kg: Double, for newUnit: WeightUnit) -> Double {
        return newUnit.fromKg(kg)
    }

    // MARK: - Goal Section Helpers
    
    private func goalCircleColor(for goal: DietGoal) -> Color {
        switch goal {
        case .loseWeight: return .green
        case .maintain:   return Color(hex: "6E54D7") ?? .purple
        case .gain:       return .orange
        }
    }
    
    private func goalIconName(for goal: DietGoal) -> String {
        switch goal {
        case .loseWeight: return "arrow.down"
        case .maintain:   return "equal"
        case .gain:       return "arrow.up"
        }
    }
    
    private func goalLightBgColor(for goal: DietGoal, isDark: Bool) -> Color {
        switch goal {
        case .loseWeight:
            return isDark ? Color.green.opacity(0.15) : (Color(hex: "EAF9F0") ?? .green.opacity(0.08))
        case .maintain:
            return isDark ? (Color(hex: "6E54D7")?.opacity(0.2) ?? .purple.opacity(0.2)) : (Color(hex: "F2EFFF") ?? .purple.opacity(0.08))
        case .gain:
            return isDark ? Color.orange.opacity(0.15) : (Color(hex: "FFF7F0") ?? .orange.opacity(0.08))
        }
    }

    // MARK: - Goal Section

    private var goalSection: some View {
        let isDark = colorScheme == .dark
        return VStack(alignment: .leading, spacing: 12) {
            Text("Goal")
                .font(.system(size: 16, weight: .bold))

            HStack(spacing: 12) {
                ForEach(DietGoal.allCases, id: \.self) { goal in
                    let isSelected = selectedGoal == goal
                    let circleColor = goalCircleColor(for: goal)
                    let iconName = goalIconName(for: goal)
                    let lightBgColor = goalLightBgColor(for: goal, isDark: isDark)

                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                            selectedGoal = goal
                        }
                    } label: {
                        ZStack(alignment: .topTrailing) {
                            VStack(spacing: 12) {
                                // Rounded circle icon
                                Circle()
                                    .fill(circleColor)
                                    .frame(width: 36, height: 36)
                                    .overlay(
                                        Image(systemName: iconName)
                                            .font(.system(size: 14, weight: .bold))
                                            .foregroundColor(.white)
                                    )

                                Text(goal.rawValue)
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundColor(isSelected ? (Color(hex: "6E54D7") ?? .purple) : .primary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(isSelected ? lightBgColor : Color("cardBackground"))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(isSelected ? (Color(hex: "6E54D7") ?? .purple) : Color.gray.opacity(isDark ? 0.25 : 0.12), lineWidth: 1.5)
                            )
                            .shadow(color: .black.opacity(isSelected ? 0.04 : 0.01), radius: 8, x: 0, y: 4)

                            // Checkmark circle badge
                            if isSelected {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(Color(hex: "6E54D7") ?? .purple)
                                    .font(.system(size: 20))
                                    .background(Circle().fill(Color("cardBackground")))
                                    .offset(x: 5, y: -5)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // MARK: - Target Preview

    private var targetPreview: some View {
        let isDark = colorScheme == .dark
        return HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Daily Calorie Target")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Color("secondaryText"))

                    HStack(spacing: 6) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 14))
                            .foregroundColor(Color(hex: "6E54D7")?.opacity(0.6) ?? .purple.opacity(0.6))
                        
                        Text("\(Int(previewTarget)) kcal/day")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundStyle(Color(hex: "6E54D7") ?? .purple)
                            .contentTransition(.numericText())
                        
                        Image(systemName: "sparkles")
                            .font(.system(size: 14))
                            .foregroundColor(Color(hex: "6E54D7")?.opacity(0.6) ?? .purple.opacity(0.6))
                    }
                }
                
                HStack(spacing: 12) {
                    // RER
                    VStack(alignment: .leading, spacing: 2) {
                        Text("RER")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundStyle(Color("secondaryText"))
                        Text("\(Int(previewRER))")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.green)
                    }
                    
                    Rectangle()
                        .fill(Color.gray.opacity(0.15))
                        .frame(width: 1, height: 24)

                    // Multiplier
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Multiplier")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundStyle(Color("secondaryText"))
                        Text("×\(String(format: "%.1f", selectedGoal.rerMultiplier))")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(Color(hex: "6E54D7") ?? .purple)
                    }

                    Rectangle()
                        .fill(Color.gray.opacity(0.15))
                        .frame(width: 1, height: 24)

                    // Weight
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Weight")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundStyle(Color("secondaryText"))
                        Text("\(String(format: "%.1f", weightKg)) kg")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(Color(hex: "6E54D7") ?? .purple)
                    }
                }
            }
            .padding(.leading, 16)
            
            Spacer()
            
            // Clipboard Image
            Image("diet_plan_clipboard")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .padding(.trailing, 10)
        }
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(isDark ? (Color(hex: "6E54D7")?.opacity(0.12) ?? .purple.opacity(0.12)) : (Color(hex: "F3F2FF") ?? .purple.opacity(0.05)))
        )
    }

    // MARK: - Meal Plan Preview

    private var mealPlanPreview: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Text("Meal Plan Preview")
                    .font(.system(size: 16, weight: .bold))
                Text("3 meals/day")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Color(hex: "6E54D7") ?? .purple)
            }
            
            HStack(spacing: 4) {
                let target = previewTarget
                let bCal = Int(ceil(target / 3.0))
                let lCal = Int(floor(target / 3.0))
                let dCal = Int(target) - bCal - lCal
                
                mealPreviewCard(title: "Breakfast", kcal: bCal, icon: "sun.max.fill", iconColor: .orange, imageName: "bowl_pink")
                
                plusDivider
                
                mealPreviewCard(title: "Lunch", kcal: lCal, icon: "sun.min.fill", iconColor: .orange, imageName: "bowl_yellow")
                
                plusDivider
                
                mealPreviewCard(title: "Dinner", kcal: dCal, icon: "moon.fill", iconColor: Color(hex: "6E54D7") ?? .purple, imageName: "bowl_blue")
            }
        }
    }
    
    private var plusDivider: some View {
        Image(systemName: "plus.circle.fill")
            .foregroundColor(Color(hex: "6E54D7") ?? .purple)
            .font(.system(size: 14))
    }
    
    private func mealPreviewCard(title: String, kcal: Int, icon: String, iconColor: Color, imageName: String) -> some View {
        let isBreakfast = title == "Breakfast"
        let isLunch = title == "Lunch"
        let isDark = colorScheme == .dark
        
        let lightHex = isBreakfast ? "FFF8EA" : (isLunch ? "FFF0E4" : "F2EFFF")
        let darkColor = isBreakfast ? Color.orange.opacity(0.12) : (isLunch ? Color.orange.opacity(0.12) : (Color(hex: "6E54D7")?.opacity(0.12) ?? .purple.opacity(0.12)))
        
        return VStack(alignment: .center, spacing: 6) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 11))
                    .foregroundColor(iconColor)
                Text(title)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.primary)
            }
            
            Text("\(kcal) kcal")
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.secondary)
            
            Spacer(minLength: 4)
            
            Image(imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 44, height: 44)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 96)
        .padding(.vertical, 8)
        .background(isDark ? darkColor : (Color(hex: lightHex) ?? .white))
        .cornerRadius(18)
    }

    // MARK: - Start Button

    private var startButton: some View {
        VStack(spacing: 12) {
            Button {
                store.mealDietStore.startDiet(goal: selectedGoal, weightKg: weightKg)
                if var pet = petStore.activePet {
                    pet.weightKg = weightKg
                    Task {
                        await petStore.updatePet(pet)
                    }
                }
                dismiss()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "play.fill")
                        .font(.system(size: 14))
                    Text("Start Diet Plan")
                        .font(.system(size: 17, weight: .bold))
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    LinearGradient(
                        colors: [Color(hex: "8D75F6") ?? .purple, Color(hex: "6E54D7") ?? .indigo],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .clipShape(Capsule())
                .shadow(color: (Color(hex: "6E54D7") ?? .purple).opacity(0.3), radius: 10, x: 0, y: 5)
            }
            
            HStack(spacing: 6) {
                Image(systemName: "checkmark.shield.fill")
                    .foregroundColor(Color(hex: "6E54D7") ?? .purple)
                    .font(.system(size: 12))
                
                Text("Vet recommended & based on your pet's needs")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.secondary)
            }
        }
    }
}

#Preview {
    DietSetupSheet(store: ActivityStore())
        .environment(PetStore())
}
