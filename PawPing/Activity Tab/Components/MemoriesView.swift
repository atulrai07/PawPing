//
//  MemoriesView.swift
//  PawPing
//

import SwiftUI
import UIKit
import PhotosUI

// MARK: - Redesigned Memory Card View
struct HomeMemoryCard: View {
    let memory: PetMemory
    let displayType: ActivityView.HomeMemoryDisplayType
    @Environment(\.colorScheme) private var colorScheme
    
    var dateString: String {
        let calendar = Calendar.current
        if calendar.isDateInToday(memory.createdAt) {
            return "Today"
        } else if calendar.isDateInYesterday(memory.createdAt) {
            return "Yesterday"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d, yyyy"
            return formatter.string(from: memory.createdAt)
        }
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Left Side: Cards stack layout
            cardsLayout(urls: memory.allImageUrls)
                .frame(width: 110, height: 110)
                .padding(.leading, 14)
            
            // Right Side: Info Details
            VStack(alignment: .leading, spacing: 4) {
                Text(dateString)
                    .font(.system(size: 13))
                    .foregroundColor(.textSecondary)
                
                Text(memory.displayName)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.textPrimary)
                    .lineLimit(1)
                
                Text(memory.displayLocation)
                    .font(.system(size: 13))
                    .foregroundColor(.textSecondary)
                    .lineLimit(1)
                
                Spacer(minLength: 0)
                
                HStack(spacing: 6) {
                    Image(systemName: "photo.on.rectangle")
                        .font(.system(size: 12))
                    Text("\(memory.allImageUrls.count) \(memory.allImageUrls.count == 1 ? "photo" : "photos")")
                        .font(.system(size: 12, weight: .medium))
                    Image(systemName: "chevron.right")
                        .font(.system(size: 8, weight: .bold))
                }
                .foregroundColor(.textSecondary)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(colorScheme == .dark ? Color.white.opacity(0.1) : Color.black.opacity(0.05))
                .clipShape(Capsule())
            }
            .padding(.vertical, 14)
            .padding(.trailing, 14)
            
            Spacer(minLength: 0)
        }
        .frame(width: 296, height: 140)
        .background(colorScheme == .dark ? Color(white: 0.12) : (Color(hex: "F8F9FB") ?? Color(.systemGray6)))
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }
    
    @ViewBuilder
    private func cardsLayout(urls: [String]) -> some View {
        if urls.isEmpty {
            noPicView
                .frame(width: 82, height: 82)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white, lineWidth: 1.5)
                )
                .shadow(color: .black.opacity(0.15), radius: 4, x: 0, y: 2)
        } else {
            ZStack {
                let maxCards = 3
                ForEach(0..<maxCards, id: \.self) { idx in
                    let urlString = urls[idx % urls.count]
                    
                    AsyncImage(url: URL(string: urlString)) { image in
                        image.resizable()
                            .scaledToFill()
                            .frame(width: 82, height: 82)
                            .clipped()
                    } placeholder: {
                        Color.gray.opacity(0.15)
                    }
                    .frame(width: 82, height: 82)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white, lineWidth: 1.5)
                    )
                    .shadow(color: .black.opacity(0.15), radius: 4, x: 0, y: 2)
                    .rotationEffect(.degrees(rotationForIndex(idx)))
                    .offset(x: offsetXForIndex(idx), y: offsetYForIndex(idx))
                }
            }
        }
    }
    
    private var noPicView: some View {
        VStack(spacing: 6) {
            Image(systemName: "photo.on.rectangle.angled")
                .font(.system(size: 24))
                .foregroundColor(.gray.opacity(0.8))
            Text("No pic")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.gray.opacity(0.8))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .background(colorScheme == .dark ? Color(white: 0.15) : (Color(hex: "F2F2F7") ?? Color(.systemGray6)))
    }
    
    private func rotationForIndex(_ index: Int) -> Double {
        switch index {
        case 0: return -8.0   // Back card: tilted counter-clockwise
        case 1: return 6.0    // Middle card: tilted clockwise
        case 2: return -3.0   // Front card: tilted slightly counter-clockwise
        default: return 0.0
        }
    }
    
    private func offsetXForIndex(_ index: Int) -> CGFloat {
        switch index {
        case 0: return -8.0   // Shifted left
        case 1: return 4.0    // Shifted right
        case 2: return 0.0    // Front card centered
        default: return 0.0
        }
    }
    
    private func offsetYForIndex(_ index: Int) -> CGFloat {
        switch index {
        case 0: return -4.0   // Shifted up
        case 1: return -2.0   // Shifted slightly up
        case 2: return 8.0    // Front card shifted down
        default: return 0.0
        }
    }
}

