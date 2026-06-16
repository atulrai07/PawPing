//
//  ProfileView.swift
//  PawPing
//

import SwiftUI

struct ProfileView: View {
    @Environment(PetStore.self) var petStore
    @Environment(AuthStore.self) var authStore
    @Environment(HealthStore.self) var healthStore
    @Environment(ActivityStore.self) var activityStore
    
    @State private var showingAddPet = false
    @State private var showingEditPet = false
    @State private var showingLogoutAlert = false

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 32) {
                    
                    // 1. Header Section
                    headerSection
                    
                    // 2. Pet Summary Hero Card
                    if petStore.activePet != nil {
                        petSummaryHeroCard
                    } else {
                        emptyPetCard
                    }
                    
                    // 3. My Pets Card
                    NavigationLink(destination: MyPetsView()) {
                        myPetsCard
                    }
                    .buttonStyle(.plain)
                    
                    // 4. Owner Information Section
                    ownerInformationSection
                    
                    // 5. Vet & Emergency Section
                    vetAndEmergencySection
                    
                    // 6. Settings Section
                    settingsSectionView
                    
                    // Log Out
                    logOutButton
                        .padding(.top, 8)
                        .padding(.bottom, 40)
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
            }
            .background(Color.white.ignoresSafeArea())
            .task {
                if petStore.currentUserProfile == nil || petStore.currentUserProfile?.id != authStore.appState?.currentUserId {
                    await petStore.fetchUserProfile()
                }
                if let petId = petStore.activePetId {
                    await healthStore.fetchVaccines(for: petId)
                    await petStore.fetchSavedVets()
                }
            }
            .sheet(isPresented: $showingAddPet) {
                AddPetView {
                    showingAddPet = false
                }
            }
            .sheet(isPresented: $showingEditPet, onDismiss: {
                Task { await petStore.fetchPets() }
            }) {
                EditPetView()
            }
            .alert("Are you sure you want to log out?", isPresented: $showingLogoutAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Log Out", role: .destructive) {
                    petStore.clear()
                    Task {
                        await authStore.logout()
                    }
                }
            }
        }
    }
}

// MARK: - Subviews
private extension ProfileView {
    
    var headerSection: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Profile")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundStyle(.primary)
                
