//
//  VaccineLabelScannerView.swift
//  PawPing
//
//  Created by Antigravity on 04/07/26.
//

import SwiftUI
import AVFoundation
import Vision

struct VaccineLabelScannerView: View {
    @Environment(\.dismiss) private var dismiss
    
    // Callback when scanning is completed with data and image
    var onCompletion: (ScannedVaccineData, UIImage) -> Void
    
    @State private var isCameraAuthorized = false
    @State private var showPermissionDenied = false
    @State private var capturedImage: UIImage? = nil
    @State private var showReviewSheet = false
    @State private var scannedData: ScannedVaccineData? = nil
    @State private var isProcessing = false
    
    // Photo Library fallback
    @State private var showImagePicker = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                #if targetEnvironment(simulator)
                simulatorFallbackView
                #else
                if isCameraAuthorized {
                    CameraScannerView(capturedImage: $capturedImage, isProcessing: $isProcessing)
                } else {
                    checkingPermissionsView
                }
                #endif
                
                // Scanner HUD / Overlay
                scannerOverlayHUD
                
                if isProcessing {
                    processingOverlay
                }
            }
            .navigationTitle("Scan Vaccine Tag")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundStyle(.white)
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        showImagePicker = true
                    }) {
                        Image(systemName: "photo.on.rectangle")
                            .foregroundStyle(.white)
                    }
                }
            }
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(selectedImage: Binding(
                    get: { nil },
                    set: { img in
                        if let img = img {
                            let cropped = img.cropToStickerAspectRatio()
                            processSelectedImage(cropped)
                        }
                    }
                ), sourceType: .photoLibrary)
            }
            .sheet(isPresented: $showReviewSheet) {
                if let data = scannedData, let img = capturedImage {
                    ScannerReviewSheet(scannedData: data, image: img) { finalData in
                        onCompletion(finalData, img)
                        dismiss()
                    }
                }
            }
            .onChange(of: capturedImage) { _, newImage in
                if let img = newImage {
                    processSelectedImage(img)
                }
            }
            .onAppear {
                checkCameraPermission()
            }
        }
    }
    
    // MARK: - Subviews
    
    private var simulatorFallbackView: some View {
        VStack(spacing: 20) {
            Image(systemName: "camera.badge.ellipsis")
                .font(.system(size: 64))
                .foregroundStyle(.gray)
            
            Text("Camera Unavailable")
                .font(.headline)
                .foregroundStyle(.white)
            
            Text("Simulators do not support physical camera feeds. Please choose a vaccine sticker image from your Photo Library to test.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Button(action: {
                showImagePicker = true
            }) {
                Label("Choose from Library", systemImage: "photo.fill")
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                    .padding()
                    .background(Color("baseColor"))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }
    
    private var checkingPermissionsView: some View {
        VStack {
            if showPermissionDenied {
                VStack(spacing: 16) {
                    Text("Camera Access Required")
                        .font(.headline)
                        .foregroundStyle(.white)
                    
                    Text("Please enable camera access in settings to scan vaccine sticker tags.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                    
                    Button("Open Settings") {
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(url)
                        }
                    }
                    .padding()
                    .background(Color("baseColor"))
                    .clipShape(Capsule())
                }
            } else {
                ProgressView()
                    .tint(.white)
            }
        }
    }
    
    private var scannerOverlayHUD: some View {
        VStack {
            Spacer()
            
            // Reticle / Box Guide
            VStack {
                Text("Align vaccine label within the frame")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(.black.opacity(0.6))
                    .clipShape(Capsule())
                    .padding(.bottom, 10)
                
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(Color.white, lineWidth: 2)
                    .frame(height: 160)
                    .padding(.horizontal, 30)
            }
            
            Spacer()
            
            #if !targetEnvironment(simulator)
            Text("Make sure code serials & dates are clearly visible")
                .font(.footnote)
                .foregroundColor(.white.opacity(0.7))
                .padding(.bottom, 30)
            #endif
        }
    }

    
    private var processingOverlay: some View {
        Color.black.opacity(0.7)
            .ignoresSafeArea()
            .overlay(
                VStack(spacing: 16) {
                    ProgressView()
                        .scaleEffect(1.5)
                        .tint(.white)
                    
                    Text("Reading vaccine label details...")
                        .font(.headline)
                        .foregroundStyle(.white)
                }
            )
    }
    
    // MARK: - OCR Actions
    
    private func processSelectedImage(_ image: UIImage) {
        isProcessing = true
        capturedImage = image
        
        Task {
            let data = await VaccineLabelOCR.performOCR(on: image)
            await MainActor.run {
                self.scannedData = data
                self.isProcessing = false
                self.showReviewSheet = true
            }
        }
    }
    
    private func checkCameraPermission() {
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
            isCameraAuthorized = false
            showPermissionDenied = true
        @unknown default:
            break
        }
    }
}

