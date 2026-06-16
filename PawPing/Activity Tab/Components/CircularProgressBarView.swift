//
//  CircularProgressBarView.swift
//  PawPing
//
//  Created by Atul on 01/02/26.
//
//

import SwiftUI

struct CircularProgressView: View {
    var progress: Double   // 0.0 to 1.0 (from WalkActivity.progress)
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color("baseColor").opacity(0.2), lineWidth: 15)
            
            Circle()
                .trim(from: 0.0, to: progress)
                .stroke(
                    Color("baseColor"),
                    style: StrokeStyle(lineWidth: 15, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeOut, value: progress)
        }
    }
}

#Preview {
    CircularProgressView(progress: 0.38)
}
