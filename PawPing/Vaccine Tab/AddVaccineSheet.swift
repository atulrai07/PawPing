//
//  AddVaccineSheet.swift
//  PawPing
//
//  Created by Shubhi on 18/03/26.
//
import SwiftUI
struct AddVaccineSheet: View {
    @State private var vaccineName = ""
    @State private var date = Date()
    @State private var time = Date()
    @State private var frequency = ""
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                Text("Add Vaccine Record")
                    .font(.headline)
                HStack{
                    Spacer()
                    Button(action: {
                        dismiss()}) {
                        Image(systemName: "xmark")
                                .foregroundColor(.black)
                                .font(.system(size: 16, weight: .semibold))
                                .frame(width: 36, height: 36)
                                .background(.ultraThinMaterial)
                                .clipShape(Circle())
                    }
                }
            }

            VStack(spacing: 10) {
                Image(systemName: "syringe")
                    .font(.system(size: 50))
            }

            VStack(alignment: .leading, spacing: 15) {
                Text("Enter Vaccine Record")
                    .font(.caption)
                    .foregroundColor(.gray)

                VStack(spacing: 15) {
                    HStack {
                        Text("Vaccine Name")
                        Spacer()
                        Text("Select")
                            .foregroundColor(.gray)
                        Image(systemName: "chevron.down")
                            .foregroundColor(.gray)
                    }
                    Divider()
                    
                    HStack {
                        Text("Date Given")
                        Spacer()
                        DatePicker("", selection: $date, displayedComponents: .date)
                            .labelsHidden()
                    }
                    Divider()

                    HStack {
                        Text("Time")
                        Spacer()
                        DatePicker("", selection: $time, displayedComponents: .hourAndMinute)
                            .labelsHidden()
                    }
                }
                .padding()
                .background(Color(.gray.opacity(0.1)))
                .cornerRadius(15)
                
                Text("Duration")
                    .font(.caption)
                    .foregroundColor(.gray)

                VStack {
                    HStack {
                        Text("Frequency")
                        Spacer()
                        Text("Select")
                            .foregroundColor(.gray)
                        Image(systemName: "chevron.down")
                            .foregroundColor(.gray)
                    }
                }
                .padding()
                .background(Color(.gray.opacity(0.1)))
                .cornerRadius(15)

                Text("Set how often this vaccine needs to be renewed.")
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
            .padding(.horizontal)

            Spacer()

            Button(action: {
                print("Next tapped")
            }) {
                Text("Next")
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.pawPrimary)
                    .cornerRadius(25)
            }
            .padding()

        }
        .padding(.top, 12)
        .presentationDetents([.medium, .large])
    }
}
#Preview {
    AddVaccineSheet()
}
