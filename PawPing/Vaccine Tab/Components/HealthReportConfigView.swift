//
//  HealthReportConfigView.swift
//  PawPing
//
//  Created by Atul on 01/04/26.
//  Updated for Health system on 28/04/26.
//

import SwiftUI

struct HealthReportConfigView: View {
    @Environment(PetStore.self) var petStore
    @Environment(HealthStore.self) var healthStore
    
    @State private var config = HealthReportConfig()
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
                    Toggle("Include Vaccinations", isOn: $config.includeVaccinations)
                        .padding(.vertical, 12)
                    
                    Divider()
                    
                    Toggle("Include Deworming", isOn: $config.includeDeworming)
                        .padding(.vertical, 12)
                    
                    Divider()
                    
                    Toggle("Include Medications", isOn: $config.includeMedications)
                        .padding(.vertical, 12)
                    
                    Divider()
                    
                    Toggle("Include Weight History", isOn: $config.includeWeightChart)
                        .padding(.vertical, 12)
                }
                .padding(.horizontal, 16)
                .background(RoundedRectangle(cornerRadius: 16).fill(Color("cardBackground")))
                .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
                .tint(Color("baseColor"))
                
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
        .navigationTitle("Health Report")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $showingPreview) {
            if let pet = petStore.activePet {
                HealthReportPreviewView(pet: pet, config: config)
            }
        }
    }
    
    // MARK: - Subviews
    
    private var dogProfileCard: some View {
        HStack(spacing: 16) {
            if let urlString = petStore.activePet?.profileImageUrl, let url = URL(string: urlString) {
                AsyncImage(url: url) { image in
                    image.resizable().scaledToFill()
                } placeholder: {
                    ProgressView()
                }
                .frame(width: 70, height: 70)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            } else {
                Image(petStore.activePet?.imageName ?? Pet.defaultImageName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 70, height: 70)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(petStore.activePet?.name ?? "Pet")
                    .font(.system(size: 16, weight: .bold))
                
                Text("Breed : \(petStore.activePet?.breed ?? "—")")
                    .font(.system(size: 14))
                
                Text("Age : \(petStore.activePet?.age ?? "?")")
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
