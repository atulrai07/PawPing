//
//  EmergencyDetailView.swift
//  PawPing
//

import SwiftUI

struct EmergencyDetailView: View {
    let guide: EmergencyGuide
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header Panel
                VStack(spacing: 16) {
                    Circle()
                        .fill(guide.color.opacity(0.12))
                        .frame(width: 80, height: 80)
                        .overlay(
                            Image(systemName: guide.icon)
                                .font(.system(size: 36, weight: .bold))
                                .foregroundStyle(guide.color)
                        )
                    
                    Text(guide.title)
                        .font(.system(size: 28, weight: .bold))
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 16)
                
                // Video Tutorial Panel
                if let videoID = guide.videoID {
                    VStack(alignment: .leading, spacing: 14) {
                        HStack(spacing: 8) {
                            Text("VIDEO TUTORIAL")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(.secondary)
                                .tracking(1)
                        }
                        .padding(.horizontal, 4)
                        
                        VideoTutorialCard(
                            videoID: videoID,
                            title: guide.title,
                            accentColor: guide.color
                        )
                    }
                    .padding(.horizontal)
                }
                
                // Symptoms / Identification Check
                VStack(alignment: .leading, spacing: 14) {
                    HStack(spacing: 8) {
                        Text("HOW TO IDENTIFY")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(.secondary)
                            .tracking(1)
                    }
                    .padding(.horizontal, 4)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(guide.symptoms, id: \.self) { symptom in
                            HStack(alignment: .top, spacing: 10) {
                                Text(symptom)
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundStyle(.primary)
                            }
                        }
                    }
                    .padding(18)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color("cardBackground"))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .padding(.horizontal)
                
                // Action Steps Flow
                VStack(alignment: .leading, spacing: 14) {
                    HStack(spacing: 8) {
                        Text("SOP ACTION STEPS")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(.secondary)
                            .tracking(1)
                    }
                    .padding(.horizontal, 4)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        ForEach(0..<guide.steps.count, id: \.self) { index in
                            HStack(alignment: .top, spacing: 14) {
                                Circle()
                                    .fill(guide.color)
                                    .frame(width: 28, height: 28)
                                    .overlay(
                                        Text("\(index + 1)")
                                            .font(.system(size: 14, weight: .bold))
                                            .foregroundStyle(.white)
                                    )
                                
                                Text(guide.steps[index])
                                    .font(.system(size: 15))
                                    .foregroundStyle(.primary)
                                    .lineSpacing(4)
                            }
                            
                            if index < guide.steps.count - 1 {
                                Divider()
                                    .padding(.leading, 42)
                            }
                        }
                    }
                    .padding(20)
                    .background(Color("cardBackground"))
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                }
                .padding(.horizontal)
                

                
                Spacer(minLength: 40)
            }
        }
        .background(Color("baseBackground"))
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        EmergencyDetailView(guide: EmergencyStaticData.guides[0])
    }
}
