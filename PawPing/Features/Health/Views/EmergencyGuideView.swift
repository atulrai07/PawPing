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
                // MARK: Saved Vets Section (Emergency Vets)
                savedVetsSection
                    .padding(.top, 16)
                
                sopList
            }
        }
        .background(
            LinearGradient(colors: [.bgWarmTop, .bgWarmBottom], startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()
        )
        .navigationTitle("Emergency Guide")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.configure(petStore: petStore, healthStore: healthStore)
        }
        .task {
            await petStore.fetchSavedVets()
        }
    }
    
    // MARK: - Saved Vets Section
    
    private var savedVetsSection: some View {
        let sortedVets = petStore.savedVets.sorted(by: { $0.createdAt > $1.createdAt }).prefix(2)
        
        return Group {
            if !petStore.savedVets.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Emergency Vets")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.secondary)
                        .padding(.horizontal)
                        .padding(.leading, 4)
                    
                    VStack(spacing: 0) {
                        ForEach(Array(sortedVets.enumerated()), id: \.element.id) { index, vet in
                            let cleanedPhone = vet.phone.filter { "+0123456789".contains($0) }
                            
                            HStack(spacing: 16) {
                                ZStack {
                                    Circle()
                                        .fill(Color("baseColor").opacity(0.12))
                                        .frame(width: 44, height: 44)
                                    Image(systemName: "cross.case.fill")
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundStyle(Color("baseColor"))
                                }
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(vet.name)
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundStyle(.primary)
                                    
                                    Text(vet.address)
                                        .font(.system(size: 12))
                                        .foregroundStyle(.secondary)
                                }
                                
                                Spacer()
                                
                                Button {
                                    if let url = URL(string: "tel://\(cleanedPhone)") {
                                        UIApplication.shared.open(url)
                                    }
                                } label: {
                                    Image(systemName: "phone.fill")
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundStyle(.white)
                                        .padding(10)
                                        .background(Circle().fill(cleanedPhone.isEmpty ? Color.gray : Color.green))
                                }
                                .buttonStyle(.plain)
                                .disabled(cleanedPhone.isEmpty)
                                .opacity(cleanedPhone.isEmpty ? 0.5 : 1.0)
                            }
                            .padding(.vertical, 14)
                            .padding(.horizontal, 20)
                            
                            if index < sortedVets.count - 1 {
                                Divider()
                                    .padding(.leading, 80)
                            }
                        }
                    }
                    .background(Color.cardIvory)
                    .clipShape(RoundedRectangle(cornerRadius: 24))
                    .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 4)
                    .padding(.horizontal)
                }
            } else {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Emergency Vets")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.secondary)
                        .padding(.horizontal)
                        .padding(.leading, 4)
                    
                    VStack(alignment: .center, spacing: 12) {
                        Image(systemName: "cross.case")
                            .font(.system(size: 32))
                            .foregroundStyle(Color("baseColor").opacity(0.6))
                            .padding(.top, 8)
                        
                        Text("No Emergency Vets")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(.primary)
                        
                        Text("Go to the Find tab to save your preferred veterinary clinics for quick emergency access.")
                            .font(.system(size: 13))
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                            .padding(.bottom, 8)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.cardIvory)
                    .clipShape(RoundedRectangle(cornerRadius: 24))
                    .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 4)
                    .padding(.horizontal)
                }
            }
        }
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
                                    .fill(Color("baseColor").opacity(0.12))
                                    .frame(width: 44, height: 44)
                                Image(systemName: guide.icon)
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundStyle(Color("baseColor"))
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
                    .buttonStyle(.plain)
                    
                    if guide.id != viewModel.guides.last?.id {
                        Divider()
                            .padding(.leading, 80)
                    }
                }
            }
            .background(Color.cardIvory)
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 4)
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
