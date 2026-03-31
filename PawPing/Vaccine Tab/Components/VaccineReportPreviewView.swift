//
//  VaccineReportPreviewView.swift
//  PawPing
//
//  Created by Atul on 01/04/26.
//

import SwiftUI

struct VaccineReportPreviewView: View {
    @Environment(ActivityStore.self) var activityStore
    @Environment(VaccineStore.self) var vaccineStore
    
    let config: VaccineReportConfig
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                
                // MARK: Report Header
                VStack(spacing: 8) {
                    if config.includeAppWatermark {
                        HStack(spacing: 4) {
                            Text("PawPing")
                                .font(.system(size: 32, weight: .black, design: .rounded))
                                .foregroundStyle(Color("baseColor"))
                            
                            Image(systemName: "pawprint.fill")
                                .font(.system(size: 20))
                                .foregroundStyle(Color("baseColor"))
                        }
                    }
                    
                    Text("Vaccine Report")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(.primary)
                    
                    Text("Generated on \(Date().formatted(date: .abbreviated, time: .omitted))")
                        .font(.system(size: 14))
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 16)
                
                // MARK: Dog Profile
                dogProfileCard
                
                // MARK: Vaccine Records
                VStack(alignment: .leading, spacing: 10) {
                    Text("Vaccine Records")
                        .font(.system(size: 16, weight: .bold))
                        .padding(.horizontal, 4)
                    
                    VStack(spacing: 0) {
                        // Header
                        HStack {
                            Text("Vaccine")
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Text("Date")
                                .frame(maxWidth: .infinity, alignment: .center)
                            Text("Status")
                                .frame(width: 60, alignment: .trailing)
                        }
                        .font(.system(size: 14, weight: .bold))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(Color(.systemGray5))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        
                        // Rows
                        let displayRecords = filteredRecords()
                        ForEach(Array(displayRecords.enumerated()), id: \.offset) { index, record in
                            vaccineRow(record)
                            if index < displayRecords.count - 1 {
                                Divider().padding(.leading, 16)
                            }
                        }
                    }
                    .background(Color("cardBackground"))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
                }
                
                // MARK: Vet Clinic Details
                if config.includeClinicContactInfo,
                   let clinic = vaccineStore.vaccineRecords.first(where: { $0.clinicInfo != nil })?.clinicInfo {
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Vet Clinic Details")
                            .font(.system(size: 16, weight: .bold))
                            .padding(.horizontal, 4)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            clinicRow(clinic.clinicName)
                            Divider()
                            clinicRow("Vet Name: \(clinic.vetName)")
                            Divider()
                            if let reg = clinic.registrationNumber {
                                clinicRow("Reg. No. : \(reg)")
                                Divider()
                            }
                            if let add = clinic.address {
                                clinicRow("Address: \(add)")
                                Divider()
                            }
                            if let email = clinic.email {
                                clinicRow("Email: \(email)")
                                Divider()
                            }
                            if let phone = clinic.phoneNumber {
                                clinicRow("Phone Number: \(phone)")
                            }
                        }
                        .padding(16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(RoundedRectangle(cornerRadius: 16).fill(Color("cardBackground")))
                        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
                    }
                }
                
                // MARK: Download Button
                Button {
                    print("Download PDF logic placeholder")
                } label: {
                    Text("Download Report")
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
            .padding(.bottom, 40)
        }
        .background(Color("baseBackground"))
        .navigationTitle("Report Preview")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    print("Share tapped")
                } label: {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.primary)
                }
            }
        }
    }
    
    // MARK: - Subviews & Helpers
    
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
    
    private func filteredRecords() -> [VaccineRecord] {
        if config.includeMissedAlerts {
            return vaccineStore.vaccineRecords.filter { $0.status == .done || $0.status == .overdue }
        } else {
            return vaccineStore.vaccineRecords.filter { $0.status == .done }
        }
    }
    
    private func vaccineRow(_ record: VaccineRecord) -> some View {
        HStack {
            Text(record.displayName)
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.system(size: 15))
            
            Text(record.formattedDateGiven)
                .frame(maxWidth: .infinity, alignment: .center)
                .font(.system(size: 15))
            
            Group {
                if record.status == .done {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.white, .green)
                } else if record.status == .overdue {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.white, .red)
                } else {
                    Image(systemName: "circle")
                        .foregroundStyle(.gray)
                }
            }
            .font(.system(size: 18))
            .frame(width: 60, alignment: .trailing)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }
    
    private func clinicRow(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 15))
            .foregroundStyle(.primary)
    }
}

#Preview {
    NavigationStack {
        VaccineReportPreviewView(config: VaccineReportConfig.defaultConfig)
            .environment(ActivityStore())
            .environment(VaccineStore())
    }
}
