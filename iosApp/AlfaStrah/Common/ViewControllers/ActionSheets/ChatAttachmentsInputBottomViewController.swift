//
//  ChatAttachmentsInputBottomViewController.swift
//  AlfaStrah
//
//  Created by vit on 06.05.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

import Legacy

class ChatAttachmentsInputBottomViewController: BaseBottomSheetViewController, AttachmentServiceDependency {
	var attachmentService: AttachmentService!
	
	private lazy var filePickerView: FilePickerView = .init(frame: .zero)
	private lazy var errorLabel = UILabel()

	struct Input {
		let title: String
		let description: String?
		let doneButtonTitle: String?
		let fileEntries: () -> [FilePickerFileEntry]
		let maxDocumentsCount: Int
		
		init(
			title: String,
			description: String?,
			doneButtonTitle: String? = nil,
			fileEntries: @escaping () -> [FilePickerFileEntry],
			validateSize: Bool = false,
			maxDocumentCount: Int = 10
		) {
			self.title = title
			self.description = description
			self.doneButtonTitle = doneButtonTitle
			self.fileEntries = fileEntries
			self.maxDocumentsCount = maxDocumentCount
		}
	}

	struct Output {
		let close: () -> Void
		let done: () -> Void
		let delete: ([FilePickerFileEntry]) -> Void
		let pickFile: () -> Void
		let showPhoto: (UIViewController, Bool, (() -> Void)?) -> Void
		let openDocument: (Attachment) -> Void
	}

	struct Notify {
		var filesUpdated: () -> Void
	}

	var input: Input!
	var output: Output!

	// swiftlint:disable:next trailing_closure
	lazy private(set) var notify: Notify = Notify(
		filesUpdated: { [weak self] in
			guard let self
			else { return }
			
			self.updateUI()
		}
	)
	
	override func setupUI() {
		super.setupUI()

		set(title: input.title)
		set(
			style: .actions(
				primaryButtonTitle: input.doneButtonTitle ?? NSLocalizedString("common_done_button", comment: ""),
				secondaryButtonTitle: nil
			)
		)
		
		set(doneButtonEnabled: true)
		set(views: [ filePickerView ])
		
		errorLabel <~ Style.Label.accentText
		errorLabel.numberOfLines = 0
		add(view: errorLabel)
		errorLabel.isHidden = true
		errorLabel.text = ""

		closeTapHandler = output.close
		primaryTapHandler = output.done

		filePickerView.output = .init(
			openDocument: { [weak self] in
				self?.output.openDocument($0)
			},
			pickFile: { [weak self] in
				guard let self
				else { return }

				if self.input.maxDocumentsCount > 0,
				   self.input.fileEntries().count >= self.input.maxDocumentsCount {
					return
				}
			
				self.output.pickFile()
			},
			delete: { [weak self] attachmentToDelete in
				guard let fileEntryToDelete = self?.input.fileEntries().first(where: { $0.attachment?.id == attachmentToDelete.id })
				else { return }
				
				self?.output.delete([fileEntryToDelete])
			},
			deleteFromGalleryMedia: { attachmentToDelete in
				self.dismiss(animated: true) { [weak self] in
					guard let self
					else { return }
					
					guard let fileEntryToDelete = self.input.fileEntries().first(where: { $0.attachment?.id == attachmentToDelete.id })
					else { return }
					
					self.output.delete([fileEntryToDelete])
				}
			},
			showPhoto: { [weak self] controller, animated, completion in
				guard let self
				else { return }

				self.output.showPhoto(controller, animated, completion)
			},
			entryStateChanged: { [weak self] entry in
				guard let self
				else { return }
				
				errorLabel.text = ""
				errorLabel.isHidden = true
				
				set(doneButtonEnabled: true)
								
				let sortedFileEntries = input.fileEntries().reversed().sorted(by: {
					$0.state.isError && !$1.state.isError
				})
								
				filePickerView.set(data: sortedFileEntries)
								
				if fileEntriesHaveProccessingState(sortedFileEntries) {
					handleDownloadingType()
					
					return
				}
				
				validateFileEntriesQueue()
				
				set(doneButtonEnabled: allSelectedFilesInError(sortedFileEntries))
			}
		)

		updateUI()
	}
	
	private func allSelectedFilesInError(_ entries: [FilePickerFileEntry]) -> Bool {
		return entries.contains(where: { !$0.state.isError })
	}
	
	private func handleDownloadingType() {
		if self.input.fileEntries().contains(where: {
			switch $0.state {
				case .processing(_, _, type: let processingType):
					guard let processingType
					else { return false }
					
					switch processingType {
						case .downloading:
							return true
						case .compressing, .uploading:
							return false
					}
				case .error, .ready:
					return false
			}
		}) {
			errorLabel.text = NSLocalizedString("chat_files_downloading_state_warning", comment: "")
		} else {
			errorLabel.text = NSLocalizedString("chat_files_processing_state_warning", comment: "")
		}
		
		errorLabel.isHidden = false
		set(doneButtonEnabled: false)
	}
	
