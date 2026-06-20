//
//  ActivityView.swift
//  PawPing
//
//  Created by Atul on 19/01/26.
//

import SwiftUI
import UIKit

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
                    .sheet(isPresented: $showMealLogSheet) {
                        MealLoggingSheet(store: store, mealType: selectedMealType, logDate: Date(), isReadOnly: false)
                            .presentationDetents([.large])
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
    
    fileprivate enum HomeMemoryDisplayType {
        case collage
        case cards
    }

    fileprivate struct HomeGroupedMemory: Identifiable {
        let id: String
        let title: String
        let description: String
        let dateString: String
        let imageURLs: [String]
        let displayType: HomeMemoryDisplayType
    }

    private var groupedMemories: [HomeGroupedMemory] {
        let calendar = Calendar.current
        let now = Date()
        
        let grouped = Dictionary(grouping: store.memories) { memory -> Date in
            calendar.startOfDay(for: memory.createdAt)
        }
        
        let sortedDates = grouped.keys.sorted(by: >)
        var result: [HomeGroupedMemory] = []
        
        for (index, date) in sortedDates.enumerated() {
            let memoriesForDate = grouped[date] ?? []
            let urls = memoriesForDate.map { $0.imageUrl }
            
            let dateString: String
            if calendar.isDateInToday(date) {
                dateString = "Today"
            } else if calendar.isDateInYesterday(date) {
                dateString = "Yesterday"
            } else {
                let formatter = DateFormatter()
                formatter.dateFormat = "MMM d, yyyy"
                dateString = formatter.string(from: date)
            }
            
            let displayType: HomeMemoryDisplayType = (index % 2 == 0) ? .collage : .cards
            let petName = petStore.activePet?.name ?? "Pet"
            let title = index == 0 ? "Central Park" : "\(petName)'s Adventure"
            let description = index == 0 ? "Morning walk" : "Fun outdoor play"
            
            result.append(HomeGroupedMemory(
                id: dateString,
                title: title,
                description: description,
                dateString: dateString,
                imageURLs: urls,
                displayType: displayType
            ))
        }
        
        return result
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
            
            ScrollView(.horizontal, showsIndicators: false) {
                let items = groupedMemories
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
                    .frame(width: UIScreen.main.bounds.width - 32)
                    .frame(height: 140)
                } else {
                    HStack(spacing: 16) {
                        ForEach(items) { memory in
                            HomeMemoryCard(memory: memory)
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
    }
}

// MARK: - Redesigned Memory Card View
struct HomeMemoryCard: View {
    fileprivate let memory: ActivityView.HomeGroupedMemory
    
    var body: some View {
        HStack(spacing: 12) {
            // Left Side: Image/Collage/Card Stack area
            Group {
                if memory.imageURLs.isEmpty {
                    VStack(spacing: 6) {
                        Image(systemName: "photo.on.rectangle.angled")
                            .font(.system(size: 24))
                            .foregroundColor(.gray.opacity(0.8))
                        Text("No pic")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.gray.opacity(0.8))
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    .background(Color(hex: "F2F2F7") ?? Color(.systemGray6))
                } else if memory.displayType == .collage && memory.imageURLs.count >= 3 {
                    // Collage Layout
                    HStack(spacing: 2) {
                        AsyncImage(url: URL(string: memory.imageURLs[0])) { image in
                            image.resizable().scaledToFill()
                        } placeholder: {
                            Color.gray.opacity(0.1)
                        }
                        .frame(width: 80, height: 140)
                        .clipped()
                        
                        VStack(spacing: 2) {
                            AsyncImage(url: URL(string: memory.imageURLs[1])) { image in
                                image.resizable().scaledToFill()
                            } placeholder: {
                                Color.gray.opacity(0.1)
                            }
                            .frame(width: 58, height: 69)
                            .clipped()
                            
                            AsyncImage(url: URL(string: memory.imageURLs[2])) { image in
                                image.resizable().scaledToFill()
                            } placeholder: {
                                Color.gray.opacity(0.1)
                            }
                            .frame(width: 58, height: 69)
                            .clipped()
                        }
                    }
                } else if memory.displayType == .cards && memory.imageURLs.count >= 2 {
                    // Cards Stack Layout
                    ZStack {
                        Color.clear // Container boundaries
                        
                        ForEach(0..<min(memory.imageURLs.count, 3), id: \.self) { idx in
                            AsyncImage(url: URL(string: memory.imageURLs[idx])) { image in
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
                } else {
                    // Fallback Single Image Layout
                    AsyncImage(url: URL(string: memory.imageURLs[0])) { image in
                        image.resizable().scaledToFill()
                    } placeholder: {
                        Color.gray.opacity(0.1)
                    }
                    .frame(width: 140, height: 140)
                    .clipped()
                }
            }
            .frame(width: 140, height: 140)
            .clipShape(RoundedRectangle(cornerRadius: 24))
            
            // Right Side: Info Details
            VStack(alignment: .leading, spacing: 6) {
                Text(memory.dateString)
                    .font(.system(size: 13))
                    .foregroundColor(.textSecondary)
                
                Text(memory.title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.textPrimary)
                    .lineLimit(1)
                
                Text(memory.description)
                    .font(.system(size: 13))
                    .foregroundColor(.textSecondary)
                    .lineLimit(1)
                
                Spacer(minLength: 0)
                
                HStack(spacing: 4) {
                    Image(systemName: "photo.stack")
                        .font(.system(size: 14))
                    Text(memory.imageURLs.count > 0 ? "\(memory.imageURLs.count) photos" : "0 photos")
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
        .background(Color(hex: "F8F9FB") ?? Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }
}

extension ActivityView {

    // MARK: - Walk Graphs Section
    private var walkGraphsSection: some View {
        NavigationLink(destination: DistanceSummaryView(store: store)) {
            WalkTimeGraphView(model: store.timeWalkedGraph)
                .padding(.top, 8)
        }
        .buttonStyle(.plain)
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
        .frame(height: 110)
        .background(Color.cardIvory)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 2)
    }
}

// MARK: - Memories Gallery View
struct MemoriesGalleryView: View {
    @Environment(ActivityStore.self) var store
    @Environment(PetStore.self) var petStore
    
    enum ImagePickerSource: String, Identifiable {
        case camera, library
        var id: String { rawValue }
        var type: UIImagePickerController.SourceType {
            self == .camera ? .camera : .photoLibrary
        }
    }
    
    @State private var activeImageSource: ImagePickerSource? = nil
    @State private var pickedImage: UIImage? = nil
    @State private var isUploading = false
    @State private var selectedMemory: PetMemory? = nil
    
    let columns = [GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        ScrollView {
            if store.memories.isEmpty && !isUploading {
                VStack(spacing: 16) {
                    Image(systemName: "photo.on.rectangle.angled")
                        .font(.system(size: 40))
                        .foregroundColor(.gray.opacity(0.5))
                    Text("No memories yet.\nTap + to add some!")
                        .multilineTextAlignment(.center)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(.gray)
                }
                .padding(.top, 60)
            } else {
                LazyVGrid(columns: columns, spacing: 16) {
                    if isUploading {
                        VStack {
                            ProgressView()
                            Text("Uploading...")
                                .font(.caption)
                                .foregroundStyle(.gray)
                        }
                        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 160, maxHeight: 160)
                        .background(Color.gray.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    
                    ForEach(store.memories) { memory in
                        if let url = URL(string: memory.imageUrl) {
                            Button {
                                selectedMemory = memory
                            } label: {
                                AsyncImage(url: url) { image in
                                    image.resizable().scaledToFill()
                                } placeholder: {
                                    Color.gray.opacity(0.2)
                                }
                                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 160, maxHeight: 160)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                            }
                            .buttonStyle(.plain)
                            .contextMenu {
                                Button(role: .destructive) {
                                    withAnimation {
                                        store.deleteMemory(id: memory.id)
                                    }
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                    }
                }
                .padding()
            }
        }
        .navigationTitle("All Memories")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button {
                        activeImageSource = .camera
                    } label: {
                        Label("Take Photo", systemImage: "camera")
                    }
                    
                    Button {
                        activeImageSource = .library
                    } label: {
                        Label("Choose from Library", systemImage: "photo.on.rectangle")
                    }
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color(hex: "6E54D7") ?? .purple)
                }
                .disabled(isUploading)
            }
        }
        .fullScreenCover(item: $activeImageSource) { source in
            ImagePicker(selectedImage: $pickedImage, sourceType: source.type)
                .ignoresSafeArea()
        }
        .fullScreenCover(item: $selectedMemory) { memory in
            MemoryDetailView(memory: memory) {
                store.deleteMemory(id: memory.id)
                selectedMemory = nil
            }
        }
        .onChange(of: pickedImage) { _, newImage in
            if let newImage {
                isUploading = true
                Task {
                    await store.addMemory(image: newImage, petStore: petStore)
                    pickedImage = nil
                    isUploading = false
                }
            }
        }
    }
}

// MARK: - Memory Detail View

struct MemoryDetailView: View {
    @Environment(\.dismiss) var dismiss
    let memory: PetMemory
    let onDelete: () -> Void
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            if let url = URL(string: memory.imageUrl) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .scaledToFit()
                        // Optional pinch-to-zoom could go here, but scaledToFit provides a great standard viewing experience
                } placeholder: {
                    ProgressView()
                        .tint(.white)
                }
            }
            
            VStack {
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                            .padding(12)
                            .background(Color.black.opacity(0.5))
                            .clipShape(Circle())
                    }
                    
                    Spacer()
                    
                    if let url = URL(string: memory.imageUrl) {
                        ShareLink(item: url) {
                            Image(systemName: "square.and.arrow.up")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.white)
                                .padding(12)
                                .background(Color.black.opacity(0.5))
                                .clipShape(Circle())
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.top, 16)
                
                Spacer()
                
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Added on")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.white.opacity(0.7))
                        Text(memory.createdAt, style: .date)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    Button(role: .destructive) {
                        onDelete()
                    } label: {
                        Image(systemName: "trash")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.red)
                            .padding(12)
                            .background(Color.white.opacity(0.1))
                            .clipShape(Circle())
                    }
                }
                .padding()
                .background(
                    LinearGradient(colors: [.black.opacity(0.8), .clear], startPoint: .bottom, endPoint: .top)
                )
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