// MARK: - Memories Gallery View
struct MemoriesGalleryView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(ActivityStore.self) var store
    @Environment(PetStore.self) var petStore
    
    @State private var showCreateAlbum = false
    @State private var selectedMemory: PetMemory? = nil
    
    let columns = [GridItem(.flexible(), spacing: 16), GridItem(.flexible(), spacing: 16)]
    
    var body: some View {
        ScrollView {
            if store.memories.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "photo.on.rectangle.angled")
                        .font(.system(size: 40))
                        .foregroundColor(.gray.opacity(0.5))
                    Text("No albums yet.\nTap + to create one!")
                        .multilineTextAlignment(.center)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(.gray)
                }
                .padding(.top, 80)
            } else {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(store.memories) { memory in
                        Button {
                            selectedMemory = memory
                        } label: {
                            VStack(alignment: .leading, spacing: 8) {
                                ZStack(alignment: .bottomTrailing) {
                                    AsyncImage(url: URL(string: memory.imageUrl)) { image in
                                        image
                                            .resizable()
                                            .scaledToFill()
                                            .frame(minWidth: 0, maxWidth: .infinity)
                                            .frame(height: 150)
                                            .clipped()
                                    } placeholder: {
                                        Color.gray.opacity(0.2)
                                            .frame(maxWidth: .infinity, minHeight: 150)
                                    }
                                    .frame(height: 150)
                                    .frame(maxWidth: .infinity)
                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                                    
                                    // Photos Count Badge
                                    Text("\(memory.allImageUrls.count) \(memory.allImageUrls.count == 1 ? "photo" : "photos")")
                                        .font(.system(size: 11, weight: .bold))
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Color.black.opacity(0.6))
                                        .clipShape(Capsule())
                                        .padding(8)
                                }
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(memory.displayName)
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(.textPrimary)
                                        .lineLimit(1)
                                    
                                    HStack(spacing: 2) {
                                        Image(systemName: "mappin.and.ellipse")
                                            .font(.system(size: 10))
                                            .foregroundColor(.textSecondary)
                                        Text(memory.displayLocation)
                                            .font(.system(size: 11))
                                            .foregroundColor(.textSecondary)
                                            .lineLimit(1)
                                    }
                                }
                                .padding(.horizontal, 4)
                            }
                        }
                        .buttonStyle(.plain)
                        .contextMenu {
                            Button(role: .destructive) {
                                withAnimation {
                                    store.deleteMemory(id: memory.id)
                                }
                            } label: {
                                Label("Delete Album", systemImage: "trash")
                            }
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.top, 24)
                .padding(.bottom, 24)
            }
        }
        .background(Color(.systemBackground))
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(Color(hex: "6E54D7") ?? .purple)
                }
                .accessibilityLabel("Back")
            }
            
            ToolbarItem(placement: .principal) {
                Text("Photo Albums")
                    .font(.system(size: 17, weight: .semibold))
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showCreateAlbum = true
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(Color(hex: "6E54D7") ?? .purple)
                }
                .accessibilityLabel("Create Album")
            }
        }
        .sheet(isPresented: $showCreateAlbum) {
            CreateAlbumSheet()
        }
        .fullScreenCover(item: $selectedMemory) { memory in
            MemoryDetailView(memory: memory) {
                store.deleteMemory(id: memory.id)
                selectedMemory = nil
            }
        }
    }
}

// MARK: - Create Album Sheet
struct CreateAlbumSheet: View {
    @Environment(\.dismiss) var dismiss
    @Environment(ActivityStore.self) var store
    @Environment(PetStore.self) var petStore
    