                Text("All about you and your pets")
                    .font(.system(size: 16))
                    .foregroundStyle(.gray)
            }
            Spacer()
            
            // Notification Bell
            Button {
                // TODO: Handle Notifications routing
            } label: {
                ZStack {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 44, height: 44)
                        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
                    
                    Image(systemName: "bell")
                        .font(.system(size: 20))
                        .foregroundStyle(Color(hex: "1C1B1F") ?? .black)
                }
                .overlay(alignment: .topTrailing) {
                    Circle()
                        .fill(Color.red)
                        .frame(width: 10, height: 10)
                        .offset(x: -2, y: 2)
                }
            }
        }
    }
    
    var emptyPetCard: some View {
        VStack(spacing: 16) {
            Image(systemName: "pawprint.fill")
                .font(.system(size: 48))
                .foregroundStyle(Color(hex: "6E54D7") ?? .purple)
                .opacity(0.5)
            
            Text("Let's add your first pet.")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(Color(hex: "1C1B1F") ?? .black)
            
            Button {
                showingAddPet = true
            } label: {
                Text("Add Pet")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color(hex: "6E54D7") ?? .purple)
                    .clipShape(Capsule())
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .background(
            RoundedRectangle(cornerRadius: 32)
                .fill(Color(hex: "F8F6FF") ?? .purple.opacity(0.05))
        )
    }
    
    var petSummaryHeroCard: some View {
        guard let pet = petStore.activePet else { return AnyView(EmptyView()) }
        return AnyView(
            VStack(spacing: 24) {
                // Top Row: Image & Name
                HStack(spacing: 16) {
                    Button {
                        showingEditPet = true
                    } label: {
                        ZStack(alignment: .bottomTrailing) {
                            if let urlString = pet.profileImageUrl, let url = URL(string: urlString) {
                                AsyncImage(url: url) { phase in
                                    switch phase {
                                    case .empty:
                                        Circle().fill(Color.gray.opacity(0.2))
                                    case .success(let image):
                                        image.resizable().scaledToFill()
                                    case .failure:
                                        Image(Pet.defaultImageName).resizable().scaledToFill()
                                    @unknown default:
                                        EmptyView()
                                    }
                                }
                                .frame(width: 100, height: 100)
                                .clipShape(Circle())
                            } else {
                                Image(pet.imageName)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 100, height: 100)
                                    .clipShape(Circle())
                            }
                            
                            Circle()
                                .fill(Color(hex: "6E54D7") ?? .purple)
                                .frame(width: 32, height: 32)
                                .overlay(
                                    Image(systemName: "camera.fill")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundStyle(.white)
                                )
                                .overlay(
                                    Circle().stroke(Color.white, lineWidth: 3)
                                )
                                .offset(x: 4, y: 4)
                        }
                    }
                    .buttonStyle(.plain)
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text(pet.name)
                            .font(.system(size: 28, weight: .bold))
                            .foregroundStyle(Color(hex: "1C1B1F") ?? .black)
                        
                        Text(pet.breed)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(Color(hex: "6E54D7") ?? .purple)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color(hex: "6E54D7")?.opacity(0.1) ?? .purple.opacity(0.1))
                            .clipShape(Capsule())
                    }
                    Spacer()
                }
                
                // Attributes Row
                HStack {
                    attributeItem(icon: "mars.and.venus", text: pet.gender.rawValue.capitalized)
                    Divider().frame(height: 16)
                    attributeItem(icon: "calendar", text: pet.age)
                    Divider().frame(height: 16)
                    attributeItem(icon: "scalemass", text: "\(String(format: "%.1f", pet.weightKg)) kg")
                }
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity)
                .background(Color.white.opacity(0.5))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                
                // Insights Row
                HStack(spacing: 0) {
                    insightItem(
                        icon: "clipboard.fill",
                        iconColor: Color(hex: "6E54D7") ?? .purple,
                        title: "Health Records",
                        value: "\(healthStore.healthRecords.count)",
                        subtitle: "Records"
                    )
                    insightItem(
                        icon: "shield.fill",
                        iconColor: .green,
                        title: "Vaccines",
                        value: "\(healthStore.summary.doneCount)",
                        subtitle: "Completed"
                    )
                    
                    let nextVaccineStr = computeNextVaccine()
                    insightItem(
                        icon: "cross.case.fill",
                        iconColor: .orange,
                        title: "Next Vaccine",
                        value: nextVaccineStr.value,
                        subtitle: nextVaccineStr.subtitle
                    )
                    insightItem(
                        icon: "waveform.path.ecg",
                        iconColor: .blue,
                        title: "Avg. Walk",
                        value: "\(activityStore.averageWalkDurationPerDay)",
                        subtitle: "min/day"
                    )
                }
            }
            .padding(24)
            .background(
                ZStack(alignment: .topTrailing) {
                    RoundedRectangle(cornerRadius: 32)
                        .fill(Color(hex: "F8F6FF") ?? .purple.opacity(0.05))
                    
                    Image(systemName: "pawprint.fill")
                        .font(.system(size: 140))
                        .foregroundStyle(Color(hex: "6E54D7") ?? .purple)
                        .opacity(0.05)
                        .offset(x: 40, y: -20)
                        .rotationEffect(.degrees(15))
                }
                .clipShape(RoundedRectangle(cornerRadius: 32))
            )
        )
    }
    
    private func attributeItem(icon: String, text: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundStyle(Color(hex: "6E54D7") ?? .purple)
            Text(text)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(Color(hex: "1C1B1F") ?? .black)
        }
        .frame(maxWidth: .infinity)
    }
    
    private func insightItem(icon: String, iconColor: Color, title: String, value: String, subtitle: String) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundStyle(iconColor)
                .padding(.bottom, 4)
            
            Text(title)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(Color(hex: "1C1B1F") ?? .black)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
                .frame(height: 28, alignment: .bottom)
            
            Text(value)
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(Color(hex: "1C1B1F") ?? .black)
                .multilineTextAlignment(.center)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
                .frame(height: 24, alignment: .center)
                .padding(.top, 4)
            
            Text(subtitle)
                .font(.system(size: 10))
                .foregroundStyle(.gray)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
    }
    
    private func computeNextVaccine() -> (value: String, subtitle: String) {
        let upcoming = healthStore.healthRecords.filter { $0.status == .upcoming || $0.status == .overdue }.sorted { ($0.nextDoseDate ?? Date()) < ($1.nextDoseDate ?? Date()) }
        
        if let first = upcoming.first, let nextDate = first.nextDoseDate {
            let daysUntil = Calendar.current.dateComponents([.day], from: Date(), to: nextDate).day ?? 0
            if daysUntil <= 30 {
                return ("\(daysUntil)", "Days left")
            }
        }
        return ("Up to Date", "Protected")
    }

    var myPetsCard: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(hex: "F8F6FF") ?? .purple.opacity(0.1))
                    .frame(width: 48, height: 48)
                Image(systemName: "pawprint.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(Color(hex: "6E54D7") ?? .purple)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("My Pets")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(Color(hex: "1C1B1F") ?? .black)
                Text("View and manage your pets")
                    .font(.system(size: 13))
                    .foregroundStyle(.gray)
            }
            
            Spacer()
            
            Text("\(petStore.pets.count)")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: 28, height: 28)
                .background(Circle().fill(Color(hex: "6E54D7") ?? .purple))
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.gray)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 4)
        )
    }
    
    var ownerInformationSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Owner Information")
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(Color(hex: "1C1B1F") ?? .black)
            
            VStack(spacing: 0) {
                ownerRow(
                    icon: "person.fill",
                    title: "Name",
                    value: petStore.currentUserProfile?.name ?? "Loading..."
                )
                Divider().padding(.leading, 64)
                ownerRow(
                    icon: "envelope.fill",
                    title: "Email",
                    value: petStore.currentUserProfile?.email ?? "Loading..."
                )
            }
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 4)
            )
        }
    }
    
    private func ownerRow(icon: String, title: String, value: String) -> some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(hex: "F8F6FF") ?? .purple.opacity(0.1))
                    .frame(width: 40, height: 40)
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundStyle(Color(hex: "6E54D7") ?? .purple)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 12))
                    .foregroundStyle(.gray)
                Text(value)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color(hex: "1C1B1F") ?? .black)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.gray)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
    }

    var vetAndEmergencySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Vet & Emergency")
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(Color(hex: "1C1B1F") ?? .black)
            
            NavigationLink(destination: SavedVetsView()) {
                HStack(spacing: 16) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white.opacity(0.8))
                            .frame(width: 48, height: 48)
                        Image(systemName: "cross.case.fill")
                            .font(.system(size: 20))
                            .foregroundStyle(.red)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Saved Vets")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(Color(hex: "1C1B1F") ?? .black)
                        Text("Quick access to your saved clinics")
                            .font(.system(size: 13))
                            .foregroundStyle(.gray)
                    }
                    
                    Spacer()
                    
                    if !petStore.savedVets.isEmpty {
                        Text("\(petStore.savedVets.count)")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(.red)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(Capsule().fill(Color.white.opacity(0.8)))
                    }
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.gray)
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color.red.opacity(0.05))
                        .shadow(color: Color.black.opacity(0.02), radius: 10, x: 0, y: 4)
                )
            }
            .buttonStyle(.plain)
        }
    }
    
    var settingsSectionView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Settings")
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(Color(hex: "1C1B1F") ?? .black)
            
            VStack(spacing: 0) {
                NavigationLink(destination: PrivacyPolicyView()) {
                    settingsRow(icon: "checkmark.shield.fill", iconColor: .blue, title: "Privacy & Security")
                }
                Divider().padding(.leading, 56)
                
                NavigationLink(destination: EmptyView()) {
                    settingsRow(icon: "bell.fill", iconColor: .green, title: "Notifications")
                }
                Divider().padding(.leading, 56)
                
                NavigationLink(destination: AccountManagementView()) {
                    settingsRow(icon: "gearshape.fill", iconColor: .orange, title: "App Settings")
                }
                Divider().padding(.leading, 56)
                
                NavigationLink(destination: AboutView()) {
                    settingsRow(icon: "info.circle.fill", iconColor: Color(hex: "6E54D7") ?? .purple, title: "Help & Support")
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 4)
            )
        }
    }
    
    private func settingsRow(icon: String, iconColor: Color, title: String) -> some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.1))
                    .frame(width: 32, height: 32)
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundStyle(iconColor)
            }
            
            Text(title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(Color(hex: "1C1B1F") ?? .black)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.gray)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .contentShape(Rectangle())
    }

    var logOutButton: some View {
        Button {
            showingLogoutAlert = true
        } label: {
            Text("Log Out")
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(Color(hex: "6E54D7") ?? .purple)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color(hex: "F8F6FF") ?? .purple.opacity(0.1))
                )
        }
    }
}
