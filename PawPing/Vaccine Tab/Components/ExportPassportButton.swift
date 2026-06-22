//
//  ExportPassportButton.swift
//  PawPing
//
//  Created by Atul on 15/03/26.
//

import SwiftUI

struct ExportPassportButton: View {
    var onExport: () -> Void = {}
    
    var body: some View {
        Button {
            onExport()
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "doc.text.below.ecg.fill")
                    .font(.system(size: 16, weight: .bold))
                
                Text("Export Health Report")
                    .font(.system(size: 16, weight: .bold))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                LinearGradient(
                    colors: [Color(hex: "6E54D7") ?? .purple, Color(hex: "8F7CEF") ?? .purple],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(color: (Color(hex: "6E54D7") ?? .purple).opacity(0.3), radius: 8, x: 0, y: 4)
        }
    }
}

#Preview {
    ExportPassportButton()
        .padding()
        .background(Color("baseBackground"))
}
