//
//  DogCameraView.swift
//  PawPing
//
//  Custom camera view with a dog silhouette overlay guide.
//  Users can capture a photo or pick from the photo library.
//

import SwiftUI
import AVFoundation
import PhotosUI

struct DogCameraView: View {
    @Environment(\.dismiss) private var dismiss
    
    var onImageCaptured: (UIImage) -> Void
    
    @State private var isCameraAuthorized = false
    @State private var showPermissionDenied = false
    @State private var showPhotoPicker = false
    @State private var isCapturing = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                #if targetEnvironment(simulator)
                simulatorFallbackView
                #else
                if isCameraAuthorized {
                    DogCameraPreview(onCapture: { image in
                        onImageCaptured(image)
                    }, isCapturing: $isCapturing)
                } else if showPermissionDenied {
                    permissionDeniedView
                } else {
                    ProgressView()
                        .tint(.white)
                }
                #endif
                
                // Silhouette guide overlay
                if isCameraAuthorized || isSimulator {
                    silhouetteOverlay
                }
            }
            .navigationTitle("Capture Your Dog")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundStyle(.white)
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showPhotoPicker = true
                    } label: {
                        Image(systemName: "photo.on.rectangle")
                            .foregroundStyle(.white)
                    }
                }
            }
            .sheet(isPresented: $showPhotoPicker) {
                PhotoPickerView { image in
                    onImageCaptured(image)
                }
            }
            .onAppear {
                checkCameraPermission()
            }
        }
    }
    
    private var isSimulator: Bool {
        #if targetEnvironment(simulator)
        return true
        #else
        return false
        #endif
    }
    
    // MARK: - Silhouette Overlay
    
    private var silhouetteOverlay: some View {
        VStack {
            Spacer()
            
            // Instruction pill
            Text("Position your dog within the guide")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(.black.opacity(0.5))
                .clipShape(Capsule())
                .padding(.bottom, 16)
            
            // Dog silhouette guide
            Image("dog_silhouette_guide")
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .foregroundColor(.white)
                .opacity(0.35)
                .frame(maxWidth: 280, maxHeight: 320)
                .padding(.bottom, 20)
            
            Spacer()
            
            // Bottom hint
            Text("The background will be automatically removed")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.white.opacity(0.6))
                .padding(.bottom, 130)
        }
    }
    
    // MARK: - Permission Denied
    
    private var permissionDeniedView: some View {
        VStack(spacing: 16) {
            Image(systemName: "camera.fill")
                .font(.system(size: 48))
                .foregroundStyle(.gray)
            
            Text("Camera Access Required")
                .font(.headline)
                .foregroundStyle(.white)
            
            Text("Enable camera access in Settings to take a photo of your dog.")
                .font(.subheadline)
                .foregroundStyle(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            HStack(spacing: 12) {
                Button("Open Settings") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(Color.homePurple)
                .clipShape(Capsule())
                
                Button("Use Photo Library") {
                    showPhotoPicker = true
                }
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(Color.white.opacity(0.2))
                .clipShape(Capsule())
            }
            .padding(.top, 8)
        }
    }
    
    // MARK: - Simulator Fallback
    
    private var simulatorFallbackView: some View {
        VStack(spacing: 20) {
            Image(systemName: "camera.badge.ellipsis")
                .font(.system(size: 64))
                .foregroundStyle(.gray)
            
            Text("Camera Unavailable")
                .font(.headline)
                .foregroundStyle(.white)
            
            Text("Camera is not available on the simulator. Choose a photo from your library instead.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Button {
                showPhotoPicker = true
            } label: {
                Label("Choose from Library", systemImage: "photo.fill")
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                    .padding()
                    .background(Color.homePurple)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }
    
    // MARK: - Permissions
    
    private func checkCameraPermission() {
        #if targetEnvironment(simulator)
        isCameraAuthorized = false
        #else
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            isCameraAuthorized = true
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    self.isCameraAuthorized = granted
                    self.showPermissionDenied = !granted
                }
            }
        case .denied, .restricted:
            showPermissionDenied = true
        @unknown default:
            break
        }
        #endif
    }
}

// MARK: - Camera Preview (UIViewRepresentable)

#if !targetEnvironment(simulator)
struct DogCameraPreview: UIViewRepresentable {
    var onCapture: (UIImage) -> Void
    @Binding var isCapturing: Bool
    
    func makeUIView(context: Context) -> DogCameraUIView {
        let view = DogCameraUIView()
        view.onCapture = onCapture
        return view
    }
    
    func updateUIView(_ uiView: DogCameraUIView, context: Context) {}
}

