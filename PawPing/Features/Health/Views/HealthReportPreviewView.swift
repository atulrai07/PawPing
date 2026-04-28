//
//  HealthReportPreviewView.swift
//  PawPing
//

import SwiftUI

struct HealthReportPreviewView: View {
    @Environment(PetStore.self) var petStore
    @Environment(HealthStore.self) var healthStore
    
    let config: VaccineReportConfig
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // The actual report content (Preview)
                ReportExportView(config: config)
                    .environment(petStore)
                    .environment(healthStore)
                
                // MARK: Download Button
                Button {
                    shareReport()
                } label: {
                    Text("Download & Share PDF")
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
            .padding(.bottom, 40)
        }
        .background(Color("baseBackground"))
        .navigationTitle("Report Preview")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    shareReport()
                } label: {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.primary)
                }
            }
        }
    }
    
    // MARK: - REAL PDF GENERATION & SHARING
    
    @MainActor
    private func shareReport() {
        // 1. Prepare metadata
        let petName = petStore.activePet?.name ?? "Pet"
        let exportView = ReportExportView(config: config)
            .environment(petStore)
            .environment(healthStore)
            .frame(width: 595) // A4 width
        
        // 2. Render to Image first (most stable way to get high quality)
        let renderer = ImageRenderer(content: exportView)
        guard let image = renderer.uiImage else { return }
        
        // 3. Create PDF from Image
        let pdfData = NSMutableData()
        let pdfRect = CGRect(origin: .zero, size: image.size)
        
        UIGraphicsBeginPDFContextToData(pdfData, pdfRect, nil)
        UIGraphicsBeginPDFPageWithInfo(pdfRect, nil)
        image.draw(at: .zero)
        UIGraphicsEndPDFContext()
        
        // 4. Save to temporary URL
        let url = URL.documentsDirectory.appending(path: "\(petName)_Health_Report.pdf")
        do {
            try pdfData.write(to: url)
        } catch {
            print("❌ Failed to save PDF: \(error)")
            return
        }
        
        // 5. Present Share Sheet
        let activityVC = UIActivityViewController(
            activityItems: [url],
            applicationActivities: nil
        )
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            
            if let popover = activityVC.popoverPresentationController {
                popover.sourceView = rootVC.view
                let bounds = rootVC.view.bounds
                popover.sourceRect = CGRect(x: bounds.midX, y: bounds.midY, width: 0, height: 0)
                popover.permittedArrowDirections = []
            }
            
            rootVC.present(activityVC, animated: true)
        }
    }
}

// MARK: - Export Content View (Simplified for PDF)

struct ReportExportView: View {
    @Environment(PetStore.self) var petStore
    @Environment(HealthStore.self) var healthStore
    let config: VaccineReportConfig
    
    var body: some View {
        VStack(spacing: 30) {
            // Header
            VStack(spacing: 10) {
                HStack {
                    Text("PawPing")
                        .font(.system(size: 40, weight: .black, design: .rounded))
                        .foregroundStyle(Color("baseColor"))
                    Image(systemName: "pawprint.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(Color("baseColor"))
                }
                
                Text("OFFICIAL HEALTH PASSPORT")
                    .font(.system(size: 14, weight: .bold))
                    .tracking(4)
                    .foregroundStyle(.secondary)
            }
            
            // Pet Details Card
            VStack(spacing: 15) {
                HStack(spacing: 20) {
                    if let imageName = petStore.activePet?.imageName {
                        Image(imageName)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 100, height: 100)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                    }
                    
                    VStack(alignment: .leading, spacing: 5) {
                        Text(petStore.activePet?.name ?? "Name")
                            .font(.system(size: 28, weight: .bold))
                        Text(petStore.activePet?.breed ?? "Breed")
                            .font(.system(size: 18))
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                }
                
                Divider()
                
                HStack {
                    detailItem(label: "AGE", value: "\(petStore.activePet?.age ?? "?") Years")
                    Spacer()
                    detailItem(label: "OWNER", value: petStore.currentUserProfile?.name ?? "Owner")
                    Spacer()
                    detailItem(label: "STATUS", value: "Verified")
                }
            }
            .padding(25)
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 24))
            
            // Records Table
            VStack(alignment: .leading, spacing: 15) {
                Text("VACCINATION HISTORY")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(Color("baseColor"))
                
                VStack(spacing: 0) {
                    tableHeader
                    ForEach(filteredRecords()) { record in
                        tableRow(record)
                    }
                }
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color(.systemGray4), lineWidth: 1))
            }
            
            // Footer Info
            if config.includeClinicContactInfo,
               let clinic = healthStore.healthRecords.first(where: { $0.vetName != nil }) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("PRIMARY VETERINARY CLINIC")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(.secondary)
                    Text(clinic.vetName ?? "")
                        .font(.system(size: 16, weight: .bold))
                    Text(clinic.vetAddress ?? "")
                        .font(.system(size: 14))
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(20)
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            
            Spacer()
            
            Text("This report is an automated summary of records provided by the owner via PawPing app.")
                .font(.system(size: 10))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(40)
        .background(Color.white)
    }
    
    // Helpers
    private var tableHeader: some View {
        HStack {
            Text("VACCINE").frame(maxWidth: .infinity, alignment: .leading)
            Text("DATE").frame(maxWidth: .infinity, alignment: .center)
            Text("STATUS").frame(width: 80, alignment: .trailing)
        }
        .font(.system(size: 12, weight: .bold))
        .padding()
        .background(Color(.systemGray5))
    }
    
    private func tableRow(_ record: HealthRecord) -> some View {
        VStack(spacing: 0) {
            Divider()
            HStack {
                Text(record.name).frame(maxWidth: .infinity, alignment: .leading)
                Text(record.formattedDateGiven).frame(maxWidth: .infinity, alignment: .center)
                Text(record.status == .done ? "DONE" : "MISSED")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(record.status == .done ? .green : .red)
                    .frame(width: 80, alignment: .trailing)
            }
            .font(.system(size: 14))
            .padding()
        }
    }
    
    private func detailItem(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label).font(.system(size: 10, weight: .bold)).foregroundStyle(.secondary)
            Text(value).font(.system(size: 16, weight: .semibold))
        }
    }
    
    private func filteredRecords() -> [HealthRecord] {
        healthStore.healthRecords.filter { $0.status == .done || (config.includeMissedAlerts && $0.status == .overdue) }
    }
}

#Preview {
    HealthReportPreviewView(config: .defaultConfig)
        .environment(PetStore.preview)
        .environment(HealthStore())
}
