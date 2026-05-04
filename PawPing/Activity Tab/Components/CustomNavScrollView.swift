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
    @State private var showingAddPet = false

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
                                    Group {
                                        if let urlString = petStore.activePet?.profileImageUrl, let url = URL(string: urlString) {
                                            AsyncImage(url: url) { image in
                                                image.resizable().scaledToFill()
                                            } placeholder: {
                                                ProgressView()
                                            }
                                        } else {
                                            Image(petStore.activePet?.imageName ?? Pet.defaultImageName)
                                                .resizable()
                                                .scaledToFill()
                                        }
                                    }
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
        .frame(height: 60)

        // ── Background gradient
        .background {
            Rectangle()
                .fill(.ultraThinMaterial)
                .opacity(isCollapsed ? 1 : 0)
                .mask {
                    LinearGradient(
                        stops: [
                            .init(color: .black,           location: 0.0),
                            .init(color: .black.opacity(0.7), location: 0.4),
                            .init(color: .black.opacity(0.3), location: 0.7),
                            .init(color: .clear,           location: 1.0),
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                }
                .ignoresSafeArea(edges: .top)
        }
        
        .sheet(isPresented: $showingAddPet) {
            AddPetView {
                showingAddPet = false
            }
        }
        .animation(.easeInOut(duration: 0.2), value: isCollapsed)
    }
}

// CustomNavigationScrollModifier

private struct CustomNavigationScrollModifier: ViewModifier {
    let title: String
    var petStore: PetStore?
    var onAddTap: (() -> Void)?
    var refreshAction: (() async -> Void)?
    var collapseThreshold: CGFloat

    @State private var scrollOffset: CGFloat = 0
    @State private var isCollapsed = false

    func body(content: Content) -> some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                Color.clear.frame(height: 60)
                content
            }
                // Attach the geometry reader to the content so its minY in
                // the named coordinate space gives us the raw scroll offset.
                .background(
                    GeometryReader { geo in
                        let minY = geo.frame(in: .named("_customNavScroll")).minY
                        Color.clear
                            .onChange(of: minY) { _, newVal in
                                scrollOffset  = max(0, -newVal)
                                isCollapsed   = scrollOffset > collapseThreshold
                            }
                            .onAppear {
                                scrollOffset  = max(0, -minY)
                                isCollapsed   = scrollOffset > collapseThreshold
                            }
                    }
                )
        }
        .refreshable {
            if let refreshAction {
                await refreshAction()
            }
        }
        .coordinateSpace(.named("_customNavScroll"))
        .background(Color("baseBackground"))
        .toolbar(.hidden, for: .navigationBar)
        .overlay(alignment: .top) {
            StickyNavHeader(
                title: title,
                petStore: petStore,
                onAddTap: onAddTap,
                isCollapsed: isCollapsed
            )
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
        refreshAction: (() async -> Void)? = nil,
        collapseThreshold: CGFloat = 50
    ) -> some View {
        modifier(CustomNavigationScrollModifier(
            title: title,
            petStore: petStore,
            onAddTap: onAddTap,
            refreshAction: refreshAction,
            collapseThreshold: collapseThreshold
        ))
    }
}
