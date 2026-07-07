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
    @State private var chartMode = 0 // 0 = Distance (km), 1 = Time (minutes)
    
    private let ranges = ["Week", "Month"]
    
    struct ActivityChartPoint: Identifiable {
        let id = UUID()
        let date: Date
        let distanceInKm: Double
        let durationMinutes: Double
        let dayLabel: String
        let dayOfMonthLabel: String
    }
    
    private var currentWeekChartData: [ActivityChartPoint] {
        let calendar = Calendar.current
        let today = Date()
        var components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today)
        components.weekday = 2
        let monday = calendar.date(from: components) ?? today
        let weekDates = (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: monday) }
        
        var points: [ActivityChartPoint] = []
        for wDate in weekDates {
            let dayStart = calendar.startOfDay(for: wDate)
            let dayActivities = store.activities.filter { calendar.isDate($0.date, inSameDayAs: dayStart) }
            
            let dist = dayActivities.reduce(0.0) { $0 + $1.distanceInKm }
            let mins = dayActivities.reduce(0.0) { $0 + Double($1.durationMinutes) }
            
            let formatter = DateFormatter()
            formatter.dateFormat = "EEE"
            let dLabel = formatter.string(from: wDate)
            formatter.dateFormat = "d"
            let dmLabel = formatter.string(from: wDate)
            
            points.append(ActivityChartPoint(
                date: wDate,
                distanceInKm: dist,
                durationMinutes: mins,
                dayLabel: dLabel,
                dayOfMonthLabel: dmLabel
            ))
        }
        
        let totalDist = points.reduce(0.0) { $0 + $1.distanceInKm }
        if totalDist == 0 && store.activities.isEmpty {
            let valsDist = [1.2, 2.3, 1.7, 0.9, 0.0, 2.6, 1.5]
            let valsMins = [24.0, 46.0, 34.0, 18.0, 0.0, 52.0, 30.0]
            return zip(points, zip(valsDist, valsMins)).map { pt, val in
                ActivityChartPoint(
                    date: pt.date,
                    distanceInKm: val.0,
                    durationMinutes: val.1,
                    dayLabel: pt.dayLabel,
                    dayOfMonthLabel: pt.dayOfMonthLabel
                )
            }
        }
        
        return points
    }

    private var currentMonthChartData: [ActivityChartPoint] {
        let calendar = Calendar.current
        let today = Date()
        guard let firstOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: today)),
              let monthRange = calendar.range(of: .day, in: .month, for: today)
        else { return [] }
        
        var points: [ActivityChartPoint] = []
        for day in monthRange {
            if let dayDate = calendar.date(byAdding: .day, value: day - 1, to: firstOfMonth) {
                let dayStart = calendar.startOfDay(for: dayDate)
                let dayActivities = store.activities.filter { calendar.isDate($0.date, inSameDayAs: dayStart) }
                
                let dist = dayActivities.reduce(0.0) { $0 + $1.distanceInKm }
                let mins = dayActivities.reduce(0.0) { $0 + Double($1.durationMinutes) }
                
                let formatter = DateFormatter()
                formatter.dateFormat = "EEE"
                let dLabel = formatter.string(from: dayDate)
                formatter.dateFormat = "d"
                let dmLabel = formatter.string(from: dayDate)
                
                points.append(ActivityChartPoint(
                    date: dayDate,
                    distanceInKm: dist,
                    durationMinutes: mins,
                    dayLabel: dLabel,
                    dayOfMonthLabel: dmLabel
                ))
            }
        }
        
        let totalDist = points.reduce(0.0) { $0 + $1.distanceInKm }
        if totalDist == 0 && store.activities.isEmpty {
            return points.map { pt in
                let day = Int(pt.dayOfMonthLabel) ?? 1
                let valDist: Double = (day == 14 || day == 15) ? 4.6 : ((day % 5 == 0) ? 1.8 : ((day % 3 == 0) ? 0.8 : 0.0))
                let valMins = valDist * 20.0
                return ActivityChartPoint(
                    date: pt.date,
                    distanceInKm: valDist,
                    durationMinutes: valMins,
                    dayLabel: pt.dayLabel,
                    dayOfMonthLabel: pt.dayOfMonthLabel
                )
            }
        }
        
        return points
    }
    
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
    
    private var weeklyGoalBannerContent: (title: String, message: String, color: Color) {
        let petName = store.activePet?.name ?? "Sheru"
        let goalDays = daysMeetingGoal
        
        if goalDays == 0 {
            return (
                title: "Let's get moving!",
                message: "\(petName) has not met the daily goal yet this week.",
                color: .homePurple
            )
        } else if goalDays == 7 {
            return (
                title: "Perfect week!",
                message: "\(petName) met the daily goal every single day!",
                color: .homeGreen
            )
        } else {
            return (
                title: "Keep it up!",
                message: "\(petName) met the goal on \(goalDays) \(goalDays == 1 ? "day" : "days") this week.",
                color: .homePurple
            )
        }
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
                    HStack {
                        Text(chartMode == 0 ? "Distance Trend" : "Duration Trend")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.textPrimary)
                        
                        Spacer()
                        
                        Picker("Metric", selection: $chartMode) {
                            Text("Distance").tag(0)
                            Text("Time").tag(1)
                        }
                        .pickerStyle(.segmented)
                        .frame(width: 160)
                    }
                    .padding(.horizontal, 4)
                    
                    chartContent
                        .frame(height: 200)
                        .padding(.top, 10)
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
                    let bannerContent = weeklyGoalBannerContent
                    HStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(Color.white.opacity(isDark ? 0.15 : 0.2))
                                .frame(width: 36, height: 36)
                            Image(systemName: "pawprint.fill")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                        }
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(bannerContent.title)
                                .font(.system(size: 14, weight: .bold))
                            Text(bannerContent.message)
                                .font(.system(size: 12, weight: .medium))
                                .opacity(0.9)
                        }
                        .foregroundColor(.white)
                        
                        Spacer()
                        
                        Image(systemName: "pawprint")
                            .font(.system(size: 22))
                            .foregroundColor(.white.opacity(0.35))
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(bannerContent.color)
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
        let data = selectedRange == 0 ? currentWeekChartData : currentMonthChartData
        
        let maxVal = data.map { chartMode == 0 ? $0.distanceInKm : $0.durationMinutes }.max() ?? 0.0
        let targetGoal: Double
        if chartMode == 0 {
            targetGoal = selectedRange == 0 ? 2.0 : 3.0
        } else {
            targetGoal = Double(store.walkActivity.goalMinutes)
        }
        let yMax = max(targetGoal + (chartMode == 0 ? 1.0 : 15.0), maxVal * 1.15)
        
        return Chart {
            // Target Goal Rule Line
            RuleMark(y: .value("Goal", targetGoal))
                .lineStyle(StrokeStyle(lineWidth: 1, dash: [4]))
                .foregroundStyle(Color.homePurple)
            
            ForEach(data) { item in
                let yVal = chartMode == 0 ? item.distanceInKm : item.durationMinutes
                let threshold = chartMode == 0 ? 2.5 : Double(store.walkActivity.goalMinutes) * 0.8
                
                BarMark(
                    x: .value("Date", selectedRange == 0 ? item.dayLabel : item.dayOfMonthLabel),
                    y: .value(chartMode == 0 ? "Distance" : "Time", yVal)
                )
                .foregroundStyle(
                    selectedRange == 0 ? Color.homePurple : 
                    ((yVal > threshold) ? Color.homePurple : Color.homePurple.opacity(0.25))
                )
                .cornerRadius(selectedRange == 0 ? 6 : 3)
                .annotation(position: .top) {
                    if selectedRange == 0 || yVal > (chartMode == 0 ? 3.0 : Double(store.walkActivity.goalMinutes) * 1.0) || (yVal > 0 && selectedRange == 1 && item.dayOfMonthLabel == "15") {
                        Text(chartMode == 0 ? String(format: "%.1f", yVal) : String(format: "%.0f", yVal))
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
                    if let val = value.as(Double.self) {
                        Text(val == 0 ? "0" : (chartMode == 0 ? String(format: "%.1f km", val) : String(format: "%.0f min", val)))
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
