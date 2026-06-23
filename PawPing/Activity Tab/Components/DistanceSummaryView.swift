//
// DistanceSummaryView.swift
// Pawping
//
// Created by Atul on 28/03/26
//

import SwiftUI
import Charts

struct DistanceSummaryView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    var store: ActivityStore
    
    @State private var selectedRange = 0
    @State private var showCalendar = false
    
    private let ranges = ["Week", "Month"]
    
    // MARK: - Synchronized Data Source (Logged or Fallback)
    
    private var currentWeekData: [DistanceData] {
        if store.activities.isEmpty {
            let calendar = Calendar.current
            let today = Date()
            var components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date())
            components.weekday = 2
            let monday = calendar.date(from: components) ?? today
            let days = (0..<7).map { calendar.date(byAdding: .day, value: $0, to: monday) ?? today }
            let vals = [1.2, 2.3, 1.7, 0.9, 0.0, 2.6, 1.5]
            return zip(days, vals).map { DistanceData(date: $0, distanceInKm: $1) }
        }
        return store.distanceSummary.weekData
    }

    private var currentMonthData: [DistanceData] {
        if store.activities.isEmpty {
            let calendar = Calendar.current
            let today = Date()
            let firstOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: today)) ?? today
            var result: [DistanceData] = []
            for day in 1...30 {
                let date = calendar.date(byAdding: .day, value: day - 1, to: firstOfMonth) ?? today
                let val: Double = (day == 14 || day == 15) ? 4.6 : ((day % 5 == 0) ? 1.8 : ((day % 3 == 0) ? 0.8 : 0.0))
                result.append(DistanceData(date: date, distanceInKm: val))
            }
            return result
        }
        return store.distanceSummary.monthData
    }
    
    // MARK: - Dynamic Calculations
    
    private var vsLastWeekPercent: Int {
        let weeklyDistance = currentWeekData.reduce(0.0) { $0 + $1.distanceInKm }
        let calendar = Calendar.current
        var comps = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date())
        comps.weekday = 2
        guard let thisMonday = calendar.date(from: comps),
              let lastMonday = calendar.date(byAdding: .weekOfYear, value: -1, to: thisMonday),
              let lastSunday = calendar.date(byAdding: .day, value: 6, to: lastMonday)
        else { return 12 }
        let lastWeekDist = store.activities
            .filter { $0.date >= lastMonday && $0.date <= lastSunday }
            .reduce(0.0) { $0 + $1.distanceInKm }
        guard lastWeekDist > 0 else { return 12 }
        return Int(((weeklyDistance - lastWeekDist) / lastWeekDist) * 100)
    }
    
    private var vsLastMonthPercent: Int {
        let monthlyDistance = currentMonthData.reduce(0.0) { $0 + $1.distanceInKm }
        let calendar = Calendar.current
        guard let thisMonthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: Date())),
              let lastMonthStart = calendar.date(byAdding: .month, value: -1, to: thisMonthStart),
              let lastMonthEnd = calendar.date(byAdding: .day, value: -1, to: thisMonthStart)
        else { return 18 }
        let lastMonthDist = store.activities
            .filter { $0.date >= lastMonthStart && $0.date <= lastMonthEnd }
            .reduce(0.0) { $0 + $1.distanceInKm }
        guard lastMonthDist > 0 else { return 18 }
        return Int(((monthlyDistance - lastMonthDist) / lastMonthDist) * 100)
    }
    
    private var daysMeetingGoal: Int {
        let calendar = Calendar.current
        let goalMins = store.walkActivity.goalMinutes
        guard goalMins > 0 else { return 0 }
        
        var components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date())
        components.weekday = 2
        guard let monday = calendar.date(from: components) else { return 0 }
        let sunday = calendar.date(byAdding: .day, value: 6, to: monday) ?? Date()
        
        let thisWeekActivities = store.activities.filter { $0.date >= monday && $0.date <= sunday }
        let groupedByDay = Dictionary(grouping: thisWeekActivities) { activity in
            calendar.startOfDay(for: activity.date)
        }
        
        return groupedByDay.values.filter { activities in
            let totalMins = activities.reduce(0) { $0 + $1.durationMinutes }
            return totalMins >= goalMins
        }.count
    }
    
    private var bestDayOfMonth: (dateLabel: String, distance: Double) {
        let sorted = currentMonthData.filter { $0.distanceInKm > 0 }.sorted(by: { $0.distanceInKm > $1.distanceInKm })
        if let best = sorted.first {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d"
            return (formatter.string(from: best.date), best.distanceInKm)
        }
        return ("—", 0.0)
    }
    
    // Bottom grid values (Week)
    private var longestWalkWeek: (distance: Double, day: String) {
        let sorted = currentWeekData.sorted(by: { $0.distanceInKm > $1.distanceInKm })
        if let best = sorted.first, best.distanceInKm > 0 {
            return (best.distanceInKm, best.dayLabel)
        }
        return (0.0, "—")
    }
    
    private var avgDistancePerWalkWeek: Double {
        let validWalks = currentWeekData.filter { $0.distanceInKm > 0 }
        guard !validWalks.isEmpty else { return 0.0 }
        let total = validWalks.reduce(0.0) { $0 + $1.distanceInKm }
        return total / Double(validWalks.count)
    }
    
    private var totalWalksWeek: Int {
        currentWeekData.filter { $0.distanceInKm > 0 }.count
    }
    
    // Bottom grid values (Month)
    private var totalWalksMonth: Int {
        currentMonthData.filter { $0.distanceInKm > 0 }.count
    }
    
    private var avgDistancePerWalkMonth: Double {
        let validWalks = currentMonthData.filter { $0.distanceInKm > 0 }
        guard !validWalks.isEmpty else { return 0.0 }
        let total = validWalks.reduce(0.0) { $0 + $1.distanceInKm }
        return total / Double(validWalks.count)
    }
    
    private var totalTimeMonthString: String {
        let calendar = Calendar.current
        let today = Date()
        guard let firstOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: today)) else {
            return "0h 0m"
        }
        let monthActivities = store.activities.filter { $0.date >= firstOfMonth && $0.date <= today }
        let totalMinutes = monthActivities.reduce(0) { $0 + $1.durationMinutes }
        guard totalMinutes > 0 else { return "0h 0m" }
        let hours = totalMinutes / 60
        let minutes = totalMinutes % 60
        return "\(hours)h \(minutes)m"
    }
    
    var body: some View {
        let isDark = colorScheme == .dark
        ScrollView {
            VStack(spacing: 20) {
                
                // MARK: - Custom Range Picker (Pill Segmented Style)
                HStack(spacing: 0) {
                    ForEach(0..<ranges.count, id: \.self) { index in
                        Button {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                selectedRange = index
                            }
                        } label: {
                            Text(ranges[index])
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(selectedRange == index ? .white : .textSecondary)
                                .frame(maxWidth: .infinity)
                                .frame(height: 38)
                                .background(
                                    RoundedRectangle(cornerRadius: 19)
                                        .fill(selectedRange == index ? Color.homePurple : Color.clear)
                                )
                        }
                    }
                }
                .padding(4)
                .background(RoundedRectangle(cornerRadius: 22).fill(isDark ? Color(white: 0.16) : Color.textPrimary.opacity(0.05)))
                .padding(.horizontal)
                .padding(.top, 8)
                
                // MARK: - Summary Statistics & Dog Illustration
                HStack(alignment: .bottom) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(selectedRange == 0 ? "THIS WEEK" : "THIS MONTH")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.textSecondary)
                            .tracking(0.5)
                        
                        let distanceVal = selectedRange == 0 ? currentWeekData.reduce(0.0) { $0 + $1.distanceInKm } : currentMonthData.reduce(0.0) { $0 + $1.distanceInKm }
                        
                        HStack(alignment: .lastTextBaseline, spacing: 4) {
                            Text(String(format: selectedRange == 0 ? "%.1f" : "%.2f", distanceVal))
                                .font(.system(size: 50, weight: .bold))
                                .foregroundColor(.homePurple)
                            Text("km")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.textPrimary)
                        }
                        
                        Text(selectedRange == 0 ? store.distanceSummary.weekRange : store.distanceSummary.monthName)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.textSecondary)
                    }
                    
                    Spacer()
                    
                    // Dog illustration
                    Image("walk_dog_illustration")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 8)
                
                // MARK: - Trend Banner
                let percent = selectedRange == 0 ? vsLastWeekPercent : vsLastMonthPercent
                let labelType = selectedRange == 0 ? "week" : "month"
                let absPercent = abs(percent)
                let direction = percent >= 0 ? "more" : "less"
                HStack {
                    Image(systemName: percent >= 0 ? "chart.line.uptrend.xyaxis" : "chart.line.downtrend.xyaxis")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(percent >= 0 ? .homePurple : .red)
                    
                    Text("\(absPercent)% \(direction) than last \(labelType)")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.textPrimary)
                    
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(isDark ? Color(white: 0.16) : Color.white)
                        .shadow(color: .black.opacity(isDark ? 0.15 : 0.03), radius: 6, x: 0, y: 3)
                )
                .padding(.horizontal)
                
                // MARK: - Chart Card
                VStack(alignment: .leading, spacing: 12) {
                    chartContent
                        .frame(height: 200)
                        .padding(.top, 16)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(isDark ? Color(white: 0.13) : Color.cardIvory)
                        .shadow(color: .black.opacity(isDark ? 0.18 : 0.04), radius: 10, x: 0, y: 4)
                )
                .padding(.horizontal)
                
                // MARK: - Highlight Banner
                if selectedRange == 0 {
                    // Weekly Goal Banner
                    HStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(Color.white.opacity(isDark ? 0.15 : 0.2))
                                .frame(width: 36, height: 36)
                            Image(systemName: "pawprint.fill")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                        }
                        
                        let goalDays = daysMeetingGoal
                        let petName = store.activePet?.name ?? "Tommy"
                        Text(goalDays > 0 ? "Great job!\n\(petName) met the goal on \(goalDays) days this week." : "Keep it up!\n\(petName) has not met the daily goal yet this week.")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.white)
                            .lineSpacing(2)
                        
                        Spacer()
                        
                        Image(systemName: "pawprint")
                            .font(.system(size: 22))
                            .foregroundColor(.white.opacity(0.35))
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.homePurple)
                    )
                    .padding(.horizontal)
                } else {
                    // Monthly Best Day Banner
                    HStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(Color.white.opacity(isDark ? 0.15 : 0.2))
                                .frame(width: 36, height: 36)
                            Image(systemName: "trophy.fill")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.yellow)
                        }
                        
                        let bestDay = bestDayOfMonth
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Best Day")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(.white)
                            Text(String(format: "%.1f km on %@", bestDay.distance, bestDay.dateLabel))
                                .font(.system(size: 12))
                                .foregroundColor(.white.opacity(0.85))
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.homePurple)
                    )
                    .padding(.horizontal)
                }
                
                // MARK: - 3 Box Stats Grid
                HStack(spacing: 12) {
                    if selectedRange == 0 {
                        // Box 1: Longest Walk
                        let longest = longestWalkWeek
                        DistanceStatCardView(
                            iconName: "mappin.and.ellipse",
                            iconColor: Color.blue,
                            title: "Longest Walk",
                            value: String(format: "%.1f km", longest.distance),
                            subtitle: longest.day
                        )
                        
                        // Box 2: Avg Distance
                        DistanceStatCardView(
                            iconName: "clock.fill",
                            iconColor: Color.homePurple,
                            title: "Avg Distance",
                            value: String(format: "%.1f km", avgDistancePerWalkWeek),
                            subtitle: "Per Walk"
                        )
                        
                        // Box 3: Total Walks
                        DistanceStatCardView(
                            iconName: "flame.fill",
                            iconColor: Color.orange,
                            title: "Total Walks",
                            value: "\(totalWalksWeek)",
                            subtitle: "This Week"
                        )
                    } else {
                        // Box 1: Total Walks
                        DistanceStatCardView(
                            iconName: "dog.fill",
                            iconColor: Color.blue,
                            title: "Total Walks",
                            value: "\(totalWalksMonth)",
                            subtitle: "This Month"
                        )
                        
                        // Box 2: Avg Distance
                        DistanceStatCardView(
                            iconName: "clock.fill",
                            iconColor: Color.homePurple,
                            title: "Avg Distance",
                            value: String(format: "%.1f km", avgDistancePerWalkMonth),
                            subtitle: "Per Walk"
                        )
                        
                        // Box 3: Total Time
                        DistanceStatCardView(
                            iconName: "clock.fill",
                            iconColor: Color.blue,
                            title: "Total Time",
                            value: totalTimeMonthString,
                            subtitle: "This Month"
                        )
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 24)
            }
        }
        .background(isDark ? Color.black : Color(white: 0.98))
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.primary)
                }
            }
            ToolbarItem(placement: .principal) {
                Text("Distance")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(.primary)
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showCalendar = true
                } label: {
                    Image(systemName: "calendar")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.primary)
                }
            }
        }
        .sheet(isPresented: $showCalendar) {
            WalkCalendarView(store: store)
        }
    }
    
    // MARK: - Chart Content View
    private var chartContent: some View {
        let isDark = colorScheme == .dark
        let data = selectedRange == 0 ? currentWeekData : currentMonthData
        
        let maxVal = data.map { $0.distanceInKm }.max() ?? 0.0
        let targetGoal: Double = selectedRange == 0 ? 2.0 : 3.0
        let yMax = max(targetGoal + 1.0, maxVal * 1.15)
        
        return Chart {
            // Target Goal Rule Line
            RuleMark(y: .value("Goal", targetGoal))
                .lineStyle(StrokeStyle(lineWidth: 1, dash: [4]))
                .foregroundStyle(Color.homePurple)
            
            ForEach(data) { item in
                BarMark(
                    x: .value("Date", selectedRange == 0 ? item.dayLabel : item.dayOfMonthLabel),
                    y: .value("Distance", item.distanceInKm)
                )
                .foregroundStyle(
                    selectedRange == 0 ? Color.homePurple : 
                    ((item.distanceInKm > 2.5) ? Color.homePurple : Color.homePurple.opacity(0.25))
                )
                .cornerRadius(selectedRange == 0 ? 6 : 3)
                .annotation(position: .top) {
                    if selectedRange == 0 || item.distanceInKm > 3.0 || (item.distanceInKm > 0 && selectedRange == 1 && item.dayOfMonthLabel == "15") {
                        Text(String(format: "%.1f", item.distanceInKm))
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.textPrimary)
                    }
                }
            }
        }
        .chartXAxis {
            if selectedRange == 0 {
                AxisMarks(values: .automatic) { _ in
                    AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [2]))
                        .foregroundStyle(isDark ? Color(white: 0.25) : Color.gray.opacity(0.2))
                    AxisValueLabel()
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(Color.textSecondary)
                }
            } else {
                AxisMarks(values: ["1", "8", "15", "22", "29", "30"]) { _ in
                    AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [2]))
                        .foregroundStyle(isDark ? Color(white: 0.25) : Color.gray.opacity(0.2))
                    AxisValueLabel()
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(Color.textSecondary)
                }
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading, values: .automatic) { value in
                AxisValueLabel {
                    if let distance = value.as(Double.self) {
                        Text(distance == 0 ? "0" : String(format: "%.1f km", distance))
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(Color.textSecondary)
                    }
                }
                AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [4]))
                    .foregroundStyle(isDark ? Color(white: 0.25) : Color.gray.opacity(0.2))
            }
        }
        .chartYScale(domain: 0...yMax)
    }
}

// MARK: - Subviews

struct DistanceStatCardView: View {
    @Environment(\.colorScheme) private var colorScheme
    let iconName: String
    let iconColor: Color
    let title: String
    let value: String
    let subtitle: String
    
    var body: some View {
        let isDark = colorScheme == .dark
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: iconName)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(iconColor)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.textSecondary)
                
                Text(value)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.textPrimary)
                
                Text(subtitle)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.textSecondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(isDark ? Color(white: 0.13) : Color.cardIvory)
                .shadow(color: .black.opacity(isDark ? 0.15 : 0.03), radius: 6, x: 0, y: 3)
        )
    }
}

#Preview {
    NavigationStack {
        DistanceSummaryView(store: ActivityStore())
    }
}
