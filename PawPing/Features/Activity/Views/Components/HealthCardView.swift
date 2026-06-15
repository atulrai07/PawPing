//
//  HealthCardView.swift
//  PawPing
//

import SwiftUI

/// A component that displays the upcoming vaccine or health task for the active pet.
struct HealthCardView: View {
    @Environment(HealthStore.self) var healthStore
    
    /// Uses the pre-computed nearest upcoming health record from the store
    private var nearestRecord: HealthRecord? {
        healthStore.nearestRecord
    }
    
    var body: some View {
        ZStack {
            // Card Background
            RoundedRectangle(cornerRadius: 28)
                .fill(Color("cardBackground"))
                .frame(width: 175, height: 190)
            
            VStack(alignment: .leading) {
                // MARK: - Header
                HStack {
                    Text("Vaccine")
                        .font(.system(size: 22, weight: .regular))
                        .foregroundStyle(.black)
                    
                    Spacer()
                }
                .padding(.trailing, 4) 
                
                Spacer()
                
                // MARK: - Status Icon
                Image(systemName: nearestRecord?.recordType == .deworming ? "pills.fill" : "heart.text.square.fill")
                    .foregroundStyle(Color("baseColor"))
                    .font(.system(size: 65))
                
                Spacer()
                
                // MARK: - Record Details
                VStack(alignment: .leading, spacing: 2) {
                    if let record = nearestRecord {
                        Text(record.name)
                            .font(.system(size: 18, weight: .medium))
                            .lineLimit(1)
                        
                        Text(record.timeRemainingText)
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(.primary.opacity(0.7))
                    } else {
                        Text("All Good")
                            .font(.system(size: 18, weight: .medium))
                        
                        Text("No upcoming tasks")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(.primary.opacity(0.7))
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
