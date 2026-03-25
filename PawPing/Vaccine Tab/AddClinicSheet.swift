//
//  AddClinicSheet.swift
//  PawPing
//
//  Created by Shubhi on 23/03/26.
//
import SwiftUI

struct AddClinicSheet: View {
    
    @Environment(\.dismiss) var dismiss
    
    init() {
        UISegmentedControl.appearance().selectedSegmentTintColor = UIColor(Color.pawPrimary)
        UISegmentedControl.appearance().setTitleTextAttributes(
                [.foregroundColor: UIColor.white],
                for: .selected
            )
    }
    @State private var isManual = true
    
    @State private var vetName = ""
    @State private var clinicName = ""
    @State private var address = ""
    @State private var phone = ""
    
    @State private var notes = ""
    
    var body: some View {
        VStack(spacing: 20) {

            ZStack {
                Text("Add Clinic Record")
                    .font(.headline)
                
                HStack {
                    Spacer()
                    
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.black)
                            .font(.system(size: 15, weight: .semibold))
                            .frame(width: 36, height: 36)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                    }
                }
            }
            .padding(.horizontal)
            
            //Icon
            Image(systemName: "syringe")
                .font(.system(size: 50))
            
            VStack(alignment: .leading, spacing: 16) {
                
                Text("Clinic Information")
                    .foregroundStyle(.primary)
                    .fontWeight(.semibold)
                

                CustomSegmentedControl(isManual: $isManual)
                
                // Switch Views
                if isManual {
                    ManualView(
                        vetName: $vetName,
                        clinicName: $clinicName,
                        address: $address,
                        phone: $phone
                    )
                } else {
                    VetCenterView(notes: $notes)
                }
            }
            .padding(.horizontal)
            
            Spacer()
            
            //Save Button
            Button(action: {
                print("Saved")
            }) {
                Text("Save")
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.pawPrimary)
                    .cornerRadius(25)
            }
            .padding()
        }
        .padding(.top, 10)
    }
}

//CustomSegmentedControl
struct CustomSegmentedControl: View {
    
    @Binding var isManual: Bool
    @Namespace private var animation
    
    var body: some View {
        HStack {
            
            segment(title: "Enter Manually", isSelected: isManual)
                .onTapGesture {
                    withAnimation(.spring()) {
                        isManual = true
                    }
                }
            
            segment(title: "Select from Vet Center", isSelected: !isManual)
                .onTapGesture {
                    withAnimation(.spring()) {
                        isManual = false
                    }
                }
        }
        .padding(2)
        .frame(height: 40)
        .background(Color.pawPrimary.opacity(0.2))
        .clipShape(Capsule())
    }
    
    private func segment(title: String, isSelected: Bool) -> some View {
        ZStack {
            if isSelected {
                Capsule()
                    .fill(Color.pawPrimary)
                    .matchedGeometryEffect(id: "SEGMENT", in: animation)
            }
            
            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(isSelected ? .white : Color.pawPrimary)
                .frame(maxWidth: .infinity)
                .padding(.vertical,1)
        }
    }
}
//Manual View
struct ManualView: View {
    
    @Binding var vetName: String
    @Binding var clinicName: String
    @Binding var address: String
    @Binding var phone: String
    
    var body: some View {
        VStack(spacing: 15) {
            FormField(title: "Vet Name", text: $vetName)
            FormField(title: "Clinic Name", text: $clinicName)
            FormField(title: "Address", text: $address)
            FormField(title: "Phone Number", text: $phone)
        }
    }
}


//Vet Center View
struct VetCenterView: View {
    
    @Binding var notes: String
    
    var body: some View {
        VStack(spacing: 20) {
            
            Image(systemName: "location.fill")
                .font(.system(size: 40))
                .foregroundColor(Color.pawPrimary)
            
            Text("Select your clinic from our vet care list to automatically add clinics")
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
            
            Button("Select Vet Clinic") {
                print("Open clinic list")
            }
            .padding(10)
            .padding(.horizontal,20)
            .frame(maxWidth: .infinity)
            .background(Color.pawPrimary)
            .foregroundColor(.white)
            .cornerRadius(20)
            
            VStack(alignment: .leading, spacing: 8) {
                FormField(title: "Notes", text: $notes)
           }
        }
        .padding(.top, 20)
    }
}
#Preview {
    AddClinicSheet()
}
