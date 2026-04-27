//
//  HealthCardView.swift
//  PawPing
//
//  Created by Antigravity on 01/04/26.
//  Updated for Health system on 27/04/26.
//

import SwiftUI

struct HealthCardView: View {
    @Environment(HealthStore.self) var healthStore
    
    private var nearestRecord: HealthRecord? {
        healthStore.healthRecords
            .filter { $0.nextDoseDate != nil && $0.nextDoseDate! > Date() }
            .sorted { ($0.nextDoseDate ?? Date.distantFuture) < ($1.nextDoseDate ?? Date.distantFuture) }
            .first
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 28)
                .fill(Color("cardBackground"))
                .frame(width: 175, height: 190)
            
            VStack(alignment: .leading) {
                HStack {
                    Text("Health")
                        .font(.system(size: 22, weight: .regular))
                    
                    Spacer()
                }
                .padding(.trailing, 4) 
                
                Spacer()
                
                Image(systemName: nearestRecord?.recordType == .deworming ? "pills.fill" : "heart.text.square.fill")
                    .foregroundStyle(Color("baseColor"))
                    .font(.system(size: 65))
                
                Spacer()
                
                VStack(alignment: .leading, spacing: 2) {
                    if let record = nearestRecord {
                        Text(record.name)
                            .font(.system(size: 18, weight: .medium))
                            .lineLimit(1)
                        
                        Text(record.timeRemainingText)
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(Color("secondaryText"))
                    } else {
                        Text("All Good")
                            .font(.system(size: 18, weight: .medium))
                        
                        Text("No upcoming tasks")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(Color("secondaryText"))
                    }
                }
            }
            .padding(16)
            .frame(width: 175, height: 190, alignment: .leading)
        }
    }
}

#Preview {
    HealthCardView()
        .environment(HealthStore())
}
