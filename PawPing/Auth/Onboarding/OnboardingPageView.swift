import SwiftUI

struct OnboardingPageView: View {
    @Binding var currentPage: Int
    let items: [OnboardingItem]
    var onGetStarted: () -> Void
    
    var body: some View {
        GeometryReader { geo in
            let safeAreaInsets = geo.safeAreaInsets
            let screenHeight = geo.size.height + safeAreaInsets.top + safeAreaInsets.bottom
            let dynamicCardHeight = screenHeight * OnboardingLayout.cardHeightMultiplier
            let currentItem = items[currentPage]
            
            VStack(spacing: 0) {
                // Top Section
                ZStack {
                    OnboardingLayout.backgroundColor
                        .ignoresSafeArea()
                    
                    VStack {
                        // Skip Button
                        HStack {
                            Spacer()
                            if currentPage < items.count - 1 {
                                Button("Skip") {
                                    withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                                        currentPage = items.count - 1
                                    }
                                }
                                .font(.system(size: 17, weight: .regular))
                                .foregroundColor(.black.opacity(0.45))
                            } else {
                                Text("Skip")
                                    .font(.system(size: 17, weight: .regular))
                                    .foregroundColor(.clear)
                            }
                        }
                        .padding(.horizontal, 28)
                        .padding(.top, 20)
                        
                        Spacer()
                        
                        // Images
                        ZStack(alignment: .bottom) {
                            Image(currentItem.lineImage)
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: .infinity)
                                .padding(.bottom, 30)
                                .transition(.opacity.combined(with: .scale(scale: 0.95)))
                                .id("line-\(currentPage)")
                            
                            Image(currentItem.dogImage)
                                .resizable()
                                .scaledToFit()
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
                
                // Bottom Card
                VStack(spacing: 0) {
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
                    
                    PrimaryButton(title: currentPage == items.count - 1 ? "Get Started" : "Next") {
                        if currentPage < items.count - 1 {
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                                currentPage += 1
                            }
                        } else {
                            onGetStarted()
                        }
                    }
                    .padding(.bottom, 42)
                }
                .frame(height: dynamicCardHeight)
                .background(
                    UnevenRoundedRectangle(topLeadingRadius: OnboardingLayout.cardCornerRadius, topTrailingRadius: OnboardingLayout.cardCornerRadius)
                        .fill(.white)
                        .shadow(color: .black.opacity(0.06), radius: 10, x: 0, y: -4)
                        .ignoresSafeArea(edges: .bottom)
                )
            }
            .animation(.spring(response: 0.5, dampingFraction: 0.8), value: currentPage)
            .ignoresSafeArea(edges: .bottom)
        }
    }
}

// MARK: - Components

struct PageIndicator: View {
    let total: Int
    let current: Int
    
    var body: some View {
        HStack(spacing: 7) {
            ForEach(0..<total, id: \.self) { index in
                Capsule()
                    .fill(current == index ? OnboardingLayout.primaryBlue : OnboardingLayout.primaryBlue.opacity(0.25))
                    .frame(width: current == index ? 22 : 8, height: 8)
            }
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.72), value: current)
    }
}

struct PrimaryButton: View {
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .fill(OnboardingLayout.primaryBlue)
                )
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 24)
    }
}
#Preview {
    OnboardingPageView(
        currentPage: .constant(0),
        items: onboardingData,
        onGetStarted: {}
    )
}
