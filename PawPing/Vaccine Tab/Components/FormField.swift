//
//  FormField.swift.swift
//  PawPing
//
//  Created by Shubhi on 23/03/26.
//

import SwiftUI
struct FormField: View {
    var title: String
    @Binding var text: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            
            Text(title)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
            
            TextField("Enter \(title)", text: $text)
                .padding(.horizontal)
                .frame(height: 44)
                .background(.gray.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 14))
        }
    }
}
