//
//  MythDetailView.swift
//  PawPing
//

import SwiftUI

struct MythDetailView: View {
    let myth: CareMyth
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header (Severity Label)
                HStack {
                    Text(myth.severity.rawValue)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(myth.severity.color)
                        .clipShape(Capsule())
                    
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top, 16)
                
                // Myth Card
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 8) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 20))
                            .foregroundStyle(.red)
                        Text("The Common Myth")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(.red)
                            .tracking(1)
                    }
                    
                    Text(myth.myth)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(.primary)
                }
                .padding(20)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.red.opacity(0.06))
                .clipShape(RoundedRectangle(cornerRadius: 18))
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(Color.red.opacity(0.15), lineWidth: 1)
                )
                .padding(.horizontal)
                
                // Fact Card
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 20))
                            .foregroundStyle(.green)
                        Text("VETERINARY FACT")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(.green)
                            .tracking(1)
                    }
                    
                    Text(myth.fact)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(.primary)
                }
                .padding(20)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.green.opacity(0.06))
                .clipShape(RoundedRectangle(cornerRadius: 18))
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(Color.green.opacity(0.15), lineWidth: 1)
                )
                .padding(.horizontal)
                
                // Veterinary Explanation Card
                VStack(alignment: .leading, spacing: 14) {
                    HStack(spacing: 8) {
                        Image(systemName: "info.circle.fill")
                            .font(.system(size: 16))
                            .foregroundStyle(Color("baseColor"))
                        Text("Why This Matters")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(.secondary)
                            .tracking(1)
                    }
                    
                    Text(myth.explanation)
                        .font(.system(size: 15))
                        .foregroundStyle(.primary)
                        .lineSpacing(6)
                }
                .padding(20)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color("cardBackground"))
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .padding(.horizontal)
                
                Spacer(minLength: 40)
            }
        }
        .background(Color("baseBackground"))
        .navigationTitle("Myth Buster")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        MythDetailView(myth: EmergencyStaticData.myths[0])
    }
}
