//
//  CustomNavigationScroll.swift
//  PawPing
//
//  Created by Atul on 19/03/26.
//
//  A reusable scroll wrapper that gives us a collapsing large-title header
//  (similar to Apple's native nav bar) without fighting with NavigationView.
//
//  HOW TO USE:
//  ──────────
//  Just slap .customNavigationScroll(title: "Activity") on any VStack/content.
//  It wraps everything in a ScrollView with a sticky header that transitions
//  from a big title to a compact centered title as you scroll.
//
//  With a profile avatar:
//  .customNavigationScroll(title: "Vaccine", profileImage: profile.dogImage)
//

import SwiftUI

// MARK: - StickyNavHeader
// The actual header bar that sits above the scroll content.
// It cross-fades between a large left-aligned title and a compact centered one.

private struct StickyNavHeader: View {

    let title: String
    var profileImage: String?
    let isCollapsed: Bool

    var body: some View {
        ZStack {

            // ── Trailing profile avatar (always visible) ──────────────
            if let img = profileImage {
                HStack {
                    Spacer()
                    Circle()
                        .fill(Color.pawNeutral)
                        .frame(width: 36, height: 36)
                        .overlay(
                            Image(img)
                                .resizable()
                                .scaledToFill()
                                .clipShape(Circle())
                        )
                } // HStack — avatar
            }

            // ── Large title (fades out on scroll) ─────────────────────
            Text(title)
                .font(.system(size: 34, weight: .bold))
                .foregroundStyle(.pawSecondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .opacity(isCollapsed ? 0 : 1)
                .scaleEffect(isCollapsed ? 0.9 : 1.0, anchor: .leading)

            // ── Inline title (fades in on scroll) ─────────────────────
            Text(title)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(.pawSecondary)
                .frame(maxWidth: .infinity, alignment: .center)
                .opacity(isCollapsed ? 1 : 0)
        } // ZStack — header content
        .padding(.horizontal, 16)
        .padding(.top, isCollapsed ? -8 : 8)
        .padding(.bottom, isCollapsed ? 12 : 6)

        // ── Background gradient ────────────────────────────────────────
        // Fades from solid to transparent at the bottom so text beneath
        // doesn't get a hard edge.
        .background {
            Rectangle()
                .fill(Color.pawBackground)
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

        // ── Hairline separator (currently hidden) ─────────────────────
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(.pawPrimary)
                .frame(height: 0.5)
                .opacity(isCollapsed ? 0 : 0)
        }

        .animation(.spring(response: 0.15, dampingFraction: 0.9), value: isCollapsed)
    }
} // StickyNavHeader

// MARK: - CustomNavigationScrollModifier
// This is a ViewModifier — think of it like a reusable "plugin" you can
// attach to any view. It wraps the content in a ScrollView and tracks
// scroll position using GeometryReader to toggle the header state.

private struct CustomNavigationScrollModifier: ViewModifier {

    let title: String
    var profileImage: String?
    var collapseThreshold: CGFloat

    // @State because only this modifier cares about scroll tracking
    @State private var scrollOffset: CGFloat = 0
    @State private var isCollapsed = false

    func body(content: Content) -> some View {
        ScrollView(showsIndicators: false) {
            content
                // GeometryReader gives us the content's position relative
                // to the named coordinate space ("_customNavScroll").
                // As the user scrolls, minY goes negative → we invert it.
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
        } // ScrollView
        .coordinateSpace(name: "_customNavScroll")
        .background(Color.pawBackground)
        // We hide the system nav bar since we're rendering our own
        .toolbar(.hidden, for: .navigationBar)
        // safeAreaInset pins the header above the scroll content —
        // it doesn't scroll with the content, it stays fixed.
        .safeAreaInset(edge: .top, spacing: 0) {
            StickyNavHeader(
                title: title,
                profileImage: profileImage,
                isCollapsed: isCollapsed
            )
        }
    }
} // CustomNavigationScrollModifier

// MARK: - View Extension
// This is what makes .customNavigationScroll(...) available on any View.

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
        collapseThreshold: CGFloat = 50
    ) -> some View {
        modifier(CustomNavigationScrollModifier(
            title: title,
            profileImage: profileImage,
            collapseThreshold: collapseThreshold
        ))
    }
}
