//
//  HealthReportPreviewView.swift
//  PawPing
//
//  Created by Atul on 28/04/26.
//

import SwiftUI
import PDFKit
import Charts

struct HealthReportPreviewView: View {
    let pet: Pet
    let config: HealthReportConfig
    @Environment(HealthStore.self) var store
    @Environment(WeightStore.self) var weightStore
    @Environment(ActivityStore.self) var activityStore
    @Environment(AppState.self) var appState
    @Environment(\.dismiss) private var dismiss
    @State private var pdfURL: URL?
    @State private var showShareSheet = false
    
    var filteredRecords: [HealthRecord] {
        store.healthRecords.filter { record in
            if record.recordType == .vaccine && config.includeVaccinations { return true }
            if record.recordType == .deworming && config.includeDeworming { return true }
            // Add more as needed
            return false
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 24) {
                    reportHeader
                    petInfoCard
                    
                    if config.includeVaccinations {
                        recordsSection(title: "Vaccine Records", records: filteredRecords.filter { $0.recordType == .vaccine })
                    }
                    
                    if config.includeDeworming {
                        recordsSection(title: "Deworming Records", records: filteredRecords.filter { $0.recordType == .deworming })
                    }
                    
                    if config.includeWeightChart {
                        weightTrendSection
                    }
                    
                    if config.includeDietPlan {
                        dietPlanSection
                    }
                    
                    vetClinicSection
                }
                .padding()
            }
            .background(Color(.systemGray6).opacity(0.5))
            
            // Download Button
            Button {
                generatePDF()
            } label: {
                Text("Download Report")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color("baseColor"))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .padding()
            .background(.white)
        }
        .navigationTitle("Report Preview")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    generatePDF()
                } label: {
                    Image(systemName: "square.and.arrow.up")
                }
            }
        }
        .sheet(isPresented: $showShareSheet) {
            if let url = pdfURL {
                ShareSheet(items: [url])
            }
        }
    }
    
    // MARK: - Components
    
    private var reportHeader: some View {
        VStack(spacing: 8) {
            Image("Pawping_logo")
                .resizable()
                .scaledToFit()
                .frame(height: 50)
            
            Text("Health Report")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Generated on \(Date().formatted(date: .abbreviated, time: .omitted))")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.top)
    }
    
    private var petInfoCard: some View {
        HStack(spacing: 16) {
            Group {
                if let urlString = pet.profileImageUrl, let url = URL(string: urlString) {
                    AsyncImage(url: url) { image in
                        image.resizable()
                    } placeholder: {
                        Color.gray.opacity(0.1)
                    }
                } else {
                    Image(pet.imageName)
                        .resizable()
                }
            }
            .scaledToFill()
            .frame(width: 80, height: 80)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(pet.name)
                    .font(.headline)
                Text("Breed: \(pet.breed)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text("Age: \(pet.age)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text("Owner: \(appState.currentUserName)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding()
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    private func recordsSection(title: String, records: [HealthRecord]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
            
            VStack(spacing: 0) {
                // Table Header
                HStack {
                    Text("Record").frame(maxWidth: .infinity, alignment: .leading)
                    Text("Date").frame(width: 100, alignment: .center)
                    Text("Status").frame(width: 60, alignment: .trailing)
                }
                .font(.caption.bold())
                .padding(.vertical, 8)
                .padding(.horizontal)
                .background(Color(.systemGray5))
                
                if records.isEmpty {
                    Text("No records found")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .padding()
                } else {
                    ForEach(records, id: \.id) { record in
                        HStack {
                            Text(record.name)
                                .font(.subheadline)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            Text(record.dateGiven.formatted(date: .abbreviated, time: .omitted))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .frame(width: 100, alignment: .center)
                            
                            Image(systemName: record.isCompleted ? "checkmark.circle.fill" : "xmark")
                                .foregroundStyle(record.isCompleted ? .green : .red)
                                .frame(width: 60, alignment: .trailing)
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal)
                        
                        if record.id != records.last?.id {
                            Divider().padding(.horizontal)
                        }
                    }
                }
            }
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
    
    private var vetClinicSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Vet Clinic Details")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 8) {
                InfoRow(label: "Clinic Name", value: "PupiLife Pet Clinic")
                InfoRow(label: "Vet Name", value: "Dr. Ananya Sharma(BVSc)")
                InfoRow(label: "Reg. No.", value: "DL/VCI/2021/4587")
                InfoRow(label: "Address", value: "Saket, New Delhi, 11034")
                InfoRow(label: "Email", value: "contact@pupilife.com")
                InfoRow(label: "Phone", value: "+91 62839 87239")
            }
            .padding()
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
    
    private var weightTrendSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Weight History")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 12) {
                let last8 = Array(weightStore.records.prefix(8)).reversed()
                if last8.isEmpty {
                    Text("No weight records found")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .padding()
                } else {
                    let dateRange = "\(last8.first?.date.formatted(date: .abbreviated, time: .omitted) ?? "") - \(last8.last?.date.formatted(date: .abbreviated, time: .omitted) ?? "")"
                    
                    Text(dateRange)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal)
                        .padding(.top, 8)
                    
                    Chart {
                        ForEach(last8) { record in
                            LineMark(
                                x: .value("Date", record.date),
                                y: .value("Weight", record.weightKg)
                            )
                            .foregroundStyle(.gray.opacity(0.4))
                            
                            PointMark(
                                x: .value("Date", record.date),
                                y: .value("Weight", record.weightKg)
                            )
                            .foregroundStyle(record.bodyCondition.color)
                        }
                    }
                    .frame(height: 150)
                    .padding()
                }
            }
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
    
    private var dietPlanSection: some View {
        let plan = activityStore.mealDietStore.dietPlan
        return VStack(alignment: .leading, spacing: 12) {
            Text("Diet Plan")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 8) {
                InfoRow(label: "Goal", value: plan.goal.rawValue)
                InfoRow(label: "Daily Target", value: "\(Int(plan.dailyCalorieTarget)) kcal")
                InfoRow(label: "Weight", value: String(format: "%.1f kg", plan.weightKg))
                InfoRow(label: "Activity", value: plan.activityLevel)
                InfoRow(label: "Life Stage", value: plan.lifeStage)
            }
            .padding()
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
    
    // MARK: - Actions
    
    @MainActor
    private func generatePDF() {
        let renderer = ImageRenderer(content: self
            .environment(store)
            .environment(PetStore())
            .environment(weightStore)
            .environment(activityStore)
        )
        
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("HealthReport.pdf")
        
        renderer.render { size, context in
            var box = CGRect(origin: .zero, size: size)
            guard let pdfContext = CGContext(url as CFURL, mediaBox: &box, nil) else { return }
            
            pdfContext.beginPDFPage(nil)
            context(pdfContext)
            pdfContext.endPDFPage()
            pdfContext.closePDF()
        }
        
        self.pdfURL = url
        self.showShareSheet = true
    }
}

struct InfoRow: View {
    let label: String
    let value: String
    var body: some View {
        HStack {
            Text(label + ":")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.subheadline)
            Spacer()
        }
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
