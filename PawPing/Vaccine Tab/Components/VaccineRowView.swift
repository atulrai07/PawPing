//
//  VaccineRowView.swift
//  PawPing
//
//  Created by Atul on 15/03/26.
//
//  A single row for an upcoming or overdue vaccine.
//  Shows the vaccine name, time remaining, last taken date, and a "Mark as Done" button.
//

import SwiftUI

struct VaccineRowView: View {
    let record: VaccineRecord
    var onMarkAsDone: () -> Void = {}
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(record.displayName)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.pawSecondary)
                
                Spacer()
                
                Text(record.timeRemainingText)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(record.status == .overdue ? .red : .pawPrimary)
            }
            
            HStack {
                Text("Last Taken : \(record.formattedDateGiven)")
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                Button {
                    onMarkAsDone()
                } label: {
                    Text("Mark as Done")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(.pawPrimary)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(
                            Capsule()
                                .stroke(Color.pawPrimary, lineWidth: 1.2)
                        )
                }
            }
        }
        .padding(.vertical, 10)
    }
}

#Preview {
    let store = VaccineStore()
    VStack {
        VaccineRowView(record: store.vaccineRecords[0])
        Divider()
        VaccineRowView(record: store.vaccineRecords[1])
    }
    .padding()
    .background(Color.pawNeutral)
}
