//
//  FilePicker.swift
//  AlfaStrah
//
//  Created by vit on 01.03.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

import PhotosUI
import Legacy

// swiftlint:disable file_length
enum FilePickerSource {
	case camera
	case gallery
	case documents
	case medicalCard
}

final class FilePicker: NSObject,
						PHPickerViewControllerDelegate,
						UIImagePickerControllerDelegate,
						UINavigationControllerDelegate,
						UIDocumentPickerDelegate,
						DependencyContainerDependency,
						MedicalCardServiceDependency {
	var container: DependencyInjectionContainer?
	var medicalCardService: MedicalCardService!
	
	private let fileManager = FileManager()
	
	static let shared: FilePicker = .init()
	
	private var configuration = Configuration.default
	
	private var searchString = ""
	
	struct Configuration {
		let compressionTargetSize: UInt
		let maxFilesCount: UInt
		let compressionRatio: CGFloat
		let maxFileSize: Int64
		
		static let `default` = Configuration(
			compressionTargetSize: 5 * 1024 * 1024,
			maxFilesCount: 10,
			compressionRatio: 0.3,
			maxFileSize: 25 * 1024 * 1024
		)
	}
	
	private var filesSelected: (([FilePickerFileEntry]) -> Void)?
	private var dismissCompletion: (() -> Void)?
	
	private var entries: [FilePickerFileEntry] = []
	
	override init() {
		/// we need wait completion of all task before delete disk storage
		try? FileManager.default.removeItem(at: Constants.filePickerTemporaryDirectoryName) /// contents of directory recursivly removes
		try? FileManager.default.removeItem(at: Constants.filePickerCompressedDirectoryName)
		
		Storage.createDirectory(url: Constants.filePickerTemporaryDirectoryName)
		/// need to avoid url conflicts between source - original  and destination - compressed file urls
		Storage.createDirectory(url: Constants.filePickerCompressedDirectoryName)
		
		super.init()
	}
	
	func pick(
		from: FilePickerSource,
		with configuration: Configuration = Configuration.default,
		filesSelected: @escaping ([FilePickerFileEntry]) -> Void,
		dismissCompletion: @escaping (() -> Void),
		on viewController: UIViewController? = nil
	) -> UIViewController? {
		self.configuration = configuration
				
		entries.removeAll()
		
		self.filesSelected = filesSelected
		self.dismissCompletion = dismissCompletion
		
		switch from {
			case .camera:
				return createCameraPicker()
				
			case .documents:
				return createDocumentPicker()
				
			case .gallery:
				return createGalleryPicker(with: configuration)
				
			case .medicalCard:
				return createMedicalCardPicker(from: viewController)
				
			@unknown default:
				return nil
		}
	}
	
	private func close(_ viewController: UIViewController) {
		viewController.dismiss(animated: true) { [weak self] in
			guard let self
			else { return }
			
			self.dismissCompletion?()
		}
	}
	
	@discardableResult private func copySelectedFile(from: URL, completion: @escaping (Result<URL, Error>) -> Void) -> URL {
		let url = Constants.filePickerTemporaryDirectoryName.appendingPathComponent(from.lastPathComponent, isDirectory: false)
		
		try? FileManager.default.removeItem(at: url)
		
		do {
			try FileManager.default.copyItem(at: from, to: url)
			completion(.success(url))
		} catch let error {
			completion(.failure(error))
		}
		
		return url
	}
	
	private func saveFile(from: Data, filename: String, completion: @escaping (Result<URL, Error>) -> Void) {
		/// since we do not control the uniqueness of assets from picker
		/// we have to provide uniqness in url path
		/// because files with the same names can come from different sources and have different asset IDs
		let directoryName = Constants.filePickerTemporaryDirectoryName
			.appendingPathComponent(UUID().uuidString, isDirectory: true)
		
		Storage.createDirectory(url: directoryName)
		
		let url = directoryName.appendingPathComponent(filename, isDirectory: false)
		
		try? FileManager.default.removeItem(at: url)
		
		do {
			try from.write(to: url)
			completion(.success(url))
		} catch {
			completion(.failure(error))
		}
	}
	
	private func compressImage(from url: URL, completion: @escaping (Result<URL, Error>) -> Void) {
		let directoryName = Constants.filePickerCompressedDirectoryName
			.appendingPathComponent(UUID().uuidString, isDirectory: true)
		
		Storage.createDirectory(url: directoryName)
		
		/// all files are jpeg files after compression
		let filename = "\(url.fileNameWithoutExtension).jpeg"
		
		let imageUrl = directoryName.appendingPathComponent(filename, isDirectory: false)
		
		try? FileManager.default.removeItem(at: imageUrl)
		
		guard let imageData = try? Data(contentsOf: url),
			  let image = UIImage(data: imageData),
			  let data = image.jpegData(compressionQuality: self.configuration.compressionRatio)
		else { return }
		
		do {
			try data.write(to: imageUrl)
			completion(.success(imageUrl))
		} catch let error {
			completion(.failure(error))
		}
	}
	
	func sizeBytes(url: URL) -> Int64 {
		let attr = try? FileManager.default.attributesOfItem(atPath: url.path) as NSDictionary
		return Int64(attr?.fileSize() ?? 0)
	}
	
	// MARK: - Medical card picker
	// swiftlint:disable function_body_length
	private func createMedicalCardPicker(from: UIViewController?) -> UIViewController? {
		guard let from
		else { return nil }
		
		let viewController = MedicalCardFilesPickerViewController()
		container?.resolve(viewController)
		
		viewController.input = .init(
			fileEntries: { [weak viewController] completion in
				guard let viewController = viewController
				else { return }
				
				self.medicalCardService.getEndpoint {
					if self.medicalCardService.hasMedicalCardToken() {
						self.medicalCardService.fileEntries { result in
							switch result {
								case .success:
									completion?()
								case .failure:
									completion?()
									viewController.notify.updateWithState(.failure)
							}
						}
					} else {
						self.medicalCardService.getMedicalCardToken { result in
							switch result {
								case .success:
									self.medicalCardService.fileEntries { result in
										switch result {
											case .success:
												completion?()
											case .failure:
												completion?()
												viewController.notify.updateWithState(.failure)
										}
									}
								case .failure:
									completion?()
									viewController.notify.updateWithState(.failure)
							}
						}
					}
				}
			},
			imagePreviewUrl: { fileEntry in
				self.medicalCardService.imagePreviewUrl(for: fileEntry)
			},
			searchFiles: { searchString in
				self.searchString = searchString
				return self.medicalCardService.searchFiles(searchString: searchString)
			}
		)
		
		viewController.output = .init(
			goToChat: {
				ApplicationFlow.shared.show(item: .tabBar(.chat))
			},
			action: { [weak viewController, weak self] medicalCardFileEntry in
				guard let viewController
				else { return }
				
				switch medicalCardFileEntry.status {
					case .downloading, .virusCheck, .error, .uploading:
						break
						
					case .retry, .remote:
						self?.medicalCardService.downloadFile(for: medicalCardFileEntry) { _ in }
						
					case .localAndRemote:
						guard let fileName = medicalCardFileEntry.localStorageFilename,
							  let fileUrl = self?.medicalCardService.localStorageUrl(for: fileName)
						else { return }
						
						LocalDocumentViewer.open(fileUrl, from: viewController)

				}
			},
			done: { [weak self] selectedFileEntries in
				guard let self
				else { return }
				
				for medicalCardFileEntry in selectedFileEntries { // from MedicalFileEntry to FilePickerFileEntry
					var localFileUrl: URL?
					
					if let localFilename = medicalCardFileEntry.localStorageFilename,
					   let fileUrl = self.medicalCardService.localStorageUrl(for: localFilename) {
						localFileUrl = fileUrl
					} else {
						localFileUrl = URL(
							string: "file:///\(medicalCardFileEntry.originalFilename).\(medicalCardFileEntry.fileExtension ?? "")"
						) // for attachment cell compability
					}
					
					var attachment = FileAttachment(
						originalName: medicalCardFileEntry.originalFilename,
						filename: medicalCardFileEntry.localStorageFilename ?? medicalCardFileEntry.originalFilename,
						url: localFileUrl ?? URL(fileURLWithPath: "")
					)
					
					let pickerFileEntry = FilePickerFileEntry(
						state: .error(
							previewUrl: self.medicalCardService.imagePreviewUrl(for: medicalCardFileEntry),
							attachment: attachment
						)
					)
					
					self.entries.append(pickerFileEntry)
					
					func readyState() {
						if let localFilename = medicalCardFileEntry.localStorageFilename,
						   let fileUrl = self.medicalCardService.localStorageUrl(for: localFilename) {
							
							let maxSize = self.configuration.compressionTargetSize
							
							let filename = fileUrl.fileNameWithoutExtension
							attachment.url = fileUrl
							attachment.filename = filename
							attachment.originalName = filename
							
							pickerFileEntry.state = .processing(
								previewUrl: self.medicalCardService.imagePreviewUrl(for: medicalCardFileEntry),
								attachment: attachment
							)
							
							if fileUrl.isImageFile,
							   maxSize != 0,
							   self.sizeBytes(url: fileUrl) > maxSize {
								self.compressImage(from: fileUrl) { result in
									switch result {
										case .success(let compressedImageUrl):
											let filename = compressedImageUrl.fileNameWithoutExtension
											
											attachment.url = compressedImageUrl
											attachment.filename = filename
											attachment.originalName = filename
											
											if self.validateFilePickerEntrySize(compressedImageUrl) {
												pickerFileEntry.state = .ready(
													previewUrl: compressedImageUrl,
													attachment: attachment		// extension forced to jpeg after compression
												)
											} else {
												pickerFileEntry.state = .error(
													previewUrl: compressedImageUrl,
													attachment: attachment
												)
											}
										case .failure:
											pickerFileEntry.state = .error(
												previewUrl: fileUrl,
												attachment: attachment
											)
									}
								}
							} else {
								let filename = fileUrl.fileNameWithoutExtension
								
								attachment.url = fileUrl
								attachment.filename = filename
								attachment.originalName = filename
								
								if self.validateFilePickerEntrySize(fileUrl) {
									pickerFileEntry.state = .ready(
										previewUrl: fileUrl,
										attachment: attachment		// extension forced to jpeg after compression
									)
								} else {
									pickerFileEntry.state = .error(
										previewUrl: fileUrl,
										attachment: attachment
									)
								}
							}
						} else { // invalid medical file entry cache
							pickerFileEntry.state = .error(
								previewUrl: self.medicalCardService.imagePreviewUrl(for: medicalCardFileEntry),
								attachment: attachment
							)
						}
					}
					
					func processingState() {
						pickerFileEntry.state = .processing(
							previewUrl: self.medicalCardService.imagePreviewUrl(for: medicalCardFileEntry),
							attachment: attachment,
							type: .downloading
						)
					}
					
					func errorState() {
						pickerFileEntry.state = .error(
							previewUrl: self.medicalCardService.imagePreviewUrl(for: medicalCardFileEntry),
							attachment: attachment,
							type: .downloading
						)
					}
					
					medicalCardFileEntry.setStateObserver { status in
						switch status {
							case .remote:
								break
								
							case .downloading:
								processingState()
								
							case .localAndRemote:
								readyState()
								
							case .virusCheck, .error, .uploading, .retry:
								/// for files at these states selection not allowed
								/// retry state for medical file entry here means that last download op was failed
								errorState()
						}
					}
					
					switch medicalCardFileEntry.status {
						case .remote:
							processingState()
							self.medicalCardService.downloadFile(for: medicalCardFileEntry) { [weak viewController] result in
								guard let viewController
								else { return }
								
								switch result {
									case .success:
										break
									case .failure(let error):
										ErrorHelper.show(
											error: error,
											text: "medical file download failed \(medicalCardFileEntry.originalFilename)",
											alertPresenter: viewController.alertPresenter
										)
								}
							}
							
						case .downloading:
							processingState()
							
						case .localAndRemote:
							readyState()
							
						case .uploading, .virusCheck, .error, .retry:
							errorState()
					}
				}
				
				self.selectionFinished()
				self.close(viewController)
			},
			downloadFileEntry: { medicalCardFileEntry in
				self.medicalCardService.downloadFile(for: medicalCardFileEntry) { _ in }
			},
			retryFileEntryUpload: { medicalCardFileEntry in
				self.medicalCardService.retryUploadFile(for: medicalCardFileEntry) { _ in }
			}
		)
		
		medicalCardService.subscribeForFileEntriesUpdates { groups in
			viewController.notify.updateWithState(.filled(groups))
		}.disposed(by: viewController.disposeBag)
		
		viewController.addCloseButton {
			from.dismiss(animated: false)
		}
		
		let navigationController = RMRNavigationController(rootViewController: viewController)
		navigationController.strongDelegate = RMRNavigationControllerDelegate()
		
		navigationController.modalPresentationStyle = .fullScreen
		
		return navigationController
	}
	
	// MARK: - Images picker
	private func createGalleryPicker(with configuration: Configuration) -> UIViewController? {
		if #available(iOS 14.0, *) {
			var galleryPickerConfiguration = PHPickerConfiguration(photoLibrary: .shared())
			
			galleryPickerConfiguration.filter = .any(of: [ .images, .livePhotos ])
			galleryPickerConfiguration.selectionLimit = Int(configuration.maxFilesCount)
			
			let galleryPicker = PHPickerViewController(configuration: galleryPickerConfiguration)
			
			galleryPicker.delegate = self
			
			return galleryPicker
		} else {
			guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary)
			else { return nil }
			
			let galleryPicker = UIImagePickerController()
			galleryPicker.view.backgroundColor = .Background.backgroundContent
			galleryPicker.sourceType = .photoLibrary
			galleryPicker.allowsEditing = false
			galleryPicker.delegate = self
			
			return galleryPicker
		}
	}
	
	// MARK: - PHPickerViewControllerDelegate
	@available(iOS 14.0, *)
	func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
		let dispatchGroup = DispatchGroup()
		
		results.forEach { _ in
			dispatchGroup.enter()
		}
		
		for result in results {
			var attachment = FileAttachment(
				originalName: nil,
				filename: "",
				url: URL(fileURLWithPath: "")
			)
			
			let pickerFileEntry = FilePickerFileEntry(
				state: .processing(
					previewUrl: nil,
					attachment: attachment
				)
			)
			
			entries.append(pickerFileEntry)
			
			result.itemProvider.loadFileRepresentation(forTypeIdentifier: UTType.image.identifier) { [weak self] fileUrl, error in
				if error != nil {
					dispatchGroup.leave()
					return
				}
				
				guard let fileUrl
				else {
					dispatchGroup.leave()
					return
				}
				
				attachment.url = fileUrl
				
				let filename = fileUrl.fileNameWithoutExtension
				
				attachment.originalName = filename
				attachment.filename = filename
				
				pickerFileEntry.state = .processing(
					previewUrl: fileUrl,
					attachment: attachment
				)
				
				do {
					let fileData = try Data(contentsOf: fileUrl)
					if fileData.isEmpty {
						dispatchGroup.leave()
						return
					}
					
					if let filename = result.itemProvider.suggestedName {
						attachment.filename = filename
						attachment.originalName = filename
						
						pickerFileEntry.state = .processing(
							previewUrl: fileUrl,
							attachment: attachment
						)
						
						self?.galleryImagesProcessingQueue.append((UUID().uuidString, fileData, pickerFileEntry))
						
						dispatchGroup.leave()
					} else {
						pickerFileEntry.state = .error(previewUrl: fileUrl, attachment: attachment)
					}
					
				} catch _ {
					pickerFileEntry.state = .error(previewUrl: fileUrl, attachment: attachment)
				}
			}
		}
		
		dispatchGroup.notify(queue: .main) { [weak self] in
			guard let self
			else { return }
			
			self.selectionFinished()
			self.close(picker)
			
			for item in self.galleryImagesProcessingQueue {
				self.startProcessingImage(item)
			}
		}
	}
	
	typealias GalleryImagesProccessingQueueItem = (id: String, imageData: Data, pickerFileEntry: FilePickerFileEntry)
	
	private var galleryImagesProcessingQueue: [GalleryImagesProccessingQueueItem] = []
	
	private func startProcessingImage(_ item: GalleryImagesProccessingQueueItem) {
		DispatchQueue.global(qos: .background).async { [weak self] in
			guard let self,
				  var attachment = item.pickerFileEntry.attachment
			else { return }
			
			let from = item.imageData
			let id = item.id
			let pickerFileEntry = item.pickerFileEntry
			
			self.saveFile(from: from, filename: "\(attachment.filename).\(attachment.url.fileExtension)") { [weak self] result in
				guard let self
				else { return }
				
				if let index = self.galleryImagesProcessingQueue.firstIndex(where: {
					id == $0.0
				}) {
					self.galleryImagesProcessingQueue.remove(at: index)
				}
				
				switch result {
					case .success(let url): // do we need compress?
						let maxSize = self.configuration.compressionTargetSize
						
						DispatchQueue.main.async {
							let filename = url.fileNameWithoutExtension
							attachment.url = url
							attachment.filename = filename
							attachment.originalName = filename
							
							pickerFileEntry.state = .processing(
								previewUrl: url,
								attachment: attachment
							)
						}
						
						if maxSize != 0,
						   self.sizeBytes(url: url) > maxSize {
							self.compressImage(from: url) { result in
								switch result {
									case .success(let compressedImageUrl):
										DispatchQueue.main.async {
											let filename = compressedImageUrl.fileNameWithoutExtension
											
											attachment.url = compressedImageUrl
											attachment.filename = filename
											attachment.originalName = filename
																						
											if self.validateFilePickerEntrySize(compressedImageUrl) {
												pickerFileEntry.state = .ready(
													previewUrl: compressedImageUrl,
													attachment: attachment		// extension forced to jpeg after compression
												)
											} else {
												pickerFileEntry.state = .error(
													previewUrl: compressedImageUrl,
													attachment: attachment
												)
											}
										}
										
									case .failure:
										DispatchQueue.main.async {
											pickerFileEntry.state = .error(
												previewUrl: url,
												attachment: attachment
											)
										}
								}
							}
						} else {
							DispatchQueue.main.async {
								let filename = url.fileNameWithoutExtension
								attachment.url = url
								attachment.filename = filename
								attachment.originalName = filename
								
								if self.validateFilePickerEntrySize(url) {
									pickerFileEntry.state = .ready(
										previewUrl: url,
										attachment: attachment		// extension forced to jpeg after compression
									)
								} else {
									pickerFileEntry.state = .error(
										previewUrl: url,
										attachment: attachment
									)
								}
							}
						}
						
					case .failure:
						DispatchQueue.main.async {
							pickerFileEntry.state = .error(
								previewUrl: attachment.url,
								attachment: attachment
							)
						}
						
				}
			}
		}
	}
	
	// MARK: - Camera picker
	private func createCameraPicker() -> UIViewController? {
		guard UIImagePickerController.isSourceTypeAvailable(.camera)
		else { return nil }
		
		let cameraImagePicker = UIImagePickerController()
		cameraImagePicker.view.backgroundColor = .Background.backgroundContent
		cameraImagePicker.sourceType = .camera
		cameraImagePicker.allowsEditing = false
		cameraImagePicker.delegate = self
		cameraImagePicker.showsCameraControls = false
		
		setupCameraOverlay(for: cameraImagePicker)
		setupHintOverlay(for: cameraImagePicker)
		
		let initialOverlay = cameraHint == nil
			? cameraOverlayView
			: hintOverlayView
		
		setOverlay(initialOverlay, for: cameraImagePicker)
		updateOverlayViewUI(with: 0)
		
		return cameraImagePicker
	}
	
	private lazy var cameraOverlayView = CameraOverlayView.fromNib()
	private lazy var hintOverlayView = CameraAutoHintOverlayView.fromNib()
	private var cameraHint: AutoOverlayHint?
	private var flashActive: Bool = false
	
	private var photosUpdatedSubscriptions: Subscriptions<Int> = Subscriptions()
	private let disposeBag: DisposeBag = DisposeBag()
	
	private func setupCameraOverlay(for cameraPicker: UIImagePickerController) {
		let hintAvailable = cameraHint != nil
		
		cameraOverlayView.input = .init(
			hint: hintAvailable,
			flashAvailable: UIImagePickerController.isFlashAvailable(for: .rear)
		)
		cameraOverlayView.output = .init(
			takePhotoTap: { [weak self] in
				guard let self
				else { return }
				
				cameraPicker.cameraFlashMode = self.flashActive ? .on : .off
				cameraPicker.takePicture()
			},
			usePhotoTap: { [weak self] in
				self?.selectionFinished()
				cameraPicker.dismiss(animated: true) { [weak self] in
					self?.dismissCompletion?()
				}
			},
			flashTap: { [weak self] in
				guard let self
				else { return }
				
				self.flashActive.toggle()
			},
			cancelTap: { [weak self] in
				guard let self
				else { return }
				
				self.close(cameraPicker)
			},
			showHintTap: { [weak self] in
				guard let self
				else { return }
				
				self.setOverlay(self.hintOverlayView, for: cameraPicker)
			}
		)
		photosUpdatedSubscriptions.add(cameraOverlayView.notify.photosUpdated).disposed(by: disposeBag)
	}
	
	private func setOverlay(_ view: UIView, for imagePicker: UIImagePickerController) {
		view.frame = imagePicker.cameraOverlayView?.frame ?? .zero
		imagePicker.cameraOverlayView = view
	}
	
	private func setupHintOverlay(for imagePicker: UIImagePickerController) {
		hintOverlayView.closeTapHandler = { [weak self] in
			guard let self
			else { return }
			
			self.setOverlay(self.cameraOverlayView, for: imagePicker)
		}
	}
	
	private func updateOverlayViewUI(with pickedImagesCount: Int) {
		photosUpdatedSubscriptions.fire(pickedImagesCount)
		
		if let cameraHint = cameraHint {
			hintOverlayView.set(hint: cameraHint)
		}
	}
	
	// MARK: - UIImagePickerControllerDelegate
	func imagePickerController(
		_ picker: UIImagePickerController,
		didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
	) {
		if let imageUrl = info[.imageURL] as? URL {
			let filename = imageUrl.fileNameWithoutExtension
			
			let attachment = FileAttachment(
				originalName: filename,
				filename: filename,
				url: imageUrl
			)
			
			if self.validateFilePickerEntrySize(imageUrl) {
				entries.append(FilePickerFileEntry(state: .ready(previewUrl: imageUrl, attachment: attachment)))
			} else {
				entries.append(FilePickerFileEntry(state: .error(previewUrl: imageUrl, attachment: attachment)))
			}
			
		} else if let originalImage = info[.originalImage] as? UIImage,
				  picker.sourceType == .camera {
			
			// UIImageWriteToSavedPhotosAlbum default format jpeg
			let cameraImageName = "Photo_\(UUID().uuidString).jpeg"
			let url = Constants.filePickerTemporaryDirectoryName.appendingPathComponent(cameraImageName, isDirectory: false)
			
			try? FileManager.default.removeItem(at: url)
			
			guard let data = originalImage.jpegData(compressionQuality: 1)
			else { return }
			
			do {
				try data.write(to: url)
			} catch let error {
				
				print(error)
				return
			}
			
			if let image = UIImage(contentsOfFile: url.path) {
				UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
			}
			
			let filename = url.fileNameWithoutExtension
			
			let attachment = FileAttachment(
				originalName: filename,
				filename: filename,
				url: url
			)
			
			if validateFilePickerEntrySize(url) {
				entries.append(FilePickerFileEntry(state: .ready(previewUrl: url, attachment: attachment)))
			} else {
				entries.append(FilePickerFileEntry(state: .error(previewUrl: url, attachment: attachment)))
			}
		} else {
			return
		}
		
		if configuration.maxFilesCount == 1 {
			self.selectionFinished()
			
			picker.dismiss(animated: true) { [weak self] in
				self?.dismissCompletion?()
			}
		} else {
			updateOverlayViewUI(with: entries.count)
		}
	}
	
	private func validateFilePickerEntrySize(_ url: URL) -> Bool {
		return sizeBytes(url: url) <= configuration.maxFileSize
	}

	private func selectionFinished() {
		filesSelected?(self.entries)
	}

	func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
		close(picker)
	}
	
	// MARK: - Document picker
	private func createDocumentPicker() -> UIViewController? {
		let documentPicker: UIDocumentPickerViewController
		
		if #available(iOS 14.0, *) {
			documentPicker = UIDocumentPickerViewController(
				forOpeningContentTypes: [.content, .data], asCopy: true
			)
		} else {
			documentPicker = UIDocumentPickerViewController(
				documentTypes: ["public.item"],
				in: .import
			)
		}
		documentPicker.allowsMultipleSelection = true
		documentPicker.delegate = self
		
		return documentPicker
	}
	
	// MARK: - UIDocumentPickerDelegate
	func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
		let sourceUrls = Array(
			urls.prefix(Int(configuration.maxFilesCount))
		)
		
		for sourceUrl in sourceUrls {
			let documentSize = sizeBytes(url: sourceUrl)
			
			if documentSize == 0 {
				continue
			}
			
			let filename = sourceUrl.filename
			
			var attachment = FileAttachment(
				originalName: filename,
				filename: filename,
				url: sourceUrl
			)
			
			let pickerFileEntry = FilePickerFileEntry(
				state: .processing(
					previewUrl: sourceUrl,
					attachment: attachment
				)
			)
			
			self.entries.append(pickerFileEntry)
						
			copySelectedFile(from: sourceUrl) { [weak self] result in
				guard let self
				else { return }
				
				DispatchQueue.main.async {
					switch result {
						case .success(let url):
							let filename = url.filename
							
							attachment.url = url
							attachment.filename = filename
							attachment.originalName = filename
							
							if self.validateFilePickerEntrySize(url) {
								pickerFileEntry.state = .ready(
									previewUrl: url,
									attachment: attachment
								)
							} else {
								pickerFileEntry.state = .error(
									previewUrl: url,
									attachment: attachment
								)
							}
						case .failure:
							pickerFileEntry.state = .error(
								previewUrl: sourceUrl,
								attachment: attachment
							)
					}
				}
			}
		}
		
		selectionFinished()
		close(controller)
	}

	func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
		close(controller)
	}
	
	private struct Constants {
		static let filePickerTemporaryDirectoryName = Storage.tempDirectory.appendingPathComponent(
			"file_picker_temp",
			isDirectory: true
		)
		
		static let filePickerCompressedDirectoryName = Storage.tempDirectory.appendingPathComponent(
			"file_picker_comp",
			isDirectory: true
		)
	}
}
// swiftlint:enable file_length