// MARK: - AVCapture Camera View Helper

#if !targetEnvironment(simulator)
struct CameraScannerView: UIViewRepresentable {
    @Binding var capturedImage: UIImage?
    @Binding var isProcessing: Bool
    
    func makeUIView(context: Context) -> CameraView {
        let view = CameraView()
        view.onCapture = { image in
            capturedImage = image
        }
        return view
    }
    
    func updateUIView(_ uiView: CameraView, context: Context) {}
}

class CameraView: UIView {
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
        
        // Custom shutter button
        let button = UIButton(type: .custom)
        button.backgroundColor = .white
        button.layer.cornerRadius = 35
        button.layer.borderWidth = 5
        button.layer.borderColor = UIColor.lightGray.cgColor
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(capturePhoto), for: .touchUpInside)
        addSubview(button)
        self.shutterButton = button
        
        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: centerXAnchor),
            button.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -20),
            button.widthAnchor.constraint(equalToConstant: 70),
            button.heightAnchor.constraint(equalToConstant: 70)
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
        let settings = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
}

extension CameraView: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard error == nil, let data = photo.fileDataRepresentation(), let image = UIImage(data: data) else { return }
        
        let normalized = image.normalizedImage()
        let previewSize = self.bounds.size
        
        let boxWidth = previewSize.width - 60
        let boxHeight: CGFloat = 160
        let boxX: CGFloat = 30
        let boxY = (previewSize.height - boxHeight) / 2
        let boxRect = CGRect(x: boxX, y: boxY, width: boxWidth, height: boxHeight)
        
        let cropped = normalized.cropToScannerBox(previewSize: previewSize, boxRect: boxRect)
        onCapture?(cropped)
    }
}
#endif

// MARK: - Review Sheet for OCR Output

