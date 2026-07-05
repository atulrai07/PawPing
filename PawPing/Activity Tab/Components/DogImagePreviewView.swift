//
//  DogImagePreviewView.swift
//  PawPing
//
//  Shows the background-removed dog image with a live card preview.
//  User can confirm ("Set as Card Image"), retake, or cancel.
//

import SwiftUI

struct DogImagePreviewView: View {
    let originalImage: UIImage
    let petId: UUID
    
    var onConfirm: (UIImage) -> Void
    var onRetake: () -> Void
    var onCancel: () -> Void
    
    @State private var unadjustedImage: UIImage? = nil
    @State private var processedImage: UIImage? = nil
    @State private var isProcessing = true
    @State private var errorMessage: String? = nil
    @State private var showEditor = false
    
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        NavigationStack {
            ZStack {
                backgroundGradient
                
                if isProcessing {
                    processingView
                } else if let error = errorMessage {
                    errorView(message: error)
                } else if let image = processedImage {
                    successView(image: image)
                }
            }
            .navigationTitle("Preview")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        onCancel()
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        onRetake()
                    } label: {
                        Label("Retake", systemImage: "camera.rotate")
                    }
                }
            }
            .sheet(isPresented: $showEditor) {
                if let unadjusted = unadjustedImage {
                    DogImageEditView(image: unadjusted) { editedImage in
                        processedImage = editedImage
                    }
                }
            }
        }
        .task {
            await processImage()
        }
    }
    
    // MARK: - Background
    
    private var backgroundGradient: some View {
        LinearGradient(
            colors: colorScheme == .dark
                ? [Color(white: 0.08), Color(white: 0.12)]
                : [Color(white: 0.96), Color(white: 1.0)],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
    
    // MARK: - Processing View
    
    private var processingView: some View {
        VStack(spacing: 24) {
            // Show the original image being processed
            Image(uiImage: originalImage)
                .resizable()
                .scaledToFit()
                .frame(maxHeight: 300)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.black.opacity(0.4))
                )
                .overlay(
                    VStack(spacing: 16) {
                        ProgressView()
                            .scaleEffect(1.3)
                            .tint(.white)
                        
                        Text("Removing background...")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                    }
                )
                .padding(.horizontal, 24)
            
            Text("This may take a few seconds")
                .font(.system(size: 13))
                .foregroundColor(.textSecondary)
        }
    }
    
    // MARK: - Success View
    
    private func successView(image: UIImage) -> some View {
        ScrollView {
            VStack(spacing: 28) {
                // Background-removed image on checkerboard
                VStack(spacing: 12) {
                    HStack {
                        Text("Background Removed")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.textSecondary)
                        
                        Spacer()
                        
                        Button {
                            showEditor = true
                        } label: {
                            Label("Resize / Crop", systemImage: "crop")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(.homePurple)
                        }
                    }
                    .padding(.horizontal, 24)
                    
                    ZStack {
                        // Checkerboard pattern to show transparency
                        CheckerboardView()
                            .frame(height: 280)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                        
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 260)
                            .padding(10)
                    }
                    .padding(.horizontal, 24)
                }
                
                // Card preview
                VStack(spacing: 12) {
                    Text("Card Preview")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.textSecondary)
                    
                    cardPreview(dogImage: image)
                        .padding(.horizontal, 24)
                }
                
                // Set as card image button
                Button {
                    let generator = UIImpactFeedbackGenerator(style: .medium)
                    generator.impactOccurred()
                    onConfirm(image)
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                        Text("Set as Card Image")
                    }
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.homePurple)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: Color.homePurple.opacity(0.3), radius: 10, x: 0, y: 5)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            }
            .padding(.top, 20)
        }
    }
    
    // MARK: - Error View
    
    private func errorView(message: String) -> some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 48))
                .foregroundColor(.orange)
            
            Text("Background Removal Failed")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.textPrimary)
            
            Text(message)
                .font(.system(size: 14))
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            VStack(spacing: 12) {
                Button {
                    onRetake()
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "camera.fill")
                        Text("Try Again")
                    }
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.homePurple)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                
                Button {
                    // Retry with the same image
                    errorMessage = nil
                    isProcessing = true
                    Task {
                        await processImage()
                    }
                } label: {
                    Text("Retry with this photo")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.homePurple)
                }
            }
            .padding(.horizontal, 40)
            .padding(.top, 8)
        }
    }
    
    // MARK: - Card Preview
    
    private func cardPreview(dogImage: UIImage) -> some View {
        ZStack {
            Image("card_bg_clean")
                .resizable()
                .scaledToFill()
                .frame(height: 160)
                .clipShape(RoundedRectangle(cornerRadius: 20))
            
            HStack {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Today's Walk")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.textSecondary)
                    
                    HStack(alignment: .lastTextBaseline, spacing: 4) {
                        Text("45")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.homePurple)
                        Text("/120 min")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.textSecondary)
                    }
                    
                    Text("Let's go!")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.homePurple)
                        .clipShape(Capsule())
                }
                .padding(.leading, 20)
                
                Spacer()
                
                Image(uiImage: dogImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 130, height: 140)
                    .padding(.trailing, 8)
            }
        }
        .frame(height: 160)
        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
    }
    
    // MARK: - Processing
    
    private func processImage() async {
        do {
            let result = try await BackgroundRemovalService.removeBackground(from: originalImage)
            unadjustedImage = result
            processedImage = result
            isProcessing = false
        } catch {
            errorMessage = error.localizedDescription
            isProcessing = false
        }
    }
}

// MARK: - Checkerboard Pattern

struct CheckerboardView: View {
    let squareSize: CGFloat = 12
    
    var body: some View {
        Canvas { context, size in
            let cols = Int(size.width / squareSize) + 1
            let rows = Int(size.height / squareSize) + 1
            
            for row in 0..<rows {
                for col in 0..<cols {
                    let isLight = (row + col) % 2 == 0
                    let rect = CGRect(
                        x: CGFloat(col) * squareSize,
                        y: CGFloat(row) * squareSize,
                        width: squareSize,
                        height: squareSize
                    )
                    context.fill(
                        Path(rect),
                        with: .color(isLight ? Color(white: 0.92) : Color(white: 0.82))
                    )
                }
            }
        }
    }
}
