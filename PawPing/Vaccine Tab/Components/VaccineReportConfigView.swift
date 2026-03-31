//
//  VaccineReportConfigView.swift
//  PawPing
//
//  Created by Atul on 01/04/26.
//

import SwiftUI

struct VaccineReportConfigView: View {
    @Environment(ActivityStore.self) var activityStore
    @Environment(VaccineStore.self) var vaccineStore
    
    @State private var config = VaccineReportConfig.defaultConfig
    @State private var showingPreview = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                
                // MARK: Dog Profile Card
                dogProfileCard
                    .padding(.top, 10)
                
                // MARK: Toggles
                Text("Report Configuration")
                    .font(.system(size: 18, weight: .bold))
                    .padding(.horizontal, 4)
                    .padding(.top, 8)
                VStack(spacing: 0) {
                    Toggle("Include Clinic Contact info", isOn: $config.includeClinicContactInfo)
                        .padding(.vertical, 12)
                    
                    Divider()
                    
                    Toggle("Include Missed Alerts", isOn: $config.includeMissedAlerts)
                        .padding(.vertical, 12)
                    
                    Divider()
                    
                    Toggle("Include app Watermark", isOn: $config.includeAppWatermark)
                        .padding(.vertical, 12)
                }
                .padding(.horizontal, 16)
                .background(RoundedRectangle(cornerRadius: 16).fill(Color("cardBackground")))
                .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
                .tint(.green)
                
                // MARK: Next Button
                Button {
                    showingPreview = true
                } label: {
                        Text("Report Preview")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            Capsule()
                                .fill(Color("baseColor"))
                                .shadow(color: Color("baseColor").opacity(0.3), radius: 8, x: 0, y: 4)
                        )
                }
                .padding(.top, 16)
            }
            .padding(.horizontal, 16)
        }
        .background(Color("baseBackground"))
        .navigationTitle("Vaccine Report")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $showingPreview) {
            VaccineReportPreviewView(config: config)
                .environment(activityStore)
                .environment(vaccineStore)
        }
    }
    
    // MARK: - Subviews
    
    private var dogProfileCard: some View {
        HStack(spacing: 16) {
            Image(activityStore.dogProfile.dogImage)
                .resizable()
                .scaledToFill()
                .frame(width: 70, height: 70)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(activityStore.dogProfile.dogName)
                    .font(.system(size: 16, weight: .bold))
                
                Text("Breed : \(activityStore.dogProfile.breed)")
                    .font(.system(size: 14))
                
                Text("Age : \(activityStore.dogProfile.age) yrs 2 months")
                    .font(.system(size: 14))
                
                Text("Owner : Rahul Kumar")
                    .font(.system(size: 14))
            }
            .foregroundStyle(.primary)
            
            Spacer()
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 16).fill(Color("cardBackground")))
        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
    }
}

#Preview {
    NavigationStack {
        VaccineReportConfigView()
            .environment(ActivityStore())
            .environment(VaccineStore())
    }
}
