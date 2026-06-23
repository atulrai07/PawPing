//
//  ActivityView.swift
//  PawPing
//
//  Created by Atul on 19/01/26.
//

import SwiftUI
import UIKit
import PhotosUI

struct ActivityView: View {
    @Environment(ActivityStore.self) var store
    @Environment(PetStore.self) var petStore
    @Environment(HealthStore.self) var healthStore
    @Environment(DietAssistantStore.self) var dietAssistantStore
    @Environment(MedicationStore.self) var medicationStore
    @Environment(AppState.self) var appState

    @State private var showWalkFlow = false
    @State private var countdownFinished = false
    @State private var showMealsLog = false
    @State private var showDistanceSummary = false
    @State private var showDietChat = false
    @State private var showEmergencyGuide = false
    @State private var showMemoriesGallery = false
    @State private var selectedDetailMemory: PetMemory? = nil
    
    @State private var showMealLogSheet = false
    @State private var selectedMealType: MealType = .breakfast

    var body: some View {
        NavigationStack {
            Group {
                if petStore.pets.isEmpty {
                    ContentUnavailableView(
                        "No Pets Added",
                        systemImage: "pawprint.fill",
                        description: Text("Add a pet from your Profile to start tracking activity.")
                    )
                    .navigationTitle("Home")
                } else {
                    VStack(spacing: 24) {
                        heroSection
                        mealsSection
                        emergencyActionSection
                        recentMemoriesSection
                        walkGraphsSection
                    }
                    .padding(.top, 16)
                    .padding(.bottom, 80)
                    .background(.clear)
                    .onAppear {
                        // Pre-warm the Lottie WKWebView so it's ready
                        // before the user taps "Let's Go"
                        LottiePreloader.shared.warmUp()
                    }
                    .customNavigationScroll(
                        title: "Home",
                        petStore: petStore,
                        refreshAction: {
                            await petStore.fetchPets()
                            if let activeId = petStore.activePetId {
                                store.switchPet(to: petStore.activePet)
                                await healthStore.fetchVaccines(for: activeId)
                                await medicationStore.fetchMedications(for: activeId)
                            }
                        },
                        backgroundColor: .clear
                    )
                    .navigationDestination(isPresented: $showMealsLog) {
                        MealLogView(store: store)
                    }
                    .navigationDestination(isPresented: $showDistanceSummary) {
                        DistanceSummaryView(store: store)
                    }
                    .navigationDestination(isPresented: $showEmergencyGuide) {
                        EmergencyGuideView()
                    }
                    .navigationDestination(isPresented: $showMemoriesGallery) {
                        MemoriesGalleryView()
                    }
                    .fullScreenCover(item: $selectedDetailMemory) { memory in
                        MemoryDetailView(memory: memory) {
                            store.deleteMemory(id: memory.id)
                            selectedDetailMemory = nil
                        }
                    }
                    .sheet(isPresented: $showMealLogSheet) {
                        MealLoggingSheet(store: store, mealType: selectedMealType, logDate: Date(), isReadOnly: false)
                            .presentationDetents([.height(570), .large])
                    }
                }
            }
        }
        .fullScreenCover(isPresented: $showWalkFlow) {
            WalkFlowContainer(
                store: store,
                startWithTracking: countdownFinished,
                onDismiss: {
                    showWalkFlow = false
                }
            )
        }
    }

    // MARK: - Hero Section (Today's Walk)
    private var heroSection: some View {
        ZStack {
            Image("card_bg")
                .resizable()
                .scaledToFill()
                .frame(height: 200) // Increased height for breathing room
                .clipShape(RoundedRectangle(cornerRadius: 24))
            
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 14) { // Increased spacing
                    HStack(spacing: 8) {
                        Text("Today's Walk")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.textSecondary)
                    }
                    
                    HStack(alignment: .lastTextBaseline, spacing: 4) {
                        Text("\(store.liveWalkedMinutes)")
                            .font(.system(size: 38, weight: .bold)) // Slightly larger
                            .foregroundColor(.homePurple)
                        
                        Text("/\(store.walkActivity.goalMinutes) min")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.textSecondary)
                    }
                    
                    // Progress Bar
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(Color.homePurple.opacity(0.2))
                                .frame(height: 8) // Slightly thicker
                            
