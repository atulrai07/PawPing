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

    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Spacer()
                Text("Add Vaccine Record")
                    .font(.headline)
                Spacer()
                Button(action: {
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.black)
                                .padding(10)
                                .background(.ultraThinMaterial)
                                .clipShape(Circle())
                                .overlay(
                                    Circle()
                                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                )
                                .shadow(color: .black.opacity(0.2), radius: 5, x: 2, y: 2)
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
                    .background(Color("baseRed"))
                    .cornerRadius(25)
            }
            .padding()

        }
        .presentationDetents([.medium, .large])
    }
}
#Preview {
    AddVaccineSheet()
}
