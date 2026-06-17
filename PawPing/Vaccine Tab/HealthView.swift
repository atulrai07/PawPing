//
//  VaccineView.swift → HealthView
//  PawPing
//

import SwiftUI

struct HealthView: View {

    @Environment(HealthStore.self) var store
    @Environment(MedicationStore.self) var medicationStore
    @Environment(PetStore.self) var petStore
    @Environment(AppState.self) var appState

    @State private var showAddRecord = false
    @State private var showReportConfig = false
    @State private var recordToComplete: HealthRecord? = nil

    // MARK: Derived collections

    var upcomingRecords: [HealthRecord] { 
        store.healthRecords.filter { record in
            if record.status == .upcoming, let nextDose = record.nextDoseDate {
                let daysUntil = Calendar.current.dateComponents([.day], from: Date(), to: nextDose).day ?? 0
                return daysUntil <= 30
            }
            return false
        } 
    }
    var overdueRecords:  [HealthRecord] { store.healthRecords.filter { $0.status == .overdue  } }
    var doneRecords:     [HealthRecord] { store.healthRecords.filter { $0.status == .done     } }
    
    var timelineEvents: [TimelineEvent] {
        guard let petId = petStore.activePetId else { return [] }
        
        let healthEvents = doneRecords.map { TimelineEvent(from: $0) }
        
        return healthEvents.sorted { $0.eventDate > $1.eventDate }
    }

    var body: some View {
        NavigationStack {
            Group {
                if let petId = petStore.activePetId, let petName = petStore.activePet?.name {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 32) {
                            
                            // 1. Protection Summary Card
                            HealthSummaryCard(summary: store.summary, petName: petName)
                                .padding(.horizontal, 20)

                            // 2. Dynamic Hero Card OR Empty State
                            if store.healthRecords.isEmpty {
                                emptyOnboardingState(petName: petName)
                                    .padding(.horizontal, 20)
                            } else {
                                Button {
                                    if let overdue = overdueRecords.sorted(by: { ($0.nextDoseDate ?? Date.distantFuture) < ($1.nextDoseDate ?? Date.distantFuture) }).first {
                                        recordToComplete = overdue
                                    } else if let upcoming = upcomingRecords.sorted(by: { ($0.nextDoseDate ?? Date.distantFuture) < ($1.nextDoseDate ?? Date.distantFuture) }).first {
                                        recordToComplete = upcoming
                                    }
                                } label: {
                                    VaccineHeroCard(petName: petName, overdueRecords: overdueRecords, upcomingRecords: upcomingRecords)
                                }
                                .buttonStyle(.plain)
                                .padding(.horizontal, 20)
                            }
                            
                            // 3. Vaccine Journey Timeline
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Text("Vaccine Journey")
                                        .font(.system(size: 18, weight: .bold))
                                        .foregroundStyle(Color(hex: "1C1B1F") ?? .black)
                                    
                                    Spacer()
                                    
                                    if timelineEvents.count > 4 {
                                        NavigationLink {
                                            FullHistoryListView(records: doneRecords)
                                        } label: {
                                            Image(systemName: "chevron.right")
                                                .font(.system(size: 14, weight: .semibold))
                                                .foregroundStyle(.gray)
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                                .padding(.horizontal, 20)

                                HealthTimelineView(events: timelineEvents, limit: nil)
                            }

                            // 4. Active Medications Card
                            NavigationLink(destination: MedicationListView()) {
                                activeMedicationsCard()
                            }
                            .buttonStyle(.plain)
                            .padding(.horizontal, 20)

                            Spacer(minLength: 80)
                        }
                        .padding(.top, 16)
                    }
                    .background(Color.white)
                    .task(id: petId) {
                        await store.fetchVaccines(for: petId)
                        await medicationStore.fetchMedications(for: petId)
                    }
                } else {
                    ContentUnavailableView(
                        "No Pet Selected",
                        systemImage: "dog.fill",
                        description: Text("Please add a pet to track their health records.")
                    )
                }
            }
            .customNavigationScroll(
                title: "Vaccine",
                petStore: petStore,
                onAddTap: {
                    if petStore.activePetId != nil {
                        showAddRecord = true
                    }
                },
                backgroundColor: .white
            )
            .sheet(isPresented: $showAddRecord) {
                if let petId = petStore.activePetId {
                    AddHealthRecordView(petId: petId)
                }
            }
            .sheet(isPresented: $showReportConfig) {
                HealthReportSelectionView()
                    .environment(store)
                    .environment(petStore)
                    .environment(appState)
            }
            .sheet(item: $recordToComplete) { record in
                CompleteVaccineSheet(originalRecord: record)
            }
        }
    }

    // MARK: - Components

    private func activeMedicationsCard() -> some View {
        HStack(spacing: 16) {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.orange.opacity(0.15))
                .frame(width: 54, height: 54)
                .overlay(
                    Image(systemName: "pills.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.orange)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Active Medications")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(Color(hex: "1C1B1F") ?? .black)
                
                Text("\(medicationStore.activeMedicationsCount) Active")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.gray)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundStyle(.gray)
                .font(.system(size: 14, weight: .semibold))
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
    }

    private func historyRow(record: HealthRecord) -> some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.green.opacity(0.15))
                    .frame(width: 44, height: 44)
                
                Image(systemName: "checkmark")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(.green)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(record.name)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(Color(hex: "1C1B1F") ?? .black)
                
                HStack(spacing: 6) {
                    Image(systemName: "calendar")
                        .font(.system(size: 12))
                    Text(record.dateGiven.formatted(.dateTime.day().month(.wide).year()))
                        .font(.system(size: 13))
                }
                .foregroundStyle(.gray)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundStyle(.gray)
                .font(.system(size: 14, weight: .semibold))
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.03), radius: 8, x: 0, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(Color.gray.opacity(0.1), lineWidth: 1)
        )
    }

    private func emptyOnboardingState(petName: String) -> some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color(hex: "F8F6FF") ?? .purple.opacity(0.1))
                    .frame(width: 80, height: 80)
                
                Image(systemName: "syringe.fill")
                    .font(.system(size: 32))
                    .foregroundStyle(Color(hex: "6E54D7") ?? .purple)
            }
            
            Text("Let's start \(petName)'s vaccine journey.")
                .font(.system(size: 18, weight: .bold))
                .multilineTextAlignment(.center)
            
            Text("Add your pet's first vaccination record to stay on track and keep them healthy.")
                .font(.system(size: 15))
                .foregroundStyle(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
            
            Button {
                showAddRecord = true
            } label: {
                Text("Add Record")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 14)
                    .background(Color(hex: "6E54D7") ?? .purple)
                    .clipShape(Capsule())
            }
            .padding(.top, 8)
        }
        .padding(32)
        .background(
            RoundedRectangle(cornerRadius: 32)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 32)
                .stroke(Color.gray.opacity(0.1), lineWidth: 1)
        )
    }

    private func emptyHistoryState() -> some View {
        HStack {
            Spacer()
            VStack(spacing: 8) {
                Image(systemName: "clock.arrow.circlepath")
                    .font(.system(size: 28))
                    .foregroundStyle(.gray.opacity(0.5))
                
                Text("No past vaccines yet.")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.gray)
            }
            .padding(.vertical, 24)
            Spacer()
        }
        .background(
            RoundedRectangle(cornerRadius: 24)
                .stroke(style: StrokeStyle(lineWidth: 1, dash: [4]))
                .foregroundStyle(Color.gray.opacity(0.3))
        )
    }
}

