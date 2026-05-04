//
//  WalkCalendarView.swift
//  PawPing
//

import SwiftUI

struct WalkCalendarView: View {
    @Environment(\.dismiss) private var dismiss
    var store: ActivityStore
    
    @State private var currentMonth: Date = Date()
    
    private let calendar = Calendar.current
    private let daysOfWeek = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"]
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                
                // MARK: - Header
                HStack {
                    Button {
                        changeMonth(by: -1)
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(Color("baseColor"))
                            .frame(width: 44, height: 44)
                    }
                    
                    Spacer()
                    
                    Text(monthYearString)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(.primary)
                    
                    Spacer()
                    
                    Button {
                        changeMonth(by: 1)
                    } label: {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(Color("baseColor"))
                            .frame(width: 44, height: 44)
                    }
                    // Disable next month if it's in the future
                    .disabled(isFutureMonth(currentMonth))
                    .opacity(isFutureMonth(currentMonth) ? 0.3 : 1.0)
                }
                .padding(.horizontal)
                .padding(.top, 16)
                
                // MARK: - Calendar Grid
                VStack(spacing: 16) {
                    // Weekday headers
                    HStack {
                        ForEach(daysOfWeek, id: \.self) { day in
                            Text(day)
                                .font(.system(size: 12, weight: .bold))
                                .foregroundStyle(Color("secondaryText"))
                                .frame(maxWidth: .infinity)
                        }
                    }
                    
                    // Days grid
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 16) {
                        let days = extractDates()
                        
                        ForEach(days) { dayValue in
                            dayView(dayValue: dayValue)
                        }
                    }
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .background(Color("baseBackground"))
            .navigationTitle("Walk History")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(Color("baseColor"))
                }
            }
        }
    }
    
    // MARK: - Subviews
    
    @ViewBuilder
    private func dayView(dayValue: DayValue) -> some View {
        VStack {
            if dayValue.day != -1 {
                let dateComps = calendar.dateComponents([.year, .month, .day], from: dayValue.date)
                let isWalked = store.walkedDates.contains(dateComps)
                let isToday = calendar.isDateInToday(dayValue.date)
                let isFuture = dayValue.date > Date()
                
                if isWalked {
                    if let activity = store.activities.first(where: {
                        calendar.dateComponents([.year, .month, .day], from: $0.date) == dateComps
                    }) {
                        NavigationLink {
                            WalkDetailView(activity: activity)
                        } label: {
                            Circle()
                                .fill(Color("baseColor"))
                                .frame(width: 36, height: 36)
                                .overlay(
                                    Text("\(dayValue.day)")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundStyle(.white)
                                )
                        }
                    } else {
                        // Fallback (shouldn't happen)
                        Text("\(dayValue.day)")
                            .font(.system(size: 16))
                            .frame(width: 36, height: 36)
                    }
                } else {
                    ZStack {
                        if isToday {
                            Circle()
                                .stroke(Color("baseColor"), lineWidth: 2)
                                .frame(width: 36, height: 36)
                        }
                        Text("\(dayValue.day)")
                            .font(.system(size: 16, weight: isToday ? .bold : .regular))
                            .foregroundStyle(isFuture ? Color("secondaryText").opacity(0.3) : .primary)
                    }
                    .frame(width: 36, height: 36)
                }
            } else {
                Text("")
                    .frame(width: 36, height: 36)
            }
        }
    }
    
    // MARK: - Helpers
    
    private var monthYearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM YYYY"
        return formatter.string(from: currentMonth)
    }
    
    private func changeMonth(by value: Int) {
        if let newMonth = calendar.date(byAdding: .month, value: value, to: currentMonth) {
            currentMonth = newMonth
        }
    }
    
    private func isFutureMonth(_ date: Date) -> Bool {
        let nextMonth = calendar.date(byAdding: .month, value: 1, to: date) ?? date
        let currentMonthComps = calendar.dateComponents([.year, .month], from: Date())
        let checkMonthComps = calendar.dateComponents([.year, .month], from: nextMonth)
        
        if let cy = currentMonthComps.year, let cm = currentMonthComps.month,
           let ny = checkMonthComps.year, let nm = checkMonthComps.month {
            if ny > cy { return true }
            if ny == cy && nm > cm { return true }
        }
        return false
    }
    
    private func extractDates() -> [DayValue] {
        var days: [DayValue] = []
        
        let components = calendar.dateComponents([.year, .month], from: currentMonth)
        guard let firstDayOfMonth = calendar.date(from: components) else { return [] }
        
        let firstWeekday = calendar.component(.weekday, from: firstDayOfMonth)
        
        guard let range = calendar.range(of: .day, in: .month, for: firstDayOfMonth) else { return [] }
        
        // Add empty slots for the days of the week before the 1st
        for _ in 1..<firstWeekday {
            days.append(DayValue(day: -1, date: Date()))
        }
        
        // Add actual days
        for day in range {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstDayOfMonth) {
                days.append(DayValue(day: day, date: date))
            }
        }
        
        return days
    }
}

struct DayValue: Identifiable {
    var id = UUID()
    var day: Int
    var date: Date
}