                            let rawProgress = CGFloat(store.liveWalkedMinutes) / CGFloat(max(store.walkActivity.goalMinutes, 1))
                            let progress = min(max(rawProgress, 0.0), 1.0)
                            Capsule()
                                .fill(Color.homePurple)
                                .frame(width: geo.size.width * progress, height: 8)
                        }
                    }
                    .frame(height: 8)
                    .padding(.bottom, 6)
                    
                    Button {
                        if store.isWalking {
                            countdownFinished = true
                        } else {
                            countdownFinished = false
                        }
                        showWalkFlow = true
                    } label: {
                        HStack {
                            Text(store.isWalking ? "Resume" : "Let's go!")
                            Image(systemName: "arrow.right")
                        }
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(Color.homePurple)
                        .clipShape(Capsule())
                        .shadow(color: Color.homePurple.opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                }
                .padding(.leading, 24)
                .padding(.vertical, 24) // Added vertical padding
                
                Spacer(minLength: 170)
            }
        }
        .padding(.horizontal)
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
    }

    // MARK: - Meals Section
    private var mealsSection: some View {
        let todayMeals = store.getMeals(for: Date())
        let b = todayMeals.first(where: { $0.mealType == .breakfast })
        let l = todayMeals.first(where: { $0.mealType == .lunch })
        let d = todayMeals.first(where: { $0.mealType == .dinner })
        
        return VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Meals")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.textPrimary)
                
                Spacer()
                
                Button {
                    showMealsLog = true
                } label: {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.textSecondary)
                }
            }
            .padding(.horizontal)
            
            HStack(spacing: 12) {
                MealCardView(
                    title: "Breakfast", 
                    time: b?.isTaken == true ? "\(b!.time) \(b!.meridian)" : "8:00 AM", 
                    iconName: "sun.max.fill", 
                    iconColor: .homeYellow, 
                    imageName: "bowl_pink", 
                    isCompleted: b?.isTaken ?? false
                ) {
                    selectedMealType = .breakfast
                    showMealLogSheet = true
                }
                MealCardView(
                    title: "Lunch", 
                    time: l?.isTaken == true ? "\(l!.time) \(l!.meridian)" : "12:30 PM", 
                    iconName: "sun.min.fill", 
                    iconColor: .orange, 
                    imageName: "bowl_yellow", 
                    isCompleted: l?.isTaken ?? false
                ) {
                    selectedMealType = .lunch
                    showMealLogSheet = true
                }
                MealCardView(
                    title: "Dinner", 
                    time: d?.isTaken == true ? "\(d!.time) \(d!.meridian)" : "8:30 PM", 
                    iconName: "moon.fill", 
                    iconColor: .homePurple, 
                    imageName: "bowl_blue", 
                    isCompleted: d?.isTaken ?? false
                ) {
                    selectedMealType = .dinner
                    showMealLogSheet = true
                }
            }
            .padding(.horizontal)
        }
    }

    // MARK: - Emergency Action Plan Section
    private var emergencyActionSection: some View {
        Button {
            showEmergencyGuide = true
        } label: {
            HStack(spacing: 16) {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.orange.opacity(0.15))
                    .frame(width: 54, height: 54)
                    .overlay(
                        Image(systemName: "cross.case.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.orange)
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Emergency Guide")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.textPrimary)
                    Text("Tap for immediate medical guidance")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.textSecondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.textSecondary)
            }
            .padding(16)
            .background(Color.cardIvory)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
            .padding(.horizontal)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Recent Memories Helpers & Section
    
    enum HomeMemoryDisplayType {
        case collage
        case cards
    }

    private var recentMemoriesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Recent Memories")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.textPrimary)
                
                Spacer()
                
                Button {
                    showMemoriesGallery = true
                } label: {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(Color(hex: "6E54D7") ?? .orange)
                }
            }
            .padding(.horizontal)
            
            GeometryReader { outerGeo in
                ScrollView(.horizontal, showsIndicators: false) {
                    let items = store.memories
                    if items.isEmpty {
                        VStack(spacing: 8) {
                            Image(systemName: "photo.on.rectangle.angled")
                                .font(.system(size: 32))
                                .foregroundColor(.gray.opacity(0.5))
                            Text("No memories yet. Tap the arrow to add photos!")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 32)
                        }
                        .frame(width: max(outerGeo.size.width - 32, 0))
                        .frame(height: 140)
                    } else {
                        HStack(spacing: 16) {
                            ForEach(Array(items.enumerated()), id: \.element.id) { index, memory in
                                Button {
                                    selectedDetailMemory = memory
                                } label: {
                                    let displayType: HomeMemoryDisplayType = (index % 2 == 0) ? .collage : .cards
                                    HomeMemoryCard(memory: memory, displayType: displayType)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .frame(height: 140)
        }
    }
}

// MARK: - Redesigned Memory Card View
struct HomeMemoryCard: View {
    let memory: PetMemory
    let displayType: ActivityView.HomeMemoryDisplayType
    @Environment(\.colorScheme) private var colorScheme
    
    var dateString: String {
        let calendar = Calendar.current
        if calendar.isDateInToday(memory.createdAt) {
            return "Today"
        } else if calendar.isDateInYesterday(memory.createdAt) {
            return "Yesterday"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d, yyyy"
            return formatter.string(from: memory.createdAt)
        }
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Left Side: Image/Collage/Card Stack area
            imageLayout(urls: memory.allImageUrls)
                .frame(width: 140, height: 140)
                .clipShape(RoundedRectangle(cornerRadius: 24))
            
            // Right Side: Info Details
            VStack(alignment: .leading, spacing: 6) {
                Text(dateString)
                    .font(.system(size: 13))
                    .foregroundColor(.textSecondary)
                
                Text(memory.displayName)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.textPrimary)
                    .lineLimit(1)
                
                Text(memory.displayLocation)
                    .font(.system(size: 13))
                    .foregroundColor(.textSecondary)
                    .lineLimit(1)
                
                Spacer(minLength: 0)
                
                HStack(spacing: 4) {
                    Image(systemName: "photo.stack")
                        .font(.system(size: 14))
                    Text("\(memory.allImageUrls.count) photos")
                        .font(.system(size: 13, weight: .medium))
                    Image(systemName: "chevron.right")
                        .font(.system(size: 11, weight: .bold))
                }
                .foregroundColor(.textPrimary.opacity(0.8))
                .padding(.top, 4)
            }
            .frame(width: 130, alignment: .leading)
            .padding(.vertical, 14)
            .padding(.trailing, 14)
        }
        .frame(width: 296, height: 140)
        .background(colorScheme == .dark ? Color(white: 0.12) : (Color(hex: "F8F9FB") ?? Color(.systemGray6)))
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }
    
    @ViewBuilder
    private func imageLayout(urls: [String]) -> some View {
        if urls.isEmpty {
            noPicView
        } else if displayType == .collage && urls.count >= 3 {
            collageLayout(urls: urls)
        } else if displayType == .cards && urls.count >= 2 {
            cardsLayout(urls: urls)
        } else {
            fallbackLayout(urls: urls)
        }
    }
    
    private var noPicView: some View {
        VStack(spacing: 6) {
            Image(systemName: "photo.on.rectangle.angled")
                .font(.system(size: 24))
                .foregroundColor(.gray.opacity(0.8))
            Text("No pic")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.gray.opacity(0.8))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .background(colorScheme == .dark ? Color(white: 0.15) : (Color(hex: "F2F2F7") ?? Color(.systemGray6)))
    }
    
    private func collageLayout(urls: [String]) -> some View {
        HStack(spacing: 2) {
            AsyncImage(url: URL(string: urls[0])) { image in
                image.resizable().scaledToFill()
            } placeholder: {
                Color.gray.opacity(0.1)
            }
            .frame(width: 80, height: 140)
            .clipped()
            
            VStack(spacing: 2) {
                AsyncImage(url: URL(string: urls[1])) { image in
                    image.resizable().scaledToFill()
                } placeholder: {
                    Color.gray.opacity(0.1)
                }
                .frame(width: 58, height: 69)
                .clipped()
                
                AsyncImage(url: URL(string: urls[2])) { image in
                    image.resizable().scaledToFill()
                } placeholder: {
                    Color.gray.opacity(0.1)
                }
                .frame(width: 58, height: 69)
                .clipped()
            }
        }
    }
    
    private func cardsLayout(urls: [String]) -> some View {
        ZStack {
            Color.clear // Container boundaries
            
            ForEach(0..<min(urls.count, 3), id: \.self) { idx in
                AsyncImage(url: URL(string: urls[idx])) { image in
                    image.resizable().scaledToFill()
                } placeholder: {
                    Color.gray.opacity(0.1)
                }
                .frame(width: 105, height: 105)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: .black.opacity(0.12), radius: 4, x: 0, y: 2)
                .rotationEffect(.degrees(Double(idx - 1) * 8.0))
                .offset(x: CGFloat(idx - 1) * 8, y: CGFloat(idx - 1) * 2)
            }
        }
    }
    
    private func fallbackLayout(urls: [String]) -> some View {
        AsyncImage(url: URL(string: urls[0])) { image in
            image.resizable().scaledToFill()
        } placeholder: {
            Color.gray.opacity(0.1)
        }
        .frame(width: 140, height: 140)
        .clipped()
    }
}

