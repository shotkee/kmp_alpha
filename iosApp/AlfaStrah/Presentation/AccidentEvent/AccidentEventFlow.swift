//
//  AccidentEventFlow
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 19.10.2020.
//  Copyright © 2020 Redmadrobot. All rights reserved.
//

import UIKit
import Legacy

class AccidentEventFlow: BaseFlow, InsurancesServiceDependency, AttachmentServiceDependency, EventReportServiceDependency {
    var insurancesService: InsurancesService!
    var attachmentService: AttachmentService!
    var eventReportService: EventReportService!

    private let storyboard = UIStoryboard(name: "AccidentEvent", bundle: nil)
    private var insurance: Insurance!
    private lazy var documentSelectionBehavior = DocumentPickerBehavior()
    private var photosUpdatedSubscriptions: Subscriptions<Void> = Subscriptions()

    enum FlowMode {
        case createNewEvent
        case show(EventReportAccident)
    }

    func start(insuranceId: String, flowMode: FlowMode, showMode: ViewControllerShowMode) {
        guard let insurance = insurancesService.cachedInsurance(id: insuranceId) else {
            alertPresenter.show(alert: ErrorNotificationAlert(text: NSLocalizedString("insurance_not_found", comment: "")))
            return
        }

        self.insurance = insurance
        switch flowMode {
            case .createNewEvent:
                showCreateAccidentEventViewController(showMode: showMode)
            case .show(let event):
                showAccidentEventViewController(event, showMode: showMode)
        }
    }

    func start(insurance: Insurance, flowMode: FlowMode, showMode: ViewControllerShowMode) {
        self.insurance = insurance
        switch flowMode {
            case .createNewEvent:
                showCreateAccidentEventViewController(showMode: showMode)
            case .show(let event):
                showAccidentEventViewController(event, showMode: showMode)
        }
    }

    private func showCreateAccidentEventViewController(showMode: ViewControllerShowMode) {
        let viewController: CreateAccidentEventViewController = storyboard.instantiate()
        container?.resolve(viewController)

        viewController.input = .init(insurance: insurance)
        viewController.output = .init(
            linkTap: linkTap,
            accidentEventReportRules: { [weak viewController] in
                guard let controller = viewController else { return }

                self.showAccidentEventReportRules(from: controller)
            },
            addPhoto: { [weak viewController] step in
                guard let controller = viewController else { return }

                if !step.attachments.isEmpty {
                    self.showGallery(step: step, from: controller)
                } else {
                    self.pickPhotos(to: step, from: controller) { [weak controller, weak self] in
                        guard let controller = controller, let `self` = self, !step.attachments.isEmpty else { return }

                        self.showGallery(step: step, from: controller)
                    }
                }
            },
            createEvent: { event, photoStep, completion in

                self.eventReportService.createAccidentEvent(event) { result in
                    switch result {
                        case .success(let eventId):
                            self.preparePhotosForSend(for: photoStep, eventId: eventId)
                            self.showAttachmentsUpload(eventReportId: eventId, aditionalPhotoUploading: false)
                        case .failure(let error):
                            ErrorHelper.show(error: error, alertPresenter: self.alertPresenter)
                    }
                    completion()
                }
            }
        )
        photosUpdatedSubscriptions.add(viewController.notify.photosUpdated).disposed(by: viewController.disposeBag)
        if showMode == .modal {
            viewController.addCloseButton { [weak viewController] in
                viewController?.dismiss(animated: true, completion: nil)
            }
        }
		
		viewController.hidesBottomBarWhenPushed = true
		
        createAndShowNavigationController(viewController: viewController, mode: showMode)
    }

