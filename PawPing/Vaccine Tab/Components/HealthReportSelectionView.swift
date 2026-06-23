//
//  HealthReportSelectionView.swift
//  PawPing
//
//  Created by Atul on 28/04/26.
//

import SwiftUI

struct HealthReportSelectionView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(HealthStore.self) var store
    @Environment(PetStore.self) var petStore
    
    @State private var config = HealthReportConfig()
    @State private var showPreview = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Toggle List
                List {
                    Section {
                        Toggle("Vaccinations", isOn: $config.includeVaccinations)
                            .tint(Color("baseColor"))
                        Toggle("Deworming", isOn: $config.includeDeworming)
                            .tint(Color("baseColor"))
                        Toggle("Medications", isOn: $config.includeMedications)
                            .tint(Color("baseColor"))
                    } header: {
                        Text("Record Types")
                    } footer: {
                        Text("Selected categories will be compiled into a single PDF document.")
                    }
                }
                .listStyle(.insetGrouped)
                .scrollContentBackground(.hidden)
                
                // Action Button
                Button {
                    showPreview = true
                } label: {
                    Text("Preview Report")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color("baseColor"))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Export Report")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .navigationDestination(isPresented: $showPreview) {
                if let pet = petStore.activePet {
                    HealthReportPreviewView(pet: pet, config: config)
                }
            }
        }
    }
}

#Preview {
    HealthReportSelectionView()
        .environment(HealthStore())
        .environment(PetStore())
}
