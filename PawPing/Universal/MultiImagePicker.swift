//
//  MultiImagePicker.swift
//  PawPing
//

import SwiftUI
import PhotosUI

struct MultiImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImages: [UIImage]
    @Environment(\.dismiss) var dismiss
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        configuration.selectionLimit = 0 // 0 means unlimited
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: MultiImagePicker
        
        init(_ parent: MultiImagePicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            parent.dismiss()
            
            let group = DispatchGroup()
            var loadedImages = [UIImage]()
            
            // Order is not guaranteed by default async loading, but we can load them
            for result in results {
                if result.itemProvider.canLoadObject(ofClass: UIImage.self) {
                    group.enter()
                    result.itemProvider.loadObject(ofClass: UIImage.self) { image, error in
                        if let image = image as? UIImage {
                            // Append safely in a thread-safe way or on main thread
                            DispatchQueue.main.async {
                                loadedImages.append(image)
                            }
                        }
                        group.leave()
                    }
                }
            }
            
            group.notify(queue: .main) {
                if !loadedImages.isEmpty {
                    self.parent.selectedImages = loadedImages
                }
            }
        }
    }
}
