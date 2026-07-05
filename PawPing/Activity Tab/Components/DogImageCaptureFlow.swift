//
//  DogImageCaptureFlow.swift
//  PawPing
//
//  Container view that orchestrates the dog image capture flow:
//  Camera → Background Removal → Preview → Confirm.
//  Similar in pattern to WalkFlowContainer.
//

import SwiftUI

struct DogImageCaptureFlow: View {
    let petId: UUID
    let walkCardImageStore: WalkCardImageStore
    var onDismiss: () -> Void
    
    @State private var capturedImage: UIImage? = nil
    @State private var showPreview = false
    
    var body: some View {
        if let captured = capturedImage, showPreview {
            DogImagePreviewView(
                originalImage: captured,
                petId: petId,
                onConfirm: { processedImage in
                    // Save the image and dismiss
                    Task {
                        await walkCardImageStore.setImage(processedImage, for: petId)
                        onDismiss()
                    }
                },
                onRetake: {
                    // Go back to camera
                    withAnimation {
                        capturedImage = nil
                        showPreview = false
                    }
                },
                onCancel: {
                    onDismiss()
                }
            )
            .transition(.move(edge: .trailing))
        } else {
            DogCameraView { image in
                withAnimation {
                    capturedImage = image
                    showPreview = true
                }
            }
            .transition(.move(edge: .leading))
        }
    }
}