struct ScannerReviewSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    var scannedData: ScannedVaccineData
    var image: UIImage
    var onConfirm: (ScannedVaccineData) -> Void
    
    @State private var vaccineName: String = ""
    @State private var manufacturer: String = ""
    @State private var batchNumber: String = ""
    @State private var hasExpDate = false
    @State private var expDate: Date = Date()
    
    init(scannedData: ScannedVaccineData, image: UIImage, onConfirm: @escaping (ScannedVaccineData) -> Void) {
        self.scannedData = scannedData
        self.image = image
        self.onConfirm = onConfirm
        
        _vaccineName = State(initialValue: scannedData.vaccineName ?? "")
        _manufacturer = State(initialValue: scannedData.manufacturer ?? "")
        _batchNumber = State(initialValue: scannedData.batchNumber ?? "")
        _hasExpDate = State(initialValue: scannedData.expiryDate != nil)
        _expDate = State(initialValue: scannedData.expiryDate ?? Date())
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Sticker Scan") {
                    HStack {
                        Spacer()
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 120)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .shadow(radius: 2)
                        Spacer()
                    }
                    .padding(.vertical, 8)
                }
                
                Section("Detected Fields") {
                    LabeledContent("Vaccine Name") {
                        TextField("e.g. DHPP Booster", text: $vaccineName)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    LabeledContent("Manufacturer") {
                        TextField("e.g. Zoetis", text: $manufacturer)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    LabeledContent("Batch/Serial #") {
                        TextField("e.g. 8209128", text: $batchNumber)
                            .multilineTextAlignment(.trailing)
                    }
                }
                
                Section("Dates") {
                    Toggle("Expiry Date", isOn: $hasExpDate)
                    if hasExpDate {
                        DatePicker("EXP Date", selection: $expDate, displayedComponents: .date)
                    }
                }
            }
            .navigationTitle("Verify Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "arrow.clockwise")
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        let finalData = ScannedVaccineData(
                            vaccineName: vaccineName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : vaccineName,
                            manufacturer: manufacturer.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : manufacturer,
                            fullDescription: scannedData.fullDescription,
                            batchNumber: batchNumber.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : batchNumber,
                            expiryDate: hasExpDate ? expDate : nil,
                            rawText: scannedData.rawText
                        )
                        onConfirm(finalData)
                        dismiss()
                    }) {
                        Image(systemName: "checkmark")
                    }
                    .disabled(vaccineName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .tint(Color("baseColor"))
        }
    }
}

// MARK: - UIImage Cropping Extensions

extension UIImage {
    func normalizedImage() -> UIImage {
        if self.imageOrientation == .up {
            return self
        }
        
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        self.draw(in: CGRect(origin: .zero, size: self.size))
        let normalized = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return normalized ?? self
    }
    
    func cropToScannerBox(previewSize: CGSize, boxRect: CGRect) -> UIImage {
        let imageSize = self.size
        
        // Calculate the aspectFill scale factor
        let widthScale = imageSize.width / previewSize.width
        let heightScale = imageSize.height / previewSize.height
        let scale = max(widthScale, heightScale)
        
        // Calculate offsets when aspectFill scales the image to fit previewSize
        let scaledWidth = previewSize.width * scale
        let scaledHeight = previewSize.height * scale
        let offsetX = (scaledWidth - imageSize.width) / 2
        let offsetY = (scaledHeight - imageSize.height) / 2
        
        // Translate box coordinates on screen to image pixel coordinates
        let cropX = boxRect.origin.x * scale - offsetX
        let cropY = boxRect.origin.y * scale - offsetY
        let cropWidth = boxRect.size.width * scale
        let cropHeight = boxRect.size.height * scale
        
        let cropRect = CGRect(x: cropX, y: cropY, width: cropWidth, height: cropHeight)
        
        // Clip to image boundaries just to be safe
        let boundedRect = cropRect.intersection(CGRect(origin: .zero, size: imageSize))
        
        guard let cgImage = self.cgImage?.cropping(to: boundedRect) else {
            return self
        }
        
        return UIImage(cgImage: cgImage, scale: self.scale, orientation: self.imageOrientation)
    }
    
    func cropToStickerAspectRatio() -> UIImage {
        let image = self.normalizedImage()
        let size = image.size
        
        // The scanner box aspect ratio is (screenWidth - 60) : 160
        // On standard screens like iPhone 15, this is 333 / 160 = 2.08125
        let targetAspectRatio: CGFloat = 2.08125
        
        var cropWidth = size.width
        var cropHeight = size.width / targetAspectRatio
        
        if cropHeight > size.height {
            cropHeight = size.height
            cropWidth = size.height * targetAspectRatio
        }
        
        let cropX = (size.width - cropWidth) / 2
        let cropY = (size.height - cropHeight) / 2
        
        let cropRect = CGRect(x: cropX, y: cropY, width: cropWidth, height: cropHeight)
        
        guard let cgImage = image.cgImage?.cropping(to: cropRect) else {
            return image
        }
        
        return UIImage(cgImage: cgImage, scale: image.scale, orientation: image.imageOrientation)
    }
}
