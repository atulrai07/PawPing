//
//  MealLoggingSheet.swift
//  PawPing
//

import SwiftUI

struct MealLoggingSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(PetStore.self) var petStore
    var store: MealStore
    var mealType: MealType

    @State private var selectedFood: FoodType? = nil
    @State private var selectedQuantity: Double = 1.0
    @State private var selectedTime: Date = Date()
    @State private var ingredients: [MealIngredient] = []
    @State private var showIngredientSearch = false

    private var calculatedCalories: Double {
        guard let food = selectedFood else { return 0 }
        if food.isEstimateOnly { return ingredients.reduce(0) { $0 + $1.calculatedCalories } }
        return store.caloriesFor(food: food, quantity: selectedQuantity)
    }

    private var canSave: Bool {
        guard let food = selectedFood else { return false }
        return food.isEstimateOnly ? !ingredients.isEmpty : selectedQuantity > 0
    }

    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 24) {
                    foodTypeSection
                    if let food = selectedFood, !food.isEstimateOnly { quantitySection(food: food) }
                    if let food = selectedFood, food.isEstimateOnly { multiIngredientSection }
                    if selectedFood != nil && calculatedCalories > 0 { caloriePreview }
                    if selectedFood != nil { timePickerSection }
                    if canSave { saveButton }
                }
                .padding(.horizontal).padding(.top, 8).padding(.bottom, 40)
            }
            .background(Color("baseBackground"))
            .navigationTitle("Log \(mealType.rawValue)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark.circle.fill").foregroundStyle(Color("secondaryText").opacity(0.5)).font(.system(size: 24))
                    }
                }
            }
            .sheet(isPresented: $showIngredientSearch) {
                IngredientSearchSheet(store: store) { ingredients.append($0) }
            }
        }
        .onAppear { prefillFromExisting() }
    }

    private func prefillFromExisting() {
        if let meal = store.meals.first(where: { $0.mealType == mealType }), meal.isTaken {
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

    private var foodTypeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("What did \(petStore.activePet?.name ?? "your pet") eat?").font(.system(size: 16, weight: .semibold))
            LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
                ForEach(FoodType.allCases) { food in
                    Button { withAnimation { selectedFood = food; if !food.isEstimateOnly { ingredients.removeAll() } } } label: {
                        foodTypeCard(food: food)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private func foodTypeCard(food: FoodType) -> some View {
        let isSelected = selectedFood == food
        return HStack(spacing: 10) {
            RoundedRectangle(cornerRadius: 12).fill(isSelected ? Color("baseColor") : Color("secondaryCardBackground")).frame(width: 40, height: 40)
                .overlay(Image(systemName: food.icon).font(.system(size: 18)).foregroundStyle(isSelected ? .white : Color("baseColor")))
            Text(food.displayName).font(.system(size: 14, weight: .medium)).foregroundStyle(isSelected ? Color("baseColor") : .primary).lineLimit(2)
            Spacer()
        }.padding(12).background(RoundedRectangle(cornerRadius: 16).fill(Color("cardBackground")))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(isSelected ? Color("baseColor") : Color.clear, lineWidth: 2))
    }

    private func quantitySection(food: FoodType) -> some View {
        QuantitySelectorView(selected: $selectedQuantity, unit: store.unitFor(food: food))
    }

    private var multiIngredientSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Ingredients").font(.system(size: 14, weight: .semibold)).foregroundStyle(Color("secondaryText"))
            VStack(spacing: 10) {
                ForEach(ingredients) { ingredient in
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(ingredient.name).font(.system(size: 16, weight: .medium))
                            Text("\(String(format: "%.0f", ingredient.quantity))\(ingredient.unit)").font(.system(size: 12)).foregroundStyle(Color("secondaryText"))
                        }
                        Spacer()
                        Text("\(Int(ingredient.calculatedCalories)) kcal").font(.system(size: 14, weight: .semibold)).foregroundStyle(.orange)
                        Button { withAnimation { ingredients.removeAll(where: { $0.id == ingredient.id }) } } label: {
                            Image(systemName: "minus.circle.fill").foregroundStyle(.red.opacity(0.8)).font(.system(size: 20))
                        }.padding(.leading, 8)
                    }.padding(14).background(Color("cardBackground")).clipShape(RoundedRectangle(cornerRadius: 14))
                }
                Button { showIngredientSearch = true } label: {
                    HStack { Image(systemName: "plus.circle.fill"); Text("Add Ingredient") }
                        .font(.system(size: 15, weight: .semibold)).foregroundStyle(Color("baseColor")).frame(maxWidth: .infinity).padding(.vertical, 14)
                        .background(RoundedRectangle(cornerRadius: 14).strokeBorder(Color("baseColor").opacity(0.5), style: StrokeStyle(lineWidth: 2, dash: [6])))
                }
            }
        }
    }

    private var caloriePreview: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Estimated Calories").font(.system(size: 12)).foregroundStyle(Color("secondaryText"))
                HStack(spacing: 6) {
                    Image(systemName: "flame.fill").foregroundStyle(.orange).font(.system(size: 20))
                    Text("\(Int(calculatedCalories)) kcal").font(.system(size: 28, weight: .bold))
                }
            }
            Spacer()
            if let food = selectedFood, !food.isEstimateOnly {
                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(String(format: "%.1f", selectedQuantity)) × \(store.unitFor(food: food))").font(.system(size: 12))
                    Text("@ \(Int(store.caloriesFor(food: food, quantity: 1.0))) kcal/\(store.unitFor(food: food))").font(.system(size: 11)).foregroundStyle(Color("secondaryText").opacity(0.7))
                }
            }
        }.padding(16).background(RoundedRectangle(cornerRadius: 18).fill(Color.orange.opacity(0.08)))
    }

    private var timePickerSection: some View {
        HStack {
            Text("Time").font(.system(size: 14, weight: .semibold)).foregroundStyle(Color("secondaryText"))
            Spacer()
            DatePicker("", selection: $selectedTime, displayedComponents: .hourAndMinute).labelsHidden().datePickerStyle(.compact).fixedSize()
        }.padding(14).background(Color("cardBackground")).clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var saveButton: some View {
        Button {
            Task {
                let unit = selectedFood?.isEstimateOnly == true ? "custom" : store.unitFor(food: selectedFood!)
                await store.updateMeal(type: mealType, foodType: selectedFood, quantity: selectedQuantity, unit: unit, ingredients: ingredients, time: selectedTime, isTaken: true, petId: petStore.activePetId ?? UUID())
                dismiss()
            }
        } label: {
            Text("Save \(mealType.rawValue)").font(.system(size: 17, weight: .semibold)).foregroundStyle(.white).frame(maxWidth: .infinity).padding(.vertical, 16).background(RoundedRectangle(cornerRadius: 16).fill(Color("baseColor")))
        }
    }
}
