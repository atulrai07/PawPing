//
//  HealthReportPreviewView.swift
//  PawPing
//
//  Created by Atul on 01/04/26.
//  Updated for Health system on 27/04/26.
//

import SwiftUI

struct HealthReportPreviewView: View {
    @Environment(PetStore.self) var petStore
    @Environment(HealthStore.self) var healthStore
    
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
                    
                    Text("Health Report")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(.primary)
                    
                    Text("Generated on \(Date().formatted(date: .abbreviated, time: .omitted))")
                        .font(.system(size: 14))
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 16)
                
                // MARK: Dog Profile
                dogProfileCard
                
                // MARK: Health Records
                VStack(alignment: .leading, spacing: 10) {
                    Text("Medical Records")
                        .font(.system(size: 16, weight: .bold))
                        .padding(.horizontal, 4)
                    
                    VStack(spacing: 0) {
                        // Header
                        HStack {
                            Text("Treatment")
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
                            healthRow(record)
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
                   let clinicRecord = healthStore.healthRecords.first(where: { $0.vetName != nil }) {
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Vet Clinic Details")
                            .font(.system(size: 16, weight: .bold))
                            .padding(.horizontal, 4)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            clinicRow(clinicRecord.vetName ?? "Unknown Clinic")
                            Divider()
                            if let add = clinicRecord.vetAddress {
                                clinicRow("Address: \(add)")
                                Divider()
                            }
                            if let phone = clinicRecord.vetPhone {
                                clinicRow("Phone: \(phone)")
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
            Image(petStore.activePet?.imageName ?? Pet.defaultImageName)
                .resizable()
                .scaledToFill()
                .frame(width: 70, height: 70)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(petStore.activePet?.name ?? "Pet")
                    .font(.system(size: 16, weight: .bold))
                
                Text("Breed : \(petStore.activePet?.breed ?? "—")")
                    .font(.system(size: 14))
                
                Text("Age : \(petStore.activePet?.age ?? "?") yrs")
                    .font(.system(size: 14))
                
                Text("Owner : \(petStore.currentUserProfile?.name ?? "Owner")")
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
    
    private func filteredRecords() -> [HealthRecord] {
        if config.includeMissedAlerts {
            return healthStore.healthRecords.filter { $0.status == .done || $0.status == .overdue }
        } else {
            return healthStore.healthRecords.filter { $0.status == .done }
        }
    }
    
    private func healthRow(_ record: HealthRecord) -> some View {
        HStack {
            Text(record.name)
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
