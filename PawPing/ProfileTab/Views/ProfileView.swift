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
                VStack(spacing: 24) {
                    
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
            .background(LinearGradient(colors: [.bgWarmTop, .bgWarmBottom], startPoint: .topLeading, endPoint: .bottomTrailing).ignoresSafeArea())
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
            }
            Spacer()
            
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
                .foregroundStyle(Color.textPrimary)
            
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
                                    Circle().stroke(Color.cardIvory, lineWidth: 3)
                                )
                                .offset(x: 4, y: 4)
                        }
                    }
                    .buttonStyle(.plain)
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text(pet.name)
                            .font(.system(size: 28, weight: .bold))
                            .foregroundStyle(Color.textPrimary)
                        
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
                .background(Color.cardIvory.opacity(0.5))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                

            }
            .padding(24)
            .background(
                ZStack(alignment: .topTrailing) {
                    RoundedRectangle(cornerRadius: 32)
                        .fill(Color.heroLavenderStart)
                    
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
                .foregroundStyle(Color.textPrimary)
        }
        .frame(maxWidth: .infinity)
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
                    .foregroundStyle(Color.textPrimary)
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
                .fill(Color.cardIvory)
                .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 4)
        )
    }
    
    var ownerInformationSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Owner Information")
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(Color.textPrimary)
            
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
                    .fill(Color.cardIvory)
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
                    .foregroundStyle(Color.textPrimary)
            }
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
    }

    var vetAndEmergencySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Vet & Emergency")
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(Color.textPrimary)
            
            NavigationLink(destination: SavedVetsView()) {
                HStack(spacing: 16) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.cardIvory.opacity(0.8))
                            .frame(width: 48, height: 48)
                        Image(systemName: "cross.case.fill")
                            .font(.system(size: 20))
                            .foregroundStyle(.red)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Saved Vets")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(Color.textPrimary)
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
                            .background(Capsule().fill(Color.cardIvory.opacity(0.8)))
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
                .foregroundStyle(Color.textPrimary)
            
            VStack(spacing: 0) {
                NavigationLink(destination: PrivacyPolicyView()) {
                    settingsRow(icon: "checkmark.shield.fill", iconColor: .blue, title: "Privacy & Security")
                }
                Divider().padding(.leading, 56)
                
                NavigationLink(destination: NotificationSettingsView()) {
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
                    .fill(Color.cardIvory)
                    .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 4)
            )
        }
    }
    
    private func settingsRow(icon: String, iconColor: Color, title: String) -> some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundStyle(iconColor)
                .frame(width: 24, alignment: .center)
            
            Text(title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(Color.textPrimary)
            
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
                        .fill(Color.heroLavenderStart)
                )
        }
    }
}
