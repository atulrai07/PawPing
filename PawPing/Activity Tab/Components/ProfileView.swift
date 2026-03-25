//
//  ProfileView.swift
//  PawPing
//
//  Created by Atul on 25/03/26.
//

import SwiftUI

struct ProfileView: View {
    var store: ActivityStore

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {

                // MARK: - Profile Header
                profileHeader

                // MARK: - Pet Information
                settingsSection(title: "Pet Information", rows: [
                    "Pet Details",
                    "Medical History"
                ])

                // MARK: - Vet & Emergency
                settingsSection(title: "Vet &  Emergency", rows: [
                    "Saved Vets",
                    "Emergency Contacts"
                ])

                // MARK: - Legal & App Settings
                settingsSection(title: "Legal & App Settings", rows: [
                    "Set Goals",
                    "Terms & Conditions",
                    "Privacy Policy",
                    "Account Management",
                    "About us"
                ])

                // MARK: - Log Out
                logOutButton
                    .padding(.top, 8)
            }
            .padding(.bottom, 40)
        }
        .background(Color(.baseBackground))
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
    }
}

// MARK: - Subviews

private extension ProfileView {

    var profileHeader: some View {
        VStack(spacing: 8) {
            Image(store.dogProfile.dogImage)
                .resizable()
                .scaledToFill()
                .frame(width: 100, height: 100)
                .clipShape(Circle())

            Text(store.dogProfile.dogName)
                .font(.system(size: 18, weight: .semibold))
        }
        .padding(.top, 12)
    }

    // MARK: Grouped Section

    func settingsSection(title: String, rows: [String]) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title)
                .font(.system(size: 17, weight: .bold))
                .padding(.horizontal, 20)
                .padding(.bottom, 8)

            VStack(spacing: 0) {
                ForEach(Array(rows.enumerated()), id: \.offset) { index, row in
                    settingsRow(label: row)

                    if index < rows.count - 1 {
                        Divider()
                            .padding(.leading, 20)
                    }
                }
            }
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding(.horizontal, 16)
        }
    }

    func settingsRow(label: String) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 16))
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .contentShape(Rectangle())
    }

    // MARK: Log Out

    var logOutButton: some View {
        Button {
            // Log-out workflow pending
        } label: {
            Text("Log Out")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    Capsule()
                        .fill(Color("baseColor"))
                )
                .padding(.horizontal, 24)
        }
    }
}

#Preview {
    NavigationStack {
        ProfileView(store: ActivityStore())
    }
}