extension ActivityView {

    // MARK: - Walk Summary Card
    private var walkGraphsSection: some View {
        NavigationLink(destination: DistanceSummaryView(store: store)) {
            WalkSummaryCard(store: store)
                .padding(.top, 8)
                .padding(.horizontal)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Walk Summary Card View
struct WalkSummaryCard: View {
    var store: ActivityStore
    @Environment(\.colorScheme) private var colorScheme

    // Total distance this week
    private var weeklyDistanceKm: Double {
        store.distanceSummary.totalWeekDistance
    }

    // Number of walks this week (activities with distance > 0)
    private var weeklyWalksCount: Int {
        let calendar = Calendar.current
        var comps = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date())
        comps.weekday = 2
        guard let monday = calendar.date(from: comps) else { return 0 }
        let sunday = calendar.date(byAdding: .day, value: 6, to: monday) ?? Date()
        return store.activities.filter { $0.date >= monday && $0.date <= sunday }.count
    }

    // Last week's total distance for % comparison
    private var lastWeekDistanceKm: Double {
        let calendar = Calendar.current
        var comps = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date())
        comps.weekday = 2
        guard let thisMonday = calendar.date(from: comps),
              let lastMonday = calendar.date(byAdding: .weekOfYear, value: -1, to: thisMonday),
              let lastSunday = calendar.date(byAdding: .day, value: 6, to: lastMonday)
        else { return 0 }
        return store.activities
            .filter { $0.date >= lastMonday && $0.date <= lastSunday }
            .reduce(0) { $0 + $1.distanceInKm }
    }

    private var vsLastWeekPercent: Int {
        guard lastWeekDistanceKm > 0 else { return 0 }
        return Int(((weeklyDistanceKm - lastWeekDistanceKm) / lastWeekDistanceKm) * 100)
    }

    var body: some View {
        let isDark = colorScheme == .dark
        ZStack(alignment: .trailing) {
            // Card background — same style as Emergency Guide & home cards
            RoundedRectangle(cornerRadius: 24)
                .fill(isDark ? Color(white: 0.13) : Color.cardIvory)
                .shadow(color: .black.opacity(isDark ? 0.18 : 0.05), radius: 10, x: 0, y: 4)

            // Dog illustration — right side, clipped by card
            Image("walk_dog_illustration")
                .resizable()
                .scaledToFit()
                .frame(width: 145, height: 145)
                .offset(x: 8, y: 10)
                .clipped()

            // Content
            VStack(alignment: .leading, spacing: 14) {
                // Header
                HStack(spacing: 10) {
                    ZStack {
                        Circle()
                            .fill(Color.homePurple.opacity(isDark ? 0.25 : 0.12))
                            .frame(width: 40, height: 40)
                        Image(systemName: "figure.walk")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.homePurple)
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Walk Summary")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.textPrimary)
                        Text("This Week")
                            .font(.system(size: 12))
                            .foregroundColor(.textSecondary)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.textSecondary)
                }

                // Stats
                HStack(alignment: .bottom, spacing: 0) {
                    VStack(alignment: .leading, spacing: 2) {
                        HStack(alignment: .lastTextBaseline, spacing: 4) {
                            Text(String(format: "%.1f", weeklyDistanceKm))
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(.homePurple)
                            Text("km")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.homePurple)
                                .padding(.bottom, 3)
                        }
                        Text("Total Distance")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.textSecondary)
                    }

                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 1.5, height: 38)
                        .padding(.horizontal, 16)
                        .padding(.bottom, 6)

                    VStack(alignment: .leading, spacing: 2) {
                        HStack(alignment: .lastTextBaseline, spacing: 4) {
                            Text("\(weeklyWalksCount)")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(.homePurple)
                            Text("walks")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.homePurple)
                                .padding(.bottom, 3)
                        }
                        Text("Completed")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.textSecondary)
                    }

                    Spacer(minLength: 120) // reserve space for dog
                }

                // vs last week badge
                let pct = vsLastWeekPercent
                HStack(spacing: 5) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 10))
                        .foregroundColor(.white)
                        .frame(width: 22, height: 22)
                        .background(Color.homePurple)
                        .clipShape(Circle())
                    Text(pct >= 0 ? "+\(pct)%" : "\(pct)%")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(pct >= 0 ? .homePurple : .red)
                    Text("vs last week")
                        .font(.system(size: 12))
                        .foregroundColor(.textSecondary)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(isDark ? Color(white: 0.2) : Color.white.opacity(0.8))
                .clipShape(Capsule())
            }
            .padding(18)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 190)
    }
}

