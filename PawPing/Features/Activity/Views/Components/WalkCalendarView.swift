//
//  WalkCalendarView.swift
//  PawPing
//

import SwiftUI

struct WalkCalendarView: View {
    @Environment(ActivityStore.self) var store
    @Environment(\.dismiss) private var dismiss
    
    @State private var currentMonth: Date = Date()
    @State private var selectedSession: WalkSession?
    @State private var showDetail = false
    
    private let calendar = Calendar.current
    private let daysInWeek = ["M", "T", "W", "T", "F", "S", "S"]
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // MARK: - Month Header
                HStack {
                    Text(currentMonth.formatted(.dateTime.month(.wide).year()))
                        .font(.system(size: 20, weight: .bold))
                    
                    Spacer()
                    
                    HStack(spacing: 20) {
                        Button { changeMonth(by: -1) } label: {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 16, weight: .bold))
                        }
                        
                        Button { changeMonth(by: 1) } label: {
                            Image(systemName: "chevron.right")
                                .font(.system(size: 16, weight: .bold))
                        }
                    }
                    .foregroundStyle(Color("baseColor"))
                }
                .padding(.horizontal, 24)
                .padding(.top, 24)
                
                // MARK: - Calendar Grid
                VStack(spacing: 16) {
                    // Weekday Labels
                    HStack(spacing: 0) {
                        ForEach(daysInWeek, id: \.self) { day in
                            Text(day)
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(.secondary)
                                .frame(maxWidth: .infinity)
                        }
                    }
                    
                    let days = generateDays()
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 12) {
                        ForEach(days, id: \.self) { date in
                            if let date = date {
                                dayView(for: date)
                            } else {
                                Color.clear.frame(height: 40)
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)
                
                Spacer()
                
                // Legend
                HStack(spacing: 20) {
                    legendItem(label: "Walked", color: Color("baseColor"))
                    legendItem(label: "Today", color: Color("baseColor"), outlined: true)
                }
                .padding(.bottom, 20)
            }
            .background(Color("baseBackground"))
            .navigationTitle("History")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close") { dismiss() }
                }
            }
            .navigationDestination(isPresented: $showDetail) {
                if let session = selectedSession {
                    WalkDetailView(session: session)
                }
            }
        }
    }
    
    // MARK: - Subviews
    
    private func dayView(for date: Date) -> some View {
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        let isToday = calendar.isDateInToday(date)
        let hasWalk = store.walkedDates.contains(components)
        let isFuture = date > Date()
        
        return Button {
            if hasWalk {
                if let session = store.walkSessions.first(where: { calendar.isDate($0.date, inSameDayAs: date) }) {
                    selectedSession = session
                    showDetail = true
                }
            }
        } label: {
            ZStack {
                if hasWalk {
                    Circle()
                        .fill(Color("baseColor"))
                        .frame(width: 36, height: 36)
                } else if isToday {
                    Circle()
                        .stroke(Color("baseColor"), lineWidth: 2)
                        .frame(width: 36, height: 36)
                }
                
                Text("\(calendar.component(.day, from: date))")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(hasWalk ? .white : (isFuture ? .secondary.opacity(0.3) : .primary))
            }
            .frame(height: 40)
        }
        .disabled(!hasWalk)
    }
    
    private func legendItem(label: String, color: Color, outlined: Bool = false) -> some View {
        HStack(spacing: 8) {
            if outlined {
                Circle().stroke(color, lineWidth: 2).frame(width: 12, height: 12)
            } else {
                Circle().fill(color).frame(width: 12, height: 12)
            }
            Text(label)
                .font(.system(size: 12))
                .foregroundStyle(.secondary)
        }
    }
    
    // MARK: - Helpers
    
    private func changeMonth(by value: Int) {
        if let newMonth = calendar.date(byAdding: .month, value: value, to: currentMonth) {
            withAnimation {
                currentMonth = newMonth
            }
        }
    }
    
    private func generateDays() -> [Date?] {
        let range = calendar.range(of: .day, in: .month, for: currentMonth)!
        let firstOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: currentMonth))!
        let weekday = calendar.component(.weekday, from: firstOfMonth)
        
        // Adjust weekday for Monday start (standard in many regions, customize if needed)
        // MapKit typically uses 1=Sun, 2=Mon... 7=Sat.
        // For Monday start: Mon=0, Tue=1... Sun=6
        let offset = (weekday + 5) % 7
        
        var days: [Date?] = Array(repeating: nil, count: offset)
        for day in 1...range.count {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstOfMonth) {
                days.append(date)
            }
        }
        return days
    }
}

#Preview {
    WalkCalendarView()
        .environment(ActivityStore())
}