	private func fileEntriesHaveProccessingState(_ entries: [FilePickerFileEntry]) -> Bool {
		if self.input.fileEntries().contains(where: {
			switch $0.state {
				case .processing:
					return true
				case .error, .ready:
					return false
			}
		}) { return true }
		
		return false
	}
	
	private func updateUI() {
		errorLabel.text = ""
		errorLabel.isHidden = true
		
		set(doneButtonEnabled: true)
		
		let sortedFileEntries = input.fileEntries().reversed().sorted(by: {
			$0.state.isError && !$1.state.isError
		})
						
		filePickerView.set(data: sortedFileEntries)
		set(doneButtonEnabled: !input.fileEntries().isEmpty)
						
		if fileEntriesHaveProccessingState(sortedFileEntries) {
			handleDownloadingType()
		} else {
			validateFileEntriesQueue()
			set(doneButtonEnabled: allSelectedFilesInError(sortedFileEntries))
		}
	}
	
	private func validateFileEntriesQueue() {
		let filesCount = input.fileEntries().count
		
		let localized = NSLocalizedString(
			"selected_files_count",
			comment: ""
		)
		
		let rootString = String(
			format: localized,
			locale: .init(identifier: "ru"),
			filesCount
		)
		
		if filesCount == 0 {
			set(infoText: input.description ?? NSLocalizedString("common_documents_sub_title", comment: ""))
			set(doneButtonEnabled: false)
			errorLabel.isHidden = true
			
			return
		} else {
			set(infoText: rootString)
		}
		
		if self.input.maxDocumentsCount > 0,
		   filesCount >= self.input.maxDocumentsCount {
			filePickerView.addFileButtonIsHidden = true
			
			let localized = NSLocalizedString(
				"documents_count_validation",
				comment: ""
			)

			errorLabel.text = String(
				format: localized,
				locale: .init(identifier: "ru"),
				self.input.maxDocumentsCount
			)
			
			set(doneButtonEnabled: true)
			errorLabel.isHidden = false
		} else {
			filePickerView.addFileButtonIsHidden = false
		}
		
		var totalInvalidAttachmentsCount = 0
		
		let invalidDownloadedFiles = input.fileEntries().filter({
			switch $0.state {
				case .processing, .ready:
					return false
				case .error(_, _, type: let errorType):
					switch errorType {
						case .common:
							return false
						case .downloading:
							return true
						default:
							return false
					}
			}
		})
		
		let invalidDownloadedFilesCount = invalidDownloadedFiles.count
					
		totalInvalidAttachmentsCount += invalidDownloadedFilesCount
		
		if !invalidDownloadedFiles.isEmpty {
			let localized = NSLocalizedString(
				"chat_files_download_error",
				comment: ""
			)
			
			let inavlidAttachmentsCountString = String(
				format: localized,
				locale: .init(identifier: "ru"),
				invalidDownloadedFilesCount
			)
			
			errorLabel.text = inavlidAttachmentsCountString
			errorLabel.isHidden = false
		}
		
		let invalidSizeAttachments = input.fileEntries().filter({
			guard let attachment = $0.attachment
			else { return false }
			
			let invalid = (attachmentService.size(from: attachment.url) ?? 0) >= Constants.maxFileSize
						
			return invalid
		})
		
		let invalidSizeAttachmentsCount = invalidSizeAttachments.count
		
		totalInvalidAttachmentsCount += invalidSizeAttachmentsCount
		
		if !invalidSizeAttachments.isEmpty {
			let localized = NSLocalizedString(
				"files_invalid_files_size_count",
				comment: ""
			)
			
			let inavlidAttachmentsCountString = String(
				format: localized,
				locale: .init(identifier: "ru"),
				invalidSizeAttachmentsCount
			)
			
			errorLabel.text = inavlidAttachmentsCountString
			errorLabel.isHidden = false
		}
		
		// all invalid attachments have to be lower than files count
		if filesCount - totalInvalidAttachmentsCount > 0 {
			set(doneButtonEnabled: true)
		}
	}
	
	private func addAttributedRedPostfix(text: String, postfix: String) -> NSMutableAttributedString {
		let attributedText = NSMutableAttributedString(string: text)
		
		let attributedPostfix = NSMutableAttributedString(
			string: " (" + postfix + ")",
			attributes: [
				.foregroundColor: UIColor.Text.textAccent
			]
		)
		attributedText.append(attributedPostfix)
		
		return attributedText
	}
	
	private func bytesCountFormatted(from bytesCount: Int64) -> String {
		let formatter = ByteCountFormatter()
		formatter.allowedUnits = [.useMB, .useKB]
		formatter.countStyle = .file
		return formatter.string(fromByteCount: bytesCount)
	}
	
	struct Constants {
		static let maxFileSize = 25 * 1024 * 1024
	}
}