    func showAccidentEventViewController(_ event: EventReportAccident, showMode: ViewControllerShowMode) {
        let viewController: AccidentEventReportViewController = storyboard.instantiate()
        container?.resolve(viewController)
        viewController.input = .init(insurance: insurance, eventReport: event)
        viewController.output = .init(
            chat: {
                ApplicationFlow.shared.show(item: .tabBar(.chat))
            },
            addDocuments: { [weak viewController] step in
                guard let controller = viewController else { return }

                if !step.attachments.isEmpty {
                    self.showGallery(step: step, uploadAditionalPhotosToEventId: event.id, from: controller)
                } else {
                    self.pickPhotos(to: step, from: controller) { [weak controller, weak self] in
                        guard let controller = controller, let self = self, !step.attachments.isEmpty else { return }

                        self.showGallery(step: step, uploadAditionalPhotosToEventId: event.id, from: controller)
                    }
                }
            },
            editBankInfo: {
                self.showEditBankInfoViewController(event: event)
            },
            showPaymentApplicationPdf: { [weak self, weak viewController] insuranceId, eventReportId in
                guard let self = self,
                      let viewController = viewController
                else { return }

                let url = self.eventReportService.urlForPaymentApplicationPdf(
                    insuranceId: insuranceId,
                    eventReportId: eventReportId
                )
                
                WebViewer.openDocument(
                    url,
                    withAuthorization: true,
                    from: viewController
                )
            }
        )
        
        if showMode == .modal {
            viewController.addCloseButton { [weak viewController] in
                viewController?.dismiss(animated: true, completion: nil)
            }
        }
        createAndShowNavigationController(viewController: viewController, mode: showMode)
    }

    func showEditBankInfoViewController(event: EventReportAccident) {
        let viewController: EditBankInfoViewController = storyboard.instantiate()
        container?.resolve(viewController)
        viewController.input = .init(eventReport: event)
        viewController.output = .init(
            accidentEventReportRules: { [weak viewController] in
                guard let controller = viewController else { return }

                self.showAccidentEventReportRules(from: controller)
            },
            sendChanges: { [weak viewController] bik, accountNumber in
                guard let viewController = viewController else { return }

                let hide = viewController.showLoadingIndicator(message: NSLocalizedString("common_loading_title", comment: ""))
                self.eventReportService.updateAccidentEventBankInfo(id: event.id, bik: bik, accountNumber: accountNumber) { result in
                    hide {}
                    switch result {
                        case .success(let infoSaved):
                            guard infoSaved else { return }

                            self.showSuccessScreen()
                        case .failure(let error):
                            ErrorHelper.show(error: error, alertPresenter: self.alertPresenter)
                    }
                }
            }
        )
        createAndShowNavigationController(viewController: viewController, mode: .push)
    }

    private func showGallery(step: BaseDocumentStep, uploadAditionalPhotosToEventId: String? = nil, from: UIViewController) {
        let viewController: DocumentInputBottomViewController = .init()
        container?.resolve(viewController)

        let actionSheetViewController = ActionSheetViewController(with: viewController)

        viewController.input = .init(
            title: NSLocalizedString("common_documents_title", comment: ""),
            description: NSLocalizedString("common_documents_sub_title", comment: ""),
            step: step
        )
        viewController.output = .init(
            close: { [weak from] in
                from?.dismiss(animated: true, completion: nil)
            },
            done: { [weak from] in
                guard let controller = from else { return }

                if let eventId = uploadAditionalPhotosToEventId, !step.attachments.isEmpty {
                    controller.dismiss(animated: true) {
                        self.preparePhotosForSend(for: step, eventId: eventId)
                        self.showAttachmentsUpload(eventReportId: eventId, aditionalPhotoUploading: true)
                    }
                } else {
                    controller.dismiss(animated: true)
                }
            },
            delete: { photoAttachment in
                let ids = photoAttachment.map { $0.id }
                step.attachments.removeAll { ids.contains($0.id) }
                photoAttachment.forEach { self.attachmentService.delete(attachment: $0) }
                self.photosUpdatedSubscriptions.fire(())
            },
            pickFile: { [weak actionSheetViewController] in
                guard let controller = actionSheetViewController else { return }

                self.pickPhotos(to: step, from: controller) {}
            },
            showPhoto: { [weak actionSheetViewController] showPhotoController, animated, completion in
                guard let controller = actionSheetViewController else { return }

                controller.present(
                    showPhotoController,
                    animated: animated,
                    completion: completion
                )
            },
            openDocument: { [weak viewController] attachment in
                guard let controller = viewController else { return }

                LocalDocumentViewer.open(attachment.url, from: controller)
            }
        )

        from.present(actionSheetViewController, animated: true)

        photosUpdatedSubscriptions.add(viewController.notify.filesUpdated).disposed(by: viewController.disposeBag)

    }

