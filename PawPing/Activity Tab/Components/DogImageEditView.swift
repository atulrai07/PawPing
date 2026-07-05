//
//  DogImageEditView.swift
//  PawPing
//
//  Enables manual resizing (zooming) and positioning (cropping) of the
//  background-removed dog image.
//

import SwiftUI

struct DogImageEditView: View {
    let image: UIImage
    var onSave: (UIImage) -> Void
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    
    // Zoom/scale state
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    
    // Offset/pan state
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    
    // Crop container size
    private let containerSize = CGSize(width: 300, height: 300)
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()
                
                // Crop area
                VStack(spacing: 12) {
                    Text("Pinch to zoom, drag to position")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.textSecondary)
                    
                    ZStack {
                        // Checkerboard background
                        CheckerboardView()
                            .frame(width: containerSize.width, height: containerSize.height)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.primary.opacity(0.15), lineWidth: 1)
                            )
                        
                        // Image with adjustments
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(width: containerSize.width, height: containerSize.height)
                            .offset(offset)
                            .scaleEffect(scale)
                            .gesture(
                                DragGesture()
                                    .onChanged { value in
                                        offset = CGSize(
                                            width: lastOffset.width + value.translation.width,
                                            height: lastOffset.height + value.translation.height
                                        )
                                    }
                                    .onEnded { _ in
                                        lastOffset = offset
                                    }
                            )
                            .simultaneousGesture(
                                MagnificationGesture()
                                    .onChanged { value in
                                        scale = max(0.2, min(5.0, lastScale * value))
                                    }
                                    .onEnded { _ in
                                        lastScale = scale
                                    }
                            )
                    }
                    .frame(width: containerSize.width, height: containerSize.height)
                    .clipped() // Clip outside the crop container bounds
                    .background(colorScheme == .dark ? Color.white.opacity(0.05) : Color.black.opacity(0.05))
                    .cornerRadius(16)
                }
                
                // Controls
                VStack(spacing: 20) {
                    // Zoom slider
                    HStack(spacing: 12) {
                        Image(systemName: "minus.magnifyingglass")
                            .font(.system(size: 14))
                            .foregroundColor(.textSecondary)
                        
                        Slider(value: $scale, in: 0.5...4.0)
                            .tint(Color.homePurple)
                            .onChange(of: scale) { _, newValue in
                                lastScale = newValue
                            }
                        
                        Image(systemName: "plus.magnifyingglass")
                            .font(.system(size: 14))
                            .foregroundColor(.textSecondary)
                    }
                    .padding(.horizontal, 32)
                    
                    // Reset button
                    Button(action: resetToDefault) {
                        Label("Reset Adjustments", systemImage: "arrow.counterclockwise")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(Color.homePurple)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.homePurple.opacity(0.1))
                            .clipShape(Capsule())
                    }
                }
                
                Spacer()
            }
            .background(
                LinearGradient(
                    colors: colorScheme == .dark
                        ? [Color(white: 0.08), Color(white: 0.12)]
                        : [Color(white: 0.96), Color(white: 1.0)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            )
            .navigationTitle("Crop & Resize")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveCroppedImage()
                    }
                    .fontWeight(.semibold)
                    .foregroundColor(Color.homePurple)
                }
            }
        }
    }
    
    private func resetToDefault() {
        withAnimation(.spring()) {
            scale = 1.0
            lastScale = 1.0
            offset = .zero
            lastOffset = .zero
        }
    }
    
    private func saveCroppedImage() {
        if let cropped = cropImage(image, scale: scale, offset: offset, containerSize: containerSize) {
            onSave(cropped)
            dismiss()
        }
    }
    
    private func cropImage(_ image: UIImage, scale: CGFloat, offset: CGSize, containerSize: CGSize) -> UIImage? {
        let containerWidth = containerSize.width
        let containerHeight = containerSize.height
        let imageWidth = image.size.width
        let imageHeight = image.size.height
        
        let scaleX = containerWidth / imageWidth
        let scaleY = containerHeight / imageHeight
        let fitScale = min(scaleX, scaleY)
        
        let fitWidth = imageWidth * fitScale
        let fitHeight = imageHeight * fitScale
        
        let format = UIGraphicsImageRendererFormat()
        format.scale = image.scale
        format.opaque = false
        
        let renderer = UIGraphicsImageRenderer(size: containerSize, format: format)
        
        return renderer.image { context in
            let centerX = containerWidth / 2
            let centerY = containerHeight / 2
            
            let drawWidth = fitWidth * scale
            let drawHeight = fitHeight * scale
            
            let x = centerX - (drawWidth / 2) + offset.width
            let y = centerY - (drawHeight / 2) + offset.height
            
            image.draw(in: CGRect(x: x, y: y, width: drawWidth, height: drawHeight))
        }
    }
}
