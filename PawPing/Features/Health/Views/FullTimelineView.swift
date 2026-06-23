//
//  FullTimelineView.swift
//  PawPing
//

import SwiftUI

struct FullTimelineView: View {
    var events: [TimelineEvent]
    
    @State private var selectedMonth: String? = nil
    @State private var startDate: Date = Date().addingTimeInterval(-86400 * 30)
    @State private var endDate: Date = Date()
    @State private var useDateRange: Bool = false
    @State private var showFilterSheet: Bool = false
    
    var availableMonths: [String] {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        let months = events.map { formatter.string(from: $0.eventDate) }
        return Array(Set(months)).sorted { month1, month2 in
            guard let date1 = formatter.date(from: month1),
                  let date2 = formatter.date(from: month2) else { return false }
            return date1 > date2
        }
    }
    
    var filteredEvents: [TimelineEvent] {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        
        return events.filter { event in
            if let month = selectedMonth {
                let eventMonth = formatter.string(from: event.eventDate)
                if eventMonth != month { return false }
            }
            
            if useDateRange {
                let calendar = Calendar.current
                let eventDay = calendar.startOfDay(for: event.eventDate)
                let startDay = calendar.startOfDay(for: startDate)
                let endDay = calendar.startOfDay(for: endDate)
                if eventDay < startDay || eventDay > endDay { return false }
            }
            
            return true
        }
    }
    
    var isFilterActive: Bool {
        selectedMonth != nil || useDateRange
    }
    
    var body: some View {
        Group {
            if filteredEvents.isEmpty {
                VStack(spacing: 0) {
                    if isFilterActive {
                        HStack {
                            Image(systemName: "line.3.horizontal.decrease.circle.fill")
                                .foregroundStyle(Color.pawPrimary)
                            Text("Filters Active")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundStyle(.secondary)
                            
                            Spacer()
                            
                            Button {
                                selectedMonth = nil
                                useDateRange = false
                            } label: {
                                Text("Clear")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundStyle(Color.pawPrimary)
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 16)
                    }
                    
                    Spacer()
                    
                    VStack(spacing: 16) {
                        Image(systemName: "clock.arrow.circlepath")
                            .font(.system(size: 40))
                            .foregroundStyle(Color.homePurple)
                            .padding(18)
                            .background(Color.homePurple.opacity(0.1))
                            .clipShape(Circle())
                        
                        Text("No Health Events")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(Color.textPrimary)
                        
                        Text("Your pet's health journey will appear here.")
                            .font(.system(size: 15))
                            .foregroundStyle(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                    }
                    .padding(32)
                    .frame(maxWidth: .infinity)
                    .background(Color.cardIvory)
                    .clipShape(RoundedRectangle(cornerRadius: 32))
                    .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 4)
                    .padding(.horizontal, 24)
                    
                    Spacer()
                }
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        if isFilterActive {
                            HStack {
                                Image(systemName: "line.3.horizontal.decrease.circle.fill")
                                    .foregroundStyle(Color.pawPrimary)
                                Text("Filters Active")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.secondary)
                                
                                Spacer()
                                
                                Button {
                                    selectedMonth = nil
                                    useDateRange = false
                                } label: {
                                    Text("Clear")
                                        .font(.caption)
                                        .fontWeight(.bold)
                                        .foregroundStyle(Color.pawPrimary)
                                }
                            }
                            .padding(.horizontal)
                            .padding(.top, 8)
                        }
                        
                        VStack(spacing: 0) {
                            HealthTimelineView(events: filteredEvents, limit: nil)
                        }
                        .padding(16)
                        .background(Color.cardIvory)
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                        .shadow(color: Color.black.opacity(0.03), radius: 8, x: 0, y: 4)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                    }
                }
            }
        }
        .background(
            LinearGradient(colors: [.bgWarmTop, .bgWarmBottom], startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()
        )
        .navigationTitle("Full Timeline")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showFilterSheet = true
                } label: {
                    Image(systemName: isFilterActive ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle")
                }
            }
        }
        .sheet(isPresented: $showFilterSheet) {
            FilterTimelineSheet(
                availableMonths: availableMonths,
                selectedMonth: $selectedMonth,
                startDate: $startDate,
                endDate: $endDate,
                useDateRange: $useDateRange
            )
        }
    }
}

struct FilterTimelineSheet: View {
    @Environment(\.dismiss) var dismiss
    
    let availableMonths: [String]
    
    @Binding var selectedMonth: String?
    @Binding var startDate: Date
    @Binding var endDate: Date
    @Binding var useDateRange: Bool
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Filter by Month") {
                    Picker("Select Month", selection: Binding(
                        get: { selectedMonth ?? "All" },
                        set: { 
                            selectedMonth = $0 == "All" ? nil : $0
                            if $0 != "All" {
                                useDateRange = false
                            }
                        }
                    )) {
                        Text("All Months").tag("All")
                        ForEach(availableMonths, id: \.self) { month in
                            Text(month).tag(month)
                        }
                    }
                }
                
                Section {
                    Toggle("Filter by Date Range", isOn: $useDateRange)
                        .onChange(of: useDateRange) { _, newValue in
                            if newValue {
                                selectedMonth = nil
                            }
                        }
                    
                    if useDateRange {
                        DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                        DatePicker("End Date", selection: $endDate, in: startDate..., displayedComponents: .date)
                    }
                } header: {
                    Text("Filter by Date Range")
                }
                
                Section {
                    Button(role: .destructive) {
                        selectedMonth = nil
                        useDateRange = false
                        startDate = Date().addingTimeInterval(-86400 * 30)
                        endDate = Date()
                        dismiss()
                    } label: {
                        Text("Reset Filters")
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                }
            }
            .navigationTitle("Filter Events")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}