// MARK: - Helper Views

struct MealCardView: View {
    let title: String
    let time: String
    let iconName: String
    let iconColor: Color
    let imageName: String
    let isCompleted: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .center, spacing: 8) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(title)
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.textPrimary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                        Text(time)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.textSecondary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                    }
                    
                    Spacer(minLength: 4)
                    
                    Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(isCompleted ? .homePurple : .textSecondary.opacity(0.3))
                        .font(.system(size: 18))
                }
                
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 70)
            }
            .padding(12)
            .frame(maxWidth: .infinity)
            .background(Color.cardIvory)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 3)
        }
        .buttonStyle(.plain)
    }
}

struct QuickActionView: View {
    let title: String
    let subtitle: String
    let iconName: String
    let iconColor: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                RoundedRectangle(cornerRadius: 12)
                    .fill(iconColor.opacity(0.1))
                    .frame(width: 44, height: 44)
                    .overlay(
                        Image(systemName: iconName)
                            .foregroundColor(iconColor)
                            .font(.system(size: 18))
                    )
                
                VStack(spacing: 2) {
                    Text(title)
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.textPrimary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                    Text(subtitle)
                        .font(.system(size: 9, weight: .medium))
                        .foregroundColor(.textSecondary)
                        .multilineTextAlignment(.center)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 4)
            .frame(maxWidth: .infinity)
            .background(Color.cardIvory)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 2)
        }
        .buttonStyle(.plain)
    }
}

