//
//  MealLogView.swift
//  PawPing
//

import SwiftUI

struct MealLogView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(PetStore.self) var petStore
    @Environment(WeightStore.self) var weightStore
    var store: MealStore
    
    // Dynamic dates for the current week (MON - SUN)
    private var weekDates: [Date] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
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
    @State private var showMealSheet = false
    @State private var selectedMealType: MealType = .breakfast
    @State private var showDietSetup = false
    @State private var showWeightTracker = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if let petId = petStore.activePetId {
                    VStack(spacing: 24) {
                        dateSelector
                        dietSection.padding(.horizontal)
                        weightCard.padding(.horizontal)
                        dailySummary.padding(.horizontal)
                        
                        VStack(spacing: 14) {
                            ForEach(store.meals, id: \.id) { meal in
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
                        
                        insightsSection.padding(.horizontal)
                        notesSection
                            .padding(.bottom, 100)
                    }
                    .padding(.top, 8)
                    .task(id: petId) {
                        await store.fetchMeals(for: petId)
                        weightStore.load(for: petId)
                    }
                } else {
                    ContentUnavailableView(
                        "No Pet Selected",
                        systemImage: "dog.fill",
                        description: Text("Please add a pet to track their meals.")
                    )
                    .padding(.top, 100)
                }
            }
            .customNavigationScroll(
                title: "Meals",
                petStore: petStore
            )
            .background(Color("baseBackground"))
            .navigationDestination(isPresented: $showWeightTracker) {
                WeightTrackerView()
            }
        }
        .onAppear {
            selectedDateIndex = todayIndex
        }
        .sheet(isPresented: $showMealSheet) {
            MealLoggingSheet(store: store, mealType: selectedMealType)
                .presentationDetents([.large])
        }
        .sheet(isPresented: $showDietSetup) {
            DietSetupSheet(store: store)
                .presentationDetents([.large])
        }
    }
    
    private var dateSelector: some View {
        HStack(spacing: 0) {
            let calendar = Calendar.current
            let weekDays = ["MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"]
            let currentWeekDates = weekDates
            ForEach(0..<currentWeekDates.count, id: \.self) { index in
                let date = currentWeekDates[index]
                let isFuture = index > todayIndex
                VStack(spacing: 6) {
                    Text(weekDays[index])
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(isFuture ? Color("secondaryText").opacity(0.3) : (index == selectedDateIndex ? Color("baseColor") : Color("secondaryText")))
                    
                    ZStack(alignment: .bottom) {
                        Circle()
                            .fill(index == selectedDateIndex ? Color("baseColor") : (index < todayIndex ? Color("baseColor").opacity(0.1) : Color.clear))
                            .frame(width: 44, height: 44)
                            .overlay(
                                Text("\(calendar.component(.day, from: date))")
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundStyle(index == selectedDateIndex ? .white : (isFuture ? Color("secondaryText").opacity(0.3) : Color.primary))
                            )
                        
                        if index == todayIndex {
                            Text("TODAY")
                                .font(.system(size: 7, weight: .black))
                                .foregroundStyle(index == selectedDateIndex ? .white : Color("baseColor"))
                                .padding(.bottom, 4)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .contentShape(Rectangle())
                .onTapGesture { 
                    if !isFuture { 
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) { 
                            selectedDateIndex = index 
                            store.selectedDate = date
                        }
                        if let petId = petStore.activePetId {
                            Task { await store.fetchMeals(for: petId) }
                        }
                    } 
                }
            }
        }
        .padding(.horizontal, 10)
    }
    
    private var dietSection: some View {
        Group {
            if store.dietPlan.isActive {
                VStack(spacing: 8) {
                    DietProgressView(
                        consumed: store.totalCaloriesToday,
                        target: store.dietPlan.dailyCalorieTarget,
                        goal: store.dietPlan.goal
                    )
                    Button { store.cancelDiet() } label: {
                        Text("End Diet Plan").font(.system(size: 12, weight: .medium)).foregroundStyle(.red.opacity(0.7))
                    }
                }
            } else {
                Button { showDietSetup = true } label: {
                    HStack(spacing: 14) {
                        RoundedRectangle(cornerRadius: 14).fill(Color.green.opacity(0.15)).frame(width: 50, height: 50)
                            .overlay(Image(systemName: "chart.line.uptrend.xyaxis").font(.system(size: 22)).foregroundStyle(.green))
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Start Diet Plan").font(.system(size: 17, weight: .semibold))
                            Text("Set calorie targets based on your pet's needs").font(.system(size: 12)).foregroundStyle(Color("secondaryText"))
                        }
                        Spacer()
                        Circle().fill(Color("baseColor").opacity(0.2)).frame(width: 28, height: 28)
                            .overlay(Image(systemName: "chevron.right").foregroundStyle(Color("baseColor")).font(.system(size: 12, weight: .bold)))
                    }
                    .padding(14).background(Color("cardBackground")).clipShape(RoundedRectangle(cornerRadius: 20))
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var weightCard: some View {
        Button {
            showWeightTracker = true
        } label: {
            HStack(spacing: 14) {
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.blue.opacity(0.15))
                    .frame(width: 50, height: 50)
                    .overlay(
                        Image(systemName: "scalemass.fill")
                            .font(.system(size: 22))
                            .foregroundStyle(.blue)
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Weight & Condition")
                        .font(.system(size: 17, weight: .semibold))
                    
                    if let latest = weightStore.latest {
                        Text("\(latest.weightKg, specifier: "%.1f") kg • \(latest.bodyConditionLabel)")
                            .font(.system(size: 12))
                            .foregroundStyle(Color("secondaryText"))
                    } else {
                        Text("Log your first weight check-in")
                            .font(.system(size: 12))
                            .foregroundStyle(Color("secondaryText"))
                    }
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

    private var dailySummary: some View {
        HStack(spacing: 0) {
            summaryNode(icon: "flame.fill", color: .orange, value: "\(Int(store.totalCaloriesToday))", label: "kcal today")
            Rectangle().fill(Color("secondaryCardBackground")).frame(width: 1, height: 40)
            summaryNode(icon: "checkmark.circle.fill", color: Color("baseColor"), value: "\(store.mealsLoggedToday)/3", label: "logged")
            if store.dietPlan.isActive {
                Rectangle().fill(Color("secondaryCardBackground")).frame(width: 1, height: 40)
                summaryNode(icon: "target", color: .green, value: "\(Int(max(0, store.dietPlan.dailyCalorieTarget - store.totalCaloriesToday)))", label: "remaining")
            }
        }
        .padding(.vertical, 16).background(Color("cardBackground")).clipShape(RoundedRectangle(cornerRadius: 20))
    }
    
    private func summaryNode(icon: String, color: Color, value: String, label: String) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon).font(.system(size: 16)).foregroundStyle(color)
            Text(value).font(.system(size: 22, weight: .bold)).contentTransition(.numericText())
            Text(label).font(.system(size: 11)).foregroundStyle(Color("secondaryText"))
        }.frame(maxWidth: .infinity)
    }

    private func mealCard(meal: Meal) -> some View {
        HStack(spacing: 14) {
            RoundedRectangle(cornerRadius: 3).fill(mealAccentColor(meal: meal)).frame(width: 4, height: 60)
            RoundedRectangle(cornerRadius: 14).fill(Color("baseColor")).frame(width: 52, height: 52)
                .overlay(Image(systemName: meal.icon).font(.system(size: 20)).foregroundStyle(.white))
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(meal.mealType.rawValue).font(.system(size: 17, weight: .semibold))
                    Spacer()
                    Text(meal.isTaken ? "Logged" : "Not Logged").font(.system(size: 11, weight: .medium))
                        .foregroundStyle(meal.isTaken ? .green : Color("secondaryText").opacity(0.6))
                        .padding(.horizontal, 8).padding(.vertical, 3)
                        .background(Capsule().fill(meal.isTaken ? Color.green.opacity(0.12) : Color("secondaryCardBackground")))
                }
                HStack(spacing: 12) {
                    if let food = meal.foodType {
                        Label(food.displayName, systemImage: food.icon).font(.system(size: 13)).foregroundStyle(Color("secondaryText")).lineLimit(2)
                    } else {
                        Text("Tap to log").font(.system(size: 13)).foregroundStyle(Color("secondaryText").opacity(0.5)).italic()
                    }
                    Spacer()
                    Text("\(meal.time) \(meal.meridian)").font(.system(size: 12, weight: .medium)).foregroundStyle(Color("secondaryText"))
                    if meal.isTaken && meal.calories > 0 { CalorieBadgeView(calories: meal.calories, style: .compact) }
                }
            }
        }
        .padding(12).background(Color("cardBackground")).clipShape(RoundedRectangle(cornerRadius: 20))
    }

    private func mealAccentColor(meal: Meal) -> Color {
        guard store.dietPlan.isActive else { return meal.isTaken ? Color("baseColor") : Color("secondaryCardBackground") }
        let perMealTarget = store.dietPlan.dailyCalorieTarget / 3.0
        if !meal.isTaken { return Color("secondaryCardBackground") }
        else if meal.calories <= perMealTarget * 1.2 { return .green }
        else { return .orange }
    }

    private var insightsSection: some View {
        VStack(spacing: 8) {
            // Simplified insights for refactor
            if store.dietPlan.isActive {
                if store.totalCaloriesToday > store.dietPlan.dailyCalorieTarget * 1.1 {
                    insightCard(text: "⚠️ Overfeeding detected today")
                } else if store.totalCaloriesToday > 0 && store.totalCaloriesToday < store.dietPlan.dailyCalorieTarget * 0.5 {
                    insightCard(text: "📉 Low appetite detected")
                }
            }
        }
    }

    private func insightCard(text: String) -> some View {
        HStack(spacing: 10) {
            Text(text).font(.system(size: 13, weight: .medium)).foregroundStyle(.primary)
            Spacer()
        }.padding(14).background(RoundedRectangle(cornerRadius: 14).fill(Color("baseColor").opacity(0.06)))
    }

    private var notesSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Notes").font(.system(size: 16, weight: .bold)).padding(.horizontal, 22)
            HStack {
                TextField("Add any additional notes here...", text: $notesText).font(.system(size: 16))
                Button { print("Notes saved: \(notesText)") } label: {
                    Text("Save").font(.system(size: 14, weight: .semibold)).foregroundStyle(.white).padding(.horizontal, 16).padding(.vertical, 8).background(Color("baseColor")).clipShape(Capsule())
                }
            }
            .padding(.leading, 20).padding(.trailing, 8).padding(.vertical, 8).background(Color("cardBackground")).clipShape(Capsule()).padding(.horizontal)
        }
    }
}
