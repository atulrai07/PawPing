//
//  VaccineReportView.swift
//  PawPing
//
//  Created by Shubhi on 25/03/26.
//

import SwiftUI

struct VaccineReportView: View {
    
    let dog: DogProfile
    
    @State private var config = VaccineReportConfig()
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                ZStack {
                    Circle()
                        .fill(.ultraThinMaterial)
                        .frame(width: 44, height: 44)
                        .shadow(color: .black.opacity(0.1), radius: 6)

                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                }
                Spacer()
                
                Text("Vaccine Report")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
                
                Image(dog.dogImage)
                    .resizable()
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
            }
            .padding(.horizontal)
            .padding(.top, 8)

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    
                    //PET CARD
                    HStack {
                        Image(dog.dogImage)
                            .resizable()
                            .frame(width: 60, height: 60)
                            .clipShape(Circle())
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(dog.dogName)
                                .font(.headline)
                                .fontWeight(.bold)
                            
                            Text("Breed : \(dog.breed)")
                            Text("Age : \(dog.age)")
                        }
                        Spacer()
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.pawNeutral)
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.1), radius: 6)
                    
                    
                    //INCLUDED SECTION
                    VStack(alignment: .leading, spacing: 14) {
                        
                        Text("Included in this Report")
                            .font(.title3)
                            .fontWeight(.medium)
                            .padding(.horizontal, 4)
                        
                        VStack(alignment: .leading, spacing: 16) {
                            
                            CheckRow(text: "Vaccination History")
                            CheckRow(text: "Missed Vaccines")
                            CheckRow(text: "Vet & Clinic Details")
                            CheckRow(text: "Date and Time of Records")
                            
                        }
                        .padding(20)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            RoundedRectangle(cornerRadius: 22)
                                .fill(Color.pawNeutral)
                        )
                        .shadow(color: .black.opacity(0.06), radius: 12, x: 0, y: 6)
                    }
                    
                    
                    //TOGGLES
                    VStack(spacing: 12) {
                        
                        ToggleRow(
                            text: "Include Clinic Contact info",
                            isOn: $config.includeClinicContactInfo
                        )
                        
                        Divider().opacity(0.3)
                        
                        ToggleRow(
                            text: "Include Missed Alerts",
                            isOn: $config.includeMissedAlerts
                        )
                        
                        Divider().opacity(0.3)
                        
                        ToggleRow(
                            text: "Include app Watermark",
                            isOn: $config.includeAppWatermark
                        )
                    }
                    .padding()
                    .background(Color.pawNeutral)
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.1), radius: 6)
                    
                    
                    //BUTTON
                    HStack {
                        Spacer()
                        Button(action: {
                            print("Report Generated")
                        }) {
                            Text("Generate Report")
                                .foregroundColor(.white)
                                .padding(.horizontal, 30)
                                .padding(.vertical, 12)
                                .background(Color.pawPrimary)
                                .cornerRadius(25)
                        }
                        Spacer()
                    }
                    .padding(.top, 10)
                }
                .padding()
            }
        }
        .background(Color(UIColor.systemGray6))
    }
}

struct CheckRow: View {
    var text: String
    
    var body: some View {
        HStack(spacing: 12) {
            
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(.green)
                .symbolRenderingMode(.hierarchical)
                .font(.system(size: 18))
            
            Text(text)
                .font(.body)
                .foregroundColor(.primary)
            
            Spacer()
        }
    }
}

struct ToggleRow: View {
    var text: String
    @Binding var isOn: Bool
    
    var body: some View {
        HStack {
            Text(text)
            Spacer()
            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(Color.pawPrimary)
        }
    }
}

#Preview {
    let dog = DogProfile(
        id: UUID(),
        ownerId: UUID(),
        dogName: "Buddy",
        breed: "Golden Retriever",
        gender: .male,
        age: "3 yrs",
        dogImage: "profilePhoto"
    )
    
    VaccineReportView(dog: dog)
}
