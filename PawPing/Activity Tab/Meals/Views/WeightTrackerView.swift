import SwiftUI
import Charts

struct WeightTrackerView: View {
    @Environment(WeightStore.self) var weightStore
    let petId: UUID
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                if weightStore.records.isEmpty {
                    ContentUnavailableView(
                        "No Records Yet",
                        systemImage: "chart.line.uptrend.xyaxis",
                        description: Text("Log your pet's weight to see trends over time.")
                    )
                    .padding(.top, 100)
                } else {
                    // Chart
                    chartSection
                    
                    // Summary Row
                    summaryRow
                    
                    // Footnote
                    Text("Body condition is self-reported. Ask your vet for a clinical assessment.")
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .padding(.top, 12)
                }
            }
            .padding()
        }
        .background(Color("baseBackground"))
        .navigationTitle("Weight & Condition")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var chartSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Weight Trend")
                .font(.system(size: 16, weight: .bold))
            
            Chart {
                ForEach(weightStore.records.reversed()) { record in
                    LineMark(
                        x: .value("Date", record.date),
                        y: .value("Weight", record.weightKg)
                    )
                    .foregroundStyle(.gray.opacity(0.4))
                    .interpolationMethod(.catmullRom)
                    
                    PointMark(
                        x: .value("Date", record.date),
                        y: .value("Weight", record.weightKg)
                    )
                    .foregroundStyle(record.bodyCondition.color)
                    .symbolSize(100)
                }
            }
            .frame(height: 240)
            .chartYScale(domain: .automatic(includesZero: false))
        }
        .padding(20)
        .background(Color("cardBackground"))
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }
    
    private var summaryRow: some View {
        Group {
            if let latest = weightStore.latestRecord {
                HStack(spacing: 8) {
                    Text("Last logged:")
                        .foregroundStyle(.secondary)
                    Text(String(format: "%.1f kg", latest.weightKg))
                        .fontWeight(.semibold)
                    Text("·")
                        .foregroundStyle(.secondary)
                    Text(latest.bodyCondition.label)
                        .foregroundStyle(latest.bodyCondition.color)
                        .fontWeight(.semibold)
                    Text("·")
                        .foregroundStyle(.secondary)
                    Text(timeAgo(date: latest.date))
                        .foregroundStyle(.secondary)
                }
                .font(.system(size: 13))
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(Color("cardBackground"))
                .clipShape(Capsule())
            }
        }
    }
    
    private func timeAgo(date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

#Preview {
    NavigationStack {
        WeightTrackerView(petId: UUID())
            .environment(WeightStore())
    }
}