    private func showSuccessScreen() {
        let viewController: AccidentEventSuccessScreen = storyboard.instantiate()
        container?.resolve(viewController)
        viewController.output = .init(
            close: {
                ApplicationFlow.shared.show(item: .tabBar(.home))
            }
        )
        createAndShowNavigationController(viewController: viewController, mode: .push)
    }

    private func pickPhotos(to step: BaseDocumentStep, from: UIViewController, completion: @escaping () -> Void) {
        let photoTip = step.minDocuments > 0
            ? String(format: NSLocalizedString("photos_mandatory_tip_value", comment: ""), "\(step.minDocuments)", "\(step.maxDocuments)")
            : String(format: NSLocalizedString("photos_optional_tip_value", comment: ""), "\(step.maxDocuments)")
        let hint = AutoOverlayHint(
            groupTitle: NSLocalizedString("accident_event_title", comment: ""),
            groupTip: "",
            stepTitle: step.title,
            stepTip: photoTip,
            icon: nil
        )

        documentSelectionBehavior.pickDocuments(
            from,
            attachmentService: attachmentService,
            sources: [ .library, .icloud, .camera ],
            maxDocuments: step.maxDocuments - step.attachments.count,
            cameraHint: hint
        ) { [weak self] attachments in
            guard let self = self else { return }

            step.attachments.append(contentsOf: attachments)
            self.photosUpdatedSubscriptions.fire(())
            completion()
        }
    }

    private func preparePhotosForSend(for step: BaseDocumentStep, eventId: String) {
        let documents: [Attachment] = step.attachments.filter { attachmentService.attachmentExists($0) }
        let attachments: [AccidentEventAttachment] = documents.map {
            AccidentEventAttachment(id: UUID().uuidString, eventReportId: eventId, filename: $0.filename)
        }
        attachmentService.addToUploadQueue(attachments: attachments)
    }

    private func showAttachmentsUpload(eventReportId: String, aditionalPhotoUploading: Bool) {
        let viewController: AttachmentUploadViewController = UIStoryboard(name: "CreateAutoEvent", bundle: nil).instantiate()
        container?.resolve(viewController)
        viewController.input = .init(
            eventReportId: eventReportId,
            text: aditionalPhotoUploading ? "" : NSLocalizedString("accident_event_photos_upload_text", comment: ""),
            attentionText: NSLocalizedString("accident_event_vpn_caution_text", comment: ""),
            presentationMode: .push
        )
        viewController.output = .init(
            close: {
                ApplicationFlow.shared.show(item: .tabBar(.home))
            },
            doneAction: {
                ApplicationFlow.shared.show(item: .tabBar(.home))
            }
        )

        createAndShowNavigationController(viewController: viewController, mode: .push)
    }

    private func showAccidentEventReportRules(from: UIViewController) {
        let cancellable = CancellableNetworkTaskContainer()
        let hide = from.showLoadingIndicator(message: nil, cancellable: cancellable)

        let networkTask = eventReportService.accidentEventReportRules(insurance.id) { result in
            hide {}
            switch result {
                case .success(let url):
                    self.linkTap(url)
                case .failure(let error):
                    guard !error.isCanceled else { return }

                    ErrorHelper.show(error: error, alertPresenter: self.alertPresenter)
            }
        }

        cancellable.addCancellables([ networkTask ])
    }

    private func linkTap(_ url: URL) {
        guard let navigationController = navigationController else { return }
        
        SafariViewController.open(url, from: navigationController)
    }
}