// MARK: - Full History List View
struct FullHistoryListView: View {
    let records: [HealthRecord]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                ForEach(records.sorted { $0.dateGiven > $1.dateGiven }) { record in
                    NavigationLink(destination: HealthRecordDetailView(record: record)) {
                        HistoryRowItem(record: record)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(20)
        }
        .navigationTitle("Full History")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(hex: "F9F9FB") ?? .gray.opacity(0.05))
    }
}

struct HistoryRowItem: View {
    let record: HealthRecord
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.green.opacity(0.15))
                    .frame(width: 44, height: 44)
                
                Image(systemName: "checkmark")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(.green)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(record.name)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(Color(hex: "1C1B1F") ?? .black)
                
                HStack(spacing: 6) {
                    Image(systemName: "calendar")
                        .font(.system(size: 12))
                    Text(record.dateGiven.formatted(.dateTime.day().month(.wide).year()))
                        .font(.system(size: 13))
                }
                .foregroundStyle(.gray)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundStyle(.gray)
                .font(.system(size: 14, weight: .semibold))
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.03), radius: 8, x: 0, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(Color.gray.opacity(0.1), lineWidth: 1)
        )
    }
}

#Preview {
    HealthView()
        .environment(HealthStore())
        .environment(PetStore())
        .environment(AuthStore())
        .environment(AppState())
        .environment(ActivityStore())
        .environment(WeightStore())
        .environment(DietAssistantStore())
        .environment(MedicationStore())
}
