//
//  SymptomCheckerView.swift
//  PawPing
//
//  Created by SidMoon on 27/04/26.
//

import SwiftUI

struct SymptomCheckerView: View {
    @Environment(SymptomStore.self) var symptomStore
    @Environment(\.dismiss) private var dismiss
    @State private var showingResults = false
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    Text("Select all symptoms your pet is experiencing. We'll provide a summary and advice based on your selection.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .listRowBackground(Color.clear)
                }
                
                ForEach(symptomStore.categories) { category in
                    Section(header: Label(category.name, systemImage: category.icon)) {
                        ForEach(category.symptoms) { symptom in
                            Button {
                                symptomStore.toggleSymptom(symptom.id)
                            } label: {
                                HStack {
                                    Text(symptom.name)
                                        .foregroundStyle(.primary)
                                    Spacer()
                                    if symptomStore.selectedSymptoms.contains(symptom.id) {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundStyle(Color.pawPrimary)
                                    } else {
                                        Image(systemName: "circle")
                                            .foregroundStyle(.secondary)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Symptom Checker")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Check") {
                        showingResults = true
                    }
                    .disabled(symptomStore.selectedSymptoms.isEmpty)
                    .fontWeight(.bold)
                }
            }
            .navigationDestination(isPresented: $showingResults) {
                SymptomResultView()
            }
        }
    }
}

#Preview {
    SymptomCheckerView()
        .environment(SymptomStore())
}
