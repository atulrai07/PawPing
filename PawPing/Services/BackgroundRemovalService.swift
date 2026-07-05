//
//  BackgroundRemovalService.swift
//  PawPing
//
//  Removes the background from a dog photo using Apple's Vision framework.
//  Uses VNGenerateForegroundInstanceMaskRequest (iOS 17+) for on-device,
//  Neural-Engine-accelerated subject segmentation.
//

import UIKit
import Vision
import CoreImage
import CoreImage.CIFilterBuiltins

enum BackgroundRemovalError: LocalizedError {
    case noSubjectFound
    case maskGenerationFailed
    case imageProcessingFailed
    case inputImageInvalid
    
    var errorDescription: String? {
        switch self {
        case .noSubjectFound:
            return "No subject was detected in the image. Try again with your dog clearly visible and good lighting."
        case .maskGenerationFailed:
            return "Failed to generate the subject mask. Please try again."
        case .imageProcessingFailed:
            return "Failed to process the image. Please try with a different photo."
        case .inputImageInvalid:
            return "The selected image could not be read."
        }
    }
}

final class BackgroundRemovalService {
    
    private static let ciContext = CIContext(options: [.useSoftwareRenderer: false])
    
    /// Removes the background from the given image, returning a transparent-background PNG.
    /// Runs the heavy Vision work on a background thread.
    static func removeBackground(from image: UIImage) async throws -> UIImage {
        guard let cgImage = image.cgImage else {
            throw BackgroundRemovalError.inputImageInvalid
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    let result = try performRemoval(cgImage: cgImage, orientation: image.imageOrientation)
                    DispatchQueue.main.async {
                        continuation.resume(returning: result)
                    }
                } catch {
                    DispatchQueue.main.async {
                        continuation.resume(throwing: error)
                    }
                }
            }
        }
    }
    
    private static func performRemoval(cgImage: CGImage, orientation: UIImage.Orientation) throws -> UIImage {
        // 1. Create the foreground instance mask request
        let request = VNGenerateForegroundInstanceMaskRequest()
        
        // Map UIImage.Orientation → CGImagePropertyOrientation for the handler
        let cgOrientation = CGImagePropertyOrientation(orientation)
        let handler = VNImageRequestHandler(cgImage: cgImage, orientation: cgOrientation, options: [:])
        
        // 2. Perform the request
        try handler.perform([request])
        
        guard let observation = request.results?.first else {
            throw BackgroundRemovalError.noSubjectFound
        }
        
        // 3. Generate a scaled mask covering all detected instances
        let allInstances = observation.allInstances
        guard !allInstances.isEmpty else {
            throw BackgroundRemovalError.noSubjectFound
        }
        
        let maskPixelBuffer = try observation.generateScaledMaskForImage(
            forInstances: allInstances,
            from: handler
        )
        
        // 4. Convert mask pixel buffer to CIImage
        let maskCIImage = CIImage(cvPixelBuffer: maskPixelBuffer)
        
        // 5. Create CIImage from original
        let originalCIImage = CIImage(cgImage: cgImage)
        
        // 6. Apply the mask to isolate the subject with transparent background
        //    We blend the original image with a clear (transparent) background using the mask.
        let filter = CIFilter.blendWithMask()
        filter.inputImage = originalCIImage
        filter.backgroundImage = CIImage.empty()  // Transparent background
        filter.maskImage = maskCIImage
        
        guard let outputCIImage = filter.outputImage else {
            throw BackgroundRemovalError.imageProcessingFailed
        }
        
        // 7. Render to CGImage
        let renderRect = outputCIImage.extent
        guard let outputCGImage = ciContext.createCGImage(outputCIImage, from: renderRect) else {
            throw BackgroundRemovalError.imageProcessingFailed
        }
        
        let resultImage = UIImage(cgImage: outputCGImage, scale: 1.0, orientation: orientation)
        return resultImage.trimmingTransparency() ?? resultImage
    }
}

// MARK: - CGImagePropertyOrientation Helper

extension CGImagePropertyOrientation {
    init(_ uiOrientation: UIImage.Orientation) {
        switch uiOrientation {
        case .up:            self = .up
        case .upMirrored:    self = .upMirrored
        case .down:          self = .down
        case .downMirrored:  self = .downMirrored
        case .left:          self = .left
        case .leftMirrored:  self = .leftMirrored
        case .right:         self = .right
        case .rightMirrored: self = .rightMirrored
        @unknown default:    self = .up
        }
    }
}

// MARK: - UIImage Transparency Trimming

extension UIImage {
    func trimmingTransparency() -> UIImage? {
        // Use UIGraphicsImageRenderer to normalize and draw the image at its exact point size.
        // This handles scale, orientation, and format normalization automatically!
        let renderer = UIGraphicsImageRenderer(size: self.size)
        
        // We render it as a standard RGBA image
        let normalizedImage = renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: self.size))
        }
        
        guard let cgImage = normalizedImage.cgImage else { return self }
        
        let width = cgImage.width
        let height = cgImage.height
        
        // Get the pixel data of the normalized CGImage
        guard let dataProvider = cgImage.dataProvider,
              let data = dataProvider.data,
              let ptr = CFDataGetBytePtr(data) else {
            return self
        }
        
        let bytesPerPixel = 4
        let bytesPerRow = cgImage.bytesPerRow
        
        var minX = width
        var minY = height
        var maxX = 0
        var maxY = 0
        
        for y in 0..<height {
            for x in 0..<width {
                let pixelIndex = (y * bytesPerRow) + (x * bytesPerPixel)
                let alpha = ptr[pixelIndex + 3]
                
                if alpha > 10 { // Alpha threshold
                    if x < minX { minX = x }
                    if x > maxX { maxX = x }
                    if y < minY { minY = y }
                    if y > maxY { maxY = y }
                }
            }
        }
        
        if minX > maxX || minY > maxY {
            return self
        }
        
        // Add padding
        let padding = 16
        minX = max(0, minX - padding)
        minY = max(0, minY - padding)
        maxX = min(width - 1, maxX + padding)
        maxY = min(height - 1, maxY + padding)
        
        let cropWidth = maxX - minX + 1
        let cropHeight = maxY - minY + 1
        
        let cropRect = CGRect(x: minX, y: minY, width: cropWidth, height: cropHeight)
        
        guard let croppedCGImage = cgImage.cropping(to: cropRect) else {
            return self
        }
        
        // Since it was created using UIGraphicsImageRenderer, the scale matches, and orientation is .up
        return UIImage(cgImage: croppedCGImage, scale: normalizedImage.scale, orientation: .up)
    }
}
