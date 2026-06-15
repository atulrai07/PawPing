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

    // MARK: - Computed

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

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 24) {
                    // Step 1: Food Type Selection
                    foodTypeSection

                    // Step 2: Quantity (only for dataset foods)
                    if let food = selectedFood, !food.isEstimateOnly {
                        quantitySection(food: food)
                            .transition(.opacity.combined(with: .move(edge: .bottom)))
                    }

                    // Step 2b: Multi-ingredient list (for custom meals)
                    if let food = selectedFood, food.isEstimateOnly {
                        multiIngredientSection
                            .transition(.opacity.combined(with: .move(edge: .bottom)))
                    }

                    // Instant Calorie Feedback
                    if selectedFood != nil && calculatedCalories > 0 {
                        caloriePreview
                            .transition(.scale.combined(with: .opacity))
                    }

                    // Time Picker
                    if selectedFood != nil {
                        timePickerSection
                            .transition(.opacity.combined(with: .move(edge: .bottom)))
                    }

                    // Save Button
                    if canSave && !isReadOnly {
                        saveButton
                            .transition(.opacity.combined(with: .move(edge: .bottom)))
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)
                .padding(.bottom, 40)
                .animation(.spring(response: 0.4, dampingFraction: 0.8), value: selectedFood)
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: calculatedCalories)
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: ingredients.count)
            }
            .background(Color("baseBackground"))
            .navigationTitle(isReadOnly ? "\(mealType.rawValue) Details" : "Log \(mealType.rawValue)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }
                }
            }
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

    // MARK: - Food Type Grid

    private var foodTypeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("What did \(petStore.activePet?.name ?? "your pet") eat?")
                .font(.system(size: 16, weight: .semibold))

            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12)
            ], spacing: 12) {
                ForEach(FoodType.allCases) { food in
                    Button {
                        withAnimation {
                            if selectedFood != food {
                                selectedFood = food
                                // Reset specific values when switching
                                if !food.isEstimateOnly {
                                    ingredients.removeAll()
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

        return HStack(spacing: 10) {
            RoundedRectangle(cornerRadius: 12)
                .fill(isSelected ? Color("baseColor") : Color("secondaryCardBackground"))
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: food.icon)
                        .font(.system(size: 18))
                        .foregroundStyle(isSelected ? .white : Color("baseColor"))
                )

            Text(food.displayName)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(isSelected ? Color("baseColor") : .primary)
                .lineLimit(2)
                .multilineTextAlignment(.leading)

            Spacer()
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color("cardBackground"))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(isSelected ? Color("baseColor") : Color.clear, lineWidth: 2)
        )
    }

    // MARK: - Quantity Section

    private func quantitySection(food: FoodType) -> some View {
        QuantitySelectorView(
            selected: $selectedQuantity,
            unit: store.mealDietStore.unitFor(food: food)
        )
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

    // MARK: - Calorie Preview (Instant Feedback)

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

    // MARK: - Save Button

    private var saveButton: some View {
        Button {
            let unit = selectedFood?.isEstimateOnly == true ? "custom" : store.mealDietStore.unitFor(food: selectedFood!)
            store.updateMeal(
                type: mealType,
                foodType: selectedFood,
                quantity: selectedQuantity,
                unit: unit,
                ingredients: ingredients,
                time: selectedTime,
                isTaken: true,
                forDate: logDate
            )
            dismiss()
        } label: {
            Text("Save \(mealType.rawValue)")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color("baseColor"))
                )
        }
    }
}

#Preview {
    MealLoggingSheet(store: ActivityStore(), mealType: .breakfast)
}
