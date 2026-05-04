//
//  SymptomCheckerView.swift
//  PawPing
//
//  Created by Atul on 24/04/26.
//
//

import SwiftUI

struct SymptomCheckerView: View {
    @Environment(SymptomStore.self) var store
    @Environment(ActivityStore.self) var activityStore

    @State private var showResults = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                
                // MARK: - Header
                headerSection
                
                // MARK: - Category Grid
                categoryGridSection
                
            }
            .padding(.bottom, 20)
        }
        .navigationTitle("Check Symptoms")
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
    
    // MARK: - Subviews
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Where is the issue?")
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(Color("baseColor"))
            
            Text("Select a category below to explore specific symptoms. We'll help you understand what might be going on.")
                .font(.system(size: 14))
                .foregroundStyle(Color("secondaryText"))
        }
        .padding(.horizontal)
        .padding(.top, 8)
    }
    
    private var categoryGridSection: some View {
        LazyVGrid(
            columns: [
                GridItem(.flexible(), spacing: 16),
                GridItem(.flexible(), spacing: 16)
            ],
            spacing: 16
        ) {
            ForEach(SymptomCategory.allCases) { category in
                NavigationLink(destination: SymptomListView(category: category)
                                                .environment(store)
                                                .environment(activityStore)) {
                    CategoryCardView(category: category)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal)
    }
}

struct SymptomCheckerPreviewWrapper: View {
    @State private var store = SymptomStore()
    @State private var activityStore = ActivityStore()
    
    var body: some View {
        NavigationStack {
            SymptomCheckerView()
                .environment(store)
                .environment(activityStore)
        }
    }
}

#Preview {
    SymptomCheckerPreviewWrapper()
}
