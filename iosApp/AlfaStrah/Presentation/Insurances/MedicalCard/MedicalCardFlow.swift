//
//  MedicalCardFlow.swift
//  AlfaStrah
//
//  Created by vit on 14.04.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

import UIKit
import Legacy
import SDWebImage

class MedicalCardFlow: BaseFlow,
                       AttachmentServiceDependency,
                       MedicalCardServiceDependency {
    var attachmentService: AttachmentService!
    var medicalCardService: MedicalCardService!
    
    private var attachmentsUpdatedSubscriptions: Subscriptions<Void> = Subscriptions()
    private lazy var documentSelectionBehavior = DocumentPickerBehavior()
    private var searchString: String = ""
    
    private let documentStep = BaseDocumentStep(
        title: NSLocalizedString("medical_card_files_upload_bottom_sheet_title", comment: ""),
        minDocuments: 0,
        maxDocuments: 200,
        attachments: []
    )
    
    func start() {
        let viewController = createMedicalCardFileStorageViewController()
        
        createAndShowNavigationController(
            viewController: viewController,
            mode: .modal
        )
    }
    
    private func createMedicalCardFileStorageViewController() -> MedicalCardFilesStorageViewController {
        let viewController = MedicalCardFilesStorageViewController()
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
            uploadFileButtonTap: { [weak viewController] in
                guard let viewController = viewController
                else { return }
                
                self.pickFiles(
                    to: self.documentStep,
                    from: viewController,
                    completion: { [weak viewController] _ in
                        guard let viewController = viewController
                        else { return }
                        
                        self.openFilesUploadInputBottomViewController(
                            from: viewController,
                            step: self.documentStep,
                            completion: { _ in }
                        )
                    }
                )
            },
            menuRightNavigationItemTap: { [weak viewController] in
                guard let viewController = viewController
                else { return }
                
                viewController.notify.selectionModeEnabled(true)
            },
            goToChat: {
                ApplicationFlow.shared.show(item: .tabBar(.chat))
            },
            retryFileEntryUpload: { fileEntry in
                self.medicalCardService.retryUploadFile(for: fileEntry) { result in
                    switch result {
                        case .success:
                            break
                        case .failure(let error):
                            ErrorHelper.show(
                                error: error,
                                alertPresenter: self.alertPresenter
                            )
                    }
                }
            },
            showInfoBottomSheet: { [weak viewController] fileEntry in
                guard let viewController = viewController
                else { return }
                
                self.showInfoBottomSheet(from: viewController, for: fileEntry)
            },
            renameFileEntry: { [weak viewController] fileEntry in
                guard let viewController = viewController
                else { return }
                
                self.openRenameFileInputBottomViewController(
                    from: viewController,
                    initialText: fileEntry.originalFilename
                ) { fileName in
                    
                    self.rewriteFieldFileEntry(
                        fileEntry: fileEntry,
                        fileName: fileName,
                        viewController: viewController
                    )
                }
            },
            removeFileEntry: { [weak viewController] fileEntry in
                guard let viewController = viewController
                else { return }
                
                self.showRemoveFileAlert(
                    fileEntry: fileEntry,
                    from: viewController
                )
            },
            removeFileEntries: { [weak viewController] isSelectedAllFiles, fileEntries in
                guard let viewController = viewController
                else { return }
                
                self.showRemoveFilesAlert(
                    files: fileEntries,
                    isSelectedAllFiles: isSelectedAllFiles,
                    from: viewController
                )
            },
            downloadFileEntry: { [weak viewController] fileEntry in
                guard let viewController = viewController
                else { return }
                
                self.medicalCardService.downloadFile(for: fileEntry) { [weak viewController] result in
                    guard let viewController = viewController
                    else { return }
                    
                    switch result {
                        case .success:
                            break
                        case .failure(let error):
                            ErrorHelper.show(
                                error: error,
                                alertPresenter: self.alertPresenter
                            )
                    }
                }
            },
            cancelUpload: { fileEntry in
                self.medicalCardService.cancelUpload(for: fileEntry)
            },
            showFileEntry: { [weak viewController] fileEntry in
                guard let viewController = viewController
                else { return }
                
                self.showFile(
                    fileEntry: fileEntry,
                    viewController: viewController
                )
            }
        )
        
        medicalCardService.subscribeForFileEntriesUpdates { groups in
            viewController.notify.updateWithState(.filled(groups))
        }.disposed(by: viewController.disposeBag)
        
        return viewController
    }
    
    private func showFile(
        fileEntry: MedicalCardFileEntry,
        viewController: ViewController
    ) {
        guard let fileName = fileEntry.localStorageFilename,
              let fileUrl = medicalCardService.localStorageUrl(for: fileName)
        else { return }
        
        LocalDocumentViewer.open(fileUrl, from: viewController)
    }
    
    private func renameFile(
        fileEntry: MedicalCardFileEntry,
        fileName: String,
        from viewController: MedicalCardFilesStorageViewController
    ){
        guard let navigationController = navigationController
        else { return }
        
        var newFileEntry = fileEntry
        newFileEntry.originalFilename = fileName
        
        let hide = navigationController.showLoadingIndicator(
            message: NSLocalizedString("medical_card_files_storage_loading_rename_file_text", comment: "")
        )
        
        medicalCardService.renameFile(
            fileEntry: newFileEntry
        ) { [weak viewController] result in
            guard let viewController = viewController
            else { return }
            
            hide(nil)
            
            switch result {
                case .success:
                    viewController.notify.updateFileNameToast()
                case .failure:
                    self.showRenameFileFailureAlert(
                        fileEntry: fileEntry,
                        fileName: fileName,
                        from: viewController
                    )
            }
        }
		
		viewController.reloadUI()
    }
    
    private func removeFiles(
        files: [MedicalCardFileEntry],
        from viewController: MedicalCardFilesStorageViewController
    ) {
        let hide = viewController.showLoadingIndicator(
            message: NSLocalizedString(
                "medical_card_files_storage_loading_delete_file_text",
                comment: ""
            )
        )
        
        var loadingFiles: [MedicalCardFileEntry] = files
        var fileEntriesGroups: [MedicalCardFileEntriesGroup] = self.medicalCardService.getActualFiles(
            searchString: searchString
        )
        var errorLoadingFile: AlfastrahError?
        
        viewController.setActivateSelectionModeBarButton(
            isEnabled: false
        )
        
        let update: (([MedicalCardFileEntriesGroup], AlfastrahError?, [MedicalCardFileEntry]) -> ()) = {
            [weak viewController] fileEntriesGroups, errorLoading, fileEntry in
            
            guard let viewController = viewController
            else { return }
            
            updateStateViewControllerAfterRemoveFiles(
                fileEntriesGroups: fileEntriesGroups,
                deleteFilesCount: files.count,
                errorLoading: errorLoading,
                hide: hide,
                isEnabled: fileEntry.isEmpty,
                viewController: viewController
            )
        }
        
        for file in files {
            if let fileId = file.fileId {
                medicalCardService.removeFile(
                    searchString: self.searchString,
                    fileId: fileId
                ) { [weak viewController] result in
                    guard let viewController = viewController
                    else { return }
                    
                    loadingFiles.removeAll(where: { $0.fileId == fileId })
                    
                    switch result {
                        case .success:
                            fileEntriesGroups = self.medicalCardService.getActualFiles(
                                searchString: self.searchString
                            )
                        case .failure(let error):
                            errorLoadingFile = error
                    }
                    update(fileEntriesGroups, errorLoadingFile, loadingFiles)
                }
            } else {
                if medicalCardService.removeCachedFile(fileName: file.originalFilename) {
                    loadingFiles = loadingFiles.filter { $0.id != file.id }
                }
                update(
                    medicalCardService.getActualFiles(
                        searchString: searchString
                    ),
                    errorLoadingFile,
                    loadingFiles
                )
            }
        }
        
        func updateStateViewControllerAfterRemoveFiles(
            fileEntriesGroups: [MedicalCardFileEntriesGroup],
            deleteFilesCount: Int,
            errorLoading: AlfastrahError?,
            hide: ((() -> Void)?) -> Void,
            isEnabled: Bool,
            viewController: MedicalCardFilesStorageViewController
        ){
            if isEnabled, errorLoading != nil {
                hide(nil)
                viewController.notify.updateStateWhenRemoveFiles(
                    .filled(fileEntriesGroups),
                    .failure(.unknownError)
                )
            } else if isEnabled, errorLoading == nil {
                hide(nil)
                viewController.notify.updateStateWhenRemoveFiles(
                    .filled(fileEntriesGroups),
                    .success(deleteFilesCount)
                )
            }
            viewController.setActivateSelectionModeBarButton(
                isEnabled: isEnabled
            )
        }
    }
    
    private func removeFile(
        fileEntry: MedicalCardFileEntry,
        from viewController: MedicalCardFilesStorageViewController
    ) {
        if let fileId = fileEntry.fileId {
            let hide = viewController.showLoadingIndicator(
                message: NSLocalizedString(
                    "medical_card_files_storage_loading_delete_file_text",
                    comment: ""
                )
            )
            
            viewController.setActivateSelectionModeBarButton(
                isEnabled: false
            )
            
            medicalCardService.removeFile(
                searchString: self.searchString,
                fileId: fileId
            ) { [weak viewController] result in
                guard let viewController = viewController
                else { return }
                
                hide(nil)
                viewController.setActivateSelectionModeBarButton(
                    isEnabled: true
                )
                
                switch result {
                    case .success:
                        viewController.notify.updateStateWhenRemoveFiles(
                            .filled(self.medicalCardService.getActualFiles(searchString: self.searchString)),
                            .success(1)
                        )
                    case .failure(let error):
                        viewController.notify.updateStateWhenRemoveFiles(
                            .filled(self.medicalCardService.getActualFiles(searchString: self.searchString)),
                            .failure(error)
                        )
                }
            }
        } else {
            if self.medicalCardService.removeCachedFile(
                fileName: fileEntry.originalFilename
            ) {
                viewController.notify.updateStateWhenRemoveFiles(
                    .filled(
                        self.medicalCardService.getActualFiles(
                            searchString: self.searchString
                        )
                    ),
                    .success(1)
                )
            }
        }
    }
    
    private func showRemoveFilesAlert(
        files: [MedicalCardFileEntry],
        isSelectedAllFiles: Bool,
        from viewController: MedicalCardFilesStorageViewController
    ) {
        let countFilesToString = String.localizedStringWithFormat(
            NSLocalizedString("files_count", comment: ""),
            files.count
        )
        let format = NSLocalizedString("medical_card_files_alert_remove_title", comment: "")
        
        let alert = UIAlertController(
            title: isSelectedAllFiles
                ? NSLocalizedString("medical_card_files_alert_remove_all_files_title", comment: "")
                : String(
                    format: format,
                    locale: .init(identifier: "ru"),
                    countFilesToString
                ),
            message: NSLocalizedString("medical_card_files_alert_remove_message", comment: ""),
            preferredStyle: .alert
        )
        
        let removeAction = UIAlertAction(
            title: NSLocalizedString(isSelectedAllFiles
                ? "medical_card_files_remove_all_files_button"
                : "common_delete",
                comment: ""
            ),
            style: .default
        ) { [weak viewController] _ in
            guard let viewController = viewController
            else { return }
            
            self.removeFiles(
                files: files,
                from: viewController
            )
        }
        
        let cancelAction = UIAlertAction(
            title: NSLocalizedString("common_cancel_button", comment: ""),
            style: .cancel
        )
        
        alert.addAction(removeAction)
        alert.addAction(cancelAction)

        viewController.present(alert, animated: true)
    }
    
    private func showRemoveFileAlert(
        fileEntry: MedicalCardFileEntry,
        from viewController: MedicalCardFilesStorageViewController
    ) {
        let alert = UIAlertController(
            title: NSLocalizedString("medical_card_file_alert_remove_title", comment: ""),
            message: NSLocalizedString("medical_card_file_alert_remove_message", comment: ""),
            preferredStyle: .alert
        )
        
        let removeAction = UIAlertAction(
            title: NSLocalizedString("common_delete", comment: ""),
            style: .default
        ) { [weak viewController] _ in
            guard let viewController = viewController
            else { return }
            
            self.removeFile(
                fileEntry: fileEntry,
                from: viewController
            )
        }
        
        let cancelAction = UIAlertAction(
            title: NSLocalizedString("common_cancel_button", comment: ""),
            style: .cancel
        )
        
        alert.addAction(removeAction)
        alert.addAction(cancelAction)

        viewController.present(alert, animated: true)
    }
    
    private func showRenameFileFailureAlert(
        fileEntry: MedicalCardFileEntry,
        fileName: String,
        from viewController: MedicalCardFilesStorageViewController
    ) {
        let alert = UIAlertController(
            title: NSLocalizedString("medical_card_file_alert_error_rename_title", comment: ""),
            message: NSLocalizedString("common_please_try_again_or_contact_to_chat", comment: ""),
            preferredStyle: .alert
        )

        let retryAction = UIAlertAction(
            title: NSLocalizedString("common_retry", comment: ""),
            style: .default
        ) { [weak viewController] _ in
            guard let viewController = viewController
            else { return }
            
            self.openRenameFileInputBottomViewController(
                from: viewController,
                initialText: fileEntry.originalFilename,
                fileName: fileName
            ) { fileName in
                
                self.rewriteFieldFileEntry(
                    fileEntry: fileEntry,
                    fileName: fileName,
                    viewController: viewController
                )
            }
        }

        let cancelAction = UIAlertAction(
            title: NSLocalizedString("common_cancel_button", comment: ""),
            style: .cancel
        )

        alert.addAction(retryAction)
        alert.addAction(cancelAction)

        viewController.present(alert, animated: true)
    }
    
    private func rewriteFieldFileEntry(
        fileEntry: MedicalCardFileEntry,
        fileName: String,
        viewController: MedicalCardFilesStorageViewController
    ) {
        self.renameFile(
            fileEntry: fileEntry,
            fileName: fileName,
            from: viewController
        )
    }
    
    private func showInfoBottomSheet(from viewController: ViewController, for fileEntry: MedicalCardFileEntry) {
        func descriptionLabel(_ text: String) -> UILabel {
            let description = UILabel()
            description <~ Style.Label.primaryText
            description.numberOfLines = 0
            description.text = text
            return description
        }

        func subtitleLabel(_ text: String) -> UILabel {
            let subtitleLabel = UILabel()
            subtitleLabel.numberOfLines = 0
            subtitleLabel <~ Style.Label.primaryHeadline3
            subtitleLabel.text = text
            return subtitleLabel
        }
        
        switch fileEntry.status {
            case .uploading:
                MedicalCardInfoBottomSheet.present(
                    from: viewController,
                    title: NSLocalizedString("medical_card_files_uploading_info_bottom_sheet_title", comment: ""),
                    buttonTitle: NSLocalizedString("medical_card_files_uploading_info_bottom_sheet_button_title", comment: ""),
                    additionalViews: [
                        descriptionLabel(NSLocalizedString("medical_card_files_uploading_info_bottom_sheet_description", comment: "")),
                        spacer(6),
                        descriptionLabel(NSLocalizedString("medical_card_files_uploading_info_bottom_sheet_secondary_description", comment: "")),
                        spacer(15),
                        subtitleLabel(NSLocalizedString("medical_card_files_uploading_info_bottom_sheet_subtitle", comment: "")),
                        spacer(6),
                        descriptionLabel(NSLocalizedString("medical_card_files_uploading_info_bottom_sheet_subdescription", comment: ""))
                    ],
                    fileEntry: fileEntry
                )
            case .virusCheck:
                MedicalCardInfoBottomSheet.present(
                    from: viewController,
                    title: NSLocalizedString("medical_card_files_virus_check_info_bottom_sheet_title", comment: ""),
                    buttonTitle: NSLocalizedString("medical_card_files_virus_check_info_bottom_sheet_button_title", comment: ""),
                    additionalViews: [
                        descriptionLabel(NSLocalizedString("medical_card_files_virus_check_info_bottom_sheet_description", comment: "")),
                        spacer(15),
                        subtitleLabel(NSLocalizedString("medical_card_files_virus_check_info_bottom_sheet_subtitle", comment: "")),
                        spacer(6),
                        descriptionLabel(NSLocalizedString("medical_card_files_virus_check_info_bottom_sheet_subdescription", comment: ""))
                    ],
                    fileEntry: fileEntry
                )
            case .error:
                MedicalCardInfoBottomSheet.present(
                    from: viewController,
                    title: NSLocalizedString("medical_card_files_error_info_bottom_sheet_title", comment: ""),
                    buttonTitle: NSLocalizedString("medical_card_files_error_info_bottom_sheet_button_title", comment: ""),
                    additionalViews: [
                        descriptionLabel(NSLocalizedString("medical_card_files_error_info_bottom_sheet_description", comment: ""))
                    ],
                    fileEntry: fileEntry,
                    completion: {
                        self.medicalCardService.retryUploadFile(for: fileEntry) { result in
                            switch result {
                                case .success:
                                    break
                                case .failure(let error):
                                    ErrorHelper.show(
                                        error: error,
                                        alertPresenter: self.alertPresenter
                                    )
                            }
                        }
                    }
                )
			case .remote, .localAndRemote, .downloading, .retry:
                break
        }
    }
        
    private func pickFiles(
        to documentsStep: BaseDocumentStep,
        from viewController: UIViewController,
        completion: (([Attachment]) -> Void)? = nil
    ) {
        documentSelectionBehavior.pickDocuments(
            viewController,
            attachmentService: attachmentService,
            sources: [.library, .icloud, .camera],
            maxDocuments: documentsStep.maxDocuments - documentsStep.attachments.count,
            callback: { attachments in
                var invalidAttachments: [Attachment] = []
                var validAttachments: [Attachment] = []
                
                for attachment in attachments {
                    let size = self.attachmentService.size(from: attachment.url)
                    
                    if let size = size,
                       size < Constants.fileMaxSize {
                        validAttachments.append(attachment)
                    } else {
                        invalidAttachments.append(attachment)
                    }
                }
                
                self.showWrongTypesAttachmentsAlert(for: invalidAttachments, from: viewController)
                                
                documentsStep.attachments.append(contentsOf: validAttachments)
                self.attachmentsUpdatedSubscriptions.fire(())

                completion?(validAttachments)
            },
            supportedTypes: [.pdf, .dotx, .dot, .docx, .doc, .png, .jpg, .tiff]
        )
    }
    
    private func showWrongTypesAttachmentsAlert(for attachments: [Attachment], from viewController: UIViewController) {
        guard !attachments.isEmpty
        else { return }
        
        let filesNames = attachments.map {
            return $0.originalName ?? $0.filename
        }
        
        let separator = "\n"
        var filesNamesString = filesNames.joined(separator: separator)
        
        filesNamesString = attachments.count == 1
            ? filesNamesString
            : separator + filesNamesString + separator
        
        let format = NSLocalizedString("medical_card_file_size_exceeded_error_description", comment: "")
        
        let alert = UIAlertController(
            title: NSLocalizedString("medical_card_file_alert_error_title", comment: ""),
            message: String(
                format:
                    format,
                    filesNamesString
            ),
            preferredStyle: .alert
        )

        let cancelAction = UIAlertAction(title: NSLocalizedString("common_cancel_button", comment: ""), style: .cancel)
        alert.addAction(cancelAction)

        UIHelper.topViewController()?.present(alert, animated: true)
    }
    
    private func showStorageSizeExceededServerAlert(
        with description: String
    ) {
        let alert = UIAlertController(
            title: NSLocalizedString("medical_card_file_alert_error_title", comment: ""),
            message: NSLocalizedString("medical_card_file_storage_size_exceeded_error_description", comment: ""),
            preferredStyle: .alert
        )
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("common_cancel_button", comment: ""), style: .cancel)
        alert.addAction(cancelAction)

        UIHelper.topViewController()?.present(alert, animated: true)
    }
    
    private func showFileSizeExceededServerAlert(
        for filename: String,
        with description: String,
        viewController: MedicalCardFilesStorageViewController
    ) {
        let format = NSLocalizedString("medical_card_file_size_exceeded_error_description", comment: "")
        
        let alert = UIAlertController(
            title: NSLocalizedString("medical_card_file_alert_error_title", comment: ""),
            message: String(
                format:
                    format,
                    filename
            ),
            preferredStyle: .alert
        )
    
        let deleteAction = UIAlertAction(
            title: NSLocalizedString("common_delete", comment: ""),
            style: .default
        ) { _ in
            guard let fileNameWithoutFormat = filename.components(separatedBy: ".").first
            else { return }
            
            if self.medicalCardService.removeCachedFile(fileName: fileNameWithoutFormat) {
                viewController.notify.updateStateWhenRemoveFiles(
                    .filled(
                        self.medicalCardService.getActualFiles(searchString: self.searchString)
                    ),
                    .success(1)
                )
            }
        }
        
        alert.addAction(deleteAction)

        let cancelAction = UIAlertAction(title: NSLocalizedString("common_cancel_button", comment: ""), style: .cancel)
        alert.addAction(cancelAction)

        UIHelper.topViewController()?.present(alert, animated: true)
    }
    
    private func openFilesUploadInputBottomViewController(
        from: MedicalCardFilesStorageViewController,
        step: BaseDocumentStep,
        completion: @escaping ([Attachment]) -> Void
    ) {
        let viewController: DocumentInputBottomViewController = .init()
        container?.resolve(viewController)
        
        let actionSheetViewController = ActionSheetViewController(with: viewController)
        
        viewController.input = .init(
            title: step.title,
            description: NSLocalizedString("disagreement_with_services_documents_sheet_hint", comment: ""),
            doneButtonTitle: NSLocalizedString("dms_cost_recovery_documents_sheet_done", comment: ""),
            step: step,
            showTotalFilesSize: true
        )
        
        viewController.output = .init(
            close: { [weak viewController] in
                viewController?.dismiss(animated: true)
            },
            done: { [weak viewController] in
                guard let viewController = viewController
                else { return }
                
                let attachments = step.attachments
                
                // remove attachments from bottom sheet controller
                step.attachments.forEach { attachment in
                    self.medicalCardService.addUpload(from: attachment)
                    self.attachmentsUpdatedSubscriptions.fire(())
                }
                step.attachments.removeAll()
                
                self.medicalCardService.startUpload { result in
                    switch result {
                        case .success:
                            break
                        case .failure(let error):
                            switch error {
                                case .fileSizeExceeded(let filename, let description):
                                    guard (UIHelper.topViewController as? UIAlertController) == nil
                                    else { return }

                                    self.showFileSizeExceededServerAlert(
                                        for: filename,
                                        with: description,
                                        viewController: from
                                    )
                                case .storageSizeExceeded(let description):
                                    guard (UIHelper.topViewController as? UIAlertController) == nil
                                    else { return }

                                    self.showStorageSizeExceededServerAlert(
                                        with: description
                                    )
                                case .unknownStatusCode, .error, .common:
                                    break
                            }
                    }
                    
                    // remove attachments from attachments service
                    attachments.forEach {
                        self.attachmentService.delete(attachment: $0)
                    }
                }
                viewController.dismiss(animated: true)
            },
            delete: { attachments in
                let ids = attachments.map { $0.id }
                step.attachments.removeAll { ids.contains($0.id) }
                self.attachmentsUpdatedSubscriptions.fire(())
                
                attachments.forEach { attachment in
                    self.attachmentService.delete(attachment: attachment)
                    self.medicalCardService.cancelUpload(for: attachment)
                }
                
                completion(step.attachments)
            },
            pickFile: { [weak actionSheetViewController] in
                guard let actionSheetViewController = actionSheetViewController
                else { return }
                
                self.pickFiles(
                    to: step,
                    from: actionSheetViewController
                ) { attachments in
                    completion(attachments)
                }
            },
            showPhoto: { [weak actionSheetViewController] showPhotoController, animated, completion in
                actionSheetViewController?.present(
                    showPhotoController,
                    animated: animated,
                    completion: completion
                )
            },
            openDocument: { [weak viewController] attachment in
                guard let viewController = viewController
                else { return }
                
                LocalDocumentViewer.open(
                    attachment.url,
                    from: viewController
                )
            }
        )
        
        attachmentsUpdatedSubscriptions
            .add(viewController.notify.filesUpdated)
            .disposed(by: viewController.disposeBag)
        
        from.present(
            actionSheetViewController,
            animated: true
        )
    }
    
    private func openRenameFileInputBottomViewController(
        from: UIViewController,
        initialText: String?,
        fileName: String? = nil,
        autocapitalizationType: UITextAutocapitalizationType = .none,
        completion: @escaping (String) -> Void
    ) {
        let controller = InputBottomViewController()
        container?.resolve(controller)
        
        var rules: [ValidationRule] = [
            RequiredValidationRule(),
            LengthValidationRule(maxChars: Constants.charsLimit)
        ]
        
        if let initialText = initialText {
            rules.append(
                ComparisonStringsValidationRule(oldString: initialText)
            )
        }
        
        let input = InputBottomViewController.InputObject(
            text: fileName == nil
                ? initialText
                : fileName,
            placeholder: nil,
            charsLimited: .limited(Constants.charsLimit),
            keyboardType: .default,
            autocapitalizationType: .none,
            validationRule: rules,
            preventInputOnLimit: true
        )
        
        controller.input = .init(
            title: NSLocalizedString("medical_card_files_bottom_input_rename_title", comment: ""),
            infoText: nil,
            inputs: [input]
        )
        
        controller.output = .init(
            close: { [weak from] in
                from?.dismiss(animated: true)
            },
            done: { [weak from] result in
                let series = result[input.id] ?? ""
                completion(series)
                from?.dismiss(animated: true)
            }
        )
        
        from.showBottomSheet(contentViewController: controller)
    }
    
    struct Constants {
        static let charsLimit = 120
        static let fileMaxSize = 5 * 1000 * 1000
    }
}