enum StatGraphType {
    case line(Color)
    case bar(Color)
}

struct StatCardView: View {
    let title: String
    let value: String
    let unit: String
    let subtitle: String
    let iconName: String
    let iconColor: Color
    let graphType: StatGraphType
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 4) {
                Image(systemName: iconName)
                    .foregroundColor(iconColor)
                    .font(.system(size: 10))
                Text(title)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            
            HStack(alignment: .lastTextBaseline, spacing: 2) {
                Text(value)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                if !unit.isEmpty {
                    Text(unit)
                        .font(.system(size: 9, weight: .medium))
                        .foregroundColor(.textSecondary)
                        .lineLimit(1)
                }
            }
            
            if !subtitle.isEmpty {
                Text(subtitle)
                    .font(.system(size: 9, weight: .medium))
                    .foregroundColor(.textSecondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            
            Spacer(minLength: 4)
            
            // Mock Graph
            GeometryReader { geo in
                switch graphType {
                case .line(let color):
                    Path { path in
                        path.move(to: CGPoint(x: 0, y: geo.size.height))
                        path.addLine(to: CGPoint(x: geo.size.width * 0.25, y: geo.size.height * 0.6))
                        path.addLine(to: CGPoint(x: geo.size.width * 0.5, y: geo.size.height * 0.8))
                        path.addLine(to: CGPoint(x: geo.size.width * 0.75, y: geo.size.height * 0.4))
                        path.addLine(to: CGPoint(x: geo.size.width, y: geo.size.height * 0.2))
                    }
                    .stroke(color, lineWidth: 2)
                    
                    // Dots
                    ForEach(0..<5, id: \.self) { i in
                        Circle()
                            .fill(color)
                            .frame(width: 4, height: 4)
                            .position(x: geo.size.width * CGFloat(i) * 0.25, y: i == 0 ? geo.size.height : (i == 1 ? geo.size.height * 0.6 : (i == 2 ? geo.size.height * 0.8 : (i == 3 ? geo.size.height * 0.4 : geo.size.height * 0.2))))
                    }
                case .bar(let color):
                    HStack(alignment: .bottom, spacing: 4) {
                        ForEach(0..<7, id: \.self) { i in
                            Capsule()
                                .fill(i == 6 ? color : color.opacity(0.3))
                                .frame(width: 4, height: CGFloat.random(in: geo.size.height * 0.4...geo.size.height))
                        }
                    }
                }
            }
            .frame(height: 20)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.cardIvory)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 2)
    }
}


// MARK: - Memories Gallery View
struct MemoriesGalleryView: View {
    @Environment(ActivityStore.self) var store
    @Environment(PetStore.self) var petStore
    
    @State private var showCreateAlbum = false
    @State private var selectedMemory: PetMemory? = nil
    
    let columns = [GridItem(.flexible(), spacing: 16), GridItem(.flexible(), spacing: 16)]
    