    @State private var name = ""
    @State private var location = ""
    @State private var date = Date()
    
    // Picked photos
    @State private var selectedImages: [UIImage] = []
    
    // Modals
    @State private var showLibraryPicker = false
    @State private var showCameraPicker = false
    @State private var cameraImage: UIImage? = nil
    
    @State private var isSaving = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Album Info")) {
                    TextField("Album Name (e.g. Beach Fun)", text: $name)
                    TextField("Location (e.g. Malibu Beach)", text: $location)
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                }
                
                Section(header: Text("Photos (\(selectedImages.count))")) {
                    if selectedImages.isEmpty {
                        Text("No photos selected yet.")
                            .foregroundColor(.gray)
                            .font(.system(size: 14))
                            .padding(.vertical, 8)
                    } else {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(Array(selectedImages.enumerated()), id: \.offset) { idx, img in
                                    ZStack(alignment: .topTrailing) {
                                        Image(uiImage: img)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 80, height: 80)
                                            .clipShape(RoundedRectangle(cornerRadius: 12))
                                            .clipped()
                                        
                                        Button {
                                            selectedImages.remove(at: idx)
                                        } label: {
                                            Image(systemName: "xmark.circle.fill")
                                                .foregroundColor(.red)
                                                .background(Color.white.clipShape(Circle()))
                                        }
                                        .offset(x: 4, y: -4)
                                    }
                                }
                            }
                            .padding(.vertical, 8)
                        }
                    }
                    
                    HStack {
                        Button {
                            showCameraPicker = true
                        } label: {
                            Label("Camera", systemImage: "camera")
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)
                        }
                        .frame(maxWidth: .infinity)
                        .buttonStyle(.bordered)
                        
                        Button {
                            showLibraryPicker = true
                        } label: {
                            Label("Gallery", systemImage: "photo.on.rectangle")
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)
                        }
                        .frame(maxWidth: .infinity)
                        .buttonStyle(.bordered)
                    }
                }
            }
            .navigationTitle("Create Album")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .disabled(isSaving)
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    if isSaving {
                        ProgressView()
                    } else {
                        Button("Create") {
                            saveAlbum()
                        }
                        .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || selectedImages.isEmpty)
                    }
                }
            }
            .sheet(isPresented: $showLibraryPicker) {
                MultiImagePicker(selectedImages: $selectedImages)
            }
            .fullScreenCover(isPresented: $showCameraPicker) {
                ImagePicker(selectedImage: $cameraImage, sourceType: .camera)
                    .ignoresSafeArea()
            }
            .onChange(of: cameraImage) { _, newImg in
                if let newImg {
                    selectedImages.append(newImg)
                    cameraImage = nil
                }
            }
        }
    }
    
    private func saveAlbum() {
        isSaving = true
        Task {
            await store.addMemoryAlbum(
                name: name,
                location: location.isEmpty ? "Somewhere Fun" : location,
                date: date,
                images: selectedImages,
                petStore: petStore
            )
            isSaving = false
            dismiss()
        }
    }
}

