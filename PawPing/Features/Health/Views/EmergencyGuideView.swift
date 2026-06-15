//
//  EmergencyGuideView.swift
//  PawPing
//

import SwiftUI

struct EmergencyGuideView: View {
    @Environment(PetStore.self) var petStore
    @Environment(HealthStore.self) var healthStore
    
    @State private var viewModel = EmergencyViewModel()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // MARK: Emergency Hotline Banner
                hotlineBanner
                    .padding(.horizontal)
                    .padding(.top, 16)
                
                sopList
            }
        }
        .background(Color("baseBackground"))
        .navigationTitle("Emergency Guide")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.configure(petStore: petStore, healthStore: healthStore)
        }
    }
    
    // MARK: - Banner Subview
    
    private var hotlineBanner: some View {
        VStack(spacing: 16) {
            HStack(spacing: 12) {
                Image(systemName: "phone.circle.fill")
                    .font(.system(size: 32))
                    .foregroundStyle(.white)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(viewModel.primaryVetPhone != nil ? "PRIMARY VET CLINIC" : "EMERGENCY HOTLINE")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(.white.opacity(0.8))
                        .tracking(1)
                    
                    Text(viewModel.primaryVetPhone != nil ? (viewModel.primaryVetName ?? "Your Vet") : "No Primary Vet Saved")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(.white)
                }
                Spacer()
            }
            
            Button {
                viewModel.initiateEmergencyCall()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "phone.fill")
                        .font(.system(size: 14))
                    Text(viewModel.primaryVetPhone != nil ? "Call Vet Now" : "Call Emergency Line")
                        .font(.system(size: 15, weight: .bold))
                }
                .foregroundStyle(.red)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(RoundedRectangle(cornerRadius: 12).fill(.white))
                .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(
                    LinearGradient(
                        colors: [.red, Color.red.opacity(0.8)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .shadow(color: Color.red.opacity(0.25), radius: 8, x: 0, y: 4)
    }
    
    // MARK: - SOP List Subview
    
    private var sopList: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Critical First Aid Procedures")
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(.secondary)
                .padding(.horizontal)
                .padding(.leading, 4)
            
            VStack(spacing: 0) {
                ForEach(viewModel.guides) { guide in
                    NavigationLink(destination: EmergencyDetailView(guide: guide)) {
                        HStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(guide.color.opacity(0.12))
                                    .frame(width: 44, height: 44)
                                Image(systemName: guide.icon)
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundStyle(guide.color)
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(guide.title)
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundStyle(.primary)
                                
                                Text(guide.symptoms.first ?? "First aid steps")
                                    .font(.system(size: 12))
                                    .foregroundStyle(.secondary)
                                    .lineLimit(1)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundStyle(Color(.systemGray4))
                        }
                        .padding(.vertical, 14)
                        .padding(.horizontal, 20)
                    }
                    
                    if guide.id != viewModel.guides.last?.id {
                        Divider()
                            .padding(.leading, 80)
                    }
                }
            }
            .background(Color("cardBackground"))
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .padding(.horizontal)
        }
    }

}

#Preview {
    NavigationStack {
        EmergencyGuideView()
            .environment(PetStore())
            .environment(HealthStore())
    }
}
