//
//  CircularProgressBarView.swift
//  PawPing
//
//  Created by Atul on 01/02/26.
//

import SwiftUI

struct CircularProgressView: View {
    var progress: Double
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color("baseRed").opacity(0.2), lineWidth: 15)
            
            Circle()
                .trim(from: 0.0, to: progress)
                .stroke(
                    Color("baseRed"),
                    style: StrokeStyle(lineWidth: 15, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeOut, value: progress)
        }
    }
}
#Preview {
    CircularProgressView(progress: 23.0)
}
