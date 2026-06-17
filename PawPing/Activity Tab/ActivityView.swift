//
//  ActivityView.swift
//  PawPing
//
//  Created by Atul on 19/01/26.
//

import SwiftUI

struct ActivityView: View {
    @Environment(ActivityStore.self) var store
    @Environment(PetStore.self) var petStore
    @Environment(HealthStore.self) var healthStore
    @Environment(DietAssistantStore.self) var dietAssistantStore
    @Environment(MedicationStore.self) var medicationStore
    @Environment(AppState.self) var appState

    @State private var showPetSwitcher = false
    @State private var showingAddPet = false

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
                    VStack(spacing: 32) {
                        DynamicHeroCardView()
                        
                        DailyTimelineView()
                        
                        RecentMemoriesView()
                        
                        WellnessInsightCardView()
                    }
                    .padding(.top, 16)
                    .padding(.bottom, 80)
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
                        backgroundColor: .white
                    )
                }
            }
        }
    }

    // MARK: - Pet Switcher Menu
    private var petSwitcherMenu: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(petStore.pets) { pet in
                Button {
                    petStore.switchPet(to: pet.id)
                    showPetSwitcher = false
                } label: {
                    HStack(spacing: 12) {
                        if let urlString = pet.profileImageUrl, let url = URL(string: urlString) {
                            AsyncImage(url: url) { image in
                                image.resizable().scaledToFill()
                            } placeholder: {
                                Color.gray.opacity(0.2)
                            }
                            .frame(width: 32, height: 32)
                            .clipShape(Circle())
                        } else {
                            Image(pet.imageName)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 32, height: 32)
                                .clipShape(Circle())
                        }
                        
                        Text(pet.name)
                            .font(.body)
                            .foregroundStyle(.primary)
                        
                        Spacer()
                        
                        if pet.id == petStore.activePetId {
                            Image(systemName: "checkmark")
                                .foregroundStyle(Color.orange)
                                .font(.system(size: 14, weight: .bold))
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                
                if pet.id != petStore.pets.last?.id {
                    Divider()
                        .padding(.leading, 60)
                }
            }
            
            Divider()
            
            Button {
                showPetSwitcher = false
                showingAddPet = true
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundStyle(Color.orange)
                        .font(.title3)
                        .frame(width: 32)
                    
                    Text("Add Pet")
                        .font(.body)
                        .foregroundStyle(.primary)
                    
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
        .frame(width: 220)
        .padding(.vertical, 8)
        .presentationCompactAdaptation(.popover)
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
                            .foregroundColor(.homeTextDark)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                        Text(time)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.homeTextGray)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                    }
                    
                    Spacer(minLength: 4)
                    
                    Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(isCompleted ? .homePurple : .homeTextGray.opacity(0.3))
                        .font(.system(size: 18))
                }
                
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 70)
            }
            .padding(12)
            .frame(maxWidth: .infinity)
            .background(Color.white)
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
                        .foregroundColor(.homeTextDark)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                    Text(subtitle)
                        .font(.system(size: 9, weight: .medium))
                        .foregroundColor(.homeTextGray)
                        .multilineTextAlignment(.center)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 4)
            .frame(maxWidth: .infinity)
            .background(Color.white)
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
                    .foregroundColor(.homeTextDark)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            
            HStack(alignment: .lastTextBaseline, spacing: 2) {
                Text(value)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.homeTextDark)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                if !unit.isEmpty {
                    Text(unit)
                        .font(.system(size: 9, weight: .medium))
                        .foregroundColor(.homeTextGray)
                        .lineLimit(1)
                }
            }
            
            if !subtitle.isEmpty {
                Text(subtitle)
                    .font(.system(size: 9, weight: .medium))
                    .foregroundColor(.homeTextGray)
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
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 2)
    }
}

// MARK: - Walk Flow Container (Countdown → Tracking)

struct WalkFlowContainer: View {
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
