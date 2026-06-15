//
//  CustomNavigationScroll.swift
//  PawPing
//
//
//  USAGE:
//  ──────
//  VStack(spacing: 20) {
//      // your scrollable content
//  }
//  .customNavigationScroll(title: "Vaccine", petStore: petStore)
//

import SwiftUI

// MARK: - StickyNavHeader

private struct StickyNavHeader: View {

    let title: String
    var petStore: PetStore?
    var onAddTap: (() -> Void)?
    let isCollapsed: Bool
    @Binding var showingAddPet: Bool

    var body: some View {
        ZStack {
            // MARK: Pet Switcher Menu
            if let petStore = petStore {
                HStack {
                    Spacer()

                    // Add button (liquid glass style)
                    if let addAction = onAddTap {
                        Button {
                            addAction()
                        } label: {
                            ZStack {
                                Circle()
                                    .fill(.ultraThinMaterial)
                                    .frame(width: 36, height: 36)
                                    .shadow(color: Color("baseColor").opacity(0.3), radius: 6, x: 0, y: 2)

                                Image(systemName: "plus")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundStyle(Color("baseColor"))
                            }
                        }
                        .padding(.trailing, 8)
                    }

                    // Pet switcher menu
                    Menu {
                        ForEach(petStore.pets) { pet in
                            Button {
                                petStore.switchPet(to: pet.id)
                            } label: {
                                Label {
                                    Text(pet.name)
                                } icon: {
                                    if pet.id == petStore.activePetId {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }

                        Divider()

                        Button {
                            showingAddPet = true
                        } label: {
                            Label("Add Pet", systemImage: "plus.circle")
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Circle()
                                .fill(Color("secondaryText").opacity(0.2))
                                .frame(width: 36, height: 36)
                                .overlay(
                                    Image(petStore.activePet?.imageName ?? Pet.defaultImageName)
                                        .resizable()
                                        .scaledToFill()
                                        .clipShape(Circle())
                                )
                            Image(systemName: "chevron.down")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundStyle(Color("secondaryText"))
                        }
                    }
                }
            }

            // Large title (fades out on scroll)
            Text(title)
                .font(.system(size: 34, weight: .bold))
                .foregroundStyle(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .opacity(isCollapsed ? 0 : 1)
                .scaleEffect(isCollapsed ? 0.9 : 1.0, anchor: .leading)

            // Inline title (fades in on scroll)
            Text(title)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(.primary)
                .frame(maxWidth: .infinity, alignment: .center)
                .opacity(isCollapsed ? 1 : 0)
        }
        .padding(.horizontal, 16)
        .padding(.top, isCollapsed ? -8 : 8)
        .padding(.bottom, isCollapsed ? 12 : 6)

        // ── Background gradient
        .background {
            Rectangle()
                .fill(.pawBackground)
                .opacity(isCollapsed ? 1 : 0.8)
                .mask {
                    LinearGradient(
                        stops: [
                            .init(color: .black,           location: 0.0),
                            .init(color: .black.opacity(0.8), location: 0.7),
                            .init(color: .clear,           location: 1.0),
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                }
                .ignoresSafeArea(edges: .top)
        }
        
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(.red)
                .frame(height: 0.5)
                .opacity(isCollapsed ? 0 : 0)
        }
        // .fullScreenCover moved to modifier for stability
        .animation(.spring(response: 0.15, dampingFraction: 0.9), value: isCollapsed)
    }
}

// CustomNavigationScrollModifier

private struct CustomNavigationScrollModifier: ViewModifier {
    let title: String
    var petStore: PetStore?
    var onAddTap: (() -> Void)?
    var collapseThreshold: CGFloat

    @State private var scrollOffset: CGFloat = 0
    @State private var isCollapsed = false
    @State private var showingAddPet = false

    func body(content: Content) -> some View {
        ScrollView(showsIndicators: false) {
            content
                // Attach the geometry reader to the content so its minY in
                // the named coordinate space gives us the raw scroll offset.
                .background(
                    GeometryReader { geo in
                        let minY = geo.frame(in: .named("_customNavScroll")).minY
                        Color.clear
                            .onChange(of: minY) { _, newVal in
                                let collapsed = -newVal > collapseThreshold
                                if isCollapsed != collapsed {
                                    isCollapsed = collapsed
                                }
                            }
                            .onAppear {
                                isCollapsed = -minY > collapseThreshold
                            }
                    }
                )
        }
        .coordinateSpace(name: "_customNavScroll")
        .background(.pawBackground)
        // Hide the system nav bar — the modifier supplies its own header.
        .toolbar(.hidden, for: .navigationBar)
        // Pin the header above the scroll content without participating in scrolling.
        .safeAreaInset(edge: .top, spacing: 0) {
            StickyNavHeader(
                title: title,
                petStore: petStore,
                onAddTap: onAddTap,
                isCollapsed: isCollapsed,
                showingAddPet: $showingAddPet
            )
        }
        .fullScreenCover(isPresented: $showingAddPet) {
            if let petStore = petStore {
                AddPetView { newPet in
                    let success = await petStore.addPet(newPet)
                    if success {
                        petStore.switchPet(to: newPet.id)
                    }
                    return success
                }
            }
        }
    }
}

// MARK: - View Extension

extension View {

    /// Wraps the view in a scroll container with a collapsing navigation header
    /// and an integrated pet-switcher dropdown.
    ///
    /// - Parameters:
    ///   - title:              The screen title shown large, then inline once collapsed.
    ///   - petStore:           The PetStore to power the pet-switcher dropdown.
    ///   - onAddTap:           Optional action for the "+" button.
    ///   - collapseThreshold:  Scroll distance (pt) before the title collapses. Default 50.
    func customNavigationScroll(
        title: String,
        petStore: PetStore? = nil,
        onAddTap: (() -> Void)? = nil,
        collapseThreshold: CGFloat = 50
    ) -> some View {
        modifier(CustomNavigationScrollModifier(
            title: title,
            petStore: petStore,
            onAddTap: onAddTap,
            collapseThreshold: collapseThreshold
        ))
    }
}
