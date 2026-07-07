//
//  LegalViews.swift
//  PawPing
//

import SwiftUI

struct TermsView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Terms & Conditions")
                    .font(.largeTitle.bold())
                    .padding(.bottom, 8)
                
                Text("Last Updated: April 2026")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                Group {
                    Text("1. Acceptance of Terms")
                        .font(.headline)
                    Text("By using PawPing, you agree to these terms. PawPing is a pet care companion app designed to help you track your dog's activities, meals, and medical history.")
                    
                    Text("2. User Accounts")
                        .font(.headline)
                    Text("You must create an account to use most features of PawPing. You are responsible for maintaining the confidentiality of your account credentials and for all activities that occur under your account.")
                    
                    Text("3. Medical Disclaimer")
                        .font(.headline)
                    Text("PawPing provides tracking tools and general information, but it does NOT provide veterinary medical advice. Always consult a qualified veterinarian for concerns regarding your pet's health.")
                    
                    Text("4. Data Privacy")
                        .font(.headline)
                    Text("We respect your privacy and your pet's data. Our use of your data is governed by our Privacy Policy. We do not sell your personal data to third parties.")
                    
                    Text("5. User Content")
                        .font(.headline)
                    Text("You retain ownership of the content you upload, such as pet photos and logs. By uploading content, you grant PawPing a license to use it to provide the app's services to you.")
                }
                
                Spacer(minLength: 40)
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct PrivacyPolicyView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Privacy & Security")
                    .font(.largeTitle.bold())
                    .padding(.bottom, 8)
                
                Text("Last Updated: April 2026")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                Group {
                    Text("Information We Collect")
                        .font(.headline)
                    Text("We collect information you provide directly to us when creating an account, such as your email address and name. We also collect data you enter about your pets, including their breed, age, weight, and medical history.")
                        .foregroundStyle(.gray)
                    
                    Text("How We Use Information")
                        .font(.headline)
                    Text("We use your information to provide, maintain, and improve PawPing. This includes syncing your data across devices, providing activity insights, and keeping your vet contacts organized.")
                        .foregroundStyle(.gray)
                    
                    Text("Data Storage & Security")
                        .font(.headline)
                    Text("Your data is securely stored using Supabase. We implement reasonable security measures to protect your information from unauthorized access.")
                        .foregroundStyle(.gray)
                    
                    Text("Third-Party Services")
                        .font(.headline)
                    Text("We may use third-party services for analytics and infrastructure. These services only have access to the data necessary to perform their functions on our behalf.")
                        .foregroundStyle(.gray)
                    
                    Text("Your Rights")
                        .font(.headline)
                    Text("You have the right to access, correct, or delete your personal data at any time. You can delete your account entirely from the Account Settings section in the app.")
                        .foregroundStyle(.gray)
                }
                
                Spacer(minLength: 40)
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview("Terms") {
    NavigationStack {
        TermsView()
    }
}

#Preview("Privacy") {
    NavigationStack {
        PrivacyPolicyView()
    }
}
