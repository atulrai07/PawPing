import SwiftUI

struct SplashView: View {
    @Binding var showSplash: Bool
    
    var body: some View {
        ZStack {
            OnboardingLayout.backgroundColor
                .ignoresSafeArea()
            
            // Top Right Corner
            VStack {
                HStack {
                    Spacer()
                    Image("Top")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 180)
                        .padding(.top, 30)
                        .offset(x: 30) // Offset trailing by -30 (moving right)
                }
                Spacer()
            }
            .ignoresSafeArea()
            
            // Bottom Left Corner
            VStack {
                Spacer()
                HStack {
                    Image("Down")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 220)
                        .padding(.bottom, 30)
                        .offset(x: -30) // Offset leading by -30 (moving left)
                    Spacer()
                }
            }
            .ignoresSafeArea()
            
            // Center Logo
            Image("pawping (1)")
                .resizable()
                .scaledToFit()
                .frame(width: 320)
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                withAnimation(.easeInOut(duration: 1)) {
                    showSplash = false
                }
            }
        }
    }
}

#Preview {
    SplashView(showSplash: .constant(true))
}
