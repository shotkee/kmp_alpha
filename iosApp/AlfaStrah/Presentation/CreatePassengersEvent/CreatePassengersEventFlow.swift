//
//  CreatePassengersEventFlow
//  AlfaStrah
//
//  Created by Stanislav Starzhevskiy on 29.08.17.
//  Copyright © 2017 RedMadRobot. All rights reserved.
//

import UIKit
import Legacy

private enum FlowSegueIDs {
    static var toStepTwo = "toStepTwo"
    static var toStepThree = "toStepThree"
}

class CreatePassengersEventFlow: AccountServiceDependency, LocalNotificationsServiceDependency, AlertPresenterDependency,
        InsurancesServiceDependency, DependencyContainerDependency, EventReportServiceDependency, AttachmentServiceDependency,
        AnalyticsServiceDependency {
    var attachmentService: AttachmentService!
    var eventReportService: EventReportService!
    var accountService: AccountService!
    var localNotificationsService: LocalNotificationsService!
    var alertPresenter: AlertPresenter!
    var insurancesService: InsurancesService!
    var analytics: AnalyticsService!
    var container: DependencyInjectionContainer?

    private var insurance: Insurance!
    private lazy var photoSelectionBehavior = DocumentPickerBehavior()
    private let storyboard = UIStoryboard(name: "CreatePassengersEvent", bundle: nil)
    private weak var navigationController: UINavigationController!
    private weak var fromViewController: UIViewController!
    private var photosUpdatedSubscriptions: Subscriptions<Void> = Subscriptions()

    init(insuranceId: String) {
        guard let insurance = insurancesService.cachedInsurance(id: insuranceId) else {
            alertPresenter.show(alert: ErrorNotificationAlert(text: NSLocalizedString("insurance_not_found", comment: "")))
            return
        }

        self.insurance = insurance
    }

    init(insurance: Insurance) {
        self.insurance = insurance
    }

    func startModaly(from controller: UIViewController, draft: PassengersEventDraft?) {
        fromViewController = controller
        let stepOne = stepOneViewController(draft: draft)
        let navigationController = RMRNavigationController(rootViewController: stepOne)
        navigationController.strongDelegate = RMRNavigationControllerDelegate()
        self.navigationController = navigationController
        controller.present(navigationController, animated: true, completion: nil)
    }

    private func close() {
        fromViewController.dismiss(animated: true, completion: nil)
    }

    private func stepOneViewController(draft: PassengersEventDraft? = nil) -> UIViewController {
        let controller: ICPassengersStepOneViewController = storyboard.instantiateInitial()
        container?.resolve(controller)

        var insurerName = ""
        if let insurer = insurance.insurerParticipants?.first {
            insurerName = "\(insurer.firstName ?? "") \(insurer.lastName ?? "")"
        }

        controller.input = ICPassengersStepOneViewController.Input(insurance: insurance, insurerName: insurerName, riskId: draft?.riskId)
        controller.onSelection = handleStepOne
        controller.onStoryboardSegue = { segue, risk, categories in
            self.proceedToStepTwo(segue: segue, risk: risk, categories: categories, draft: draft)
        }

        return controller
    }

    private func handleStepOne(ctrl: ICPassengersStepOneViewController) {
        ctrl.performSegue(withIdentifier: FlowSegueIDs.toStepTwo, sender: self)
    }

    private func proceedToStepTwo(segue: UIStoryboardSegue, risk: Risk, categories: [RiskCategory], draft: PassengersEventDraft? = nil) {
        guard let dest = segue.destination as? ICPassengersStepTwoViewController else { fatalError("Invalid segue destination") }

        let insuranceId = insurance.id
        var declarerRiskValues: [RiskValue] = []

        dest.categories = categories
        dest.draft = draft
        dest.output = { controller, riskValues in
            declarerRiskValues = riskValues
            controller.performSegue(withIdentifier: FlowSegueIDs.toStepThree, sender: self)
        }
        dest.onSaveDraft = { controller, values in
            self.saveDraft(riskId: risk.id, values: values, controller: controller)
        }

        dest.onStoryboardSegue = { segue, output in
            guard let dest = segue.destination as? ICPassengersStepThreeViewController else { fatalError("Invalid segue destination") }

            dest.risk = risk
            dest.draft = draft
            dest.output = { controller, riskValues in
                guard !self.accountService.isDemo else {
                    DemoAlertHelper().showDemoAlert(from: controller)
                    return
                }

                let event = CreatePassengersEventReport(insuranceId: insuranceId, riskValues: riskValues + declarerRiskValues)
                let hide = dest.showLoadingIndicator(message: "")
                    self.eventReportService.createPassengersEvent(event) { [weak self] result in
                        guard let self = self else { return }

                        switch result {
                            case .success(let passengersEvent):
                                self.analytics.track(
                                    event: AnalyticsEvent.Passenger.reportPassengersDone,
                                    properties: [ AnalyticsParam.Auto.sentFromDraft: AnalyticsParam.string(draft != nil) ]
                                )
                                draft.map(self.eventReportService.deletePassengerDraft)
                                hide {
                                    self.showStepFourController(eventId: passengersEvent.eventReportId,
                                        documents: passengersEvent.riskDocumentList, risk: risk)
                                }
                            case .failure(let error):
                                hide(nil)
                                ErrorHelper.show(error: error, alertPresenter: self.alertPresenter)
                        }
                    }
            }

            dest.onSaveDraft = { controller, values in
                self.saveDraft(riskId: risk.id, values: declarerRiskValues + values, controller: controller)
            }
        }
    }

    private func showStepFourController(eventId: String, documents: [RiskDocument], risk: Risk) {
        let viewController: ICPassengersStepFourViewController = storyboard.instantiate()
        container?.resolve(viewController)

        let photoSteps = makePhotoSteps(from: documents)
        viewController.input = .init(
            risk: risk,
            eventReportId: eventId,
            photoSteps: photoSteps
        )
        viewController.output = .init(
            // Important to capture weak self to avoid memory leak.
            addPhoto: { [weak viewController, weak self] step in
                guard let controller = viewController, let self = self else { return }

                if !step.attachments.isEmpty {
                    self.showGallery(step: step, from: controller)
                } else {
                    self.pickPhotos(to: step, from: controller) {
                        guard !step.attachments.isEmpty else { return }

                        self.showGallery(step: step, from: controller)
                    }
                }
            },
            sendFiles: {
                let photos = photoSteps.flatMap { $0.attachments }
                if photos.isEmpty {
                    self.eventReportService.markPassengersEventWithNoPhotos(eventReportId: eventId) { [weak self] result in
                        guard let self = self else { return }

                        switch result {
                            case .success:
                                self.showAttachmentsUpload(eventReportId: eventId)
                            case .failure(let error):
                                ErrorHelper.show(error: error, alertPresenter: self.alertPresenter)
                            }
                    }
                } else {
                    self.preparePhotosForSend(from: photoSteps, eventId: eventId)
                    self.showAttachmentsUpload(eventReportId: eventId)
                }
            },
            goBack: {
                let photos = photoSteps.flatMap { $0.attachments }
                self.deleteAttachments(photos)
                self.navigationController.popViewController(animated: true)
            }
        )
        photosUpdatedSubscriptions.add(viewController.notify.photosUpdated).disposed(by: viewController.disposeBag)
        navigationController.pushViewController(viewController, animated: true)
    }

    // MARK: - Photos adding

    private func showGallery(step: AutoPhotoStep, from: UIViewController) {
        let viewController: DocumentInputBottomViewController = .init()
        container?.resolve(viewController)

        let actionSheetViewController = ActionSheetViewController(with: viewController)

        viewController.input = .init(
            title: NSLocalizedString("common_documents_title", comment: ""),
            description: NSLocalizedString("common_photos_sub_title", comment: ""),
            step: step
        )
        viewController.output = .init(
            close: { [weak from] in
                from?.dismiss(animated: true)
            },
            done: { [weak from] in
                from?.dismiss(animated: true)
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

    private func pickPhotos(to step: AutoPhotoStep, from: UIViewController, completion: @escaping () -> Void) {
        photoSelectionBehavior.pickDocuments(
            from,
            attachmentService: attachmentService,
            sources: [ .library, .camera ],
            maxDocuments: step.maxDocuments - step.attachments.count,
            cameraHint: nil
        ) { [weak self] attachments in
            guard let self = self else { return }

            step.attachments.append(contentsOf: attachments)
            self.photosUpdatedSubscriptions.fire(())
            completion()
        }
    }

    private func showAttachmentsUpload(eventReportId: String) {
        let viewController: AttachmentUploadViewController = UIStoryboard(name: "CreateAutoEvent", bundle: nil).instantiate()
        container?.resolve(viewController)
        viewController.input = .init(
            eventReportId: eventReportId,
            text: NSLocalizedString("photos_upload_tip", comment: ""),
            presentationMode: .push
        )
        viewController.output = .init(
            close: {
                ApplicationFlow.shared.show(item: .tabBar(.home))
            },
            doneAction: {
                ApplicationFlow.shared.show(item: .eventReport(.passengers(eventReportId), self.insurance))
            }
        )
        navigationController.pushViewController(viewController, animated: true)
    }

    // MARK: - Helpers

    private func makePhotoSteps(from documents: [RiskDocument]) -> [AutoPhotoStep] {
        documents.map {
            AutoPhotoStep(
                title: $0.title,
                order: 0,
                attachmentType: .documents,
                stepId: $0.id,
                icon: "ico-passenger-documents",
                minPhotos: $0.required ? 1 : 0,
                maxPhotos: 15,
                hint: $0.description,
                photos: []
            )
        }
    }

    private func preparePhotosForSend(from steps: [AutoPhotoStep], eventId: String) {
        let photosCount = steps.flatMap { $0.attachments }.filter { attachmentService.attachmentExists($0) }.count
        var passengersEventAttachment: [PassengersEventAttachment] = []
        for step in steps {
            let photos: [Attachment] = step.attachments.filter { attachmentService.attachmentExists($0) }
            let attachments: [PassengersEventAttachment] = photos.map {
                PassengersEventAttachment(id: UUID().uuidString, eventReportId: eventId, documentId: step.stepId,
                    filename: $0.filename, documentsCount: photosCount)
            }
            passengersEventAttachment.append(contentsOf: attachments)
        }
        attachmentService.addToUploadQueue(attachments: passengersEventAttachment)
    }

    private func deleteAttachments(_ attachments: [Attachment]) {
        attachments.forEach { attachmentService.delete(attachment: $0) }
    }

    private func saveDraft(riskId: String, values: [RiskValue], controller: UIViewController) {
        let draft = PassengersEventDraft(id: UUID().uuidString, insuranceId: insurance.id, riskId: riskId,
            date: Date(), values: values)
        eventReportService.savePassengerDraft(draft)
        analytics.track(event: AnalyticsEvent.Passenger.reportPassengersSaveDraft)

        let alert = UIAlertController(title: "Успешно", message: "Черновик сохранен.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ОК", style: .default, handler: nil))
        controller.present(alert, animated: true, completion: nil)
    }
}
