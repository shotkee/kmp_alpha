//
//  DisagreementWithServicesFlow.swift
//  AlfaStrah
//
//  Created by Vitaly Trofimov on 23.05.2022.
//  Copyright © 2022 Touch Instinct. All rights reserved.
//

import UIKit
import Legacy

class DisagreementWithServicesFlow: BaseFlow,
    InsuranceBillDisagreementServiceDependency,
    AttachmentServiceDependency,
    AccountServiceDependency
{
    var insuranceBillDisagreementService: InsuranceBillDisagreementsService!
    var attachmentService: AttachmentService!   // used only to store attachments, upload done manually
    var accountService: AccountService!
    
    private let storyboard = UIStoryboard(name: "DisagreementWithServices", bundle: nil)
    
    private lazy var documentSelectionBehavior = DocumentPickerBehavior()
    private var photosUpdatedSubscriptions: Subscriptions<Void> = Subscriptions()
    
    private var insuranceId: String?
    private var insuranceBillId: Int?
    private var disagreementReason: InsuranceBillDisagreementReason?
    
    private typealias AttachmentId = String
    
    private struct DocumentUpload
    {
        let id: InsuranceBillDisagreementsService.DocumentUploadId
        let attachment: Attachment
        
        var result: InsuranceBillDisagreementsService.DocumentUploadResult?
    }
    
    private var documentsUploads: [AttachmentId: DocumentUpload] = [:]
    private var onAllUploadsCompleted: (() -> Void)?
    
    func showSubmitDisagreement(
        insuranceId: String,
        insuranceBillId: Int
    )
    {
        let hide = fromViewController.showLoadingIndicator(message: nil)
        
        insuranceBillDisagreementService.insuranceBillDisagreementServices(
            insuranceId: insuranceId,
            insuranceBillId: insuranceBillId
        ) { result in
            switch result {
                case .success(let services):
                    self.insuranceBillDisagreementService.insuranceBillDisagreementReasons(
                        insuranceId: insuranceId,
                        insuranceBillId: insuranceBillId
                    ) { result in
                        hide(nil)
                        
                        switch result {
                            case .success(let reasons):
                                if let reason = reasons.first
                                {
                                    self.insuranceId = insuranceId
                                    self.insuranceBillId = insuranceBillId
                                    self.disagreementReason = reason
                                    
                                    self.showSubmitDisagreement(services: services)
                                }
                                
                            case .failure(let error):
                                self.showError(error)
                        }
                    }
                    
                case .failure(let error):
                    hide(nil)
                    
                    self.showError(error)
            }
        }
    }
    
    private func showSubmitDisagreement(services: [InsuranceBillDisagreementService])
    {
        guard accountService.isAuthorized
        else { return }
        
        guard let topViewController = navigationController?.topViewController as? ViewController
        else { return }
        
        let hide = topViewController.showLoadingIndicator(
            message: NSLocalizedString("common_loading_title",
            comment: "")
        )
        
        accountService.getAccount(useCache: true) { result in
            hide(nil)
            
            switch result {
                case .success(let userAccount):
                    let disagreementViewController: DisagreementWithServicesViewController = self.storyboard.instantiate()
                    self.container?.resolve(disagreementViewController)
                    
                    disagreementViewController.input = .init(
                        services: services,
                        userPhone: userAccount.phone,
                        userEmail: userAccount.email
                    )
                    
                    disagreementViewController.output = .init(
                        addDocuments: { [weak disagreementViewController] documentsStep in
                            guard let disagreementViewController = disagreementViewController
                            else { return }
                            
                            if documentsStep.attachments.isEmpty
                            {
                                self.pickDocuments(
                                    to: documentsStep,
                                    from: disagreementViewController,
                                    completion: { [weak disagreementViewController] in
                                        guard let disagreementViewController = disagreementViewController,
                                              !documentsStep.attachments.isEmpty
                                        else { return }
                                        
                                        self.showGallery(
                                            documentsStep: documentsStep,
                                            from: disagreementViewController
                                        )
                                    }
                                )
                            }
                            else
                            {
                                self.showGallery(
                                    documentsStep: documentsStep,
                                    from: disagreementViewController
                                )
                            }
                        },
                        submit: { [weak disagreementViewController] data in
                            guard let disagreementViewController = disagreementViewController
                            else { return }
                            
                            self.submitDisagreement(
                                data: data,
                                from: disagreementViewController
                            )
                        }
                    )
                    
                    self.photosUpdatedSubscriptions
                        .add(disagreementViewController.notify.documentsUpdated)
                        .disposed(by: disagreementViewController.disposeBag)
                    
                    self.createAndShowNavigationController(
                        viewController: disagreementViewController,
                        mode: .push
                    )
                case .failure(let error):
                    ErrorHelper.show(error: error, alertPresenter: self.alertPresenter)
            }
        }
    }
    
    private func pickDocuments(
        to documentsStep: BaseDocumentStep,
        from viewController: UIViewController,
        completion: (() -> Void)? = nil
    ) {
        documentSelectionBehavior.pickDocuments(
            viewController,
            attachmentService: attachmentService,
            sources: [.library, .icloud, .camera],
            callback: { attachments in
                documentsStep.attachments.append(contentsOf: attachments)
                self.photosUpdatedSubscriptions.fire(())
                
                attachments.forEach { attachment in
                    self.uploadDocument(attachment)
                }
                
                completion?()
            }
        )
    }
    
    private func showGallery(
        documentsStep: BaseDocumentStep,
        from viewController: UIViewController
    ) {
        let bottomViewController: DocumentInputBottomViewController = .init()
        container?.resolve(bottomViewController)
        
        let actionSheetViewController = ActionSheetViewController(with: bottomViewController)
        
        bottomViewController.input = .init(
            title: NSLocalizedString("common_documents_title", comment: ""),
            description: NSLocalizedString("disagreement_with_services_documents_sheet_hint", comment: ""),
            doneButtonTitle: NSLocalizedString("disagreement_with_services_documents_sheet_done", comment: ""),
            step: documentsStep
        )
        
        bottomViewController.output = .init(
            close: { [weak viewController] in
                viewController?.dismiss(animated: true)
            },
            done: { [weak viewController] in
                viewController?.dismiss(animated: true)
            },
            delete: { attachments in
                let ids = attachments.map { $0.id }
                documentsStep.attachments.removeAll { ids.contains($0.id) }
                self.photosUpdatedSubscriptions.fire(())
                
                attachments.forEach { attachment in
                    self.attachmentService.delete(attachment: attachment)
                    
                    if let upload = self.documentsUploads.removeValue(forKey: attachment.id)
                    {
                        self.insuranceBillDisagreementService.cancelDocumentUpload(uploadId: upload.id)
                    }
                }
            },
            pickFile: { [weak actionSheetViewController] in
                guard let actionSheetViewController = actionSheetViewController
                else { return }
                
                self.pickDocuments(
                    to: documentsStep,
                    from: actionSheetViewController
                )
            },
            showPhoto: { [weak actionSheetViewController] showPhotoController, animated, completion in
                actionSheetViewController?.present(
                    showPhotoController,
                    animated: animated,
                    completion: completion
                )
            },
            openDocument: { [weak bottomViewController] attachment in
                guard let bottomViewController = bottomViewController
                else { return }
                
                LocalDocumentViewer.open(
                    attachment.url,
                    from: bottomViewController
                )
            }
        )
        
        photosUpdatedSubscriptions
            .add(bottomViewController.notify.filesUpdated)
            .disposed(by: bottomViewController.disposeBag)
        
        viewController.present(
            actionSheetViewController,
            animated: true
        )
    }
    
    private func uploadDocument(_ attachment: Attachment)
    {
        guard let insuranceId = self.insuranceId,
              let insuranceBillId = self.insuranceBillId
        else { return }
        
        let uploadId = insuranceBillDisagreementService.uploadDocument(
            insuranceId: insuranceId,
            insuranceBillId: insuranceBillId,
            attachment: attachment,
            completion: { result in
                self.documentsUploads[attachment.id]?.result = result
                
                if !self.documentsUploads.values.contains(where: { $0.result == nil })
                {
                    self.onAllUploadsCompleted?()
                }
            }
        )
        
        if let uploadId = uploadId
        {
            documentsUploads[attachment.id] = .init(
                id: uploadId,
                attachment: attachment
            )
        }
    }
    
    private func submitDisagreement(
        data: DisagreementWithServicesViewController.SubmitData,
        from viewController: UIViewController
    )
    {
        guard let insuranceId = insuranceId,
              let insuranceBillId = insuranceBillId,
              let disagreementReason = disagreementReason
        else { return }
        
        let hide = viewController.showLoadingIndicator(message: nil)
        
        let failedUploads = documentsUploads.values.filter { $0.result?.error != nil }
        failedUploads.forEach { failedUpload in
            documentsUploads.removeValue(forKey: failedUpload.attachment.id)
            uploadDocument(failedUpload.attachment)
        }
        
        let submitDisagreement = { [weak self] in
            guard let self = self
            else { return }
            
            self.insuranceBillDisagreementService.submitDisagreement(
                insuranceId: insuranceId,
                insuranceBillId: insuranceBillId,
                reasonId: disagreementReason.id,
                servicesIds: data.services.map { $0.id },
                comment: data.comment,
                phone: data.phone,
                email: data.email,
                documentsIds: self.documentsUploads.values
                    .compactMap { $0.result?.value }
                    .compactMap { $0 }
            ) { [weak viewController] result in
                guard let viewController = viewController
                else { return }
                
                hide(nil)
                
                switch result {
                    case .success:
                        self.showSubmitResultScreen(
                            successful: true,
                            from: viewController
                        )
                    case .failure:
                        self.showSubmitResultScreen(
                            successful: false,
                            from: viewController,
                            retry: { resultViewController in
                                self.submitDisagreement(
                                    data: data,
                                    from: resultViewController
                                )
                            }
                        )
                }
            }
        }
        
        let pendingUploads = documentsUploads.values.filter { $0.result == nil }
        if pendingUploads.isEmpty
        {
            submitDisagreement()
        }
        else
        {
            onAllUploadsCompleted = {
                DispatchQueue.main.async { [weak self, weak viewController] in
                    guard let self = self,
                          let viewController = viewController
                    else { return }
                    
                    self.onAllUploadsCompleted = nil
                    
                    if self.documentsUploads.values.contains(where: { $0.result?.error != nil })
                    {
                        hide(nil)
                        
                        self.showSubmitResultScreen(
                            successful: false,
                            from: viewController,
                            retry: { resultViewController in
                                self.submitDisagreement(
                                    data: data,
                                    from: resultViewController
                                )
                            }
                        )
                    }
                    else
                    {
                        submitDisagreement()
                    }
                }
            }
        }
    }
    
    private func showSubmitResultScreen(
        successful: Bool,
        from viewController: UIViewController,
        retry: ((UIViewController) -> Void)? = nil
    )
    {
        let navigationController = viewController.navigationController
        
        let resultViewController = UIViewController()
        resultViewController.title = NSLocalizedString("disagreement_with_services", comment: "")
        
        let operationView = OperationStatusView()
        
        if successful
        {
            operationView.notify.updateState(
                .info(
                    .init(
                        title: NSLocalizedString("disagreement_with_services_success_title", comment: ""),
                        description: NSLocalizedString("disagreement_with_services_success_description", comment: ""),
                        icon: .Icons.tick.resized(newWidth: 54)?.withRenderingMode(.alwaysTemplate)
                    )
                )
            )
            
            operationView.notify.buttonConfiguration(
                [
                    .init(
                        title: NSLocalizedString("common_to_main_screen", comment: ""),
                        style: Style.RoundedButton.oldOutlinedButtonSmall,
                        action: {
                            ApplicationFlow.shared.show(
                                item: .tabBar(.home)
                            )
                        }
                    ),
                    .init(
                        title: NSLocalizedString("common_done_button", comment: ""),
                        style: Style.RoundedButton.oldPrimaryButtonSmall,
                        action: { [weak navigationController] in
                            guard let navigationController = navigationController else { return }

                            let insuranceBillsVC = navigationController.viewControllers
                                .first(where: { $0 is InsuranceBillsViewController })

                            if let insuranceBillsVC = insuranceBillsVC {
                                navigationController.popToViewController(
                                    insuranceBillsVC,
                                    animated: true
                                )
                            } else {
                                navigationController.popToRootViewController(animated: true)
                            }
                        }
                    )
                ]
            )
        }
        else
        {
            operationView.notify.updateState(
                .info(
                    .init(
                        title: NSLocalizedString("disagreement_with_services_failure_title", comment: ""),
                        description: NSLocalizedString("disagreement_with_services_failure_description", comment: ""),
                        icon: .init(named: "icon-common-failure")
                    )
                )
            )
            
            operationView.notify.buttonConfiguration(
                [
                    .init(
                        title: NSLocalizedString("common_go_to_chat", comment: ""),
                        style: Style.RoundedButton.oldOutlinedButtonSmall,
                        action: {
                            ApplicationFlow.shared.show(
                                item: .tabBar(.chat)
                            )
                        }
                    ),
                    .init(
                        title: NSLocalizedString("disagreement_with_services_failure_retry", comment: ""),
                        style: Style.RoundedButton.oldPrimaryButtonSmall,
                        action: { [weak resultViewController] in
                            guard let resultViewController = resultViewController
                            else { return }
                            
                            retry?(resultViewController)
                        }
                    )
                ]
            )
        }
        
        resultViewController.view.addSubview(operationView)
        NSLayoutConstraint.activate(
            NSLayoutConstraint.fill(
                view: operationView,
                in: resultViewController.view
            )
        )
        
        if viewController.view.subviews.contains(where: { $0 is OperationStatusView })
        {
            if var viewControllers = navigationController?.viewControllers
            {
                viewControllers.removeLast()
                viewControllers.append(resultViewController)
                navigationController?.setViewControllers(
                    viewControllers,
                    animated: true
                )
            }
        }
        else
        {
            navigationController?.pushViewController(
                resultViewController,
                animated: true
            )
        }
    }
}
