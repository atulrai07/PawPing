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
                // Emergency Intro Banner (contains the SF Symbol decoratively)
                HStack(spacing: 16) {
                    Image(systemName: guide.icon)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(guide.color)
                        .frame(width: 52, height: 52)
                        .background(guide.color.opacity(0.12))
                        .clipShape(Circle())
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Emergency Protocol")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(guide.color)
                        Text("Follow the steps below to assist your pet.")
                            .font(.system(size: 13))
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                }
                .padding(16)
                .background(guide.color.opacity(0.04))
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .padding(.horizontal)
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
                    .background(Color.cardIvory)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 4)
                }
                .padding(.horizontal)
                .padding(.top, guide.videoID == nil ? 0 : 0)
                
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
                    .background(Color.cardIvory)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 4)
                }
                .padding(.horizontal)
                

                
                Spacer(minLength: 40)
            }
        }
        .background(Color("baseBackground"))
        .navigationTitle(guide.title)
        .navigationBarTitleDisplayMode(.large)
    }
}

#Preview {
    NavigationStack {
        EmergencyDetailView(guide: EmergencyStaticData.guides[0])
    }
}
