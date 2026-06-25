//
//  MealLogView.swift
//  PawPing
//
//  Created by SidMoon — Upgraded to MealsDashboardView on 25/04/26.
//
//

import SwiftUI

struct MealLogView: View {
    @Environment(\.dismiss) private var dismiss
    var store: ActivityStore
    @Environment(WeightStore.self) var weightStore
    @Environment(PetStore.self) var petStore
    
    // Dynamic dates for the week containing selectedDate (MON - SUN)
    private var weekDates: [Date] {
        let calendar = Calendar.current
        let baseDate = calendar.startOfDay(for: selectedDate)
        
        // Find the Monday of the week of baseDate
        var components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: baseDate)
        components.weekday = 2 // Monday
        
        guard let monday = calendar.date(from: components) else { return [] }
        
        return (0..<7).compactMap { day in
            calendar.date(byAdding: .day, value: day, to: monday)
        }
    }

    @State private var selectedDate: Date = Date()
    @State private var showDatePicker = false

    // Sheet states
    @State private var showMealSheet = false
    @State private var selectedMealType: MealType = .breakfast
    @State private var showDietSetup = false
    @State private var showWeightSheet = false
    
    // Convenience
    private var mealDietStore: MealDietStore {
        store.mealDietStore
    }

    private var selectedDateIndex: Int {
        let dayStart = Calendar.current.startOfDay(for: selectedDate)
        return weekDates.firstIndex(where: { Calendar.current.isDate($0, inSameDayAs: dayStart) }) ?? 0
    }

    private var isToday: Bool {
        Calendar.current.isDateInToday(selectedDate)
    }

    private var displayedMeals: [Meal] {
        store.getMeals(for: selectedDate)
    }

    private var totalCalories: Double {
        displayedMeals.filter { $0.isTaken }.reduce(0) { $0 + $1.calories }
    }
    
    private var mealsLoggedCount: Int {
        displayedMeals.filter { $0.isTaken }.count
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 24) {
                // Date Selector
                dateSelector
                    .padding(.top, 16)
                
                // Diet Card
                if isToday {
                    dietSection
                        .padding(.horizontal)
                }

                // Daily Summary
                dailySummary
                    .padding(.horizontal)
                
                // Meals List
                VStack(spacing: 14) {
                    ForEach(displayedMeals, id: \.id) { meal in
                        Button {
                            selectedMealType = meal.mealType
                            showMealSheet = true
                        } label: {
                            mealCard(meal: meal)
                        }
                        .buttonStyle(.plain)
                        .disabled(!isToday && meal.foodType != .custom)
                    }
                }
                .padding(.horizontal)
                
                // Insights
                insightsSection
                    .padding(.horizontal)
                
                Spacer(minLength: 40)
            }
        }
        .background(
            LinearGradient(colors: [.bgWarmTop, .bgWarmBottom], startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()
        )
        .navigationTitle("Meals")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showDatePicker = true
                } label: {
                    Image(systemName: "calendar")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(Color.homePurple)
                }
            }
        }
        .onAppear {
            selectedDate = Calendar.current.startOfDay(for: Date())
        }
        .sheet(isPresented: $showMealSheet) {
            MealLoggingSheet(store: store, mealType: selectedMealType, logDate: selectedDate, isReadOnly: !isToday)
                .presentationDetents([.large])
        }
        .sheet(isPresented: $showDatePicker) {
            NavigationStack {
                DatePicker(
                    "Select Date",
                    selection: $selectedDate,
                    in: ...Date(),
                    displayedComponents: [.date]
                )
                .datePickerStyle(.graphical)
                .tint(Color("baseColor"))
                .padding()
                .navigationTitle("Select Date")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Done") {
                            showDatePicker = false
                        }
                    }
                }
            }
            .presentationDetents([.medium])
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
                weightStore.load(for: petId, petName: petStore.activePet?.name ?? "")
            }
        }
    }
    
    // MARK: - Date Selector (preserved & redesigned)

    private var dateSelector: some View {
        HStack(spacing: 0) {
            let calendar = Calendar.current
            let weekDays = ["MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"]
            let currentWeekDates = weekDates
            
            ForEach(0..<currentWeekDates.count, id: \.self) { index in
                let date = currentWeekDates[index]
                let isFuture = date > calendar.startOfDay(for: Date())
                
                VStack(spacing: 10) {
                    Text(weekDays[index])
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(isFuture ? Color.textSecondary.opacity(0.3) : Color.textSecondary)
                    
                    Circle()
                        .fill(backgroundForDateNode(index: index))
                        .frame(width: 38, height: 38)
                        .overlay(
                            Text("\(calendar.component(.day, from: date))")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(foregroundColorForDateNode(index: index))
                        )
                }
                .frame(maxWidth: .infinity)
                .contentShape(Circle())
                .onTapGesture {
                    if !isFuture {
                        withAnimation {
                            selectedDate = date
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 10)
    }
    
    private func backgroundForDateNode(index: Int) -> Color {
        if index == selectedDateIndex {
            return Color.homePurple
        } else {
            return Color.clear
        }
    }
    
    private func foregroundColorForDateNode(index: Int) -> Color {
        let calendar = Calendar.current
        let date = weekDates[index]
        let isFuture = date > calendar.startOfDay(for: Date())
        
        if index == selectedDateIndex {
            return .white
        } else {
            return isFuture ? Color.textSecondary.opacity(0.3) : Color.textPrimary
        }
    }

    // MARK: - Diet Section (Redesigned Start Diet Plan Card)

    @Environment(\.colorScheme) private var colorScheme

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
                let isDark = colorScheme == .dark
                Button {
                    showDietSetup = true
                } label: {
                    HStack(spacing: 12) {
                        // Left Icon
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color.homeGreen.opacity(isDark ? 0.25 : 0.15))
                            .frame(width: 50, height: 50)
                            .overlay(
                                Image(systemName: "chart.line.uptrend.xyaxis")
                                    .font(.system(size: 22))
                                    .foregroundStyle(Color.homeGreen)
                            )
                        
                        // Text
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Start Diet Plan")
                                .font(.system(size: 17, weight: .bold))
                                .foregroundStyle(Color.textPrimary)
                            Text("Set calorie targets based on your pet's needs")
                                .font(.system(size: 12))
                                .foregroundStyle(Color.textSecondary)
                                .lineLimit(2)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(Color.homePurple)
                            .frame(width: 28, height: 28)
                            .background(isDark ? Color(white: 0.18) : Color.white)
                            .clipShape(Circle())
                            .shadow(color: .black.opacity(isDark ? 0.3 : 0.1), radius: 4, x: 0, y: 2)
                    }
                    .padding(.vertical, 12)
                    .padding(.horizontal, 16)
                    .background(
                        isDark
                        ? LinearGradient(
                            colors: [Color.homeGreen.opacity(0.18), Color.homeGreen.opacity(0.08)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                          )
                        : LinearGradient(
                            colors: [Color(hex: "EAF9F0") ?? .green.opacity(0.12), Color(hex: "F6FDF9") ?? .green.opacity(0.04)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                          )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 24))
                    .shadow(color: .black.opacity(isDark ? 0.15 : 0.03), radius: 8, x: 0, y: 4)
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - Daily Summary

    private var dailySummary: some View {
        HStack(spacing: 0) {
            // Total calories
            HStack(spacing: 12) {
                Spacer()
                
                ZStack {
                    Circle()
                        .fill(Color.orange.opacity(0.15))
                        .frame(width: 36, height: 36)
                    Image(systemName: "flame.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(.orange)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(Int(totalCalories))")
                        .font(.system(size: 26, weight: .bold))
                        .foregroundStyle(Color.textPrimary)
                        .contentTransition(.numericText())
                    Text("kcal")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Color.textSecondary)
                }
                
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .background(alignment: .leading) {
                Image(systemName: "pawprint.fill")
                    .font(.system(size: 44))
                    .foregroundStyle(Color.orange)
                    .opacity(0.06)
                    .rotationEffect(.degrees(-15))
                    .offset(x: 16, y: -8)
            }

            // Middle Separator
            Rectangle()
                .fill(Color.gray.opacity(0.15))
                .frame(width: 1.5, height: 50)

            // Meals logged
            HStack(spacing: 12) {
                Spacer()
                
                ZStack {
                    Circle()
                        .fill(Color.homePurple)
                        .frame(width: 36, height: 36)
                    Image(systemName: "checkmark")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.white)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(mealsLoggedCount)/3")
                        .font(.system(size: 26, weight: .bold))
                        .foregroundStyle(Color.textPrimary)
                    Text("logged")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Color.textSecondary)
                }
                
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .background(alignment: .trailing) {
                Image(systemName: "pawprint.fill")
                    .font(.system(size: 44))
                    .foregroundStyle(Color.homePurple)
                    .opacity(0.06)
                    .rotationEffect(.degrees(15))
                    .offset(x: -16, y: -8)
            }
        }
        .padding(.vertical, 20)
        .background(
            colorScheme == .dark
            ? LinearGradient(
                colors: [Color.orange.opacity(0.12), Color.homePurple.opacity(0.12)],
                startPoint: .leading,
                endPoint: .trailing
              )
            : LinearGradient(
                colors: [Color(hex: "FFF7F0") ?? .orange.opacity(0.04), Color(hex: "F3F2FF") ?? .purple.opacity(0.04)],
                startPoint: .leading,
                endPoint: .trailing
              )
        )
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .shadow(color: .black.opacity(colorScheme == .dark ? 0.2 : 0.03), radius: 8, x: 0, y: 4)
    }

    // MARK: - Meal Card

    private func mealCard(meal: Meal) -> some View {
        HStack(spacing: 14) {
            // Icon (Bowl Image instead of sun/moon)
            RoundedRectangle(cornerRadius: 16)
                .fill(mealIconBgColor(meal: meal))
                .frame(width: 52, height: 52)
                .overlay(
                    Image(mealImageName(meal: meal))
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 40)
                )

            // Info
            VStack(alignment: .leading, spacing: 6) {
                Text(meal.mealType.rawValue)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(Color.textPrimary)

                // Food name + calories separated by centered dot
                if let food = meal.foodType {
                    let foodText = meal.isTaken && meal.calories > 0
                        ? "\(food.displayName) • \(Int(meal.calories)) kcal"
                        : food.displayName
                    Text(foodText)
                        .font(.system(size: 13))
                        .foregroundStyle(Color.textSecondary)
                        .lineLimit(1)
                } else {
                    Text("Tap to log")
                        .font(.system(size: 13))
                        .foregroundStyle(Color.textSecondary.opacity(0.7))
                }
            }
            
            Spacer()
            
            // Status and Time (Bowl image removed from right)
            VStack(alignment: .trailing, spacing: 4) {
                // Status badge
                Text(meal.isTaken ? "Logged" : "Not Logged")
                    .font(.system(size: 11, weight: .bold))
                    .lineLimit(1)
                    .fixedSize(horizontal: true, vertical: false)
                    .foregroundStyle(meal.isTaken ? Color.homeGreen : mealBadgeTextColor(meal: meal))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(meal.isTaken ? Color.homeGreen.opacity(0.12) : mealBadgeBgColor(meal: meal))
                    )

                // Time
                Text("\(meal.time) \(meal.meridian)")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Color.textSecondary)
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(colorScheme == .dark ? Color(white: 0.12) : Color.cardIvory)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .shadow(color: .black.opacity(colorScheme == .dark ? 0.2 : 0.03), radius: 8, x: 0, y: 4)
    }
    
    // MARK: - Meal Helpers
    
    private func mealIconBgColor(meal: Meal) -> Color {
        switch meal.mealType {
        case .breakfast:
            return Color.homeYellow.opacity(0.15)
        case .lunch:
            return Color.orange.opacity(0.15)
        case .dinner:
            return Color.homePurple.opacity(0.15)
        }
    }
    
    private func mealIconColor(meal: Meal) -> Color {
        switch meal.mealType {
        case .breakfast:
            return Color.homeYellow
        case .lunch:
            return Color.orange
        case .dinner:
            return Color.homePurple
        }
    }
    
    private func mealBadgeTextColor(meal: Meal) -> Color {
        switch meal.mealType {
        case .breakfast, .lunch:
            return .orange
        case .dinner:
            return Color.homePurple
        }
    }
    
    private func mealBadgeBgColor(meal: Meal) -> Color {
        switch meal.mealType {
        case .breakfast, .lunch:
            return Color.orange.opacity(0.1)
        case .dinner:
            return Color.homePurple.opacity(0.1)
        }
    }
    
    private func mealImageName(meal: Meal) -> String {
        switch meal.mealType {
        case .breakfast:
            return "bowl_pink"
        case .lunch:
            return "bowl_yellow"
        case .dinner:
            return "bowl_blue"
        }
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
}

#Preview {
    NavigationStack {
        MealLogView(store: ActivityStore())
            .environment(PetStore())
            .environment(WeightStore())
    }
}
