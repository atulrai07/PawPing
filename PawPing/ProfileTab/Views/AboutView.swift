//
//  AboutView.swift
//  PawPing
//
//  Created by Atul on 25/03/26.
//

import SwiftUI

struct AboutView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                // MARK: - Logo & App Info
                VStack(spacing: 16) {
                    // Custom Logo matching design
                    ZStack {
                        RoundedRectangle(cornerRadius: 32)
                            .fill(LinearGradient(colors: [Color("baseColor"), Color("baseColor").opacity(0.8)], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(width: 140, height: 140)
                            .shadow(color: Color("baseColor").opacity(0.3), radius: 15, x: 0, y: 10)
                        
                        Image(systemName: "pawprint.fill")
                            .font(.system(size: 70))
                            .foregroundStyle(.white)
                    }
                    .padding(.top, 20)

                    VStack(spacing: 4) {
                        Text("PawPing")
                            .font(.system(size: 34, weight: .bold))
                        Text("Version 1.0")
                            .font(.system(size: 16))
                            .foregroundStyle(.secondary)
                    }
                }

                // MARK: - Tagline & Description
                VStack(spacing: 12) {
                    Text("Your dog's care companion")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(Color("baseColor"))
                    
                    Text("PawPing was built with a simple mission: to make pet parenting easier and more organized. Whether you're tracking daily walks, monitoring vaccine schedules, or keeping emergency vet contacts handy, we are here to support you and your furry best friend.")
                        .font(.system(size: 15))
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .padding(.horizontal, 32)
                }

                // MARK: - Action Links
                VStack(spacing: 0) {
                    LinkRow(label: "Rate on the App Store", icon: "star.fill")
                    Divider().padding(.leading, 56)
                    LinkRow(label: "Contact Support", icon: "envelope.fill")
                    Divider().padding(.leading, 56)
                    LinkRow(label: "Visit our Website", icon: "globe")
                }
                .background(Color("cardBackground"))
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 4)
                .padding(.horizontal, 24)

                Spacer(minLength: 40)

                // MARK: - Footer
                VStack(spacing: 4) {
                    Text("Made with ❤️ in India")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(.secondary)
                    Text("© 2026 PawPing. All rights reserved.")
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary.opacity(0.7))
                }
                .padding(.bottom, 20)
            }
        }
        .background(Color("baseBackground"))
        .navigationTitle("About Us")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct LinkRow: View {
    let label: String
    let icon: String
    
    var body: some View {
        Button {
            // Action for link
        } label: {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundStyle(Color("baseColor"))
                    .frame(width: 24)
                
                Text(label)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(Color("baseColor"))
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color("baseColor").opacity(0.5))
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
        .buttonStyle(.plain)
    }
}
