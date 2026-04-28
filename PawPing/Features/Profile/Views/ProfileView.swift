//
//  ProfileView.swift
//  PawPing
//
//  Created by Atul on 25/03/26.
//

import SwiftUI
import Supabase

struct ProfileView: View {
    @Environment(PetStore.self) var petStore
    @Environment(AuthStore.self) var authStore
    @State private var showingAddPet = false
    @State private var showingEditPet = false
    @State private var showingLogoutAlert = false
    

    var body: some View {
        ScrollView {
            VStack(spacing: 32) {

                // MARK: - Profile Header (Pet)
                profileHeader
                    .padding(.top, 10)

                // MARK: - Pet Information
                settingsSection(title: "Pet Information") {
                    NavigationLink(destination: MyPetsView()) {
                        settingsRow(label: "My Pets", icon: "pawprint.fill", badge: "\(petStore.pets.count)")
                    }
                    Divider().padding(.leading, 56)
                    NavigationLink(destination: HealthView()) { 
                        settingsRow(label: "Health History", icon: "heart.fill")
                    }
                }

                // MARK: - Owner Information
                settingsSection(title: "Owner Information") {
                    infoRow(label: "Name", value: petStore.currentUserProfile?.name ?? "Loading...", icon: "person.fill")
                    Divider().padding(.leading, 56)
                    infoRow(label: "Email", value: petStore.currentUserProfile?.email ?? "Loading...", icon: "envelope.fill")
                }

                // MARK: - Vet & Emergency
                settingsSection(title: "Vet & Emergency") {
                    NavigationLink(destination: SavedVetsView()) {
                        settingsRow(label: "Saved Vets", icon: "cross.case.fill")
                    }
                }

                // MARK: - Legal & App Settings
                settingsSection(title: "Legal & App Settings") {
                    NavigationLink(destination: TermsView()) {
                        settingsRow(label: "Terms & Conditions", icon: "doc.text.fill")
                    }
                    Divider().padding(.leading, 56)
                    NavigationLink(destination: PrivacyPolicyView()) {
                        settingsRow(label: "Privacy Policy", icon: "lock.shield.fill")
                    }
                    Divider().padding(.leading, 56)
                    NavigationLink(destination: AccountManagementView()) {
                        settingsRow(label: "Account Management", icon: "person.badge.key.fill")
                    }
                    Divider().padding(.leading, 56)
                    NavigationLink(destination: AboutView()) {
                        settingsRow(label: "About Us", icon: "info.circle.fill")
                    }
                }

                // MARK: - Log Out
                logOutButton
                    .padding(.top, 8)
            }
            .padding(.bottom, 40)
        }
        .background(Color("baseBackground"))
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            if petStore.currentUserProfile == nil {
                await petStore.fetchUserProfile()
            }
        }
        .fullScreenCover(isPresented: $showingAddPet) {
            AddPetView { newPet in
                let success = await petStore.addPet(newPet)
                if success {
                    petStore.switchPet(to: newPet.id)
                }
                return success
            }
        }
        .sheet(isPresented: $showingEditPet) {
            EditPetView()
        }
        .alert("Are you sure you want to log out?", isPresented: $showingLogoutAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Log Out", role: .destructive) {
                Task {
                    await authStore.logout()
                }
            }
        }
    }
}

// MARK: - Subviews

private extension ProfileView {

    var profileHeader: some View {
        VStack(spacing: 8) {
            if let pet = petStore.activePet {
                Button {
                    showingEditPet = true
                } label: {
                    ZStack(alignment: .bottomTrailing) {
                        if let urlString = pet.profileImageUrl, let url = URL(string: urlString) {
                            AsyncImage(url: url) { phase in
                                switch phase {
                                case .empty:
                                    ZStack {
                                        Circle().fill(Color("baseColor").opacity(0.2))
                                        Image(systemName: "pawprint.fill")
                                            .foregroundStyle(Color("baseColor"))
                                    }
                                case .success(let image):
                                    image.resizable().scaledToFill()
                                case .failure:
                                    Image(Pet.defaultImageName).resizable().scaledToFill()
                                @unknown default:
                                    EmptyView()
                                }
                            }
                            .frame(width: 90, height: 90)
                            .clipShape(Circle())
                        } else {
                            Image(pet.imageName)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 90, height: 90)
                                .clipShape(Circle())
                        }

                        // Pencil Badge (Pen Icon)
                        Circle()
                            .fill(Color("baseColor"))
                            .frame(width: 28, height: 28)
                            .overlay(
                                Image(systemName: "pencil")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundStyle(.white)
                            )
                            .overlay(
                                Circle().stroke(Color(UIColor.systemBackground), lineWidth: 2.5)
                            )
                            .offset(x: 4, y: 4)
                    }
                }
                .buttonStyle(.plain) // Prevents the whole row from highlighting if unwanted

                Text(pet.name)
                    .font(.system(.title2, weight: .bold))

                Text(pet.breed)
                    .font(.subheadline)
                    .foregroundStyle(Color("secondaryText"))
                    .padding(.bottom, 8)

            } else {
                Image(Pet.defaultImageName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 80, height: 80)
                    .clipShape(Circle())

                Text("No Pet")
                    .font(.system(.title2, weight: .bold))
                    .foregroundStyle(Color("secondaryText"))
                
                Button {
                    showingAddPet = true
                } label: {
                    Text("+ Add Pet")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color("baseColor"))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color("baseColor").opacity(0.1))
                        .clipShape(Capsule())
                }
                .padding(.top, 4)
            }
        }
        .padding(.top, 12)
    }

    // MARK: Grouped Section

    func settingsSection<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(Color("secondaryText").opacity(0.7))
                .padding(.horizontal, 24)

            VStack(spacing: 0) {
                content()
            }
            .background(Color("cardBackground"))
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 4)
            .padding(.horizontal, 16)
        }
    }

    func settingsRow(label: String, icon: String, badge: String? = nil) -> some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundStyle(Color("baseColor"))
                .frame(width: 24)
            
            Text(label)
                .font(.system(size: 16))
                .foregroundStyle(.primary)
            
            Spacer()
            
            if let badge {
                Text(badge)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(Capsule().fill(Color("baseColor")))
            }
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .contentShape(Rectangle())
    }

    func infoRow(label: String, value: String, icon: String) -> some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundStyle(Color("baseColor"))
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.secondary)
                Text(value)
                    .font(.system(size: 16))
                    .foregroundStyle(.primary)
                    .lineLimit(1)
            }
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
    }

    // MARK: Log Out

    var logOutButton: some View {
        Button {
            showingLogoutAlert = true
        } label: {
            Text("Log Out")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color("baseColor"))
                )
                .padding(.horizontal, 24)
        }
    }
}

struct ProfileViewPreviewWrapper: View {
    @State private var appState = AppState()
    @State private var petStore = PetStore.preview
    
    var body: some View {
        NavigationStack {
            ProfileView()
                .environment(appState)
                .environment(petStore)
                .environment(AuthStore(appState: appState))
        }
    }
}

#Preview {
    ProfileViewPreviewWrapper()
}
