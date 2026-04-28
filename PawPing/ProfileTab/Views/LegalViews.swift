//
//  LegalViews.swift
//  PawPing
//
//  Created by Atul on 25/03/26.
//

import SwiftUI

struct TermsView: View {
    var body: some View {
        ScrollView {
            Text("Terms and Conditions")
                .font(.title)
                .bold()
                .padding()
            
            Text("Placeholder for Terms and Conditions content. By using PawPing, you agree to our terms of service...")
                .padding()
        }
        .navigationTitle("Terms")
    }
}

struct PrivacyPolicyView: View {
    var body: some View {
        ScrollView {
            Text("Privacy Policy")
                .font(.title)
                .bold()
                .padding()
            
            Text("Placeholder for Privacy Policy content. Your data privacy is important to us...")
                .padding()
        }
        .navigationTitle("Privacy")
    }
}