// MARK: - Memory Detail View
struct MemoryDetailView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(ActivityStore.self) var store
    @Environment(PetStore.self) var petStore
    @Environment(\.colorScheme) var colorScheme
    
    let memory: PetMemory
    let onDelete: () -> Void
    
    @State private var currentImageIndex = 0
    @State private var selectedPhotoIndex: Int? = nil
    @State private var showLibraryPicker = false
    @State private var showCameraPicker = false
    @State private var showEditSheet = false
    @State private var pickedImages: [UIImage] = []
    @State private var pickedCameraImage: UIImage? = nil
    @State private var isAddingImages = false
    @State private var isFocused = false
    
    // Selection Mode states
    @State private var isSelectionMode = false
    @State private var selectedPhotoUrls: Set<String> = []
    
    private var currentMemory: PetMemory {
        store.memories.first { $0.id == memory.id } ?? memory
    }
    
    private var isDark: Bool { colorScheme == .dark }
    private var bgColor: Color { isDark ? .black : .white }
    private var textColor: Color { isDark ? .white : .primary }
    private var secondaryTextColor: Color { isDark ? .white.opacity(0.7) : .secondary }
    private var buttonBgColor: Color { isDark ? Color.white.opacity(0.12) : Color.black.opacity(0.06) }
    
    var body: some View {
        Group {
            if let selectedIndex = selectedPhotoIndex {
                photoDetailViewer(urls: currentMemory.allImageUrls, startIndex: selectedIndex)
            } else {
                albumGridView(urls: currentMemory.allImageUrls)
            }
        }
        .background(bgColor.ignoresSafeArea())
        .sheet(isPresented: $showLibraryPicker) {
            MultiImagePicker(selectedImages: $pickedImages)
        }
        .sheet(isPresented: $showEditSheet) {
            EditAlbumSheet(album: currentMemory)
        }
        .fullScreenCover(isPresented: $showCameraPicker) {
            ImagePicker(selectedImage: $pickedCameraImage, sourceType: .camera)
                .ignoresSafeArea()
        }
        .onChange(of: pickedCameraImage) { _, newImg in
            if let newImg {
                pickedImages.append(newImg)
                pickedCameraImage = nil
            }
        }
        .onChange(of: pickedImages) { _, images in
            if !images.isEmpty {
                isAddingImages = true
                Task {
                    await store.addImagesToAlbum(albumId: currentMemory.id, images: images, petStore: petStore)
                    pickedImages = []
                    isAddingImages = false
                }
            }
        }
    }
    
    @ViewBuilder
    private func albumGridView(urls: [String]) -> some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Album Metadata Header
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 4) {
                            Image(systemName: "mappin.and.ellipse")
                                .font(.system(size: 12))
                                .foregroundColor(.textSecondary)
                            Text(currentMemory.displayLocation)
                                .font(.system(size: 14))
                                .foregroundColor(.textSecondary)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                    
                    if isAddingImages {
                        VStack(spacing: 12) {
                            ProgressView()
                                .tint(textColor)
                            Text("Adding photos to album...")
                                .foregroundColor(secondaryTextColor)
                                .font(.caption)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 40)
                    } else if urls.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "photo.on.rectangle.angled")
                                .font(.system(size: 40))
                                .foregroundColor(.gray.opacity(0.5))
                            Text("No photos in this album.")
                                .foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 60)
                    } else {
                        // Grid layout
                        let columns = [
                            GridItem(.flexible(), spacing: 10),
                            GridItem(.flexible(), spacing: 10),
                            GridItem(.flexible(), spacing: 10)
                        ]
                        
                        LazyVGrid(columns: columns, spacing: 10) {
                            ForEach(Array(urls.enumerated()), id: \.element) { idx, urlStr in
                                Button {
                                    if isSelectionMode {
                                        if selectedPhotoUrls.contains(urlStr) {
                                            selectedPhotoUrls.remove(urlStr)
                                        } else {
                                            selectedPhotoUrls.insert(urlStr)
                                        }
                                    } else {
                                        currentImageIndex = idx
                                        selectedPhotoIndex = idx
                                    }
                                } label: {
                                    ZStack(alignment: .bottomTrailing) {
                                        GeometryReader { geo in
                                            AsyncImage(url: URL(string: urlStr)) { image in
                                                image.resizable()
                                                    .scaledToFill()
                                                    .frame(width: geo.size.width, height: geo.size.width)
                                                    .clipped()
                                            } placeholder: {
                                                Color.gray.opacity(0.15)
                                                    .overlay(ProgressView().tint(textColor))
                                            }
                                            .frame(width: geo.size.width, height: geo.size.width)
                                            .clipShape(RoundedRectangle(cornerRadius: 12))
                                        }
                                        .aspectRatio(1, contentMode: .fit)
                                        
                                        if isSelectionMode {
                                            let isSelected = selectedPhotoUrls.contains(urlStr)
                                            Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                                                .font(.system(size: 20))
                                                .foregroundColor(isSelected ? (Color(hex: "6E54D7") ?? .purple) : .white)
                                                .background(Circle().fill(Color.black.opacity(0.2)))
                                                .padding(6)
                                        }
                                    }
                                }
                                .buttonStyle(.plain)
                                .contextMenu {
                                    if !isSelectionMode {
                                        if let shareUrl = URL(string: urlStr) {
                                            ShareLink(item: shareUrl) {
                                                Label("Share Photo", systemImage: "square.and.arrow.up")
                                            }
                                        }
                                        Button(role: .destructive) {
                                            deletePhoto(urlStr)
                                        } label: {
                                            Label("Delete Photo", systemImage: "trash")
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.top, 8)
                .padding(.bottom, 90) // Leave space for Floating Add Button or Selection Toolbar
            }
            .background(bgColor)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    if !isSelectionMode {
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(Color(hex: "6E54D7") ?? .purple)
                        }
                        .accessibilityLabel("Back")
                    } else {
                        // Empty spacer to keep layout balanced in selection mode
                        Color.clear.frame(width: 36, height: 36)
                    }
                }
                
                ToolbarItem(placement: .principal) {
                    Text(isSelectionMode ? "Select Items" : currentMemory.displayName)
                        .font(.system(size: 17, weight: .semibold))
                        .lineLimit(1)
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    if !isSelectionMode {
                        // Pill container with ellipsis menu + Select button
                        HStack(spacing: 4) {
                            Menu {
                                Button {
                                    showEditSheet = true
                                } label: {
                                    Label("Edit Details", systemImage: "pencil")
                                }
                                
                                Button(role: .destructive) {
                                    onDelete()
                                } label: {
                                    Label("Delete Album", systemImage: "trash")
                                }
                            } label: {
                                Image(systemName: "ellipsis.circle")
                                    .font(.system(size: 22, weight: .medium))
                                    .foregroundColor(Color(hex: "6E54D7") ?? .purple)
                            }
                            .accessibilityLabel("More Options")
                            
                            Button {
                                withAnimation {
                                    isSelectionMode = true
                                    selectedPhotoUrls.removeAll()
                                }
                            } label: {
                                Text("Select")
                                    .font(.system(size: 17, weight: .semibold))
                                    .foregroundColor(Color(hex: "6E54D7") ?? .purple)
                            }
                            .accessibilityLabel("Select Photos")
                        }

                    } else {
                        Button {
                            withAnimation {
                                isSelectionMode = false
                                selectedPhotoUrls.removeAll()
                            }
                        } label: {
                            Text("Cancel")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(Color(hex: "6E54D7") ?? .purple)
                        }
                    }
                }
            }
            .toolbar(isSelectionMode ? .visible : .hidden, for: .bottomBar)
            .toolbarBackground(.visible, for: .bottomBar)
            .toolbar {
                if isSelectionMode {
                    ToolbarItemGroup(placement: .bottomBar) {
                        let shareUrls = Array(selectedPhotoUrls).compactMap { URL(string: $0) }
                        ShareLink(items: shareUrls) {
                            Image(systemName: "square.and.arrow.up")
                        }
                        .disabled(selectedPhotoUrls.isEmpty)
                        .tint(selectedPhotoUrls.isEmpty ? .gray : (Color(hex: "6E54D7") ?? .purple))
                        
                        Spacer()
                        
                        Button(role: .destructive) {
                            deleteSelectedPhotos()
                        } label: {
                            Image(systemName: "trash")
                        }
                        .disabled(selectedPhotoUrls.isEmpty)
                        .tint(selectedPhotoUrls.isEmpty ? .gray : .red)
                    }
                }
            }
        }
        // Floating Action Button (Only in non-selection mode)
        .overlay(alignment: .bottomTrailing) {
            if !isSelectionMode && !isAddingImages {
                Menu {
                    Button {
                        showCameraPicker = true
                    } label: {
                        Label("Camera Photo", systemImage: "camera")
                    }
                    
                    Button {
                        showLibraryPicker = true
                    } label: {
                        Label("Select Gallery Photos", systemImage: "photo")
                    }
                } label: {
                    Circle()
                        .fill(Color(hex: "6E54D7") ?? .purple)
                        .frame(width: 56, height: 56)
                        .shadow(color: (Color(hex: "6E54D7") ?? .purple).opacity(0.3), radius: 6, x: 0, y: 3)
                        .overlay(
                            Image(systemName: "plus")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.white)
                        )
                }
                .padding(20)
            }
        }
        // Bottom Actions Toolbar in Selection Mode

    }
    
    @ViewBuilder
    private func photoDetailViewer(urls: [String], startIndex: Int) -> some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack {
                // Top Navbar
                if !isFocused {
                    HStack {
                        Button {
                            selectedPhotoIndex = nil
                        } label: {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                                .padding(10)
                                .background(Color.white.opacity(0.15))
                                .clipShape(Circle())
                        }
                        
                        Spacer()
                        
                        Text("\(min(currentImageIndex + 1, urls.count)) of \(urls.count)")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        HStack(spacing: 12) {
                            if !urls.isEmpty, let shareUrl = URL(string: urls[min(currentImageIndex, urls.count - 1)]) {
                                ShareLink(item: shareUrl) {
                                    Image(systemName: "square.and.arrow.up")
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(.white)
                                        .padding(10)
                                        .background(Color.white.opacity(0.15))
                                        .clipShape(Circle())
                                }
                            }
                            
                            Menu {
                                if !urls.isEmpty {
                                    Button(role: .destructive) {
                                        deletePhoto(urls[min(currentImageIndex, urls.count - 1)])
                                    } label: {
                                        Text("Delete Photo")
                                    }
                                }
                            } label: {
                                Image(systemName: "ellipsis")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.white)
                                    .padding(10)
                                    .background(Color.white.opacity(0.15))
                                    .clipShape(Circle())
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 16)
                    .transition(.move(edge: .top).combined(with: .opacity))
                }
                
                Spacer()
                
                // Photo TabView (swipeable)
                TabView(selection: $currentImageIndex) {
                    ForEach(Array(urls.enumerated()), id: \.element) { idx, urlStr in
                        AsyncImage(url: URL(string: urlStr)) { image in
                            image
                                .resizable()
                                .scaledToFit()
                        } placeholder: {
                            ProgressView()
                                .tint(.white)
                        }
                        .tag(idx)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        isFocused.toggle()
                    }
                }
                
                Spacer()
            }
        }
    }
    
    private func deletePhoto(_ photoUrl: String) {
        let urls = currentMemory.allImageUrls
        store.deletePhotoFromAlbum(albumId: currentMemory.id, photoUrl: photoUrl)
        if urls.count <= 1 {
            selectedPhotoIndex = nil
            dismiss()
        } else {
            if currentImageIndex >= urls.count - 1 {
                currentImageIndex = max(0, urls.count - 2)
            }
            selectedPhotoIndex = currentImageIndex
        }
    }
    
    private func deleteSelectedPhotos() {
        let urlsToDelete = Array(selectedPhotoUrls)
        for url in urlsToDelete {
            store.deletePhotoFromAlbum(albumId: currentMemory.id, photoUrl: url)
        }
        selectedPhotoUrls.removeAll()
        withAnimation {
            isSelectionMode = false
        }
        if currentMemory.allImageUrls.isEmpty {
            dismiss()
        }
    }
}

// MARK: - Edit Album Sheet View
struct EditAlbumSheet: View {
    @Environment(\.dismiss) var dismiss
    @Environment(ActivityStore.self) var store
    let albumId: UUID
    
    @State private var name: String
    @State private var location: String
    @State private var date: Date
    
    init(album: PetMemory) {
        self.albumId = album.id
        _name = State(initialValue: album.displayName)
        _location = State(initialValue: album.displayLocation)
        _date = State(initialValue: album.createdAt)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Album Info")) {
                    TextField("Album Name", text: $name)
                    TextField("Location", text: $location)
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                }
            }
            .navigationTitle("Edit Album")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        store.updateMemoryAlbumInfo(
                            albumId: albumId,
                            name: name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Paw Adventure" : name,
                            location: location.isEmpty ? "Somewhere Fun" : location,
                            date: date
                        )
                        dismiss()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}