class DogCameraUIView: UIView {
    var onCapture: ((UIImage) -> Void)?
    
    private let captureSession = AVCaptureSession()
    private let photoOutput = AVCapturePhotoOutput()
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private var shutterButton: UIButton?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSession()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupSession()
    }
    
    private func setupSession() {
        captureSession.sessionPreset = .photo
        
        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let input = try? AVCaptureDeviceInput(device: camera) else { return }
        
        if captureSession.canAddInput(input) {
            captureSession.addInput(input)
        }
        
        if captureSession.canAddOutput(photoOutput) {
            captureSession.addOutput(photoOutput)
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer?.videoGravity = .resizeAspectFill
        if let previewLayer = previewLayer {
            layer.addSublayer(previewLayer)
        }
        
        // Shutter button
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(capturePhoto), for: .touchUpInside)
        addSubview(button)
        self.shutterButton = button
        
        // Outer ring
        let outerRing = UIView()
        outerRing.isUserInteractionEnabled = false
        outerRing.translatesAutoresizingMaskIntoConstraints = false
        outerRing.layer.cornerRadius = 38
        outerRing.layer.borderWidth = 4
        outerRing.layer.borderColor = UIColor.white.cgColor
        outerRing.backgroundColor = .clear
        button.addSubview(outerRing)
        
        // Inner circle
        let innerCircle = UIView()
        innerCircle.isUserInteractionEnabled = false
        innerCircle.translatesAutoresizingMaskIntoConstraints = false
        innerCircle.layer.cornerRadius = 30
        innerCircle.backgroundColor = .white
        button.addSubview(innerCircle)
        
        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: centerXAnchor),
            button.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -20),
            button.widthAnchor.constraint(equalToConstant: 76),
            button.heightAnchor.constraint(equalToConstant: 76),
            
            outerRing.centerXAnchor.constraint(equalTo: button.centerXAnchor),
            outerRing.centerYAnchor.constraint(equalTo: button.centerYAnchor),
            outerRing.widthAnchor.constraint(equalToConstant: 76),
            outerRing.heightAnchor.constraint(equalToConstant: 76),
            
            innerCircle.centerXAnchor.constraint(equalTo: button.centerXAnchor),
            innerCircle.centerYAnchor.constraint(equalTo: button.centerYAnchor),
            innerCircle.widthAnchor.constraint(equalToConstant: 60),
            innerCircle.heightAnchor.constraint(equalToConstant: 60),
        ])
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.captureSession.startRunning()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        previewLayer?.frame = bounds
    }
    
    @objc private func capturePhoto() {
        // Haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        // Animate shutter
        UIView.animate(withDuration: 0.1, animations: {
            self.shutterButton?.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.shutterButton?.transform = .identity
            }
        }
        
        let settings = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
    
    /// Stop the session when removed
    func stopSession() {
        DispatchQueue.global(qos: .userInitiated).async {
            self.captureSession.stopRunning()
        }
    }
    
    override func removeFromSuperview() {
        stopSession()
        super.removeFromSuperview()
    }
}

extension DogCameraUIView: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard error == nil,
              let data = photo.fileDataRepresentation(),
              let image = UIImage(data: data) else { return }
        
        // Normalize orientation
        let normalizedImage = image.normalizedForOrientation()
        
        DispatchQueue.main.async {
            self.onCapture?(normalizedImage)
        }
    }
}
#endif

// MARK: - Photo Picker (PHPicker wrapper for single selection)

struct PhotoPickerView: UIViewControllerRepresentable {
    @Environment(\.dismiss) var dismiss
    var onImageSelected: (UIImage) -> Void
    
    init(onImageSelected: @escaping (UIImage) -> Void) {
        self.onImageSelected = onImageSelected
    }
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 1
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: PhotoPickerView
        
        init(_ parent: PhotoPickerView) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            parent.dismiss()
            
            guard let result = results.first,
                  result.itemProvider.canLoadObject(ofClass: UIImage.self) else { return }
            
            result.itemProvider.loadObject(ofClass: UIImage.self) { image, error in
                if let uiImage = image as? UIImage {
                    DispatchQueue.main.async {
                        self.parent.onImageSelected(uiImage)
                    }
                }
            }
        }
    }
}

// MARK: - UIImage Orientation Helper

extension UIImage {
    /// Returns a new UIImage normalized to .up orientation to avoid rotation issues
    /// when passing images to Vision/Core Image pipelines.
    func normalizedForOrientation() -> UIImage {
        guard imageOrientation != .up else { return self }
        
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        draw(in: CGRect(origin: .zero, size: size))
        let normalizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return normalizedImage ?? self
    }
}
