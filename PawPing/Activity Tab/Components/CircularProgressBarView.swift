//
//  CircularProgressBarView.swift
//  PawPing
//
//  Created by Atul on 01/02/26.
//
//  A simple circular progress ring — pass in a 0.0 to 1.0 value
//  and it draws a rounded stroke around a circle. Used on the
//  Activity tab to show daily walk progress.
//

import SwiftUI

struct CircularProgressView: View {
    var progress: Double   // 0.0 to 1.0 (from WalkActivity.progress)
    
    var body: some View {
        ZStack {
            // Background track ring (faint blue)
            Circle()
                .stroke(Color.pawPrimary.opacity(0.2), lineWidth: 15)
            
            // Progress arc — .trim clips the stroke to the progress %
            Circle()
                .trim(from: 0.0, to: progress)
                .stroke(
                    Color.pawPrimary,
                    style: StrokeStyle(lineWidth: 15, lineCap: .round)
                )
                .rotationEffect(.degrees(-90)) // start from 12 o'clock position
                .animation(.easeOut, value: progress)
        } // ZStack — progress ring
    }
} // CircularProgressView

#Preview {
    CircularProgressView(progress: 23.0)
}
