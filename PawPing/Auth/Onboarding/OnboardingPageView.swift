//
//  OnboardingPageView.swift
//  PawPing
//
//  Created by Atul on 28/04/26.
//

import SwiftUI

struct OnboardingPageView: View {
    @Binding var currentPage: Int
    let items: [OnboardingItem]
    var onGetStarted: () -> Void
    
    var body: some View {
        ZStack {
            // Background Elements (Paws)
            if currentPage == 0 {
                VStack {
                    HStack {
                        Spacer()
                        Image("topPawFirstScreenOnboarding")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 150)
                            .padding(.trailing, -20)
                            .padding(.top, 40)
                    }
                    .ignoresSafeArea()
                    Spacer()
                        
                }
                .ignoresSafeArea()
            }
            
            VStack(spacing: 0) {
                // Top Bar
                HStack {
                    Spacer()
                    Button("Skip") {
                        onGetStarted()
                    }
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(.secondary)
                    .padding()
                }
                
                // Image Area
                ZStack {
                    // Line Asset
                    if !items[currentPage].lineImage.isEmpty {
                        Image(items[currentPage].lineImage)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 320)
                            .offset(y: 40)
                    }
                    
                    // Dog Asset
                    Image(items[currentPage].dogImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 300)
                        .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
                        .id(items[currentPage].dogImage)
                }
                .frame(maxHeight: .infinity)
                .offset(y: -20)
                
                // Content Card
                VStack(spacing: 0) {
                    // Page Indicator (at the top of the card)
                    HStack(spacing: 8) {
                        ForEach(0..<items.count, id: \.self) { index in
                            Circle()
                                .fill(currentPage == index ? OnboardingLayout.primaryColor : Color.gray.opacity(0.3))
                                .frame(width: 8, height: 8)
                        }
                    }
                    .padding(.top, 30)
                    
                    VStack(spacing: 24) {
                        Text(items[currentPage].title)
                            .font(.system(size: 34, weight: .bold, design: .rounded))
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.primary)
                        
                        Text(items[currentPage].description)
                            .font(.system(size: 18, weight: .regular, design: .rounded))
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.primary)
                            .padding(.horizontal, 40)
                            .lineSpacing(4)
                    }
                    .padding(.top, 60)
                    
                    Spacer(minLength: 40)
                    
                    // Next Button (Full Width)
                    Button {
                        if currentPage < items.count - 1 {
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                                currentPage += 1
                            }
                        } else {
                            onGetStarted()
                        }
                    } label: {
                        Text(currentPage == items.count - 1 ? "Get Started" : "Next")
                            .font(.system(size: 18, weight: .bold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(OnboardingLayout.primaryColor)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 25))
                    }
                    .padding(.horizontal, 30)
                    .padding(.bottom, 40)
                }
                .frame(maxWidth: .infinity)
                .background(
                    Color(uiColor: .systemBackground)
                        .clipShape(CustomCorner(corners: [.topLeft, .topRight], radius: 40))
                        .shadow(color: .black.opacity(0.05), radius: 10, y: -5)
                )
            }
        }
    }
}

// Helper for rounded corners
struct CustomCorner: Shape {
    var corners: UIRectCorner
    var radius: CGFloat
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}
#Preview {
    OnboardingPageView(
        currentPage: .constant(0),
        items: onboardingData,
        onGetStarted: {}
    )
}
