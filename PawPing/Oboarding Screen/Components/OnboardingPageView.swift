//
//  OnboardingPageView.swift
//  PawPing
//
//  Created by Shailesh on 24/03/26.
//

import SwiftUI

struct OnboardingPageView: View {
    @Binding var currentPage: Int
    let items: [OnboardingItem]
    let onGetStarted: () -> Void
    
    // Computed property for the current item to keep the body clean
    private var currentItem: OnboardingItem {
        items[currentPage]
    }
    
    // Checks if we are on the very last screen
    private var isLastPage: Bool {
        currentPage == items.count - 1
    }
    
    var body: some View {
        // GeometryReader helps us calculate sizes relative to the screen height
        GeometryReader { geo in
            let screenHeight = geo.size.height + geo.safeAreaInsets.bottom + geo.safeAreaInsets.top
            let dynamicCardHeight = screenHeight * OnboardingLayout.cardHeightMultiplier
            
            VStack(spacing: 0) {
                // 1. TOP SECTION: Background and Dog Illustrations
                ZStack(alignment: .top) {
                    OnboardingLayout.backgroundColor
                        .ignoresSafeArea()
                    
                    VStack(spacing: 0) {
                        // Skip Button: Stays fixed at the top right
                        HStack {
                            Spacer()
                            if !isLastPage {
                                Button(action: {
                                    withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                                        currentPage = items.count - 1
                                    }
                                }) {
                                    Text("Skip")
                                        .font(.system(size: 17, weight: .regular))
                                        .foregroundColor(.black.opacity(0.45))
                                }
                            } else {
                                // Empty placeholder to maintain spacing on the last page
                                Text("Skip").foregroundColor(.clear)
                            }
                        }
                        .padding(.horizontal, 28)
                        .padding(.top, 20)
                        
                        Spacer()
                        
                        // Animated Images: Change based on currentPage
                        ZStack(alignment: .bottom) {
                            // Background line/ribbon
                            Image(currentItem.lineImage)
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: .infinity)
                                .padding(.bottom, 30)
                                .transition(.opacity.combined(with: .scale(scale: 0.95)))
                                .id("line-\(currentPage)")
                            
                            // Main Dog Image
                            Image(currentItem.dogImage)
                                .resizable()
                                .scaledToFit()
                            // Proportional horizontal padding
                                .padding(.horizontal, currentPage == 1 ? 30 : 50)
                                .transition(.asymmetric(
                                    insertion: .move(edge: .trailing).combined(with: .opacity),
                                    removal: .move(edge: .leading).combined(with: .opacity)
                                ))
                                .id("dog-\(currentPage)")
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                // 2. BOTTOM CARD SECTION: White rounded card with text and buttons
                VStack(spacing: 0) {
                    // Progress dots
                    PageIndicator(total: items.count, current: currentPage)
                        .padding(.top, 24)
                        .padding(.bottom, 16)
                    VStack(spacing: 8) {
                        Text(currentItem.title)
                            .font(.system(size: 30, weight: .bold))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                            .transition(.opacity)
                            .id("title-\(currentPage)")
                        
                        Text(currentItem.description)
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(.black.opacity(0.55))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                            .transition(.opacity)
                            .id("desc-\(currentPage)")
                    }
                    
                    Spacer()
                    
                    // Main Action Button (Next / Get Started)
                    PrimaryButton(
                        title: isLastPage ? "Get Started" : "Next",
                        action: {
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                                if !isLastPage {
                                    currentPage += 1
                                } else {
                                    onGetStarted()
                                }
                            }
                        }
                    )
                    .padding(.bottom, 42)
                }
                .frame(maxWidth: .infinity)
                .frame(height: dynamicCardHeight)
                .background(
                    // White card with rounded top corners
                    UnevenRoundedRectangle(topLeadingRadius: OnboardingLayout.cardCornerRadius,
                                           topTrailingRadius: OnboardingLayout.cardCornerRadius)
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.06), radius: 10, y: -4)
                    .ignoresSafeArea(edges: .bottom)
                )
            }
        }
        .ignoresSafeArea(edges: .bottom)
        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: currentPage)
    }
}

