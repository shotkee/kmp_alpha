//
//  DocumentInputBottomViewController.swift
//  AlfaStrah
//
//  Created by Nikita Omelchenko on 05.02.2021.
//  Copyright © 2021 Redmadrobot. All rights reserved.
//

import Legacy

class DocumentInputBottomViewController: BaseBottomSheetViewController, AttachmentServiceDependency {
    var attachmentService: AttachmentService!
    
    private lazy var filePickerView: FilePickerView = .init(frame: .zero)
	private lazy var errorLabel = UILabel()

    struct Input {
        let title: String
        let description: String?
        let doneButtonTitle: String?
        let step: BaseDocumentStep
        let showTotalFilesSize: Bool
		let validateSize: Bool
        
        init(
            title: String,
            description: String?,
            doneButtonTitle: String? = nil,
            step: BaseDocumentStep,
            showTotalFilesSize: Bool = false,
			validateSize: Bool = false
        ) {
            self.title = title
            self.description = description
            self.doneButtonTitle = doneButtonTitle
            self.step = step
            self.showTotalFilesSize = showTotalFilesSize
			self.validateSize = validateSize
        }
    }

    struct Output {
        let close: () -> Void
        let done: () -> Void
        let delete: ([Attachment]) -> Void
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
            self?.updateUI()
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

        closeTapHandler = output.close
        primaryTapHandler = output.done

        filePickerView.output = .init(
            openDocument: { [weak self] in
                self?.output.openDocument($0)
            },
            pickFile: { [weak self] in
                guard let self
                else { return }

				if self.input.step.maxDocuments > 0,
				   self.input.step.attachments.count >= self.input.step.maxDocuments {
					return
				}
				
				self.output.pickFile()
            },
            delete: { [weak self] in
                self?.output.delete([$0])
            },
            deleteFromGalleryMedia: { [weak self] attachment in
                guard let self
                else { return }

                self.dismiss(animated: true) {
                    self.output.delete([attachment])
                }
            },
            showPhoto: { [weak self] controller, animated, completion in
                guard let self
                else { return }

                self.output.showPhoto(controller, animated, completion)
            },
			entryStateChanged: { _ in }
        )

        updateUI()
    }

    private func updateUI() {
		let attachmentEntries = input.step.attachments.map {
			return FilePickerFileEntry(
				state: .ready(previewUrl: $0.url, attachment: $0)
			)
		}
					
        filePickerView.set(data: attachmentEntries)
        set(doneButtonEnabled: !input.step.attachments.isEmpty)
                
        let localized = NSLocalizedString(
            "selected_files_count",
            comment: ""
        )
        
        let rootString = String(
            format: localized,
            locale: .init(identifier: "ru"),
            input.step.attachments.count
        )
		
        if input.step.attachments.isEmpty {
			set(infoText: input.description ?? NSLocalizedString("common_documents_sub_title", comment: ""))
			set(doneButtonEnabled: false)
			errorLabel.isHidden = true
			
			return
        } else {
            if input.showTotalFilesSize {
                let totalAttachmentsSize = input.step.attachments.reduce(0) { $0 + (attachmentService.size(from: $1.url) ?? 0) }
                let totalAttachmentsSizeString = bytesCountFormatted(from: totalAttachmentsSize)
                
                let attributedRootString = addAttributedRedPostfix(text: rootString, postfix: totalAttachmentsSizeString)
                set(attributedInfoText: attributedRootString)
            } else {
                set(infoText: rootString)
            }
			
			func errorMaxAttachmentCountText() -> String {
				let localized = NSLocalizedString(
					"documents_count_validation",
					comment: ""
				)

				return String(
					format: localized,
					locale: .init(identifier: "ru"),
					self.input.step.maxDocuments
				)
			}
						
			if self.input.step.maxDocuments > 0,
			   self.input.step.attachments.count >= self.input.step.maxDocuments {
				errorLabel.text = errorMaxAttachmentCountText()
				
				set(doneButtonEnabled: true)
				errorLabel.isHidden = false
			}
						
			if input.validateSize {
				let invalidAttachmentsCount = input.step.attachments.filter({
					(attachmentService.size(from: $0.url) ?? 0) >= Constants.maxFileSize
				}).count
				
				let isValidCount = !(invalidAttachmentsCount > 0)
								
				if !isValidCount {
					let localized = NSLocalizedString(
						"files_invalid_files_size_count",
						comment: ""
					)
					
					let inavlidAttachmentsCountString = String(
						format: localized,
						locale: .init(identifier: "ru"),
						invalidAttachmentsCount
					)
					
					errorLabel.text = inavlidAttachmentsCountString
					set(doneButtonEnabled: false)
					errorLabel.isHidden = false
					
					return
				}
			}
        }
		
		set(doneButtonEnabled: true)
		errorLabel.isHidden = true
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
