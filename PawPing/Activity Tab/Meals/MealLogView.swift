//
//  MealLogView.swift
//  PawPing
//
//  Created by SidMoon — Upgraded to MealsDashboardView on 25/04/26.
//
//  The Meals Dashboard — the main hub for the Meals & Diet system.
//  Shows: date selector, diet plan card, daily summary, meal cards,
//  insights, and notes. Meal cards open MealLoggingSheet on tap.
//

import SwiftUI

struct MealLogView: View {
    @Environment(\.dismiss) private var dismiss
    var store: ActivityStore
    @Environment(WeightStore.self) var weightStore
    @Environment(PetStore.self) var petStore
    
    // Dynamic dates for the current week (MON - SUN)
    private var weekDates: [Date] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        // Find the Monday of the current week
        var components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today)
        components.weekday = 2 // Monday
        
        guard let monday = calendar.date(from: components) else { return [] }
        
        return (0..<7).compactMap { day in
            calendar.date(byAdding: .day, value: day, to: monday)
        }
    }
    
    private var todayIndex: Int {
        let today = Calendar.current.startOfDay(for: Date())
        return weekDates.firstIndex(where: { Calendar.current.isDate($0, inSameDayAs: today) }) ?? 0
    }

    @State private var selectedDateIndex: Int = 0
    @State private var notesText = ""

    // Sheet states
    @State private var showMealSheet = false
    @State private var selectedMealType: MealType = .breakfast
    @State private var showDietSetup = false
    @State private var showWeightSheet = false
    
    // Convenience
    private var mealDietStore: MealDietStore {
        store.mealDietStore
    }

    private var totalCalories: Double {
        let date = weekDates[selectedDateIndex]
        return store.mealDietStore.totalCalories(on: date)
    }
    
    private var mealsLoggedCount: Int {
        let date = weekDates[selectedDateIndex]
        return store.mealDietStore.mealsLoggedCount(on: date)
    }
    
    private var displayedMeals: [Meal] {
        let date = weekDates[selectedDateIndex]
        return store.getMeals(for: date)
    }

    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 24) {
                
                // Date Selector
                dateSelector
                
                // Diet Card
                dietSection
                    .padding(.horizontal)

                // Weight & Condition Card
                weightSection
                    .padding(.horizontal)

                // Daily Summary
                dailySummary
                    .padding(.horizontal)
                
                VStack(spacing: 14) {
                    ForEach(displayedMeals, id: \.id) { meal in
                        Button {
                            selectedMealType = meal.mealType
                            showMealSheet = true
                        } label: {
                            mealCard(meal: meal)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal)
                
                // Insights
                insightsSection
                    .padding(.horizontal)
                
                // Notes Section
                notesSection
                
            }
            .padding(.top, 8)
            .navigationTitle("Meals")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.backward")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(.primary)
                    }
                }
            }
        }
        .background(Color("baseBackground"))
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .tabBar) 
        .onAppear {
            selectedDateIndex = todayIndex
        }
        .sheet(isPresented: $showMealSheet) {
            MealLoggingSheet(store: store, mealType: selectedMealType, logDate: weekDates[selectedDateIndex])
                .presentationDetents([.large])
        }
        .sheet(isPresented: $showDietSetup) {
            DietSetupSheet(store: store)
                .presentationDetents([.large])
        }
        .sheet(isPresented: $showWeightSheet) {
            if let pet = petStore.activePet {
                LogWeightSheet(pet: pet)
                    .presentationDetents([.medium])
            }
        }
        .task(id: petStore.activePetId) {
            if let petId = petStore.activePetId {
                weightStore.load(for: petId)
            }
        }
    }
    
    // MARK: - Date Selector (preserved from original)

    private var dateSelector: some View {
        HStack(spacing: 0) {
            let calendar = Calendar.current
            let weekDays = ["MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"]
            let currentWeekDates = weekDates
            
            ForEach(0..<currentWeekDates.count, id: \.self) { index in
                let date = currentWeekDates[index]
                let isFuture = index > todayIndex
                
                VStack(spacing: 10) {
                    Text(weekDays[index])
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(isFuture ? Color("secondaryText").opacity(0.3) : (index <= selectedDateIndex ? Color.primary : Color("secondaryText")))
                    
                    Circle()
                        .fill(backgroundForDateNode(index: index))
                        .frame(width: 46, height: 46)
                        .overlay(
                            Text("\(calendar.component(.day, from: date))")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(foregroundColorForDateNode(index: index))
                        )
                }
                .frame(maxWidth: .infinity)
                .contentShape(Circle())
                .onTapGesture {
                    if !isFuture {
                        withAnimation {
                            selectedDateIndex = index
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 10)
    }
    
    private func backgroundForDateNode(index: Int) -> Color {
        if index == selectedDateIndex {
            return Color("baseColor")
        } else if index < selectedDateIndex {
            return Color("baseColor").opacity(0.15)
        } else {
            return Color.clear
        }
    }
    
    private func foregroundColorForDateNode(index: Int) -> Color {
        let isFuture = index > todayIndex
        
        if index == selectedDateIndex {
            return .white
        } else if index < selectedDateIndex {
            return Color("baseColor")
        } else {
            return isFuture ? Color("secondaryText").opacity(0.3) : Color("secondaryText")
        }
    }

    // MARK: - Diet Section

    private var dietSection: some View {
        Group {
            if mealDietStore.dietPlan.isActive {
                // Active diet plan progress card
                VStack(spacing: 8) {
                    DietProgressView(
                        consumed: totalCalories,
                        target: mealDietStore.dietPlan.dailyCalorieTarget,
                        goal: mealDietStore.dietPlan.goal
                    )

                    Button {
                        mealDietStore.cancelDiet()
                    } label: {
                        Text("End Diet Plan")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(.red.opacity(0.7))
                    }
                }
            } else {
                // Start diet plan card
                Button {
                    showDietSetup = true
                } label: {
                    HStack(spacing: 14) {
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color.green.opacity(0.15))
                            .frame(width: 50, height: 50)
                            .overlay(
                                Image(systemName: "chart.line.uptrend.xyaxis")
                                    .font(.system(size: 22))
                                    .foregroundStyle(.green)
                            )

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Start Diet Plan")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundStyle(.primary)
                            Text("Set calorie targets based on your pet's needs")
                                .font(.system(size: 12))
                                .foregroundStyle(Color("secondaryText"))
                        }

                        Spacer()

                        Circle()
                            .fill(Color("baseColor").opacity(0.2))
                            .frame(width: 28, height: 28)
                            .overlay(
                                Image(systemName: "chevron.right")
                                    .foregroundStyle(Color("baseColor"))
                                    .font(.system(size: 12, weight: .bold))
                            )
                    }
                    .padding(14)
                    .background(Color("cardBackground"))
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - Daily Summary

    private var dailySummary: some View {
        HStack(spacing: 0) {
            // Total calories
            VStack(spacing: 4) {
                Image(systemName: "flame.fill")
                    .font(.system(size: 16))
                    .foregroundStyle(.orange)
                Text("\(Int(totalCalories))")
                    .font(.system(size: 22, weight: .bold))
                    .contentTransition(.numericText())
                Text("kcal today")
                    .font(.system(size: 11))
                    .foregroundStyle(Color("secondaryText"))
            }
            .frame(maxWidth: .infinity)

            Rectangle()
                .fill(Color("secondaryCardBackground"))
                .frame(width: 1, height: 40)

            // Meals logged
            VStack(spacing: 4) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 16))
                    .foregroundStyle(Color("baseColor"))
                Text("\(mealsLoggedCount)/3")
                    .font(.system(size: 22, weight: .bold))
                Text("logged")
                    .font(.system(size: 11))
                    .foregroundStyle(Color("secondaryText"))
            }
            .frame(maxWidth: .infinity)

            // Target (if diet active)
            if mealDietStore.dietPlan.isActive {
                Rectangle()
                    .fill(Color("secondaryCardBackground"))
                    .frame(width: 1, height: 40)

                VStack(spacing: 4) {
                    Image(systemName: "target")
                        .font(.system(size: 16))
                        .foregroundStyle(.green)
                    Text("\(Int(mealDietStore.dietPlan.dailyCalorieTarget - totalCalories))")
                        .font(.system(size: 22, weight: .bold))
                        .contentTransition(.numericText())
                    Text("remaining")
                        .font(.system(size: 11))
                        .foregroundStyle(Color("secondaryText"))
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.vertical, 16)
        .background(Color("cardBackground"))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    // MARK: - Meal Card

    private func mealCard(meal: Meal) -> some View {
        HStack(spacing: 14) {
            // Left accent bar for visual guidance
            RoundedRectangle(cornerRadius: 3)
                .fill(mealAccentColor(meal: meal))
                .frame(width: 4, height: 60)

            // Icon
            RoundedRectangle(cornerRadius: 14)
                .fill(Color("baseColor"))
                .frame(width: 52, height: 52)
                .overlay(
                    Image(systemName: meal.icon)
                        .font(.system(size: 20))
                        .foregroundStyle(.white)
                )

            // Info
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(meal.mealType.rawValue)
                        .font(.system(size: 17, weight: .semibold))

                    Spacer()

                    // Status badge
                    Text(meal.isTaken ? "Logged" : "Not Logged")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(meal.isTaken ? .green : Color("secondaryText").opacity(0.6))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(
                            Capsule()
                                .fill(meal.isTaken ? Color.green.opacity(0.12) : Color("secondaryCardBackground"))
                        )
                }

                HStack(spacing: 12) {
                    // Food name
                    if let food = meal.foodType {
                        Label(food.displayName, systemImage: food.icon)
                            .font(.system(size: 13))
                            .foregroundStyle(Color("secondaryText"))
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                    } else {
                        Text("Tap to log")
                            .font(.system(size: 13))
                            .foregroundStyle(Color("secondaryText").opacity(0.5))
                            .italic()
                    }

                    Spacer()

                    // Time
                    HStack(spacing: 2) {
                        Text(meal.time)
                            .font(.system(size: 12, weight: .medium))
                        Text(meal.meridian)
                            .font(.system(size: 9, weight: .medium))
                    }
                    .foregroundStyle(Color("secondaryText"))

                    // Calories badge
                    if meal.isTaken && meal.calories > 0 {
                        CalorieBadgeView(calories: meal.calories, style: .compact)
                    }
                }
            }
        }
        .padding(12)
        .background(Color("cardBackground"))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    /// Visual guidance: green for recommended, amber for over-allocation
    private func mealAccentColor(meal: Meal) -> Color {
        guard mealDietStore.dietPlan.isActive else {
            return meal.isTaken ? Color("baseColor") : Color("secondaryCardBackground")
        }

        let perMealTarget = mealDietStore.dietPlan.dailyCalorieTarget / 3.0

        if !meal.isTaken {
            return Color("secondaryCardBackground")
        } else if meal.calories <= perMealTarget * 1.2 {
            return .green   // recommended range
        } else {
            return .orange  // over per-meal allocation
        }
    }

    // MARK: - Insights Section

    private var insightsSection: some View {
        VStack(spacing: 8) {
            if let daily = mealDietStore.dailyInsight(on: Date()) {
                insightCard(text: daily)
            }

            if let weekly = mealDietStore.weeklyInsight(on: Date()) {
                insightCard(text: weekly)
            }
        }
    }

    private func insightCard(text: String) -> some View {
        HStack(spacing: 10) {
            Text(text)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(.primary)

            Spacer()
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color("baseColor").opacity(0.06))
        )
    }

    // MARK: - Notes Section (preserved)

    private var notesSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Notes")
                .font(.system(size: 16, weight: .bold))
                .padding(.horizontal, 22)
            
            HStack {
                TextField("Add any additional notes here...", text: $notesText)
                    .font(.system(size: 16))
                
                Button {
                    // Logic to save notes can be added here
                    print("Notes saved: \(notesText)")
                } label: {
                    Text("Save")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color("baseColor"))
                        .clipShape(Capsule())
                }
            }
            .padding(.leading, 20)
            .padding(.trailing, 8)
            .padding(.vertical, 8)
            .background(Color("cardBackground"))
            .clipShape(Capsule())
            .padding(.horizontal)
        }
    }

    // MARK: - Weight Section

    private var weightSection: some View {
        Group {
            if let latest = weightStore.latestRecord {
                NavigationLink {
                    WeightTrackerView(petId: petStore.activePetId!)
                } label: {
                    HStack(spacing: 14) {
                        RoundedRectangle(cornerRadius: 14)
                            .fill(latest.bodyCondition.color.opacity(0.15))
                            .frame(width: 50, height: 50)
                            .overlay(
                                Image(systemName: "scalemass.fill")
                                    .font(.system(size: 22))
                                    .foregroundStyle(latest.bodyCondition.color)
                            )

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Weight & Condition")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundStyle(.primary)
                            Text("\(String(format: "%.1f kg", latest.weightKg)) · \(latest.bodyCondition.label)")
                                .font(.system(size: 12))
                                .foregroundStyle(Color("secondaryText"))
                        }

                        Spacer()

                        Circle()
                            .fill(Color("baseColor").opacity(0.2))
                            .frame(width: 28, height: 28)
                            .overlay(
                                Image(systemName: "chevron.right")
                                    .foregroundStyle(Color("baseColor"))
                                    .font(.system(size: 12, weight: .bold))
                            )
                    }
                    .padding(14)
                    .background(Color("cardBackground"))
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                }
                .buttonStyle(.plain)
            } else {
                Button {
                    showWeightSheet = true
                } label: {
                    HStack(spacing: 14) {
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color("baseColor").opacity(0.15))
                            .frame(width: 50, height: 50)
                            .overlay(
                                Image(systemName: "scalemass")
                                    .font(.system(size: 22))
                                    .foregroundStyle(Color("baseColor"))
                            )

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Weight & Condition")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundStyle(.primary)
                            Text("Log your first check-in →")
                                .font(.system(size: 12))
                                .foregroundStyle(Color("secondaryText"))
                        }

                        Spacer()

                        Circle()
                            .fill(Color("baseColor").opacity(0.2))
                            .frame(width: 28, height: 28)
                            .overlay(
                                Image(systemName: "chevron.right")
                                    .foregroundStyle(Color("baseColor"))
                                    .font(.system(size: 12, weight: .bold))
                            )
                    }
                    .padding(14)
                    .background(Color("cardBackground"))
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                }
                .buttonStyle(.plain)
            }
        }
    }
}

#Preview {
    NavigationStack {
        MealLogView(store: ActivityStore())
            .environment(PetStore())
            .environment(WeightStore())
    }
}
