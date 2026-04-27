//
//  IngredientSearchSheet.swift
//  PawPing
//

import SwiftUI

struct IngredientSearchSheet: View {
    @Environment(\.dismiss) private var dismiss
    var store: MealStore
    
    var onAddIngredient: (MealIngredient) -> Void
    
    @State private var searchText: String = ""
    @State private var selectedFood: USDAFood? = nil
    @State private var quantityText: String = ""
    
    private var searchResults: [USDAFood] {
        store.searchUSDA(query: searchText)
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                HStack {
                    Image(systemName: "magnifyingglass").foregroundStyle(Color("secondaryText"))
                    TextField("Search ingredients (e.g. Rice, Chicken)", text: $searchText).font(.system(size: 16))
                    if !searchText.isEmpty {
                        Button { searchText = "" } label: { Image(systemName: "xmark.circle.fill").foregroundStyle(Color("secondaryText")) }
                    }
                }
                .padding(12).background(Color("secondaryCardBackground").opacity(0.6)).clipShape(RoundedRectangle(cornerRadius: 12)).padding()
                
                if searchResults.isEmpty && !searchText.isEmpty {
                    Spacer(); Text("No ingredients found").font(.system(size: 15)).foregroundStyle(Color("secondaryText")); Spacer()
                } else {
                    List {
                        ForEach(searchResults) { food in
                            Button { selectedFood = food; quantityText = "" } label: {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(food.name).font(.system(size: 16, weight: .medium)).foregroundStyle(.primary)
                                        Text("\(Int(food.caloriesPer100g)) kcal per 100g").font(.system(size: 12)).foregroundStyle(Color("secondaryText"))
                                    }
                                    Spacer(); Image(systemName: "plus.circle").foregroundStyle(Color("baseColor")).font(.system(size: 20))
                                }.padding(.vertical, 4)
                            }.buttonStyle(.plain)
                        }
                    }.listStyle(.plain)
                }
            }
            .background(Color("baseBackground"))
            .navigationTitle("Add Ingredient")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) { Button("Cancel") { dismiss() } }
            }
            .sheet(item: $selectedFood) { quantityEntryView(for: $0).presentationDetents([.fraction(0.35)]) }
        }
    }
    
    private func quantityEntryView(for food: USDAFood) -> some View {
        VStack(spacing: 20) {
            Text("Add \(food.name)").font(.system(size: 18, weight: .semibold)).padding(.top)
            HStack(spacing: 12) {
                TextField("Quantity", text: $quantityText).keyboardType(.decimalPad).font(.system(size: 20, weight: .semibold))
                    .padding(14).background(Color("cardBackground")).clipShape(RoundedRectangle(cornerRadius: 14))
                Text("grams").font(.system(size: 16, weight: .medium)).foregroundStyle(Color("secondaryText"))
            }.padding(.horizontal)
            
            let enteredGrams = Double(quantityText) ?? 0
            let calculatedCalories = (food.caloriesPer100g / 100.0) * enteredGrams
            
            HStack {
                Text("Calories:").font(.system(size: 14)).foregroundStyle(Color("secondaryText"))
                Text("\(Int(calculatedCalories)) kcal").font(.system(size: 16, weight: .bold)).foregroundStyle(.orange)
            }
            
            Button {
                if enteredGrams > 0 {
                    onAddIngredient(MealIngredient(name: food.name, quantity: enteredGrams, unit: "g", caloriesPer100g: food.caloriesPer100g))
                    selectedFood = nil
                    dismiss()
                }
            } label: {
                Text("Add Ingredient").font(.system(size: 17, weight: .semibold)).foregroundStyle(.white).frame(maxWidth: .infinity).padding(.vertical, 16)
                    .background(RoundedRectangle(cornerRadius: 16).fill(enteredGrams > 0 ? Color("baseColor") : Color("secondaryText").opacity(0.5)))
            }
            .disabled(enteredGrams <= 0).padding(.horizontal)
            Spacer()
        }.background(Color("baseBackground"))
    }
}
