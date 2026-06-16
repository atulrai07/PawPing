import SwiftUI

struct SplashView: View {
    @Binding var showSplash: Bool
    
    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()
            
            // Top Right Corner Watermark
            VStack {
                HStack {
                    Spacer()
                    Image("buttonPawFirstScreenOnboarding")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 280)
                        .opacity(0.4) // Subtle watermark style
                        .offset(x: 80, y: -40)
                }
                Spacer()
            }
            .ignoresSafeArea()
            
            // Bottom Left Corner Watermark
            VStack {
                Spacer()
                HStack {
                    Image("buttonPawFirstScreenOnboarding")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 300)
                        .opacity(0.4) // Subtle watermark style
                        .offset(x: -90, y: 60)
                    Spacer()
                }
            }
            .ignoresSafeArea()
            
            // Center Logo
            Image("Pawping_logo")
                .resizable()
                .scaledToFit()
                .frame(width: 260)
        }
        .task {
            try? await Task.sleep(for: .seconds(1.5))
            withAnimation(.easeInOut(duration: 0.8)) {
                showSplash = false
            }
        }
    }
}

#Preview {
    SplashView(showSplash: .constant(true))
}
