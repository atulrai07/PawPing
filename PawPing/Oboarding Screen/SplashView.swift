//
//  SplashView.swift
//  PawPing
//
//  Created by Shailesh on 24/03/26.
//

import SwiftUI

struct SplashView: View {
    @Binding var showSplash: Bool
    
    var body: some View {
        ZStack {
            // Background
            Color("baseBackground").ignoresSafeArea()
            
            // Top Right Paw
            VStack {
                HStack {
                    Spacer()
                    Image("Top")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 180)
                        .padding(.top, 30)
                        .padding(.trailing, -30)
                }
                Spacer()
            }
            .ignoresSafeArea()
            
            // Bottom Left Paw
            VStack {
                Spacer()
                HStack {
                    Image("Down")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 220)
                        .padding(.bottom, -30)
                        .padding(.leading, -30)
                    Spacer()
                }
            }
            .ignoresSafeArea()
            
            // Main Logo
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
