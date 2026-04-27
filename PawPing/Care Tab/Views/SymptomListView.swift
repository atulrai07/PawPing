//
//  SymptomListView.swift
//  PawPing
//
//  Created by Antigravity on 24/04/26.
//
//  Displays full-width rows of symptoms for a given category.
//

import SwiftUI

struct SymptomListView: View {
    let category: SymptomCategory
    @Environment(SymptomStore.self) var store
    @Environment(ActivityStore.self) var activityStore
    
    @State private var showResults = false
    
    var filteredSymptoms: [Symptom] {
        store.allSymptoms.filter { $0.category == category }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                ForEach(filteredSymptoms) { symptom in
                    let isSelected = store.isSelected(symptom)
                    
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            store.toggleSymptom(symptom)
                        }
                    } label: {
                        HStack(spacing: 16) {
                            if symptom.isEmergency {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundStyle(.red)
                                    .font(.system(size: 16))
                            }
                            
                            Text(symptom.name)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundStyle(Color("baseColor"))
                            
                            Spacer()
                            
                            if isSelected {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(Color("baseColor"))
                                    .font(.system(size: 22))
                            } else {
                                Image(systemName: "circle")
                                    .foregroundStyle(Color("secondaryText").opacity(0.3))
                                    .font(.system(size: 22))
                            }
                        }
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(isSelected ? Color("baseColor").opacity(0.1) : Color("secondaryCardBackground"))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(isSelected ? Color("baseColor").opacity(0.5) : Color.clear, lineWidth: 1.5)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding()
            .padding(.bottom, 20)
        }
        .navigationTitle(category.rawValue)
        .navigationBarTitleDisplayMode(.inline)
        .safeAreaInset(edge: .bottom) {
            SymptomStickyBar {
                store.analyze()
                showResults = true
            }
        }
        .navigationDestination(isPresented: $showResults) {
            SymptomResultView()
                .environment(store)
                .environment(activityStore)
        }
    }
}

struct SymptomListViewPreviewWrapper: View {
    @State private var store = SymptomStore()
    @State private var activityStore = ActivityStore()
    
    var body: some View {
        NavigationStack {
            SymptomListView(category: .digestive)
                .environment(store)
                .environment(activityStore)
        }
        .onAppear {
            let sample = store.allSymptoms.first { $0.category == .digestive }
            if let sample {
                store.toggleSymptom(sample)
            }
        }
    }
}

#Preview {
    SymptomListViewPreviewWrapper()
}
