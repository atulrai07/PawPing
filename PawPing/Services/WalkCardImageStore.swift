//
//  WalkCardImageStore.swift
//  PawPing
//
//  Manages local persistence and Supabase sync for custom walk card dog images.
//  Each pet gets its own image, stored as a transparent PNG in the app's Documents directory.
//

import Foundation
import UIKit
import Observation
import Supabase

@MainActor
@Observable
class WalkCardImageStore {
    
    // MARK: - In-memory cache (per-pet)
    
    /// Cached UIImages keyed by pet ID for instant access without disk reads.
    private var imageCache: [UUID: UIImage] = [:]
    
    /// Tracks whether each pet has a custom image (quick check without disk access).
    private var customImageFlags: [UUID: Bool] = [:]
    
    // MARK: - Public API
    
    /// Returns the custom walk card image for the given pet, or nil if none is set.
    func loadImage(for petId: UUID) -> UIImage? {
        // Check memory cache first
        if let cached = imageCache[petId] {
            return cached
        }
        
        // Try loading from disk
        let path = localImagePath(for: petId)
        if FileManager.default.fileExists(atPath: path.path),
           let image = UIImage(contentsOfFile: path.path) {
            imageCache[petId] = image
            customImageFlags[petId] = true
            return image
        }
        
        customImageFlags[petId] = false
        return nil
    }
    
    /// Returns true if the pet has a custom walk card image set.
    func hasCustomImage(for petId: UUID) -> Bool {
        if let flag = customImageFlags[petId] {
            return flag
        }
        
        let exists = FileManager.default.fileExists(atPath: localImagePath(for: petId).path)
        customImageFlags[petId] = exists
        return exists
    }
    
    /// Saves the processed (background-removed) image locally and uploads to Supabase.
    func setImage(_ image: UIImage, for petId: UUID) async {
        // 1. Save to local file system
        saveImageLocally(image, for: petId)
        
        // 2. Update in-memory cache
        imageCache[petId] = image
        customImageFlags[petId] = true
        
        // 3. Upload to Supabase in background
        await uploadToSupabase(image, for: petId)
    }
    
    /// Removes the custom image and reverts to the default dog.
    func resetToDefault(for petId: UUID) async {
        // 1. Remove local file
        let path = localImagePath(for: petId)
        try? FileManager.default.removeItem(at: path)
        
        // 2. Clear cache
        imageCache.removeValue(forKey: petId)
        customImageFlags[petId] = false
        
        // 3. Clear Supabase reference
        await clearSupabaseImage(for: petId)
    }
    
    /// Downloads the walk card image from Supabase if available locally.
    /// Called on app launch / pet switch to ensure sync.
    func syncFromSupabase(for petId: UUID, imageUrl: String?) async {
        // If we already have a local image, skip download
        if hasCustomImage(for: petId) { return }
        
        // If there's a cloud URL, download and cache locally
        guard let urlString = imageUrl, !urlString.isEmpty,
              let url = URL(string: urlString) else { return }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let image = UIImage(data: data) {
                saveImageLocally(image, for: petId)
                imageCache[petId] = image
                customImageFlags[petId] = true
            }
        } catch {
            print("  Failed to download walk card image from Supabase: \(error)")
        }
    }
    
    /// Cleans up all data for a deleted pet.
    func cleanUp(for petId: UUID) {
        let path = localImagePath(for: petId)
        try? FileManager.default.removeItem(at: path)
        imageCache.removeValue(forKey: petId)
        customImageFlags.removeValue(forKey: petId)
    }
    
    // MARK: - Local File System
    
    private func localImagePath(for petId: UUID) -> URL {
        let documentsDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let imagesDir = documentsDir.appendingPathComponent("walk_card_images", isDirectory: true)
        
        // Ensure directory exists
        if !FileManager.default.fileExists(atPath: imagesDir.path) {
            try? FileManager.default.createDirectory(at: imagesDir, withIntermediateDirectories: true)
        }
        
        return imagesDir.appendingPathComponent("\(petId.uuidString).png")
    }
    
    private func saveImageLocally(_ image: UIImage, for petId: UUID) {
        let path = localImagePath(for: petId)
        if let pngData = image.pngData() {
            try? pngData.write(to: path)
        }
    }
    
    // MARK: - Supabase Sync
    
    private func uploadToSupabase(_ image: UIImage, for petId: UUID) async {
        do {
            guard let pngData = image.pngData() else { return }
            
            // Walk card images need transparency, so always use PNG
            let uploadData = pngData
            
            let fileName = "\(petId.uuidString).png"
            
            // Upload to Supabase Storage (upsert: overwrite if exists)
            try await SupabaseConfig.client.storage
                .from("walk-card-images")
                .upload(
                    fileName,
                    data: uploadData,
                    options: FileOptions(
                        contentType: "image/png",
                        upsert: true
                    )
                )
            
            // Get public URL
            let publicURL = try SupabaseConfig.client.storage
                .from("walk-card-images")
                .getPublicURL(path: fileName)
            
            // Update the pet record with the image URL
            try await SupabaseConfig.client
                .from("pets")
                .update(["walk_card_image_url": publicURL.absoluteString])
                .eq("id", value: petId)
                .execute()
            
            print("Walk card image uploaded and pet record updated for \(petId)")
        } catch {
            print("  Failed to upload walk card image to Supabase: \(error)")
        }
    }
    
    private func clearSupabaseImage(for petId: UUID) async {
        do {
            // Remove from storage
            let fileName = "\(petId.uuidString).png"
            try await SupabaseConfig.client.storage
                .from("walk-card-images")
                .remove(paths: [fileName])
            
            // Clear the URL in the pet record
            let nullValue: String? = nil
            try await SupabaseConfig.client
                .from("pets")
                .update(["walk_card_image_url": nullValue])
                .eq("id", value: petId)
                .execute()
            
            print("Walk card image cleared for \(petId)")
        } catch {
            print("  Failed to clear walk card image from Supabase: \(error)")
        }
    }
}
