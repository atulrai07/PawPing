//
//  SymptomStickyBar.swift
//  PawPing
//
//  Created by Antigravity on 24/04/26.
//

import SwiftUI

struct SymptomStickyBar: View {
    @Environment(SymptomStore.self) var store
    let onAnalyze: () -> Void
    
    var body: some View {
        if !store.selectedSymptoms.isEmpty {
            VStack(spacing: 8) {
                if store.selectedSymptoms.contains(where: { $0.isEmergency }) {
                    HStack(spacing: 6) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundStyle(.red)
                            .font(.system(size: 12))
                        Text("Emergency symptoms detected")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(.red)
                    }
                    .padding(.top, 8)
                }
                
                HStack {
                    Text("\(store.selectedSymptoms.count) selected")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(Color("baseColor"))
                    
                    Spacer()
                    
                    Button {
                        withAnimation {
                            store.reset()
                        }
                    } label: {
                        Image(systemName: "trash")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(Color.red)
                            .padding(.trailing, 8)
                    }
                    
                    Button(action: onAnalyze) {
                        HStack(spacing: 8) {
                            Text("Analyze")
                                .font(.system(size: 15, weight: .bold))
                            Image(systemName: "arrow.right")
                                .font(.system(size: 14, weight: .bold))
                        }
                        .foregroundStyle(.white)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 20)
                        .background(
                            Capsule()
                                .fill(Color("baseColor"))
                        )
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color("cardBackground"))
                        .shadow(color: Color.black.opacity(0.1), radius: 10, y: -5)
                )
                .padding(.horizontal)
            }
            .background(Color.clear)
        }
    }
}
