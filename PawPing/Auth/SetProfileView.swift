//
//  SetProfileView.swift
//  PawPing
//
//  Created by Antigravity on 23/04/26.
//
//  Pet profile setup screen — shown after new account creation.
//  Users enter their pet's name, gender, breed, weight, birthday,
//  and neutered status before reaching the Home screen.
//
//  Uses native iOS pickers (Menu-based) and system components
//  for a fully native feel. Data is held in AuthStore.
//

import SwiftUI

struct SetProfileView: View {

    @Bindable var store: AuthStore
    var onAuthenticated: () -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {

                // MARK: - Profile Image Placeholder
                VStack(spacing: 10) {
                    Circle()
                        .fill(Color(.systemGray5))
                        .frame(width: 100, height: 100)
                        .overlay(
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .foregroundStyle(Color(.systemGray3))
                        )

                    Button {
                        // Stub: image picker
                    } label: {
                        Text("Upload Photo")
                            .font(.subheadline)
                            .foregroundStyle(Color("baseColor"))
                    }
                }
                .padding(.top, 24)
                .padding(.bottom, 28)

                // MARK: - Form Fields
                VStack(spacing: 0) {

                    // Name
                    ProfileRow(label: "Name") {
                        TextField("Enter Name", text: $store.petName)
                            .multilineTextAlignment(.trailing)
                    }

                    Divider().padding(.leading, 16)

                    // Gender
                    ProfileRow(label: "Gender") {
                        Menu {
                            ForEach(DogGender.allCases, id: \.self) { gender in
                                Button(gender.rawValue) {
                                    store.petGender = gender
                                }
                            }
                        } label: {
                            HStack(spacing: 4) {
                                Text(store.petGender.rawValue)
                                    .foregroundStyle(.primary)
                                Image(systemName: "chevron.down")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }

                    Divider().padding(.leading, 16)

                    // Breed
                    ProfileRow(label: "Breed") {
                        Menu {
                            ForEach(DogBreed.allCases, id: \.self) { breed in
                                Button(breed.rawValue) {
                                    store.petBreed = breed
                                }
                            }
                        } label: {
                            HStack(spacing: 4) {
                                Text(store.petBreed.rawValue)
                                    .foregroundStyle(.primary)
                                Image(systemName: "chevron.down")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }

                    Divider().padding(.leading, 16)

                    // Weight
                    ProfileRow(label: "Weight") {
                        HStack(spacing: 4) {
                            TextField("0", text: $store.petWeight)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                                .frame(maxWidth: 60)
                            Text("kg")
                                .foregroundStyle(.secondary)
                        }
                    }

                    Divider().padding(.leading, 16)

                    // Birthday
                    ProfileRow(label: "Birthday") {
                        DatePicker(
                            "",
                            selection: $store.petBirthday,
                            in: ...Date(),
                            displayedComponents: .date
                        )
                        .labelsHidden()
                        .tint(Color("baseColor"))
                    }

                    Divider().padding(.leading, 16)

                    // Neutered
                    ProfileRow(label: "Neutered") {
                        Menu {
                            ForEach(NeuteredStatus.allCases, id: \.self) { status in
                                Button(status.rawValue) {
                                    store.petNeutered = status
                                }
                            }
                        } label: {
                            HStack(spacing: 4) {
                                Text(store.petNeutered.rawValue)
                                    .foregroundStyle(.primary)
                                Image(systemName: "chevron.down")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                } // VStack — form fields
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color(.systemBackground))
                )
                .padding(.horizontal, 16)

                // MARK: - Save Button
                Button {
                    // Stub: save profile → home
                    onAuthenticated()
                } label: {
                    Text("Save")
                        .font(.system(.body, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(Color("baseColor"))
                        )
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 24)
                .padding(.top, 28)
                .padding(.bottom, 40)

            } // VStack — content
        } // ScrollView
        .background(Color("baseBackground").ignoresSafeArea())
        .navigationTitle("Create Profile")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.body.weight(.medium))
                        .foregroundStyle(.primary)
                }
            }
        }
    }
}

// MARK: - Profile Row

/// A single row in the profile form — label on the left, content on the right.
/// Keeps each row consistent without hardcoding heights.
private struct ProfileRow<Content: View>: View {

    let label: String
    @ViewBuilder let content: Content

    var body: some View {
        HStack {
            Text(label)
                .foregroundStyle(.primary)

            Spacer()

            content
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }
}


#Preview {
    NavigationStack {
        SetProfileView(store: AuthStore(), onAuthenticated: {})
    }
}
