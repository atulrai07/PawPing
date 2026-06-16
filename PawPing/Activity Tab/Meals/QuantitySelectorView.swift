//
//  QuantitySelectorView.swift
//  PawPing
//
//  Created by Atul on 25/04/26.
//
//

import SwiftUI

struct QuantitySelectorView: View {
    @Binding var selected: Double
    var unit: String = "cups"

    // Quick select options
    let quickOptions: [Double] = [0.5, 1.0, 1.5, 2.0]

    // Local state for the text field to handle partial input like "1."
    @State private var manualInput: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Quantity (\(unit))")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color("secondaryText"))

            // Quick Select Options
            HStack(spacing: 12) {
                ForEach(quickOptions, id: \.self) { qty in
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selected = qty
                            manualInput = String(qty)
                        }
                    } label: {
                        Text(String(format: "%.1f", qty))
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(selected == qty ? .white : Color("baseColor"))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(selected == qty ? Color("baseColor") : Color("secondaryCardBackground"))
                            )
                    }
                    .buttonStyle(.plain)
                }
            }

            // Custom Input Field
            HStack(spacing: 12) {
                Text("Custom:")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Color("secondaryText"))
                
                TextField("e.g. 2.5", text: $manualInput)
                    .keyboardType(.decimalPad)
                    .font(.system(size: 16, weight: .semibold))
                    .padding(12)
                    .background(Color("secondaryCardBackground").opacity(0.5))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .onChange(of: manualInput) { _, newValue in
                        if let val = Double(newValue) {
                            selected = val
                        }
                    }
            }
            .padding(.top, 4)

            // Helper text
            if unit.lowercased() == "cup" || unit.lowercased() == "cups" {
                Text("1 cup ≈ 100g (varies by food)")
                    .font(.system(size: 12))
                    .foregroundStyle(Color("secondaryText").opacity(0.8))
                    .padding(.top, 2)
            }
        }
        .onAppear {
            manualInput = String(selected)
        }
    }
}

#Preview {
    @Previewable @State var qty: Double = 1.0
    QuantitySelectorView(selected: $qty)
        .padding()
}
