//
//  CustomNavigationScroll.swift
//  PawPing
//

import SwiftUI

// MARK: - StickyNavHeader

private struct StickyNavHeader: View {

    let title: String
    var profileImage: String?
    var onProfileTap: (() -> Void)?
    let isCollapsed: Bool

    var body: some View {
        ZStack {

            // Profile Avatar
            if let img = profileImage {
                HStack {
                    Spacer()
                    Button {
                        onProfileTap?()
                    } label: {
                        Circle()
                            .fill(.gray.opacity(0.2))
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

            // Large title
            Text(title)
                .font(.system(size: 34, weight: .bold))
                .foregroundStyle(.pawSecondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .opacity(isCollapsed ? 0 : 1)
                .scaleEffect(isCollapsed ? 0.9 : 1.0, anchor: .leading)

            // Small title
            Text(title)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(.pawSecondary)
                .frame(maxWidth: .infinity, alignment: .center)
                .opacity(isCollapsed ? 1 : 0)
        }
        .padding(.horizontal, 16)
        .padding(.top, isCollapsed ? -8 : 8)
        .padding(.bottom, isCollapsed ? 12 : 6)

        // Background
        .background {
            Rectangle()
                .fill(Color.pawBackground)
                .opacity(isCollapsed ? 1 : 0.8)
                .mask {
                    LinearGradient(
                        stops: [
                            .init(color: .black, location: 0.0),
                            .init(color: .black.opacity(0.8), location: 0.7),
                            .init(color: .clear, location: 1.0),
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                }
                .ignoresSafeArea(edges: .top)
        }

        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(.pawPrimary)
                .frame(height: 0.5)
                .opacity(0)
        }

        .animation(.spring(response: 0.15, dampingFraction: 0.9), value: isCollapsed)
    }
}

// MARK: - Modifier

private struct CustomNavigationScrollModifier: ViewModifier {
    let title: String
    var profileImage: String?
    var onProfileTap: (() -> Void)?
    var collapseThreshold: CGFloat

    @State private var scrollOffset: CGFloat = 0
    @State private var isCollapsed = false

    func body(content: Content) -> some View {
        ScrollView(showsIndicators: false) {
            content
                .background(
                    GeometryReader { geo in
                        let minY = geo.frame(in: .named("_customNavScroll")).minY
                        Color.clear
                            .onChange(of: minY) { _, newVal in
                                scrollOffset = max(0, -newVal)
                                isCollapsed = scrollOffset > collapseThreshold
                            }
                            .onAppear {
                                scrollOffset = max(0, -minY)
                                isCollapsed = scrollOffset > collapseThreshold
                            }
                    }
                )
        }
        .coordinateSpace(name: "_customNavScroll")
        .background(Color.pawBackground)
        .toolbar(.hidden, for: .navigationBar)
        .safeAreaInset(edge: .top, spacing: 0) {
            StickyNavHeader(
                title: title,
                profileImage: profileImage,
                onProfileTap: onProfileTap,
                isCollapsed: isCollapsed
            )
        }
    }
}

// MARK: - Extension

extension View {

    func customNavigationScroll(
        title: String,
        profileImage: String? = nil,
        onProfileTap: (() -> Void)? = nil,
        collapseThreshold: CGFloat = 50
    ) -> some View {
        modifier(CustomNavigationScrollModifier(
            title: title,
            profileImage: profileImage,
            onProfileTap: onProfileTap,
            collapseThreshold: collapseThreshold
        ))
    }
}
