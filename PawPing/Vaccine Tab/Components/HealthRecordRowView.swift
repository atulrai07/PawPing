//
//  HealthRecordRowView.swift
//  PawPing
//
//  Created by Atul on 16/03/26.
//  Updated for Health system on 27/04/26.
//

import SwiftUI

struct HealthRecordRowView: View {
    let record: HealthRecord
    var onMarkDone: (() -> Void)? = nil
    
    var body: some View {
        HStack(spacing: 14) {
            // Icon
            ZStack {
                Circle()
                    .fill(record.recordType == .vaccine ? Color.blue.opacity(0.1) : Color.orange.opacity(0.1))
                    .frame(width: 44, height: 44)
                
                Image(systemName: record.recordType == .vaccine ? "syringe.fill" : "pills.fill")
                    .font(.system(size: 18))
                    .foregroundStyle(record.recordType == .vaccine ? .blue : .orange)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(record.name)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.primary)
                
                if let nextDose = record.formattedNextDoseDate {
                    Text("Next: \(nextDose)")
                        .font(.system(size: 12))
                        .foregroundStyle(record.status == .overdue ? .red : .secondary)
                }
            }
            
            Spacer()
            
            HStack(spacing: 12) {
                if record.status != .done, let onMarkDone {
                    Button {
                        onMarkDone()
                    } label: {
                        Text("Done")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.pawPrimary)
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                } else {
                    VStack(alignment: .trailing, spacing: 4) {
                        Text(record.formattedDateGiven)
                            .font(.system(size: 13))
                            .foregroundStyle(.secondary)
                        
                        if record.status == .done {
                            Text("Completed")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundStyle(.green)
                        }
                    }
                }
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.secondary.opacity(0.5))
            }
        }
        .padding(.vertical, 10)
    }
}
