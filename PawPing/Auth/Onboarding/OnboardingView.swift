import SwiftUI

struct OnboardingView: View {
    var onCompletion: () -> Void
    @State private var currentPage = 0
    @State private var isMovingForward = true
    let items = onboardingData

    var body: some View {
        OnboardingPageView(
            currentPage: $currentPage,
            isMovingForward: $isMovingForward,
            items: items,
            onGetStarted: {
                onCompletion()
            }
        )
        .background(OnboardingLayout.backgroundColor)
        .gesture(
            DragGesture()
                .onEnded { value in
                    let threshold: CGFloat = 50
                    if value.translation.width < -threshold {
                        // Swiped Left -> Go to next page
                        if currentPage < items.count - 1 {
                            isMovingForward = true
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                                currentPage += 1
                            }
                        }
                    } else if value.translation.width > threshold {
                        // Swiped Right -> Go to previous page
                        if currentPage > 0 {
                            isMovingForward = false
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                                currentPage -= 1
                            }
                        }
                    }
                }
        )
    }
}

#Preview {
    OnboardingView(onCompletion: {})
}
