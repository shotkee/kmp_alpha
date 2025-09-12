//
//  OsagoPhotoUploadFlow.swift
//  AlfaStrah
//
//  Created by vit on 06.05.2025.
//  Copyright © 2025 Touch Instinct. All rights reserved.
//

import SDWebImage

extension BDUI {
	class OsagoPhotoUploadFlow: AlertPresenterDependency,
								BackendDrivenServiceDependency {
		var alertPresenter: AlertPresenter!
		var backendDrivenService: BackendDrivenService!
		
		private var pickedFileIds: [Int] = []
		private var osagoFilePickerEntries: [FilePickerFileEntry] = []
		private var currentFilePickerFileEntry: FilePickerFileEntry?
		private var galleryFilePickerFileEntries: [FilePickerFileEntry] = []
		private var insructionForOsagoPhotoPickerWasShown: Bool = false
		
		// MARK: - Osago Photo Picker
		private func resetOsagoPhotoPickerForNewAction() {
			insructionForOsagoPhotoPickerWasShown = false
			currentFilePickerFileEntry = nil
			osagoFilePickerEntries.removeAll()
			pickedFileIds.removeAll()
		}
		
		func showAutoEventPhotosSheet(
			picker: OsagoPhotoUploadPickerComponentDTO?,
			from: ViewController,
			completion: @escaping (_ fileIds: [Int]) -> Void
		) {
			self.resetOsagoPhotoPickerForNewAction()
			
			inputEntryFiles(picker?.input)
			
			let viewController = AutoEventPhotosPickerViewController()
			ApplicationFlow.shared.container.resolve(viewController)
			
			viewController.input = .init(
				picker: picker,
				fileEntries: {
					return self.osagoFilePickerEntries
				}
			)
			
			viewController.output = .init(
				addPhoto: { [weak viewController, weak from] in
					viewController?.dismiss(animated: true) { [weak from] in
						guard let from
						else { return }
						
						self.filePicker(picker: picker, from: from) { fileIds in
							completion(self.pickedFileIds)
							self.resetOsagoPhotoPickerForNewAction()
						}
					}
				},
				showPhoto: {
					
				},
				deletePhoto: { attachment in
					if let entryIndex = self.osagoFilePickerEntries.firstIndex(where: {
						$0.attachment?.id == attachment.id
					}) {
						self.osagoFilePickerEntries.remove(at: entryIndex)
					}
				},
				close: { [weak viewController] in
					viewController?.dismiss(animated: true) {
						self.resetOsagoPhotoPickerForNewAction()
					}
				},
				save: { [weak viewController] in
					viewController?.dismiss(animated: true) {
						completion(self.pickedFileIds)
						self.resetOsagoPhotoPickerForNewAction()
					}
				}
			)
			
			from.present(viewController, animated: false)
		}
		
		private func inputEntryFiles(_ inputEntries: [InputEntryOsagoUploadPickerComponentDTO]?) {
			guard let inputEntries
			else { return }
			
			for entry in inputEntries {
				var attachment: FileAttachment?
				
				if let url = entry.url {
					attachment = FileAttachment(
						originalName: url.filename,
						filename: url.filename,
						url: url
					)
				}
				
				let fileEntry = FilePickerFileEntry(state: .processing(previewUrl: entry.url, attachment: attachment, type: .downloading))
				
				SDWebImageManager.shared.loadImage(
					with: entry.url,
					options: .highPriority,
					progress: nil,
					completed: { _, _, error, _, _, _ in
						fileEntry.state = error == nil
						? .ready(previewUrl: entry.url, attachment: attachment)
						: .error(previewUrl: entry.url, attachment: attachment, type: .downloading)
					}
				)
				
				osagoFilePickerEntries.append(fileEntry)
			}
		}
		
		private func filePicker(
			picker: OsagoPhotoUploadPickerComponentDTO?,
			from: ViewController,
			completion: @escaping (_ fileIds: [Int]) -> Void
		) {
			if picker?.canSelectFromSavedPhotos ?? false {
				self.showFilePickerSourceSelectionAlert(from: from) { [weak from] source in
					guard let from
					else { return }
					
					switch source {
						case .camera:
							if self.insructionForOsagoPhotoPickerWasShown {
								self.showCameraPicker(from: from) { [weak from] in
									guard let from
									else { return }
									
									if self.currentFilePickerFileEntry != nil {
										self.showOsagoPhotoUploadConfirm(for: picker?.uploadUrl, from: from) { [weak from] in
											guard let from
											else { return }
											
											if let currentFilePickerFileEntry = self.currentFilePickerFileEntry {
												self.osagoFilePickerEntries.append(currentFilePickerFileEntry)
												
												self.uploadPhoto(to: picker?.uploadUrl, from: currentFilePickerFileEntry)
											}
											
											self.showAutoEventPhotosSheet(picker: picker, from: from, completion: completion)
										}
									}
								}
							} else {
								self.showPhotoInstruction(picker: picker, from: from) { [weak from] in
									guard let from
									else { return }
									
									self.insructionForOsagoPhotoPickerWasShown = true
									self.showAutoEventPhotosSheet(picker: picker, from: from, completion: completion)
								}
							}
							
						case .gallery:
							self.showGalleryPicker(from: from) { [weak from] in
								guard let from,
									  !self.galleryFilePickerFileEntries.isEmpty
								else { return }
								
								self.osagoFilePickerEntries.append(contentsOf: self.galleryFilePickerFileEntries)
								
								for entry in self.osagoFilePickerEntries {
									self.uploadPhoto(to: picker?.uploadUrl, from: entry)
								}
								
								self.showAutoEventPhotosSheet(picker: picker, from: from, completion: completion)
							}
							
						default:
							break
					}
				}
			} else {
				if self.insructionForOsagoPhotoPickerWasShown {
					self.showCameraPicker(from: from) { [weak from] in
						guard let from
						else { return }
						
						if self.currentFilePickerFileEntry != nil {
							self.showOsagoPhotoUploadConfirm(for: picker?.uploadUrl, from: from) { [weak from] in
								guard let from
								else { return }
								
								if let currentFilePickerFileEntry = self.currentFilePickerFileEntry {
									self.osagoFilePickerEntries.append(currentFilePickerFileEntry)
									
									self.uploadPhoto(to: picker?.uploadUrl, from: currentFilePickerFileEntry)
								}
								
								self.showAutoEventPhotosSheet(picker: picker, from: from, completion: completion)
							}
						}
					}
				} else {
					self.showPhotoInstruction(picker: picker, from: from) { [weak from] in
						guard let from
						else { return }
						
						if let currentFilePickerFileEntry = self.currentFilePickerFileEntry {
							self.osagoFilePickerEntries.append(currentFilePickerFileEntry)
							
							self.uploadPhoto(to: picker?.uploadUrl, from: currentFilePickerFileEntry)
						}
						
						self.insructionForOsagoPhotoPickerWasShown = true
						self.showAutoEventPhotosSheet(picker: picker, from: from, completion: completion)
					}
				}
			}
		}
		
		private func showFilePickerSourceSelectionAlert(
			from: ViewController,
			completion: @escaping (FilePickerSource) -> Void
		) {
			let actionSheet = UIAlertController(
				title: nil,
				message: nil,
				preferredStyle: .actionSheet
			)
			
			let cameraPickerAction = UIAlertAction(
				title: NSLocalizedString("bdui_osago_alert_filesource_camera", comment: ""),
				style: .default
			) { _ in
				
				completion(.camera)
			}
			actionSheet.addAction(cameraPickerAction)
			
			let galleryPickerAction = UIAlertAction(
				title: NSLocalizedString("bdui_osago_alert_filesource_gallery", comment: ""),
				style: .default,
				handler: { _ in
					completion(.gallery)
				}
			)
			
			actionSheet.addAction(galleryPickerAction)
			
			let cancel = UIAlertAction(
				title: NSLocalizedString(
					"common_cancel_button",
					comment: ""
				),
				style: .cancel,
				handler: nil
			)
			
			actionSheet.addAction(cancel)
			
			from.present(
				actionSheet,
				animated: true
			)
		}
		
		private func showCameraPicker(
			from: ViewController,
			completion: @escaping () -> Void
		) {
			Permissions.camera { [weak from] granted in
				guard granted, let from
				else { return }
				
				let configuration = FilePicker.Configuration(
					compressionTargetSize: 5 * 1024 * 1024,
					maxFilesCount: 1,
					compressionRatio: 0.3,
					maxFileSize: 25 * 1024 * 1024
				)
				
				if let picker = FilePicker.shared.pick(
					from: .camera,
					with: configuration,
					filesSelected: { [weak from] entries in
						guard let from
						else { return }
						
						self.currentFilePickerFileEntry = entries.last
						
						if self.insructionForOsagoPhotoPickerWasShown {
							from.presentedViewController?.dismiss(animated: true) {
								completion()
							}
						} else {
							completion()
						}
					},
					dismissCompletion: { [weak from] in
						guard let from
						else { return }
					},
					on: from
				) {
					from.present(picker, animated: true)
				}
			}
		}
		
		private func showOsagoPhotoUploadConfirm(for uploadUrl: URL?, from: ViewController, completion: @escaping () -> Void) {
			guard let currentFilePickerFileEntry,
				  let uploadUrl
			else { return }
			
			let viewController = AutoEventPhotoAttachmentConfirmationViewController()
			
			viewController.input = .init(
				lastTakedPhotoEntry: currentFilePickerFileEntry
			)
			
			viewController.output = .init(
				retakePhoto: { [weak from, weak viewController] in
					guard let from,
						  let viewController
					else { return }
					
					self.showCameraPicker(
						from: from
					) { [weak viewController] in
						viewController?.notify.reload(self.currentFilePickerFileEntry)
					}
				},
				savePhoto: { [weak viewController] in
					if self.insructionForOsagoPhotoPickerWasShown {
						viewController?.dismiss(animated: true) {
							completion()
						}
					} else {
						completion()
					}
				}
			)
			
			if self.insructionForOsagoPhotoPickerWasShown {
				viewController.addBackButton { [weak viewController] in
					viewController?.navigationController?.dismiss(animated: true) {
						completion()
					}
				}
				
				viewController.addCloseButton(position: .right) { [weak viewController] in
					viewController?.navigationController?.dismiss(animated: true) {
						completion()
					}
				}
				
				let navigationController = RMRNavigationController()
				navigationController.strongDelegate = RMRNavigationControllerDelegate()
				
				navigationController.setViewControllers([ viewController ], animated: true)
				from.present(navigationController, animated: true)
			} else {
				from.navigationController?.pushViewController(viewController, animated: true)
			}
		}
		
		private func uploadPhoto(to uploadUrl: URL?, from fileEntry: FilePickerFileEntry) {
			if let uploadUrl {
				self.backendDrivenService.upload(
					fileEntry: fileEntry,
					to: uploadUrl
				) { result in
					switch result {
						case .success(let fileId):
							self.pickedFileIds.append(fileId)
							
						case .failure(let error):
							ErrorHelper.show(error: error, alertPresenter: self.alertPresenter)
							
					}
				}
			}
		}
		
		private func showPhotoInstruction(
			picker: OsagoPhotoUploadPickerComponentDTO?,
			from: ViewController,
			completion: @escaping () -> Void
		) {
			let viewController = AutoEventPhotoAttachmentInstructionsViewController()
			
			viewController.input = .init(
				picker: picker
			)
			
			viewController.output = .init(
				createPhoto: {
					self.showCameraPicker(from: viewController) { [weak viewController] in
						guard let viewController
						else { return }
						
						if self.currentFilePickerFileEntry != nil {
							self.showOsagoPhotoUploadConfirm(
								for: picker?.uploadUrl,
								from: viewController
							) { [weak viewController] in
								viewController?.navigationController?.dismiss(animated: true) {
									completion()
								}
							}
						}
					}
				}
			)
			
			viewController.addCloseButton(position: .right) { [weak viewController] in
				viewController?.navigationController?.dismiss(animated: true) {
					completion()
				}
			}
			
			let navigationController = RMRNavigationController()
			navigationController.strongDelegate = RMRNavigationControllerDelegate()
			
			navigationController.setViewControllers([ viewController ], animated: true)
			from.present(navigationController, animated: true, completion: nil)
		}
		
		private func showGalleryPicker(
			from: ViewController,
			completion: @escaping () -> Void
		) {
			func galleryPicker(from: ViewController, completion: @escaping () -> Void) {
				let configuration = FilePicker.Configuration(
					compressionTargetSize: 5 * 1024 * 1024,
					maxFilesCount: 20,
					compressionRatio: 0.3,
					maxFileSize: 25 * 1024 * 1024
				)
				
				if let picker = FilePicker.shared.pick(
					from: .gallery,
					with: configuration,
					filesSelected: { [weak from] entries in
						guard let from
						else { return }
						
						self.galleryFilePickerFileEntries.append(contentsOf: entries)
					},
					dismissCompletion: { [weak from] in
						guard let from
						else { return }
						
						completion()
					},
					on: from
				) {
					from.present(picker, animated: true)
				}
			}
			
			if #available(iOS 14.0, *) {
				Permissions.photoLibrary(for: .readWrite) { [weak from] granted in
					guard granted, let from
					else { return }
					
					galleryPicker(from: from, completion: completion)
				}
			} else {
				galleryPicker(from: from, completion: completion)
			}
		}
	}
}
