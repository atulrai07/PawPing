//
//  AboutView.swift
//  PawPing
//

import SwiftUI

struct AboutView: View {
    let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                
                // MARK: - App Header
                VStack(spacing: 12) {
                    if let icon = UIImage(named: "AppIcon") {
                        Image(uiImage: icon)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 120, height: 120)
                            .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
                            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 4)
                    } else {
                        RoundedRectangle(cornerRadius: 26, style: .continuous)
                            .fill(Color("baseColor"))
                            .frame(width: 120, height: 120)
                            .overlay(
                                Image(systemName: "pawprint.fill")
                                    .font(.system(size: 50))
                                    .foregroundStyle(.white)
                            )
                            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 4)
                    }
                    
                    VStack(spacing: 4) {
                        Text("PawPing")
                            .font(.system(size: 28, weight: .bold))
                        
                        Text("Version \(appVersion)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.top, 40)
                
                // MARK: - Mission Statement
                VStack(spacing: 12) {
                    Text("Your dog's care companion")
                        .font(.headline)
                        .foregroundStyle(Color("baseColor"))
                    
                    Text("PawPing was built with a simple mission: to make pet parenting easier and more organized. Whether you're tracking daily walks, monitoring vaccine schedules, or keeping emergency vet contacts handy, we are here to support you and your furry best friend.")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .padding(.horizontal, 24)
                }
                
                // MARK: - Action Links
                VStack(spacing: 0) {
                    actionRow(icon: "star.fill", title: "Rate on the App Store")
                    Divider().padding(.leading, 48)
                    actionRow(icon: "envelope.fill", title: "Contact Support")
                    Divider().padding(.leading, 48)
                    actionRow(icon: "globe", title: "Visit our Website")
                }
                .background(Color(.secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .padding(.horizontal, 16)
                
                Spacer(minLength: 40)
                
                // MARK: - Footer
                VStack(spacing: 4) {
                    Text("Made with ❤️ in India")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    Text("© 2026 PawPing. All rights reserved.")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
                .padding(.bottom, 32)
            }
        }
        .background(Color("baseBackground"))
        .navigationTitle("About Us")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func actionRow(icon: String, title: String) -> some View {
        Button {
            // Placeholder action
        } label: {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundStyle(Color("baseColor"))
                    .frame(width: 24)
                
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(.primary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .contentShape(Rectangle())
        }
    }
}

#Preview {
    NavigationStack {
        AboutView()
    }
}
