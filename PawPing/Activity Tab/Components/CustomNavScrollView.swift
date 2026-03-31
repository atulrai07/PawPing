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
//  .customNavigationScroll(title: "Vaccine")
//
//  With a profile avatar:
//  .customNavigationScroll(title: "Vaccine", profileImage: profile.dogImage)
//
//  Custom collapse threshold:
//  .customNavigationScroll(title: "Vaccine", collapseThreshold: 60)

import SwiftUI

// MARK: - StickyNavHeader

private struct StickyNavHeader: View {

    let title: String
    var profileImage: String?
    var onProfileTap: (() -> Void)?
    var onAddTap: (() -> Void)?
    let isCollapsed: Bool

    var body: some View {
        ZStack {
            // MARK: Profile View is in Activity View
            // Trailing profile avatar (always visible)
            if let img = profileImage {//if let because profile image is option (?) value.
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
                    
                    Button {
                        onProfileTap?()
                    } label: {
                        Circle()
                            .fill(Color("secondaryText").opacity(0.2))
                            .frame(width: 36, height: 36)
                            .overlay(
                                Image(img)
                                    .resizable()
                                    .scaledToFill()
                                    .clipShape(Circle())
                            )
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
                .fill(Color("baseBackground"))
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

        .animation(.spring(response: 0.15, dampingFraction: 0.9), value: isCollapsed)
    }
}

// CustomNavigationScrollModifier

private struct CustomNavigationScrollModifier: ViewModifier { // View Modifier, so that we can it as .Nav...(__)\n
    let title: String
    var profileImage: String?
    var onProfileTap: (() -> Void)?
    var onAddTap: (() -> Void)?
    var collapseThreshold: CGFloat

    @State private var scrollOffset: CGFloat = 0
    @State private var isCollapsed = false

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
        .coordinateSpace(name: "_customNavScroll")
        .background(Color("baseBackground"))
        // Hide the system nav bar — the modifier supplies its own header.
        .toolbar(.hidden, for: .navigationBar)
        // Pin the header above the scroll content without participating in scrolling.
        .safeAreaInset(edge: .top, spacing: 0) {
            StickyNavHeader(
                title: title,
                profileImage: profileImage,
                onProfileTap: onProfileTap,
                onAddTap: onAddTap,
                isCollapsed: isCollapsed
            )
        }
    }
}

// MARK: - View Extension

extension View {

    /// Wraps the view in a scroll container with a collapsing navigation header.
    ///
    /// - Parameters:
    ///   - title:              The screen title shown large, then inline once collapsed.
    ///   - profileImage:       Optional asset name for a trailing circular avatar.
    ///   - collapseThreshold:  Scroll distance (pt) before the title collapses. Default 50.
    func customNavigationScroll(
        title: String,
        profileImage: String? = nil,
        onProfileTap: (() -> Void)? = nil,
        onAddTap: (() -> Void)? = nil,
        collapseThreshold: CGFloat = 50
    ) -> some View {
        modifier(CustomNavigationScrollModifier(
            title: title,
            profileImage: profileImage,
            onProfileTap: onProfileTap,
            onAddTap: onAddTap,
            collapseThreshold: collapseThreshold
        ))
    }
}
