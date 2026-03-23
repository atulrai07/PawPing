//
//  ExportPassportButton.swift
//  PawPing
//

import SwiftUI

struct ExportPassportButton: View {
    var onExport: () -> Void = {}
    
    var body: some View {
        Button {
            onExport()
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "arrow.down.to.line")
                    .font(.system(size: 16, weight: .semibold))
                
                Text("Export Vaccine Report")
                    .font(.system(size: 16, weight: .semibold))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(Color.pawPrimary)   // ✅ kept original
            .clipShape(Capsule())
        }
    }
}

#Preview {
    ExportPassportButton()
        .padding()
        .background(Color.pawNeutral)
}