    var body: some View {
        ScrollView {
            if store.memories.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "photo.on.rectangle.angled")
                        .font(.system(size: 40))
                        .foregroundColor(.gray.opacity(0.5))
                    Text("No albums yet.\nTap + to create one!")
                        .multilineTextAlignment(.center)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(.gray)
                }
                .padding(.top, 80)
            } else {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(store.memories) { memory in
                        Button {
                            selectedMemory = memory
                        } label: {
                            VStack(alignment: .leading, spacing: 8) {
                                ZStack(alignment: .bottomTrailing) {
                                    AsyncImage(url: URL(string: memory.imageUrl)) { image in
                                        image.resizable().scaledToFill()
                                    } placeholder: {
                                        Color.gray.opacity(0.2)
                                    }
                                    .frame(height: 150)
                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                                    .clipped()
                                    
                                    // Photos Count Badge
                                    Text("\(memory.allImageUrls.count) \(memory.allImageUrls.count == 1 ? "photo" : "photos")")
                                        .font(.system(size: 11, weight: .bold))
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Color.black.opacity(0.6))
                                        .clipShape(Capsule())
                                        .padding(8)
                                }
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(memory.displayName)
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(.textPrimary)
                                        .lineLimit(1)
                                    
                                    HStack(spacing: 2) {
                                        Image(systemName: "mappin.and.ellipse")
                                            .font(.system(size: 10))
                                            .foregroundColor(.textSecondary)
                                        Text(memory.displayLocation)
                                            .font(.system(size: 11))
                                            .foregroundColor(.textSecondary)
                                            .lineLimit(1)
                                    }
                                }
                                .padding(.horizontal, 4)
                            }
                        }
                        .buttonStyle(.plain)
                        .contextMenu {
                            Button(role: .destructive) {
                                withAnimation {
                                    store.deleteMemory(id: memory.id)
                                }
                            } label: {
                                Label("Delete Album", systemImage: "trash")
                            }
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.top, 24)
                .padding(.bottom, 24)
            }
        }
        .navigationTitle("Photo Albums")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showCreateAlbum = true
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color(hex: "6E54D7") ?? .purple)
                }
            }
        }
        .sheet(isPresented: $showCreateAlbum) {
            CreateAlbumSheet()
        }
        .fullScreenCover(item: $selectedMemory) { memory in
            MemoryDetailView(memory: memory) {
                store.deleteMemory(id: memory.id)
                selectedMemory = nil
            }
        }
    }
}

// MARK: - Create Album Sheet
struct CreateAlbumSheet: View {
    @Environment(\.dismiss) var dismiss
    @Environment(ActivityStore.self) var store
    @Environment(PetStore.self) var petStore
    
    @State private var name = ""
    @State private var location = ""
    @State private var date = Date()
    
    // Picked photos
    @State private var selectedImages: [UIImage] = []
    
    // Modals
    @State private var showLibraryPicker = false
    @State private var showCameraPicker = false
    @State private var cameraImage: UIImage? = nil
    
    @State private var isSaving = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Album Info")) {
                    TextField("Album Name (e.g. Beach Fun)", text: $name)
                    TextField("Location (e.g. Malibu Beach)", text: $location)
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                }
                
                Section(header: Text("Photos (\(selectedImages.count))")) {
                    if selectedImages.isEmpty {
                        Text("No photos selected yet.")
                            .foregroundColor(.gray)
                            .font(.system(size: 14))
                            .padding(.vertical, 8)
                    } else {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(Array(selectedImages.enumerated()), id: \.offset) { idx, img in
                                    ZStack(alignment: .topTrailing) {
                                        Image(uiImage: img)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 80, height: 80)
                                            .clipShape(RoundedRectangle(cornerRadius: 12))
                                            .clipped()
                                        
                                        Button {
                                            selectedImages.remove(at: idx)
                                        } label: {
                                            Image(systemName: "xmark.circle.fill")
                                                .foregroundColor(.red)
                                                .background(Color.white.clipShape(Circle()))
                                        }
                                        .offset(x: 4, y: -4)
                                    }
                                }
                            }
                            .padding(.vertical, 8)
                        }
                    }
                    
                    HStack {
                        Button {
                            showCameraPicker = true
                        } label: {
                            Label("Camera", systemImage: "camera")
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)
                        }
                        .frame(maxWidth: .infinity)
                        .buttonStyle(.bordered)
                        
                        Button {
                            showLibraryPicker = true
                        } label: {
                            Label("Gallery", systemImage: "photo.on.rectangle")
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)
                        }
                        .frame(maxWidth: .infinity)
                        .buttonStyle(.bordered)
                    }
                }
            }
            .navigationTitle("Create Album")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .disabled(isSaving)
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    if isSaving {
                        ProgressView()
                    } else {
                        Button("Create") {
                            saveAlbum()
                        }
                        .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || selectedImages.isEmpty)
                    }
                }
            }
            .sheet(isPresented: $showLibraryPicker) {
                MultiImagePicker(selectedImages: $selectedImages)
            }
            .fullScreenCover(isPresented: $showCameraPicker) {
                ImagePicker(selectedImage: $cameraImage, sourceType: .camera)
                    .ignoresSafeArea()
            }
            .onChange(of: cameraImage) { _, newImg in
                if let newImg {
                    selectedImages.append(newImg)
                    cameraImage = nil
                }
            }
        }
    }
    
    private func saveAlbum() {
        isSaving = true
        Task {
            await store.addMemoryAlbum(
                name: name,
                location: location.isEmpty ? "Somewhere Fun" : location,
                date: date,
                images: selectedImages,
                petStore: petStore
            )
            isSaving = false
            dismiss()
        }
    }
}

