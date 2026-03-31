//
//  MealLogView.swift
//  PawPing
//
//  Created by Mamoon.
//

import SwiftUI

struct MealLogView: View {
    @Environment(\.dismiss) private var dismiss
    var store: ActivityStore
    
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

    @State private var selectedDateIndex: Int = 0 // Will be set in .onAppear
    @State private var notesText = ""
    
    // Selected meals per type, using predefined sample structure
    @State private var breakfastSelection: MealName = .pedigree
    @State private var lunchSelection: MealName = .select
    @State private var dinnerSelection: MealName = .select
    
    // Saved status per meal
    @State private var isBreakfastSaved = true
    @State private var isLunchSaved = false
    @State private var isDinnerSaved = false
    
    // Date states for pickers
    @State private var breakfastTime: Date = Calendar.current.date(bySettingHour: 8, minute: 0, second: 0, of: Date()) ?? Date()
    @State private var lunchTime: Date = Calendar.current.date(bySettingHour: 13, minute: 0, second: 0, of: Date()) ?? Date()
    @State private var dinnerTime: Date = Calendar.current.date(bySettingHour: 20, minute: 0, second: 0, of: Date()) ?? Date()
    
    @State private var showAlert = false
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 24) {
                
                // Date Selector
                dateSelector
                
                // Meal Cards
                VStack(spacing: 16) {
                    mealCard(type: .breakfast, selectedMeal: $breakfastSelection, time: $breakfastTime, isSaved: $isBreakfastSaved)
                    
                    mealCard(type: .lunch, selectedMeal: $lunchSelection, time: $lunchTime, isSaved: $isLunchSaved)
                    mealCard(type: .dinner, selectedMeal: $dinnerSelection, time: $dinnerTime, isSaved: $isDinnerSaved)
                }
                .padding(.horizontal)
                
                // Notes Section
                notesSection
                
                // Allergies Info Card
                allergiesCard
                    .padding(.bottom, 60)
            }
            .padding(.top,8)
            .navigationTitle("Meals")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar{
                ToolbarItem(placement:.topBarLeading){
                    Button{
                        dismiss()
                    }label:{
                        Image(systemName:"chevron.left")
                    }
                }
            }
        }
        .background(Color("baseBackground"))
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .tabBar) 
        .onAppear {
            selectedDateIndex = todayIndex
            syncWithStore()
        }
        .alert("Selection Required", isPresented: $showAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("You must select a meal to save the log.")
        }
    }
    
    // MARK: - Store Synchronization
    
    private func syncWithStore() {
        if let breakfast = store.meals.first(where: { $0.mealType == .breakfast }) {
            breakfastSelection = breakfast.mealName
            isBreakfastSaved = breakfast.isTaken
            breakfastTime = parseTime(breakfast.time, meridian: breakfast.meridian)
        }
        
        if let lunch = store.meals.first(where: { $0.mealType == .lunch }) {
            lunchSelection = lunch.mealName
            isLunchSaved = lunch.isTaken
            lunchTime = parseTime(lunch.time, meridian: lunch.meridian)
        }
        
        if let dinner = store.meals.first(where: { $0.mealType == .dinner }) {
            dinnerSelection = dinner.mealName
            isDinnerSaved = dinner.isTaken
            dinnerTime = parseTime(dinner.time, meridian: dinner.meridian)
        }
    }
    
    private func parseTime(_ time: String, meridian: String) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.date(from: "\(time) \(meridian)") ?? Date()
    }
    
    private func saveToStore(type: MealType) {
        switch type {
        case .breakfast:
            store.updateMeal(type: .breakfast, name: breakfastSelection, time: breakfastTime, isTaken: isBreakfastSaved)
        case .lunch:
            store.updateMeal(type: .lunch, name: lunchSelection, time: lunchTime, isTaken: isLunchSaved)
        case .dinner:
            store.updateMeal(type: .dinner, name: dinnerSelection, time: dinnerTime, isTaken: isDinnerSaved)
        }
    }
    
    // MARK: - Date Selector
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
    
    // MARK: - Meal Card
    private func mealCard(type: MealType, selectedMeal: Binding<MealName>, time: Binding<Date>, isSaved: Binding<Bool>) -> some View {
        HStack(alignment: .top, spacing: 16) {
            // Icon
            RoundedRectangle(cornerRadius: 16)
                .fill(Color("baseColor"))
                .frame(width: 64, height: 64)
                .overlay(
                    Image("allergiesIcon") // Placeholder for dog food bowl icon, reusing for shape
                        .resizable()
                        .renderingMode(.template)
                        .foregroundStyle(.white)
                        .frame(width: 40, height: 40) // scaling it down
                )
            
            VStack(alignment: .leading, spacing: 0) {
                // Title & Dropdown
                HStack(alignment: .center) {
                    Text(type.rawValue)
                        .font(.system(size: 20, weight: .regular))
                    
                    Spacer()
                    
                    Menu {
                        Picker("Meal", selection: selectedMeal) {
                            ForEach(MealName.allCases) { meal in
                                Text(meal == .select ? "Select Meal" : meal.rawValue).tag(meal)
                            }
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Text(selectedMeal.wrappedValue == .select ? "Select Meal" : selectedMeal.wrappedValue.rawValue)
                                .font(.system(size: 15))
                                .foregroundStyle(Color("secondaryText"))
                            Image(systemName: "chevron.down")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(Color("secondaryText"))
                        }
                    }
                }
                .padding(.bottom, 6)
                .onChange(of: selectedMeal.wrappedValue) { _, _ in
                    if isSaved.wrappedValue { saveToStore(type: type) }
                }
                
                Divider()
                
                // Time & Status buttons
                HStack(spacing: 8) {
                    Spacer()
                    
                    // Time Picker
                    DatePicker("", selection: time, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                        .datePickerStyle(.compact)
                        .fixedSize()
                        .onChange(of: time.wrappedValue) { _, _ in
                            if isSaved.wrappedValue { saveToStore(type: type) }
                        }
                    
                    // Status Button
                    Button {
                        if !isSaved.wrappedValue && selectedMeal.wrappedValue == .select {
                            showAlert = true
                        } else {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                isSaved.wrappedValue.toggle()
                                saveToStore(type: type)
                            }
                        }
                    } label: {
                        Text(isSaved.wrappedValue ? "Log Saved" : "Save Log")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(isSaved.wrappedValue ? .white : Color("baseColor"))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(isSaved.wrappedValue ? Color("baseColor") : .clear)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(Color("baseColor"), lineWidth: isSaved.wrappedValue ? 0 : 1.5)
                            )
                    }
                }
                .padding(.top, 8)
            }
        }
        .padding()
        .background(Color("cardBackground"))
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }
    
    // MARK: - Notes Section
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
    
    // MARK: - Allergies Card
    private var allergiesCard: some View {
        HStack(alignment: .top, spacing: 16) {
            // Icon
            RoundedRectangle(cornerRadius: 20)
                .fill(Color("secondaryCardBackground"))
                .frame(width: 80, height: 80)
                .overlay(
                    Image("allergiesIcon") // Assuming this exists based on ActivityView
                        .resizable()
                        .frame(width: 66, height: 63)
                )
            
            VStack(alignment: .leading, spacing: 6) {
                Text("Allergies")
                    .font(.system(size: 22, weight: .bold))
                
                Text("Check Symptoms & find possible food that Cause discomfort!")
                    .font(.system(size: 14))
                    .foregroundStyle(Color("secondaryText"))
                    .lineLimit(2)
                
                // Tags
                HStack(spacing: 8) {
                    allergyTag("Gluten")
                    allergyTag("Lactose")
                    allergyTag("Wheat")
                }
                .padding(.top, 4)
                
                Button {
                    // Navigate to manage allergies
                } label: {
                    Text("Manage Allergies")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color("baseColor"))
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                }
                .padding(.top, 4)
            }
        }
        .padding()
        .background(Color("cardBackground"))
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .padding(.horizontal)
    }
    
    private func allergyTag(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 12, weight: .medium))
            .foregroundStyle(Color("baseColor"))
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(
                Capsule()
                    .stroke(Color("baseColor").opacity(0.5), lineWidth: 1)
            )
    }
}

#Preview {
    NavigationStack {
        MealLogView(store: ActivityStore())
    }
}
