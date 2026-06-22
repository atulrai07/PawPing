//
//  MealLoggingSheet.swift
//  PawPing
//
//  Created by Atul on 25/04/26.
//
//

import SwiftUI

struct MealLoggingSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(PetStore.self) var petStore
    @Environment(\.colorScheme) var colorScheme

    var store: ActivityStore
    var mealType: MealType
    var logDate: Date = Date()
    var isReadOnly: Bool = false

    // MARK: - Local State

    @State private var selectedFood: FoodType? = nil
    @State private var selectedQuantity: Double = 1.0
    @State private var selectedTime: Date = Date()
    
    // For Custom flow
    @State private var ingredients: [MealIngredient] = []
    @State private var showIngredientSearch = false

    // MARK: - Computed Properties

    private var calculatedCalories: Double {
        guard let food = selectedFood else { return 0 }
        if food.isEstimateOnly {
            return ingredients.reduce(0) { $0 + $1.calculatedCalories }
        }
        return store.mealDietStore.caloriesFor(food: food, quantity: selectedQuantity)
    }

    private var canSave: Bool {
        guard let food = selectedFood else { return false }
        if food.isEstimateOnly {
            return !ingredients.isEmpty
        }
        return selectedQuantity > 0
    }

    // MARK: - Dynamic Banner Configs

    private var bannerTitle: String {
        let petName = petStore.activePet?.name ?? "your pet"
        switch mealType {
        case .breakfast:
            return "Let's fuel \(petName)'s morning!"
        case .lunch:
            return "Let's fuel \(petName)'s afternoon!"
        case .dinner:
            return "Let's fuel \(petName)'s evening!"
        }
    }

    private var bannerSubtitle: String {
        let pronoun: String
        if let pet = petStore.activePet {
            pronoun = pet.gender == .male ? "he" : "she"
        } else {
            pronoun = "your pet"
        }
        return "Choose what \(pronoun) ate for \(mealType.rawValue.lowercased())."
    }

    private var bannerBgColor: Color {
        let isDark = colorScheme == .dark
        switch mealType {
        case .breakfast:
            return isDark ? (Color(hex: "FF9500")?.opacity(0.12) ?? .orange.opacity(0.12)) : (Color(hex: "FFF8EA") ?? .orange.opacity(0.08))
        case .lunch:
            return isDark ? (Color(hex: "007AFF")?.opacity(0.12) ?? .blue.opacity(0.12)) : (Color(hex: "EBF9FF") ?? .blue.opacity(0.08))
        case .dinner:
            return isDark ? (Color(hex: "6E54D7")?.opacity(0.15) ?? .purple.opacity(0.15)) : (Color(hex: "F2EFFF") ?? .purple.opacity(0.08))
        }
    }

    private var bannerIconBgColor: Color {
        let isDark = colorScheme == .dark
        switch mealType {
        case .breakfast:
            return isDark ? (Color(hex: "FF9500")?.opacity(0.2) ?? .orange.opacity(0.2)) : (Color(hex: "FFF1D6") ?? .orange.opacity(0.15))
        case .lunch:
            return isDark ? (Color(hex: "007AFF")?.opacity(0.2) ?? .blue.opacity(0.2)) : (Color(hex: "DDF5FF") ?? .blue.opacity(0.15))
        case .dinner:
            return isDark ? (Color(hex: "6E54D7")?.opacity(0.25) ?? .purple.opacity(0.25)) : (Color(hex: "E6E0F8") ?? .purple.opacity(0.15))
        }
    }

    private var bannerIconColor: Color {
        switch mealType {
        case .breakfast:
            return Color(hex: "FF9500") ?? .orange
        case .lunch:
            return Color(hex: "007AFF") ?? .blue
        case .dinner:
            return Color(hex: "6E54D7") ?? .purple
        }
    }

    private var bannerIconName: String {
        switch mealType {
        case .breakfast:
            return "sun.max.fill"
        case .lunch:
            return "sun.min.fill"
        case .dinner:
            return "moon.fill"
        }
    }

    private var bowlImageName: String {
        switch mealType {
        case .breakfast:
            return "bowl_pink"
        case .lunch:
            return "bowl_yellow"
        case .dinner:
            return "bowl_blue"
        }
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                headerSection
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 24) {
                        bannerCard
                        
                        foodTypeSection
                            .padding(.horizontal)

                        // For Custom flow: show multi-ingredient UI and a dedicated Save button
                        if let food = selectedFood, food.isEstimateOnly {
                            VStack(spacing: 24) {
                                multiIngredientSection
                                    .padding(.horizontal)
                                
                                if calculatedCalories > 0 {
                                    caloriePreview
                                        .padding(.horizontal)
                                }
                                
                                timePickerSection
                                    .padding(.horizontal)
                                
                                saveCustomButton
                            }
                            .transition(.opacity.combined(with: .move(edge: .bottom)))
                        } else {
                            // Standard selection shows the Tip Card
                            tipCard
                        }
                    }
                    .padding(.vertical, 8)
                    .padding(.bottom, 40)
                    .animation(.spring(response: 0.4, dampingFraction: 0.8), value: selectedFood)
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: calculatedCalories)
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: ingredients.count)
                }
            }
            .background(Color("baseBackground"))
            .toolbar(.hidden, for: .navigationBar)
            .sheet(isPresented: $showIngredientSearch) {
                IngredientSearchSheet(store: store) { ingredient in
                    ingredients.append(ingredient)
                }
            }
        }
        .onAppear {
            prefillFromExisting()
        }
    }

    // MARK: - Pre-fill from existing meal data

    private func prefillFromExisting() {
        let mealsForDate = store.getMeals(for: logDate)
        if let meal = mealsForDate.first(where: { $0.mealType == mealType }), meal.isTaken {
            selectedFood = meal.foodType
            selectedQuantity = meal.quantity
            ingredients = meal.ingredients
            selectedTime = parseTime(meal.time, meridian: meal.meridian)
        }
    }

    private func parseTime(_ time: String, meridian: String) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.date(from: "\(time) \(meridian)") ?? Date()
    }

    // MARK: - Header Section

    private var headerSection: some View {
        HStack {
            Spacer()
            Text(isReadOnly ? "\(mealType.rawValue) Details" : "Log \(mealType.rawValue)")
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

    // MARK: - Banner Card

    private var bannerCard: some View {
        HStack(spacing: 0) {
            HStack(spacing: 12) {
                // Left Icon
                RoundedRectangle(cornerRadius: 16)
                    .fill(bannerIconBgColor)
                    .frame(width: 48, height: 48)
                    .overlay(
                        Image(systemName: bannerIconName)
                            .font(.system(size: 24))
                            .foregroundColor(bannerIconColor)
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(bannerTitle)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.primary)
                    Text(bannerSubtitle)
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                }
            }
            .padding(.leading, 16)
            
            Spacer()
            
            ZStack(alignment: .center) {
                // Background pawprint behind the bowl
                Image(systemName: "pawprint.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 70, height: 70)
                    .foregroundColor(bannerIconColor.opacity(0.04))
                    .rotationEffect(.degrees(25))
                    .offset(x: -25, y: -10)
                
                // Pet food bowl image
                Image(bowlImageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 88, height: 88)
                    .offset(x: 10, y: 5)
            }
        }
        .frame(height: 96)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(bannerBgColor)
        )
        .padding(.horizontal)
    }

    // MARK: - Food Type Grid

    private var foodTypeSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            let petName = petStore.activePet?.name ?? "your pet"
            Text("What did \(petName) eat?")
                .font(.system(size: 16, weight: .bold))

            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 16),
                GridItem(.flexible(), spacing: 16)
            ], spacing: 16) {
                ForEach(FoodType.allCases) { food in
                    Button {
                        withAnimation {
                            if food == .custom {
                                selectedFood = food
                            } else {
                                selectedFood = food
                                
                                // Auto-save standard selection
                                let unit = store.mealDietStore.unitFor(food: food)
                                store.updateMeal(
                                    type: mealType,
                                    foodType: food,
                                    quantity: 1.0,
                                    unit: unit,
                                    ingredients: [],
                                    time: Date(),
                                    isTaken: true,
                                    forDate: logDate
                                )
                                // Brief delay for selection animation
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                                    dismiss()
                                }
                            }
                        }
                    } label: {
                        foodTypeCard(food: food)
                    }
                    .buttonStyle(.plain)
                    .disabled(isReadOnly)
                }
            }
        }
    }

    private func foodTypeCard(food: FoodType) -> some View {
        let isSelected = selectedFood == food
        let isDark = colorScheme == .dark

        let imageName: String
        switch food {
        case .dryDogFood: imageName = "dry_dog_food"
        case .wetDogFood: imageName = "wet_dog_food"
        case .chicken:    imageName = "chicken_meal"
        case .rice:       imageName = "rice_meal"
        case .egg:        imageName = "egg_meal"
        case .custom:     imageName = "custom_meal"
        }

        // Selection backgrounds that adapt nicely to Light vs Dark Mode
        let selectionBg = isDark ? (Color(hex: "FFB950")?.opacity(0.15) ?? .orange.opacity(0.15)) : (Color(hex: "FFF9F2") ?? .white)
        let selectionBorder = Color(hex: "FFB950") ?? Color("baseColor")
        let innerIconBg = isSelected ? (Color(hex: "FFF1D6") ?? Color.orange.opacity(0.2)) : Color("secondaryCardBackground")

        return ZStack(alignment: .topTrailing) {
            HStack(spacing: 12) {
                // Image Container
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(innerIconBg)
                        .frame(width: 56, height: 56)
                    
                    Image(imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 44, height: 44)
                }
                
                Text(food.displayName)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(isSelected ? .primary : Color("secondaryText"))
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
                Spacer()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(isSelected ? selectionBg : Color("cardBackground"))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(isSelected ? selectionBorder : Color.gray.opacity(isDark ? 0.25 : 0.15), lineWidth: 1.5)
            )
            .shadow(color: .black.opacity(isSelected ? 0.04 : 0.01), radius: 8, x: 0, y: 4)

            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(Color(hex: "FFB950") ?? .orange)
                    .font(.system(size: 22))
                    .background(Circle().fill(Color("cardBackground")))
                    .offset(x: 6, y: -6)
            }
        }
    }

    // MARK: - Multi-Ingredient Section

    private var multiIngredientSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Ingredients")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color("secondaryText"))

            VStack(spacing: 10) {
                ForEach(ingredients) { ingredient in
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(ingredient.name)
                                .font(.system(size: 16, weight: .medium))
                            Text("\(String(format: "%.0f", ingredient.quantity))\(ingredient.unit)")
                                .font(.system(size: 12))
                                .foregroundStyle(Color("secondaryText"))
                        }
                        
                        Spacer()
                        
                        Text("\(Int(ingredient.calculatedCalories)) kcal")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.orange)
                        
                        if !isReadOnly {
                            Button {
                                withAnimation {
                                    ingredients.removeAll(where: { $0.id == ingredient.id })
                                }
                            } label: {
                                Image(systemName: "minus.circle.fill")
                                    .foregroundStyle(.red.opacity(0.8))
                                    .font(.system(size: 20))
                            }
                            .padding(.leading, 8)
                        }
                    }
                    .padding(14)
                    .background(Color("cardBackground"))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }

                if !isReadOnly {
                    Button {
                        showIngredientSearch = true
                    } label: {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Add Ingredient")
                        }
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Color("baseColor"))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .strokeBorder(Color("baseColor").opacity(0.5), style: StrokeStyle(lineWidth: 2, dash: [6]))
                        )
                    }
                }
            }
        }
    }

    // MARK: - Calorie Preview

    private var caloriePreview: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Estimated Calories")
                    .font(.system(size: 12))
                    .foregroundStyle(Color("secondaryText"))
                HStack(spacing: 6) {
                    Image(systemName: "flame.fill")
                        .foregroundStyle(.orange)
                        .font(.system(size: 20))
                    Text("\(Int(calculatedCalories)) kcal")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(.primary)
                        .contentTransition(.numericText())
                }
            }
            Spacer()
            if let food = selectedFood, !food.isEstimateOnly {
                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(String(format: "%.1f", selectedQuantity)) × \(store.mealDietStore.unitFor(food: food))")
                        .font(.system(size: 12))
                        .foregroundStyle(Color("secondaryText"))
                    Text("@ \(Int(store.mealDietStore.caloriesFor(food: food, quantity: 1.0))) kcal/\(store.mealDietStore.unitFor(food: food))")
                        .font(.system(size: 11))
                        .foregroundStyle(Color("secondaryText").opacity(0.7))
                }
            } else if let food = selectedFood, food.isEstimateOnly {
                Text("\(ingredients.count) item(s)")
                    .font(.system(size: 12))
                    .foregroundStyle(Color("secondaryText"))
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.orange.opacity(0.08))
        )
    }

    // MARK: - Time Picker

    private var timePickerSection: some View {
        HStack {
            Text("Time")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color("secondaryText"))
            Spacer()
            DatePicker("", selection: $selectedTime, displayedComponents: .hourAndMinute)
                .labelsHidden()
                .datePickerStyle(.compact)
                .fixedSize()
                .disabled(isReadOnly)
        }
        .padding(14)
        .background(Color("cardBackground"))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Tip Card

    private var tipCard: some View {
        let isDark = colorScheme == .dark
        return ZStack(alignment: .trailing) {
            HStack(alignment: .top, spacing: 12) {
                // Sparkles icon
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(hex: "E6E0F8") ?? .purple.opacity(0.1))
                    .frame(width: 36, height: 36)
                    .overlay(
                        Image(systemName: "sparkles")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(Color(hex: "6E54D7") ?? .purple)
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Tip")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(Color(hex: "6E54D7") ?? .purple)
                    
                    let petName = petStore.activePet?.name ?? "your pet"
                    Text("Add the right food to keep \(petName) healthy and full of energy.")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                Spacer()
            }
            .padding(16)
            
            // Pawprint watermark on bottom right
            Image(systemName: "pawprint.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 50, height: 50)
                .foregroundColor(Color(hex: "6E54D7")?.opacity(isDark ? 0.08 : 0.04) ?? .purple.opacity(0.04))
                .rotationEffect(.degrees(-15))
                .offset(x: 10, y: 15)
        }
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(isDark ? (Color(hex: "6E54D7")?.opacity(0.12) ?? .purple.opacity(0.12)) : (Color(hex: "F2EFFF") ?? .purple.opacity(0.05)))
        )
        .padding(.horizontal)
    }

    // MARK: - Save Custom Button

    private var saveCustomButton: some View {
        Button {
            store.updateMeal(
                type: mealType,
                foodType: .custom,
                quantity: selectedQuantity,
                unit: "custom",
                ingredients: ingredients,
                time: selectedTime,
                isTaken: true,
                forDate: logDate
            )
            dismiss()
        } label: {
            HStack {
                Spacer()
                Text("Save Custom Meal")
                    .font(.system(size: 17, weight: .bold))
                Spacer()
                Image(systemName: "arrow.right")
                    .font(.system(size: 16, weight: .bold))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .padding(.horizontal, 24)
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
        .disabled(!canSave)
        .opacity(canSave ? 1.0 : 0.6)
        .padding(.horizontal)
    }
}

#Preview {
    MealLoggingSheet(store: ActivityStore(), mealType: .breakfast)
        .environment(PetStore())
}
