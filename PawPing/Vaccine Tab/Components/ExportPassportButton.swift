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
            HStack(spacing: 8) {
                Image(systemName: "arrow.down.to.line")
                    .font(.system(size: 16, weight: .semibold))
                
                Text("Export Vaccine Passport (PDF)")
                    .font(.system(size: 16, weight: .semibold))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(Color("baseRed"))
            .clipShape(Capsule())
        }
    }
}

#Preview {
    ExportPassportButton()
        .padding()
        .background(Color("baseBackground"))
}
