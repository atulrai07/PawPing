//
//  VaccineCardView.swift
//  PawPing
//
//  Created by Atul on 01/04/26.
//

import SwiftUI

struct VaccineCardView: View {
    @Environment(HealthStore.self) var healthStore
    
    private var nearestVaccine: HealthRecord? {
        healthStore.healthRecords
            .filter { $0.nextDoseDate != nil }
            .sorted { ($0.nextDoseDate ?? Date()) < ($1.nextDoseDate ?? Date()) }
            .first
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 28)
                .fill(Color("cardBackground"))
                .frame(width: 175, height: 190)
            
            VStack(alignment: .leading) {
                HStack {
                    Text("Upcoming")
                        .font(.system(size: 22, weight: .regular))
                    
                    Spacer()
                }
                .padding(.trailing, 4) 
                
                Spacer()
                
                Image(systemName: "syringe")
                    .foregroundStyle(Color("baseColor"))
                    .rotationEffect(.degrees(270))
                    .font(.system(size: 65))
                
                Spacer()
                
                VStack(alignment: .leading, spacing: 2) {
                    if let vaccine = nearestVaccine {
                        Text(vaccine.name)
                            .font(.system(size: 18, weight: .medium))
                            .lineLimit(1)
                        
                        Text(vaccine.timeRemainingText)
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(Color("secondaryText"))
                    } else {
                        Text("No vaccine")
                            .font(.system(size: 18, weight: .medium))
                        
                        Text("All up to date")
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
    VaccineCardView()
        .environment(HealthStore())
}
