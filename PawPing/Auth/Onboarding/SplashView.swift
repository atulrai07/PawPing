import SwiftUI

struct SplashView: View {
    @Binding var showSplash: Bool
    
    var body: some View {
        ZStack {
            Color("baseBackground")
                .ignoresSafeArea()
            
            // Top Right Corner Watermark
            VStack {
                HStack {
                    Spacer()
                    Image("topPawFirstScreenOnboarding")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 280)
                        .colorMultiply(Color("baseColor"))
                        .opacity(0.8) // Clear watermark style
                        .offset(x: 20, y: -20)
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
                        .colorMultiply(Color("baseColor"))
                        .opacity(0.8) // Clear watermark style
                        .offset(x: -90, y: 60)
                    Spacer()
                }
            }
            .ignoresSafeArea()
            
            // Center Logo
            Image("Pawping_logo")
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .frame(width: 260)
                .foregroundStyle(Color("baseColor"))
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
