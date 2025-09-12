//
//  DocumentPickerBehavior
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 15/06/2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

import UIKit
import AVFoundation
import Photos
import Legacy
import PhotosUI
import MobileCoreServices

enum DocumentSource {
    case camera
    case library
    case icloud
}

class DocumentPickerBehavior: NSObject,
							  UIImagePickerControllerDelegate,
							  UINavigationControllerDelegate,
							  PHPickerViewControllerDelegate,
							  UIDocumentPickerDelegate {
    enum FileType {
        case pdf
        case doc
        case docx
        case dot
        case dotx
        case jpg
        case png
        case tiff
        
        @available(iOS 14.0, *)
        var utType: UTType? {
            Self.utType(from: self)
        }
        
        var documentType: String {
            switch self {
                case .doc:
                    return "com.microsoft.word.doc"
                case .docx:
                    return "org.openxmlformats.wordprocessingml.document"
                case .dot:
                    return "com.microsoft.word.dot"
                case .dotx:
                    return "org.openxmlformats.wordprocessingml.template"
                case .pdf:
                    return "com.adobe.pdf"
                case .jpg:
                    return "public.jpeg"
                case .png:
                    return "public.png"
                case .tiff:
                    return "public.tiff"
            }
        }
        
        @available(iOS 14.0, *)
        static func utTypes(from fileTypes: [FileType]) -> [UTType] {
            return fileTypes.compactMap { utType(from: $0) }
        }
        
        @available(iOS 14.0, *)
        private static func utType(from fileType: FileType) -> UTType? {
            switch fileType {
                case .doc:
                    return UTType("com.microsoft.word.doc")
                case .docx:
                    return UTType("org.openxmlformats.wordprocessingml.document")
                case .dot:
                    return UTType("com.microsoft.word.dot")
                case .dotx:
                    return UTType("org.openxmlformats.wordprocessingml.template")
                case .pdf:
                    return .pdf
                case .jpg:
                    return .jpeg
                case .png:
                    return .png
                case .tiff:
                    return .tiff
            }
        }
        
        static func documentTypes(from fileTypes: [FileType]) -> [String] {
            return fileTypes.map { $0.documentType }
        }
    }
    
    private enum Constants {
        /// 0.0 to 1.0 --> 0 means maximum compression and 1 means minimum compression
        static let imageCompressionQuality: CGFloat = 0.3
        static let imageMaxPixelSize = 2_000
    }

    private var pickedDocumentsHandler: (([Attachment]) -> Void)?
    private weak var viewController: UIViewController!
    private var attachmentService: AttachmentService!
    private lazy var imagePicker: UIImagePickerController = UIImagePickerController()
    private lazy var cameraOverlayView = CameraOverlayView.fromNib()
    private lazy var hintOverlayView = CameraAutoHintOverlayView.fromNib()
    private var flashActive: Bool = false
    private var maxDocuments: Int?
    private var pickedDocuments: [Attachment] = []
    private var photosUpdatedSubscriptions: Subscriptions<Int> = Subscriptions()
    private let disposeBag: DisposeBag = DisposeBag()
    private var cameraHint: AutoOverlayHint?
    private var finishedPickingPhotos: Bool {
        switch imagePicker.sourceType {
            case .camera:
                return maxDocuments
                    .map { pickedDocuments.count == $0 }
                    ?? !pickedDocuments.isEmpty
            default:
                return !pickedDocuments.isEmpty
        }
    }

    func pickDocuments(
        _ viewController: UIViewController,
        sourceView: UIView? = nil,
        attachmentService: AttachmentService,
        sources: [DocumentSource],
        maxDocuments: Int? = nil,
        cameraHint: AutoOverlayHint? = nil,
        callback: @escaping ([Attachment]) -> Void,
        supportedTypes: [FileType] = [.pdf]
    ) {
        if let maxDocuments = maxDocuments, maxDocuments < 0 { return }

        self.viewController = viewController
        self.attachmentService = attachmentService
        pickedDocumentsHandler = callback
        self.maxDocuments = maxDocuments
        self.cameraHint = cameraHint

        showActionSheet(
            sources: sources,
            supportedTypes: supportedTypes,
            sourceView: sourceView ?? viewController.view
        )
    }

    private func showActionSheet(
        sources: [DocumentSource],
        supportedTypes: [FileType],
        sourceView: UIView
    ) {
        struct ActionInfo {
            let title: String
            let action: () -> Void
        }
        let actions: [ActionInfo] = sources.map {
            switch $0 {
                case .library:
                    return ActionInfo(
                        title: NSLocalizedString("common_photo_library", comment: ""),
                        action: {
                            if #available(iOS 14.0, *) {
                                self.selectImageFromGalleryTap()
                            } else {
                                Permissions.photoLibrary(for: .readWrite) { granted in
                                    guard granted, UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else { return }

                                    self.selectImageFromGalleryTap()
                                }
                            }
                        })
                case .camera:
                    return ActionInfo(
                        title: NSLocalizedString("common_take_photo", comment: ""),
                        action: {
                            Permissions.camera { granted in
                                guard granted, UIImagePickerController.isSourceTypeAvailable(.camera) else { return }

                                self.selectImageFromCameraTap()
                            }
                        })
                case .icloud:
                    return ActionInfo(
                        title: NSLocalizedString("common_pick_documents", comment: ""),
                        action: {
                            self.selectDocumentsTap(filter: supportedTypes)
                        })
            }
        }

        if actions.count == 1 {
            actions.first?.action()
        } else {
            let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            actions.forEach { action in
                let alertAction = UIAlertAction(
                    title: action.title,
                    style: .default
                ) { _ in action.action() }
                actionSheet.addAction(alertAction)
            }

            let cancelAction = UIAlertAction(title: NSLocalizedString("common_cancel_button", comment: ""), style: .cancel)
            actionSheet.addAction(cancelAction)

            actionSheet.popoverPresentationController?.sourceView = sourceView
            UIHelper.topViewController()?.present(actionSheet, animated: true)
        }
    }

    private func selectDocumentsTap(filter: [FileType]) {
        let controller: UIDocumentPickerViewController
        if #available(iOS 14.0, *) {
            controller = UIDocumentPickerViewController(
                forOpeningContentTypes: FileType.utTypes(from: filter),
                asCopy: true
            )
        } else {
            controller = UIDocumentPickerViewController(
                documentTypes: FileType.documentTypes(from: filter),
                in: .import
            )
        }
        controller.allowsMultipleSelection = true
        controller.delegate = self
        viewController.present(
            controller,
            animated: true,
            completion: nil
        )
    }
    
    private func selectImageFromGalleryTap() {
        if #available(iOS 14.0, *) {
            pickedDocuments = []
            var configuration = PHPickerConfiguration()
            configuration.filter = .any(of: [ .images, .livePhotos ])
            configuration.selectionLimit = maxDocuments ?? 0
            let picker = PHPickerViewController(configuration: configuration)
            picker.delegate = self
            viewController.present(picker, animated: true)
        } else {
            pickedDocuments = []
            imagePicker.view.backgroundColor = .Background.backgroundContent
            imagePicker.sourceType = .photoLibrary
            imagePicker.allowsEditing = false
            imagePicker.delegate = self
            viewController.present(imagePicker, animated: true, completion: nil)
        }
    }

    private func selectImageFromCameraTap() {
        pickedDocuments = []
		imagePicker.view.backgroundColor = .Background.backgroundContent
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false
        imagePicker.delegate = self
        imagePicker.showsCameraControls = false

        // Overlay
        setupCameraOverlay()
        setupHintOverlay()
        let initialOverlay = cameraHint == nil ? cameraOverlayView : hintOverlayView
        setOverlay(initialOverlay)
       
		viewController.present(imagePicker, animated: true) { [weak self] in
			self?.updateOverlayViewUI()
		}
    }

    private func updateOverlayViewUI() {
		photosUpdatedSubscriptions.fire(pickedDocuments.count)
		
        if let cameraHint = cameraHint {
            hintOverlayView.set(hint: cameraHint)
        }
    }

    private func setupCameraOverlay() {
        let hintAvailable = cameraHint != nil
        cameraOverlayView.input = .init(
            hint: hintAvailable,
            flashAvailable: UIImagePickerController.isFlashAvailable(for: .rear)
        )
        cameraOverlayView.output = .init(
            takePhotoTap: { [weak self] in
                guard let self = self else { return }

                self.imagePicker.cameraFlashMode = self.flashActive ? .on : .off
                self.imagePicker.takePicture()
            },
            usePhotoTap: { [weak self] in
                guard let self = self else { return }

                self.usePickedDocuments(savePhotosToCameraRoll: true, dismiss: true)
            },
            flashTap: { [weak self] in
                guard let self = self else { return }

                self.flashActive.toggle()
            },
            cancelTap: { [weak self] in
                guard let self = self else { return }

                self.close()
            },
            showHintTap: { [weak self] in
                guard let self = self else { return }

                self.setOverlay(self.hintOverlayView)
            }
        )
		photosUpdatedSubscriptions.add(cameraOverlayView.notify.photosUpdated).disposed(by: disposeBag)
    }

    private func setupHintOverlay() {
        hintOverlayView.closeTapHandler = { [weak self] in
            guard let self = self else { return }

            self.setOverlay(self.cameraOverlayView)
        }
    }

    private func setOverlay(_ view: UIView) {
        view.frame = imagePicker.cameraOverlayView?.frame ?? .zero
        imagePicker.cameraOverlayView = view
    }

    private func close() {
        viewController.dismiss(animated: true) { [weak self] in
            self?.pickedDocuments = []
        }
        if imagePicker.sourceType == .camera {
            imagePicker.cameraOverlayView = nil
        }
    }

    private func usePickedDocuments(savePhotosToCameraRoll: Bool, dismiss: Bool) {
        if savePhotosToCameraRoll {
            pickedDocuments.forEach {
                if let image = UIImage(contentsOfFile: $0.url.path) {
                    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                }
            }
        }

        if dismiss {
            close()
        }
        pickedDocumentsHandler?(pickedDocuments)
    }

    // MARK: - UIImagePickerControllerDelegate

    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
    ) {
        guard !finishedPickingPhotos
		else { return }

        let originalImage = info[.originalImage] as? UIImage
        if let image = originalImage?.resized(newWidth: CGFloat(Constants.imageMaxPixelSize)) {
            let imageUrl = info[.phAsset] as? URL
            let attachment = attachmentService.save(image: image, name: imageUrl?.fileNameWithoutExtension)
            pickedDocuments.append(attachment)
        }

        updateOverlayViewUI()
        if finishedPickingPhotos {
            usePickedDocuments(savePhotosToCameraRoll: picker.sourceType == .camera, dismiss: true)
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        close()
    }

    // MARK: - PHPickerViewControllerDelegate
    @available(iOS 14, *)
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        guard !results.isEmpty
		else {
            close()
            return
        }

        let hide = picker.showLoadingIndicator(message: NSLocalizedString("common_loading_title", comment: ""))

        let dispatchGroup = DispatchGroup()
        results.forEach { _ in
            dispatchGroup.enter()
        }

        struct DocumentInfo {
            let data: Data
            let name: String?
        }

        let dispatchQueue = DispatchQueue(label: "com.alfastrah.SelectedImageQueue")
        var selectedImageDatas = [DocumentInfo?](repeating: nil, count: results.count)

        // Using PHPickerViewController Images in a Memory-Efficient Way
        // https://christianselig.com/2020/09/phpickerviewcontroller-efficiently/

        for (index, result) in results.enumerated() {
            result.itemProvider.loadFileRepresentation(forTypeIdentifier: UTType.image.identifier) { url, error in
                if let error = error {
                    print("Error loading image with PHPickerViewController. Error: \(error)")
                    dispatchGroup.enter()
                    return
                }

                guard let url = url else {
                    dispatchGroup.leave()
                    return
                }

                let sourceOptions = [ kCGImageSourceShouldCache: false ] as CFDictionary

                guard let source = CGImageSourceCreateWithURL(url as CFURL, sourceOptions) else {
                    dispatchGroup.leave()
                    return
                }

                let downsampleOptions = [
                    kCGImageSourceCreateThumbnailFromImageAlways: true,
                    kCGImageSourceCreateThumbnailWithTransform: true,
                    kCGImageSourceThumbnailMaxPixelSize: Constants.imageMaxPixelSize,
                ] as CFDictionary

                guard let cgImage = CGImageSourceCreateThumbnailAtIndex(source, 0, downsampleOptions) else {
                    dispatchGroup.leave()
                    return
                }

                let data = NSMutableData()

                guard let imageDestination = CGImageDestinationCreateWithData(data, kUTTypeJPEG, 1, nil) else {
                    dispatchGroup.leave()
                    return
                }

                // Don't compress PNGs
                let isPNG: Bool = {
                    guard let utType = cgImage.utType else { return false }
                    return (utType as String) == UTType.png.identifier
                }()

                let destinationProperties = [
                    kCGImageDestinationLossyCompressionQuality: isPNG ? 1.0 : Constants.imageCompressionQuality
                ] as CFDictionary

                CGImageDestinationAddImage(imageDestination, cgImage, destinationProperties)
                CGImageDestinationFinalize(imageDestination)

                dispatchQueue.sync {
                    selectedImageDatas[index] = DocumentInfo(data: data as Data, name: url.fileNameWithoutExtension)
                    dispatchGroup.leave()
                }
            }
        }

        dispatchGroup.notify(queue: .main) { [weak self] in
            guard let self = self else { return }

            hide(nil)
            var attachments = selectedImageDatas
                .compactMap { $0 }
                .map { self.attachmentService.save(jpegImageData: $0.data, name: $0.name) }
            if let maxDocuments = self.maxDocuments
            {
                attachments = Array(
                    attachments.prefix(maxDocuments)
                )
            }
            self.pickedDocuments = attachments
            self.usePickedDocuments(savePhotosToCameraRoll: false, dismiss: true)
        }
    }

    // MARK: - UIDocumentPickerDelegate
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
		var attachments = urls.map { attachmentService.saveFileAttachment(from: $0) { _ in } }
        if let maxDocuments = self.maxDocuments
        {
            attachments = Array(
                attachments.prefix(maxDocuments)
            )
        }
        pickedDocuments = attachments

        // UIDocumentPickerViewController has a bug. It is dismissed itself.
        usePickedDocuments(savePhotosToCameraRoll: false, dismiss: false)
        pickedDocuments = []
    }

    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) { }
}