// MARK: - Memory Detail View
struct MemoryDetailView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(ActivityStore.self) var store
    @Environment(PetStore.self) var petStore
    
    let memory: PetMemory
    let onDelete: () -> Void
    
    @State private var currentImageIndex = 0
    @State private var showLibraryPicker = false
    @State private var showCameraPicker = false
    @State private var showEditSheet = false
    @State private var pickedImages: [UIImage] = []
    @State private var pickedCameraImage: UIImage? = nil
    @State private var isAddingImages = false
    
    private var currentMemory: PetMemory {
        store.memories.first { $0.id == memory.id } ?? memory
    }
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            let urls = currentMemory.allImageUrls
            
            VStack {
                // Top Navbar
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                            .padding(12)
                            .background(Color.black.opacity(0.5))
                            .clipShape(Circle())
                    }
                    
                    Spacer()
                    
                    Text("\(min(currentImageIndex + 1, urls.count)) of \(urls.count)")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    HStack(spacing: 12) {
                        Button {
                            showEditSheet = true
                        } label: {
                            Image(systemName: "pencil")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.white)
                                .padding(12)
                                .background(Color.black.opacity(0.5))
                                .clipShape(Circle())
                        }
                        
                        Menu {
                            Button {
                                showCameraPicker = true
                            } label: {
                                Label("Camera Photo", systemImage: "camera")
                            }
                            
                            Button {
                                showLibraryPicker = true
                            } label: {
                                Label("Select Gallery Photos", systemImage: "photo")
                            }
                        } label: {
                            Image(systemName: "plus")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.white)
                                .padding(12)
                                .background(Color.black.opacity(0.5))
                                .clipShape(Circle())
                        }
                        .disabled(isAddingImages)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 16)
                
                // Photo Viewer
                if isAddingImages {
                    Spacer()
                    VStack(spacing: 12) {
                        ProgressView()
                            .tint(.white)
                        Text("Adding photos to album...")
                            .foregroundColor(.white.opacity(0.8))
                            .font(.caption)
                    }
                    Spacer()
                } else if !urls.isEmpty {
                    TabView(selection: $currentImageIndex) {
                        ForEach(Array(urls.enumerated()), id: \.element) { idx, urlStr in
                            AsyncImage(url: URL(string: urlStr)) { image in
                                image
                                    .resizable()
                                    .scaledToFit()
                            } placeholder: {
                                ProgressView()
                                    .tint(.white)
                            }
                            .tag(idx)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                } else {
                    Spacer()
                    Text("No photos in this album.")
                        .foregroundColor(.gray)
                    Spacer()
                }
                
                // Info Section
                VStack(alignment: .leading, spacing: 8) {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(currentMemory.displayName)
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)
                            
                            HStack(spacing: 4) {
                                Image(systemName: "mappin.and.ellipse")
                                    .font(.system(size: 12))
                                    .foregroundColor(.white.opacity(0.7))
                                Text(currentMemory.displayLocation)
                                    .font(.system(size: 14))
                                    .foregroundColor(.white.opacity(0.7))
                            }
                        }
                        
                        Spacer()
                        
                        Text(currentMemory.createdAt, style: .date)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                    }
                    
                    HStack {
                        // Delete individual photo
                        if !urls.isEmpty {
                            Button {
                                deletePhoto(urls[min(currentImageIndex, urls.count - 1)])
                            } label: {
                                Label("Delete Photo", systemImage: "photo.badge.trash")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.red)
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 14)
                                    .background(Color.white.opacity(0.1))
                                    .clipShape(Capsule())
                            }
                        }
                        
                        Spacer()
                        
                        // Delete Album
                        Button(role: .destructive) {
                            onDelete()
                        } label: {
                            Label("Delete Album", systemImage: "trash")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.red)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 14)
                                .background(Color.red.opacity(0.15))
                                .clipShape(Capsule())
                        }
                    }
                    .padding(.top, 8)
                }
                .padding()
                .background(
                    LinearGradient(colors: [.black.opacity(0.9), .black.opacity(0.4), .clear], startPoint: .bottom, endPoint: .top)
                )
            }
        }
        .sheet(isPresented: $showLibraryPicker) {
            MultiImagePicker(selectedImages: $pickedImages)
        }
        .sheet(isPresented: $showEditSheet) {
            EditAlbumSheet(album: currentMemory)
        }
        .fullScreenCover(isPresented: $showCameraPicker) {
            ImagePicker(selectedImage: $pickedCameraImage, sourceType: .camera)
                .ignoresSafeArea()
        }
        .onChange(of: pickedCameraImage) { _, newImg in
            if let newImg {
                pickedImages.append(newImg)
                pickedCameraImage = nil
            }
        }
        .onChange(of: pickedImages) { _, images in
            if !images.isEmpty {
                isAddingImages = true
                Task {
                    await store.addImagesToAlbum(albumId: currentMemory.id, images: images, petStore: petStore)
                    pickedImages = []
                    isAddingImages = false
                }
            }
        }
    }
    
    private func deletePhoto(_ photoUrl: String) {
        let urls = currentMemory.allImageUrls
        store.deletePhotoFromAlbum(albumId: currentMemory.id, photoUrl: photoUrl)
        if urls.count <= 1 {
            // Album deleted because last photo was removed
            dismiss()
        } else {
            // Adjust page index if deleted last page
            if currentImageIndex >= urls.count - 1 {
                currentImageIndex = max(0, urls.count - 2)
            }
        }
    }
}

