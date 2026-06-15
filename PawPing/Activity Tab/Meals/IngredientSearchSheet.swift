//
//  IngredientSearchSheet.swift
//  PawPing
//
//  Created by Atul on 25/04/26.
//
//  Live search UI for USDA dataset to add ingredients to a custom meal.
//

import SwiftUI

struct IngredientSearchSheet: View {
    @Environment(\.dismiss) private var dismiss
    var store: ActivityStore
    
    // Callback when an ingredient is selected and a quantity is entered
    var onAddIngredient: (MealIngredient) -> Void
    
    @State private var searchText: String = ""
    @State private var selectedFood: USDAFood? = nil
    @State private var quantityText: String = ""
    
    private var searchResults: [USDAFood] {
        store.mealDietStore.searchUSDA(query: searchText)
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(Color("secondaryText"))
                    TextField("Search ingredients (e.g. Rice, Chicken)", text: $searchText)
                        .font(.system(size: 16))
                    if !searchText.isEmpty {
                        Button {
                            searchText = ""
                        } label: {
                            Image(systemName: "xmark")
                        }
                    }
                }
                .padding(12)
                .background(Color("secondaryCardBackground").opacity(0.6))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding()
                
                if searchResults.isEmpty && !searchText.isEmpty {
                    Spacer()
                    Text("No ingredients found")
                        .font(.system(size: 15))
                        .foregroundStyle(Color("secondaryText"))
                    Spacer()
                } else {
                    List {
                        ForEach(searchResults) { food in
                            Button {
                                selectedFood = food
                                quantityText = ""
                            } label: {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(food.name)
                                            .font(.system(size: 16, weight: .medium))
                                            .foregroundStyle(.primary)
                                        Text("\(Int(food.caloriesPer100g)) kcal per 100g")
                                            .font(.system(size: 12))
                                            .foregroundStyle(Color("secondaryText"))
                                    }
                                    Spacer()
                                    Image(systemName: "plus.circle")
                                        .foregroundStyle(Color("baseColor"))
                                        .font(.system(size: 20))
                                }
                                .padding(.vertical, 4)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .background(Color("baseBackground"))
            .navigationTitle("Add Ingredient")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            // Quantity Entry Sheet
            .sheet(item: $selectedFood) { food in
                quantityEntryView(for: food)
                    .presentationDetents([.fraction(0.35)])
            }
        }
    }
    
    private func quantityEntryView(for food: USDAFood) -> some View {
        VStack(spacing: 20) {
            Text("Add \(food.name)")
                .font(.system(size: 18, weight: .semibold))
                .padding(.top)
            
            HStack(spacing: 12) {
                TextField("Quantity", text: $quantityText)
                    .keyboardType(.decimalPad)
                    .font(.system(size: 20, weight: .semibold))
                    .padding(14)
                    .background(Color("cardBackground"))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                
                Text("grams")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(Color("secondaryText"))
            }
            .padding(.horizontal)
            
            let enteredGrams = Double(quantityText) ?? 0
            let calculatedCalories = (food.caloriesPer100g / 100.0) * enteredGrams
            
            HStack {
                Text("Calories:")
                    .font(.system(size: 14))
                    .foregroundStyle(Color("secondaryText"))
                Text("\(Int(calculatedCalories)) kcal")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.orange)
            }
            
            Button {
                if enteredGrams > 0 {
                    let ingredient = MealIngredient(
                        name: food.name,
                        quantity: enteredGrams,
                        unit: "g",
                        caloriesPer100g: food.caloriesPer100g
                    )
                    onAddIngredient(ingredient)
                    selectedFood = nil
                    dismiss()
                }
            } label: {
                Text("Add Ingredient")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(enteredGrams > 0 ? Color("baseColor") : Color("secondaryText").opacity(0.5))
                    )
            }
            .disabled(enteredGrams <= 0)
            .padding(.horizontal)
            
            Spacer()
        }
        .background(Color("baseBackground"))
    }
}
