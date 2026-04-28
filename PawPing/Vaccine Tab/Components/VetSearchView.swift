//
//  VetSearchView.swift
//  PawPing
//
//  Created by Atul on 27/04/26.
//

import SwiftUI
import MapKit

struct VetSearchView: View {
    @State private var viewModel = VetSearchViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var onSelect: (MKMapItem) -> Void
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(.secondary)
                    
                    TextField("Search clinics or area...", text: $viewModel.searchText)
                        .textFieldStyle(.plain)
                        .onSubmit {
                            viewModel.performSearch()
                        }
                    
                    if !viewModel.searchText.isEmpty {
                        Button {
                            viewModel.searchText = ""
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .padding(12)
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding()
                
                if viewModel.isSearching {
                    ProgressView("Searching clinics...")
                        .frame(maxHeight: .infinity)
                } else if let error = viewModel.errorMessage {
                    VStack(spacing: 16) {
                        Image(systemName: "magnifyingglass.circle")
                            .font(.system(size: 64))
                            .foregroundStyle(.secondary.opacity(0.5))
                        Text(error)
                            .font(.headline)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxHeight: .infinity)
                    .padding()
                } else if viewModel.searchResults.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "map.fill")
                            .font(.system(size: 64))
                            .foregroundStyle(.secondary.opacity(0.3))
                        Text("Search for a veterinary clinic near you")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxHeight: .infinity)
                } else {
                    ScrollView {
                        VStack(spacing: 0) {
                            ForEach(viewModel.searchResults, id: \.self) { item in
                                Button {
                                    onSelect(item)
                                    dismiss()
                                } label: {
                                    VStack(alignment: .leading, spacing: 6) {
                                        Text(item.name ?? "Unknown Clinic")
                                            .font(.system(size: 18, weight: .bold))
                                            .foregroundStyle(.primary)
                                        
                                        Text(item.address?.fullAddress ?? "")
                                            .font(.system(size: 14))
                                            .foregroundStyle(.secondary)
                                            .lineLimit(2)
                                        
                                        if let phone = item.phoneNumber {
                                            HStack(spacing: 4) {
                                                Image(systemName: "phone.fill")
                                                    .font(.system(size: 12))
                                                Text(phone)
                                                    .font(.system(size: 14, weight: .medium))
                                            }
                                            .foregroundStyle(.blue)
                                            .padding(.top, 2)
                                        }
                                        
                                        Divider()
                                            .padding(.top, 10)
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.horizontal)
                                    .padding(.vertical, 12)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Find Vet Clinic")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                viewModel.requestLocationPermission()
                // Initial search for nearby clinics
                viewModel.searchText = ""
                viewModel.performSearch()
            }
        }
    }
}

#Preview {
    VetSearchView(onSelect: { _ in })
}
