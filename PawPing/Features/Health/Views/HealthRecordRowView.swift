//
//  HealthRecordRowView.swift
//  PawPing
//

import SwiftUI

/// A horizontal row component for displaying individual health records (Vaccines/Deworming).
/// Supports both completed history states and actionable upcoming/overdue states.
struct HealthRecordRowView: View {
    // MARK: - Properties
    let record: HealthRecord
    /// Optional action to mark an upcoming record as completed
    var onMarkDone: (() -> Void)? = nil
    
    var body: some View {
        HStack(spacing: 16) {
            // MARK: - Category Icon
            ZStack {
                Circle()
                    .fill(iconBackgroundColor)
                    .frame(width: 46, height: 46)
                
                Image(systemName: iconName)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(iconColor)
            }
            
            // MARK: - Record Info
            VStack(alignment: .leading, spacing: 4) {
                Text(record.name)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.primary)
                
                if let vet = record.vetName {
                    HStack(spacing: 4) {
                        Image(systemName: "mappin.and.ellipse")
                            .font(.system(size: 10))
                        Text(vet)
                            .lineLimit(1)
                    }
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
                }
                
                if let nextDose = record.formattedNextDoseDate {
                    HStack(spacing: 4) {
                        Image(systemName: "calendar")
                            .font(.system(size: 10))
                        Text("Next: \(nextDose)")
                    }
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(record.status == .overdue ? .red : .secondary)
                }
            }
            
            Spacer()
            
            // MARK: - Action or Status
            if record.isCompleted != true, onMarkDone != nil {
                actionButton
            } else {
                statusMetadata
            }
        }
        .padding(.vertical, 12)
        .contentShape(Rectangle()) // Makes the whole row tappable
    }

    // MARK: - View Components
    
    private var actionButton: some View {
        Button {
            onMarkDone?()
        } label: {
            Text("Done")
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color("baseColor"))
                .clipShape(Capsule())
                .shadow(color: Color("baseColor").opacity(0.3), radius: 5, x: 0, y: 3)
        }
    }
    
    private var statusMetadata: some View {
        VStack(alignment: .trailing, spacing: 4) {
            if let completedDate = record.completedDate {
                Text(completedDate, style: .date)
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
                
                HStack(spacing: 4) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 10))
                    Text("Completed")
                }
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(.green)
            } else {
                Text(record.formattedDateGiven)
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
            }
        }
    }

    // MARK: - Helpers
    
    private var iconName: String {
        record.recordType == .vaccine ? "syringe.fill" : "pills.fill"
    }
    
    private var iconColor: Color {
        record.recordType == .vaccine ? .blue : .orange
    }
    
    private var iconBackgroundColor: Color {
        iconColor.opacity(0.12)
    }
}

#Preview {
    VStack {
        HealthRecordRowView(record: HealthRecord.sampleRecords[0])
        Divider()
        HealthRecordRowView(record: HealthRecord.sampleRecords[1])
    }
    .padding()
}
