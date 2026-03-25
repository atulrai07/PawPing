//
//  DoneVaccineRowView.swift
//  PawPing
//
//  Created by Atul on 15/03/26.
//
//  A row for a completed vaccine — shows the vaccine name, date taken,
//  clinic info, and action buttons (Call / Navigate).
//

import SwiftUI

struct DoneVaccineRowView: View {
    let record: VaccineRecord
    
    var body: some View {
        HStack(alignment: .center) {
            // Vaccine Info
            VStack(alignment: .leading, spacing: 4) {
                Text(record.displayName)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.pawSecondary)
                
                Text("Last Taken : \(record.formattedDateGiven)")
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
                
                if let clinic = record.clinicInfo {
                    Text("Clinic: \(clinic.clinicName)")
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
            
            // Action Buttons
            HStack(spacing: 8) {
                if let clinic = record.clinicInfo, clinic.phoneNumber != nil {
                    Button {
                        print("Calling \(clinic.clinicName)")
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "phone.fill")
                                .font(.system(size: 10))
                            Text("Call")
                                .font(.system(size: 12, weight: .semibold))
                        }
                        .foregroundStyle(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.pawPrimary)
                        .clipShape(Capsule())
                    }
                }
                
                Button {
                    print("Navigate to clinic")
                } label: {
                    Image(systemName: "arrow.triangle.turn.up.right.diamond.fill")
                        .font(.system(size: 14))
                        .foregroundStyle(.pawSecondary)
                }
            }
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    DoneVaccineRowView(record: VaccineStore().vaccineRecords[3])
        .padding()
        .background(Color.pawNeutral)
}