// MARK: - Edit Album Sheet View
struct EditAlbumSheet: View {
    @Environment(\.dismiss) var dismiss
    @Environment(ActivityStore.self) var store
    let albumId: UUID
    
    @State private var name: String
    @State private var location: String
    @State private var date: Date
    
    init(album: PetMemory) {
        self.albumId = album.id
        _name = State(initialValue: album.displayName)
        _location = State(initialValue: album.displayLocation)
        _date = State(initialValue: album.createdAt)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Album Info")) {
                    TextField("Album Name", text: $name)
                    TextField("Location", text: $location)
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                }
            }
            .navigationTitle("Edit Album")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        store.updateMemoryAlbumInfo(
                            albumId: albumId,
                            name: name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Paw Adventure" : name,
                            location: location.isEmpty ? "Somewhere Fun" : location,
                            date: date
                        )
                        dismiss()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}

// MARK: - Walk Flow Container (Countdown → Tracking)

private struct WalkFlowContainer: View {
    var store: ActivityStore
    var startWithTracking: Bool
    var onDismiss: () -> Void

    @State private var showTracking: Bool

    init(store: ActivityStore, startWithTracking: Bool, onDismiss: @escaping () -> Void) {
        self.store = store
        self.startWithTracking = startWithTracking
        self.onDismiss = onDismiss
        _showTracking = State(initialValue: startWithTracking)
    }

    var body: some View {
        if showTracking {
            WalkTrackingView(store: store, onDismiss: onDismiss)
                .transition(.opacity)
        } else {
            CountdownView(
                onComplete: {
                    store.startWalk()
                    withAnimation {
                        showTracking = true
                    }
                },
                onCancel: {
                    store.isWalking = false
                    onDismiss()
                }
            )
            .transition(.opacity)
        }
    }
}

struct ActivityViewPreviewWrapper: View {
    @State private var store = ActivityStore()
    @State private var petStore = PetStore()
    @State private var healthStore = HealthStore()
    @State private var authStore = AuthStore()
    @State private var appState = AppState()
    @State private var dietAssistantStore = DietAssistantStore()
    
    var body: some View {
        ActivityView()
            .environment(store)
            .environment(petStore)
            .environment(healthStore)
            .environment(authStore)
            .environment(appState)
            .environment(dietAssistantStore)
    }
}

#Preview {
    ActivityViewPreviewWrapper()
}
