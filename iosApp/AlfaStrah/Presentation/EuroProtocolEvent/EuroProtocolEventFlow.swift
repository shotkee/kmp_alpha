//
//  EuroProtocolEventFlow
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 29.03.2021.
//  Copyright © 2021 Redmadrobot. All rights reserved.
//

import UIKit
import Legacy

// swiftlint:disable file_length
class EuroProtocolEventFlow: BaseFlow,
							 EuroProtocolServiceDependency,
							 InsurancesServiceDependency,
							 AccountServiceDependency,
							 SessionServiceDependency {
    enum Constants {
        static let restartFlowNotification: String = "restartFlowNotification"
        static let exitFlowNotification: String = "exitFlowNotification"
        static let authAgainNotification: String = "authAgainNotification"
        static let maxSelectedVehiclePartsNumber: Int = 20
    }

    var euroProtocolService: EuroProtocolService!
    var insurancesService: InsurancesService!
    var accountService: AccountService!
    var sessionService: UserSessionService!
	
	private var insurance: Insurance!
	
    private lazy var osagoInfoUpdatedSubscriptions: Subscriptions<Void> = Subscriptions()
    private lazy var firstBumpInfoUpdatedSubscriptions: Subscriptions<Void> = Subscriptions()
    private lazy var draftInfoUpdatedSubscriptions: Subscriptions<Void> = Subscriptions()
    private lazy var participantAccidentUpdatedSubscriptions: Subscriptions<Void> = Subscriptions()
    private lazy var damagedPartsUpdatedSubscription: Subscriptions<Void> = Subscriptions()

    private let createPaperEuroProtocolHandler: () -> Void

	private var currentDraft: EuroProtocolCurrentDraftContentModel? {
        didSet {
            draftInfoUpdatedSubscriptions.fire(())
        }
    }

    init(rootController: UIViewController, paperEuroProtocolHandler: @escaping () -> Void) {
        createPaperEuroProtocolHandler = paperEuroProtocolHandler

        super.init(rootController: rootController)
    }

    required init(rootController: UIViewController) {
        fatalError("init(rootController:) has not been implemented")
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

	func start(insuranceId: String, isModal: Bool = false) {
        guard let insurance = insurancesService.cachedInsurance(id: insuranceId) else {
            alertPresenter.show(alert: ErrorNotificationAlert(text: NSLocalizedString("insurance_not_found", comment: "")))
            return
        }

		self.insurance = insurance

        if euroProtocolService.checkActiveSessionPresent() {
            showActiveSessionFoundScreen(isModal: isModal)
        } else {
            startNewEuroProtocolFlow(isModal: isModal)
        }

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(deleteDraftAndExit),
            name: Notification.Name(EuroProtocolEventFlow.Constants.restartFlowNotification),
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(exitFlow),
            name: Notification.Name(EuroProtocolEventFlow.Constants.exitFlowNotification),
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(authAgain),
            name: Notification.Name(EuroProtocolEventFlow.Constants.authAgainNotification),
            object: nil
        )
    }

    @objc private func exitFlow() {
        guard let fromViewController = fromViewController else { return }

        navigationController?.popToViewController(fromViewController, animated: true)
    }

    @objc private func deleteDraftAndExit() {
        euroProtocolService.stopSdk { _ in
            self.exitFlow()
        }
    }

    @objc private func authAgain() {
        let authViewController = navigationController?.viewControllers.first { $0 is EuroProtocolSdkAuthViewController }
        if let authViewController = authViewController {
            navigationController?.popToViewController(authViewController, animated: true)
        } else {
            showSdkAuthScreen()
        }
    }

	private func startNewEuroProtocolFlow(isModal: Bool = false) {
        euroProtocolService.clearCachedData()
        showQuestionsViewController(isModal: isModal)
    }

	private func showQuestionsViewController(isModal: Bool = false) {
        let viewController = EuroProtocolQuestionsViewController()
        container?.resolve(viewController)

        viewController.output = .init(
            euroProtocol: {
                self.showSdkAuthScreen()
            },
            paperEuroProtocol: {
                self.createPaperEuroProtocolHandler()
            }
        )
        viewController.addCloseButton { [weak viewController] in
			if let navigationController = self.navigationController, !isModal {
				navigationController.popViewController(animated: true)
			} else {
				viewController?.dismiss(animated: true)
			}
        }
		
		viewController.hidesBottomBarWhenPushed = true

		createAndShowNavigationController(viewController: viewController, mode: isModal ? .modal : .push)
    }

	private func showActiveSessionFoundScreen(isModal: Bool = false) {
        let viewController: EuroProtocolActiveSessionFoundViewController = .init()
        container?.resolve(viewController)

        viewController.output = .init(
            continueFromDraft: {
                self.showSdkAuthScreen()
            },
            newEuroProtocol: { [weak fromViewController] in
                guard let fromViewController
				else { return }

                self.euroProtocolService.stopSdk { [weak fromViewController] _ in
					guard let fromViewController
					else { return }
					
					if let navigationController = self.navigationController, !isModal {
						navigationController.popToViewController(fromViewController, animated: false)
					} else {
						fromViewController.dismiss(animated: true)
					}
					
                    self.startNewEuroProtocolFlow(isModal: isModal)
                }
            }
        )
		
		viewController.hidesBottomBarWhenPushed = true

		createAndShowNavigationController(viewController: viewController, mode: isModal ? .modal : .push)
    }

    private func showSdkAuthScreen() {
        let viewController: EuroProtocolSdkAuthViewController = .init()
        container?.resolve(viewController)

        viewController.input = .init(
            esiaLink: { completion in
                self.euroProtocolService.getEsiaLinkInfo(completion: completion)
            },
            esiaUser: { tokenScs, completion in
                self.euroProtocolService.getEsiaUser(tokenScs: tokenScs, completion: completion)
            },
            startSdk: { completion in
                self.euroProtocolService.startSdk(completion: completion)
            },
            stopSdk: { completion in
                self.euroProtocolService.stopSdk(completion: completion)
            },
            currentDraftContentModel: { completion in
                self.updateCurrentDraftModel(completion: completion)
            }
        )
        viewController.output = .init(
            authDone: { draft in
                self.navigateToSuitableScreenAfterAuthentication(with: draft)
            },
            exitFlow: { self.exitFlow() },
            openAppStore: { [weak self] completion in
                self?.sessionService.getAppStoreLink { result in
                    completion(result)
                    if case .success(let response) = result {
                            let url = URL(string: response)
                            guard let url = url else { return }

                            UIApplication.shared.open(url, options: [:]) { _ in }
                    }
                }
            }
        )
        createAndShowNavigationController(viewController: viewController, mode: .push)
    }

    private func navigateToSuitableScreenAfterAuthentication(with draft: EuroProtocolCurrentDraftContentModel?) {
        guard let draft = draft else {
            self.showEuroProtocolMainPlanAccidentScreen()
            return
        }

        func navigateBasedOnStatus(_ status: EuroProtocolDraftStatus) {
            switch status {
                case .noInviteCode, .draftNotConfigured, .waitingForMySign:
                    showEuroProtocolMainDraftScreen()
                case .waitingForOtherSign, .signed, .draftSaved, .waiting,
                         .rejected, .rejectedAgain, .sentToRegistrate,
                             .registered, .timeout, .sendingServerError:
                    showEuroProtocolDraftStatusScreen()
                case .myDraftNotFound, .myDraftRejected, .partyDraftRejected, .draftNotFound:
                    showEuroProtocolMainDraftScreen()
            }
        }

        let photosStepFilled = draft.noticeInfo.placePhotos.count == 3
        let driverDocumentsStepFilled = !(draft.participantA.license?.isEmpty ?? true)
        let policyAStepFilled = !draft.participantA.policy.isEmpty
        let policyBAStepFilled = !draft.participantB.policy.isEmpty
        if photosStepFilled && driverDocumentsStepFilled && policyAStepFilled && policyBAStepFilled {
            self.euroProtocolService.getDraftStatus { [weak self] result in
                guard let self = self else { return }

                switch result {
                    case .success(let status):
                        navigateBasedOnStatus(status)
                    case .failure:
                        self.showEuroProtocolMainDraftScreen()
                }
            }
        } else {
            self.showEuroProtocolMainPlanAccidentScreen()
        }
    }

    private func showEuroProtocolMainPlanAccidentScreen() {
        let viewController = EuroProtocolMainPlanAccidentViewController()
        container?.resolve(viewController)

        viewController.input = .init(
            loadPhoto: { index in
                let imageResult = self.euroProtocolService.getImage(type: EuroProtocolFreeImageType.freeImage(index: index))
                guard case .success(let image) = imageResult else { return nil }

                return image
            }
        )
        viewController.output = .init(
            addPhoto: { index, completion in
                self.euroProtocolService.freePhoto(index: index, action: .add, completion: completion)
            },
            removePhoto: { index, completion in
                self.euroProtocolService.freePhoto(index: index, action: .remove) { result in
                    completion(result.map { _ in Void() })
                }
            },
            nextScreen: {
                self.showEuroProtocolDriverDocumentsScreen()
            }
        )

        viewController.addCloseButton { [weak viewController] in
            guard let viewController = viewController else { return }

            self.showSaveBackAlert(from: viewController)
        }

        createAndShowNavigationController(viewController: viewController, mode: .push)
    }

    private func showEuroProtocolDriverDocumentsScreen() {
        let viewController = EuroProtocolDriverDocumentsViewController()
        container?.resolve(viewController)

        let documentsInfo: DriverDocumentsInfo = {
            if let participant = currentDraft?.participantA, !(participant.license?.isEmpty ?? true) {
                return DriverDocumentsInfo(participantInfo: participant)
            } else {
                return DriverDocumentsInfo(esiaUser: euroProtocolService.esiaUser)
            }
        }()

        viewController.input = .init(
            dataSource: documentsInfo
        )
        viewController.output = .init(
            nextScreen: {
                self.showEuroProtocolCheckOSAGOMainViewController()
            },
            setDriverInfo: { driverInfo, completion in
                self.euroProtocolService.setDriverInfo(info: driverInfo) { [weak self] in
                    completion($0)
                    self?.updateCurrentDraftModel { _ in }
                }
            }
        )
        createAndShowNavigationController(viewController: viewController, mode: .push)
    }

    private func showEuroProtocolCheckOSAGOMainViewController() {
        let viewController = EuroProtocolCheckOSAGOMainViewController()
        container?.resolve(viewController)

        viewController.input = .init(
            draft: { self.currentDraft },
            participants: {
                [
                    .participantA(
                        defaultDocument: self.currentDraft?.participantA.policy.seriesAndNumber
                            ?? self.insurance.seriesAndNumber
                    ),
                    .participantB(
                        defaultDocument: self.currentDraft?.participantB.policy.seriesAndNumber
                    )
                ]
            }
        )
        viewController.output = .init(
            openParticipant: { type in
                self.showEuroProtocolCheckOSAGOParticipantInfoViewController(with: type)
            },
            nextScreen: {
                self.showAddParticipantMainViewController()
            }
        )

        osagoInfoUpdatedSubscriptions.add(viewController.notify.infoUpdated).disposed(by: viewController.disposeBag)
        createAndShowNavigationController(viewController: viewController, mode: .push)
    }

    private func showEuroProtocolCheckOSAGOParticipantInfoViewController(
        with type: OSAGOCheckParticipantType
    ) {
        let viewController = EuroProtocolCheckOSAGOInfoViewController()
        container?.resolve(viewController)

        viewController.input = .init(
            type: type,
            policyInfo: { [weak viewController] seriesAndNumber, completion in
                guard let controller = viewController else { return }

                self.setOsagoPolicyInfo(from: controller, participantType: type, seriesAndNumber: seriesAndNumber, completion: completion)
            }
        )
        viewController.output = .init(
            successfullySetPolicyInfo: {
                self.updateCurrentDraftModel { _ in
                    self.osagoInfoUpdatedSubscriptions.fire(())
                }
            },
            acceptPolicyInfo: {
                self.navigationController?.popViewController(animated: true)
            }
        )

        createAndShowNavigationController(viewController: viewController, mode: .push)
    }

    private func showCircumstancesAccidentMainViewController() {
        let viewController = CircumstancesAccidentMainViewController()
        container?.resolve(viewController)
        viewController.input = .init(
            hasDisagreements: {
                self.euroProtocolService.hasDisagreements
            },
            currentDraftNoticeInfo: {
                self.currentDraft?.noticeInfo
            }
        )
        viewController.output = .init(
            openDisagreements: {
                self.showCircumstancesAccidentDisagreementsViewController()
            },
            openAddress: {
                self.showCircumstancesAccidentAddressViewController()
            },
            openDate: {
                self.showCircumstancesAccidentDateViewController()
            },
            openPhoto: {
                self.showCircumstancesAccidentPhotoViewController()
            },
            save: {
                self.navigationController?.popViewController(animated: true)
            }
        )

        draftInfoUpdatedSubscriptions.add(viewController.notify.infoUpdated).disposed(by: viewController.disposeBag)
        createAndShowNavigationController(viewController: viewController, mode: .push)
    }

    private func showCircumstancesAccidentDisagreementsViewController() {
        let viewController = AccidentDisagreementsViewController()
        container?.resolve(viewController)

        viewController.input = .init(hasDisagreements: euroProtocolService.hasDisagreements)
        viewController.output = .init(
            save: { hasDisagreements in
                self.euroProtocolService.hasDisagreements = hasDisagreements
                self.draftInfoUpdatedSubscriptions.fire(())
                self.navigationController?.popViewController(animated: true)
            }
        )

        createAndShowNavigationController(viewController: viewController, mode: .push)
    }

    private func showCircumstancesAccidentAddressViewController() {
        let viewController = CircumstancesAccidentAddressViewController()
        container?.resolve(viewController)

        viewController.input = .init(address: currentDraft?.noticeInfo.place)
        viewController.output = .init(
            save: { address, completion in
                self.euroProtocolService.setAccidentCoords(address: address) { result in
                    completion(result)

                    if case .success = result {
                        self.updateCurrentDraftModel { _ in }
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            }
        )

        createAndShowNavigationController(viewController: viewController, mode: .push)
    }

    private func showCircumstancesAccidentDateViewController() {
        let viewController = CircumstancesAccidentDateViewController()
        container?.resolve(viewController)

        viewController.input = .init(date: currentDraft?.noticeInfo.date)

        viewController.output = .init(
            save: { date, completion in
                self.euroProtocolService.setAccidentDate(date) { result in
                    completion(result)

                    if case .success = result {
                        self.updateCurrentDraftModel { _ in }
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            }
        )

        createAndShowNavigationController(viewController: viewController, mode: .push)
    }

    private func showCircumstancesAccidentPhotoViewController() {
        let viewController = CircumstancesAccidentPhotoViewController()
        container?.resolve(viewController)

        viewController.input = .init(
            currentImage: { self.euroProtocolService.getImage(type: EuroProtocolPrivateImageType.accidentScheme) }
        )

        viewController.output = .init(
            takePhoto: { result in
                self.protectedPhoto(action: .add, imageType: .accidentScheme, completion: result)
            },
            removePhoto: { result in
                self.protectedPhoto(action: .remove, imageType: .accidentScheme, completion: result)
            },
            save: {
                self.navigationController?.popViewController(animated: true)
            }
        )

        createAndShowNavigationController(viewController: viewController, mode: .push)
    }

    private func createAddParticipantMainViewController(from mainDraftViewController: ViewController?) -> ViewController {
        let viewController = AddParticipantMainViewController()
        container?.resolve(viewController)

        viewController.input = .init(
            participantBInviteModel: euroProtocolService.participantBInviteModel,
            shouldShowLaterButton: mainDraftViewController == nil
        )
        viewController.output = .init(
            cacheInputData: { participantData in
                self.euroProtocolService.participantBInviteModel = participantData
            },
            generateCode: { participant, completion in
                self.initLinkQR(from: viewController, participant: participant) { result in
                    switch result {
                        case .success(let image):
                            self.draftInfoUpdatedSubscriptions.fire(())
                            self.showAddParticipantCodeViewController(
                                from: mainDraftViewController,
                                state: .next,
                                qrCode: image
                            )
                        case .failure:
                            break
                    }
                    completion(result)
                }
            },
            later: {
                self.showEuroProtocolMainDraftScreen()
            }
        )

        return viewController
    }

    private func showAddParticipantMainViewController(from mainDraftViewController: ViewController? = nil) {
        let viewController = createAddParticipantMainViewController(from: mainDraftViewController)
        createAndShowNavigationController(viewController: viewController, mode: .push)
    }

    private func showAddParticipantCodeViewController(
        from mainDraftViewController: ViewController?,
        state: AddParticipantCodeViewController.State,
        qrCode: UIImage
    ) {
        let viewController = AddParticipantCodeViewController()
        container?.resolve(viewController)

        viewController.input = .init(
            code: qrCode,
            state: state
        )

        viewController.output = .init(
            next: {
                if let mainDraftViewController = mainDraftViewController {
                    self.navigationController?.popToViewController(mainDraftViewController, animated: true)
                } else {
                    self.showEuroProtocolMainDraftScreen()
                }
            },
            anew: {
                if var viewControllers = self.navigationController?.viewControllers, !viewControllers.isEmpty {
                    let inviteViewController = self.createAddParticipantMainViewController(from: mainDraftViewController)
                    viewControllers.removeLast()
                    viewControllers.append(inviteViewController)
                    self.navigationController?.setViewControllers(viewControllers, animated: true)
                }
            }
        )

        createAndShowNavigationController(viewController: viewController, mode: .push)
    }

    private func showEuroProtocolMainDraftScreen() {
        let viewController = EuroProtocolMainDraftViewController()
        container?.resolve(viewController)

        viewController.input = .init(
            draft: {
                self.currentDraft
            },
            updateDraft: { completion in
                self.updateCurrentDraftModel(completion: completion)
            },
            participantBInviteModel: { self.euroProtocolService.participantBInviteModel },
            isAccidentCircumstancesFilled: {
                self.areAccidentCircumstancesFilled()
            },
            isParticipantAInfoFilled: {
                !(self.currentDraft?.participantA.owner.isEmpty ?? true)
                    && self.isVehicleLicensePlatePhotoTaken(for: .participantA)
            },
            isParticipantAVehicleDamagesFilled: {
                !(self.currentDraft?.participantA.roadAccidents.isEmpty ?? true)
                    && self.areDamagedPartsPhotosTaken(for: .participantA)
            },
            isParticipantBInfoFilled: {
                !(self.currentDraft?.participantB.owner.isEmpty ?? true)
                    && self.isVehicleLicensePlatePhotoTaken(for: .participantB)
            },
            isParticipantBVehicleDamagesFilled: {
                !(self.currentDraft?.participantB.roadAccidents.isEmpty ?? true)
                    && self.areDamagedPartsPhotosTaken(for: .participantB)
            }
        )
        viewController.output = .init(
            createDraft: { completion in
                guard let disagreements = self.euroProtocolService.hasDisagreements else { return }

                self.euroProtocolService.createDraft(disagreements: disagreements, validateOnly: false) { [weak self] result in
                    completion(result)
                    if case .failure(let error) = result, case .sdkError(let rsaError) = error,
                          case .draftIsAlreadyRegistered(_, _) = rsaError {
                        self?.showEuroProtocolPreviewMainDraftScreen()
                    }
                }
            },
            draftPreview: {
                self.showEuroProtocolPreviewMainDraftScreen()
            },
            addParticipantB: { [weak viewController] in
                guard let viewController = viewController else { return }

                if let qrCode = self.euroProtocolService.participantBInviteModel.imageQRCode {
                    self.showAddParticipantCodeViewController(from: viewController, state: .anew, qrCode: qrCode)
                } else {
                    self.showAddParticipantMainViewController(from: viewController)
                }
            },
            accidentInfo: {
                self.showCircumstancesAccidentMainViewController()
            },
            participantAInfo: {
                self.showParticipantInfoViewController(for: .participantA)
            },
            participantAAutoDamage: {
                self.showAutoDamageMainViewController(for: .participantA)
            },
            participantBInfo: {
                self.showParticipantInfoViewController(for: .participantB)
            },
            participantBAutoDamage: {
                self.showAutoDamageMainViewController(for: .participantB)
            }
        )

        viewController.addCloseButton { [weak viewController] in
            guard let viewController = viewController else { return }

            self.showSaveBackAlert(from: viewController)
        }

        draftInfoUpdatedSubscriptions.add(viewController.notify.draftUpdated).disposed(by: viewController.disposeBag)
        createAndShowNavigationController(viewController: viewController, mode: .push)
    }

    private func showEuroProtocolPreviewMainDraftScreen() {
        let viewController = EuroProtocolPreviewMainDraftViewController()
        container?.resolve(viewController)

        viewController.input = .init(
            draft: {
                self.currentDraft
            },
            updateDraft: { completion in
                self.updateCurrentDraftModel(completion: completion)
            },
            user: euroProtocolService.esiaUser,
            acceptDraft: { completion in
                self.euroProtocolService.acceptDraft(completion: completion)
            },
            participantBInviteModel: {
                self.euroProtocolService.participantBInviteModel
            }
        )

        viewController.output = .init(
            draftAccepted: {
                self.showEuroProtocolDraftStatusScreen()
            }
        )

        draftInfoUpdatedSubscriptions.add(viewController.notify.draftUpdated).disposed(by: viewController.disposeBag)
        createAndShowNavigationController(viewController: viewController, mode: .push)
    }

    private func showEuroProtocolDraftStatusScreen() {
        let viewController = EuroProtocolDraftStatusViewController()
        container?.resolve(viewController)

        viewController.input = .init(
            draftStatus: { completion in
                self.euroProtocolService.getDraftStatus(completion: completion)
            },
            aisStatus: {
                guard let aisNumber = self.euroProtocolService.aisIdentifier else {
                    return .notSent
                }

                guard self.euroProtocolService.aisAlfaRegistrationId != nil else {
                    return .sendToAlfaError(aisNumber: aisNumber)
                }

                return .success(aisNumber: aisNumber)
            }
        )

        viewController.output = .init(
            eraseClose: {
                self.showEraseBackAlert(from: viewController)
            },
            saveClose: {
                self.showSaveBackAlert(from: viewController)
            },
            finalClose: {
                self.showRegisteredDraftLeaveAlert(from: viewController)
            },
            sendNotice: { completion in
                self.euroProtocolService.sendNotice { [weak self] result in
                    guard let self = self else { return }

                    self.updateCurrentDraftModel { _ in
                        switch result {
                            case .success(let aisNumber):
                                self.euroProtocolService.aisIdentifier = aisNumber
                            case .failure:
                                break

                        }
                        completion(result)
                    }
                }
            },
            sendAlfaReport: { aisNumber, completion in
                guard let insurance = self.currentDraft?.participantA.policy.seriesAndNumber else {
                    completion(.failure(.error(
                        .error(EuroProtocolDraftStatusViewController.DraftStatusError.noParticipantAInsuranceFound)
                    )))
                    return
                }

                self.euroProtocolService.reportCreatedOsagoEvent(
                    insurance: insurance,
                    aisNumber: aisNumber
                ) { [weak self] result in
                    guard let self = self else { return }

                    switch result {
                        case .success(let id):
                            self.euroProtocolService.aisAlfaRegistrationId = id
                        case .failure:
                            break
                    }
                    completion(result)
                }
            },
            changeDraft: {
                self.navigationController?.popViewController(animated: true)
            },
            backToHome: {
                self.euroProtocolService.stopSdk { _ in
                    ApplicationFlow.shared.show(item: .tabBar(.home))
                }
            },
            next: {
                self.showSuccessFinalBottomSheet(from: viewController)
            },
            continueAtOffice: {
                self.euroProtocolService.stopSdk { _ in
                    let officesFlow = OfficesFlow()
                    self.container?.resolve(officesFlow)
                    officesFlow.start(from: viewController)
                }
            }
        )

        createAndShowNavigationController(viewController: viewController, mode: .push)
    }

    private func showSuccessFinalBottomSheet(from: EuroProtocolBaseViewController) {
        let viewController = InfoBottomViewController()
        container?.resolve(viewController)

        viewController.input = .init(
            title: NSLocalizedString("insurance_euro_protocol_draft_status_next_steps_title", comment: ""),
            description: NSLocalizedString("insurance_euro_protocol_draft_status_next_steps_text", comment: ""),
            primaryButtonTitle: NSLocalizedString("insurance_euro_protocol_draft_status_continue_in_app", comment: ""),
            secondaryButtonTitle: NSLocalizedString("insurance_euro_protocol_draft_status_continue_at_office", comment: "")
        )
        viewController.output = .init(
            close: { viewController.dismiss(animated: true) },
            primaryAction: {
                self.euroProtocolService.stopSdk { _ in
                    ApplicationFlow.shared.show(item: .tabBar(.home))
                }
            },
            secondaryAction: {
                self.euroProtocolService.stopSdk { _ in
                    let officesFlow = OfficesFlow()
                    self.container?.resolve(officesFlow)
                    officesFlow.start(from: viewController)
                }
            }
        )

        from.showBottomSheet(contentViewController: viewController)
    }

    private func showParticipantInfoViewController(
        for type: EuroProtocolParticipant
    ) {
        let viewController = ParticipantInfoViewController()
        container?.resolve(viewController)

        viewController.input = .init(
            type: type,
            currentDraft: { self.currentDraft },
            isFilled: { card in
                switch card {
                    case .owner:
                        return self.isVehicleOwnerDataFilled(for: type)
                    case .photo:
                        return self.isVehicleLicensePlatePhotoTaken(for: type)
                }
            }
        )
        viewController.output = .init(
            save: {
                self.navigationController?.popViewController(animated: true)
            },
            showOwner: {
                self.showCarOwnerViewController(for: type)
            },
            showPhoto: {
                self.showParticipantInfoNumberPhoto(for: type)
            }
        )

        draftInfoUpdatedSubscriptions.add(viewController.notify.infoUpdated)
            .disposed(by: viewController.disposeBag)
        createAndShowNavigationController(viewController: viewController, mode: .push)
    }

    private func showCarOwnerViewController(
        for type: EuroProtocolParticipant
    ) {
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
                    let viewController = EuroProtocolCarOwnerViewController()
                    self.container?.resolve(viewController)

                    let owner: EuroProtocolOwner? = {
                        switch type {
                            case .participantA:
                                return self.currentDraft?.participantA.owner
                            case .participantB:
                                return self.currentDraft?.participantB.owner
                        }
                    }()

                    viewController.input = .init(
                        participant: type,
                        owner: owner,
                        accountName: userAccount.fullName
                    )

                    viewController.output = .init(
                        save: { owner, completion in
                            self.euroProtocolService.setOwner(participant: type, owner: owner) { [weak self] result in
                                guard let self = self
                                else { return }
                                
                                if case .success = result {
                                    self.navigationController?.popViewController(animated: true)
                                    self.updateCurrentDraftModel { _ in }
                                }
                                completion(result)
                            }
                        }
                    )

                    self.createAndShowNavigationController(viewController: viewController, mode: .push)
                case .failure(let error):
                    ErrorHelper.show(error: error, alertPresenter: self.alertPresenter)
            }
        }
    }

    private func showAutoDamageMainViewController(
        for type: EuroProtocolParticipant
    ) {
        let viewController = AutoDamageMainViewController()
        container?.resolve(viewController)

        let currentDraftParticipant: () -> EuroProtocolParticipantInfo? = {
            switch type {
                case .participantA:
                    return self.currentDraft?.participantA
                case .participantB:
                    return self.currentDraft?.participantB
            }
        }

        viewController.input = .init(
            type: .init(euroProtocolParticipant: type),
            info: { currentDraftParticipant() },
            isFieldFilled: { field in
                switch field {
                    case .place:
                        return currentDraftParticipant()?.roadAccidents.initialImpact != nil
                    case .photo:
                        return self.areDamagedPartsPhotosTaken(for: type)
                    case .info:
                        return currentDraftParticipant()?.roadAccidents.comments != nil
                            && !(currentDraftParticipant()?.roadAccidents.circumstances.isEmpty ?? true)
                }
            }
        )
        viewController.output = .init(
            save: {
                self.navigationController?.popViewController(animated: true)
            },
            showPlace: {
                self.showFirstDamagePlaceViewController(for: type)
            },
            showPhoto: {
                self.showDamagedPartPhotosViewController(participant: type)
            },
            showInfo: {
                self.showAccidentInfoMainViewController(participant: type)
            }
        )

        firstBumpInfoUpdatedSubscriptions.add(viewController.notify.infoUpdated)
            .disposed(by: viewController.disposeBag)
        damagedPartsUpdatedSubscription.add(viewController.notify.infoUpdated)
            .disposed(by: viewController.disposeBag)
        participantAccidentUpdatedSubscriptions.add(viewController.notify.infoUpdated)
            .disposed(by: viewController.disposeBag)

        createAndShowNavigationController(viewController: viewController, mode: .push)
    }

    private func showFirstDamagePlaceViewController(
        for participant: EuroProtocolParticipant
    ) {
        let viewController = FirstDamagePlaceViewController()
        container?.resolve(viewController)

        var damagePlace: EuroProtocolVehicleDamagePosition? = {
            let initialImpact = self.vehicleFirstBump(for: participant)
            guard
                let value = initialImpact?.sector,
                let vehicleType = initialImpact?.vechicleType,
                let scheme = vehicleType.bumpSchemeType.init(sectionValue: value)
            else { return nil }

            return EuroProtocolVehicleDamagePosition(scheme: scheme)
        }()

        viewController.input = .init(
            participant: .init(euroProtocolParticipant: participant),
            initialImpact: { self.vehicleFirstBump(for: participant) },
            selectedDamageText: { damagePlace?.filledCardText },
            isSaveEnabled: { damagePlace != nil }
        )

        viewController.output = .init(
            showDamagePositionPicker: { vehicleType in
                self.showFirstDamagePlacePickerViewController(
                    vehicleType: vehicleType,
                    initialDamagePlace: damagePlace,
                    updateDamagePosition: { position in damagePlace = position }
                )
            },
            selectedVehicleTypeChanged: { damagePlace = nil },
            save: { completion in
                guard let scheme = damagePlace else { return }

                let hide = viewController.showLoadingIndicator(message: nil)
                self.euroProtocolService.setAccidentFirstHitPlace(participant: participant, schemeType: scheme.bumpScheme) { result in
                    hide(nil)
                    completion(result)
                    if case .success = result {
                        self.navigationController?.popViewController(animated: true)
                        self.updateCurrentDraftModel { _ in
                            self.firstBumpInfoUpdatedSubscriptions.fire(())
                        }
                    }
                }
            }
        )

        firstBumpInfoUpdatedSubscriptions.add(viewController.notify.infoUpdated).disposed(by: viewController.disposeBag)

        createAndShowNavigationController(viewController: viewController, mode: .push)
    }

    private func showFirstDamagePlacePickerViewController(
        vehicleType: EuroProtocolVehicleType,
        initialDamagePlace: EuroProtocolVehicleDamagePosition?,
        updateDamagePosition: @escaping (EuroProtocolVehicleDamagePosition) -> Void
    ) {
        let viewController = FirstDamagePlacePickerViewController()
        container?.resolve(viewController)

        viewController.input = .init(
            vehicleType: vehicleType,
            initialDamagePosition: initialDamagePlace
        )
        viewController.output = .init(
            save: { damagePosition in
                updateDamagePosition(damagePosition)
                self.firstBumpInfoUpdatedSubscriptions.fire(())
                self.navigationController?.popViewController(animated: true)
            }
        )

        createAndShowNavigationController(viewController: viewController, mode: .push)
    }

    private func showDamagedPartPhotosViewController(participant: EuroProtocolParticipant) {
        let viewController = DamagedPartPhotosViewController()
        container?.resolve(viewController)

        var selectedVehicleType = vehicleType(with: selectedVehicleParts(for: participant))

        viewController.input = .init(
            participant: .init(euroProtocolParticipant: participant),
            damages: { self.selectedVehicleParts(for: participant) },
            photo: { part in
                let result = self.euroProtocolService.getImage(type: EuroProtocolPrivateImageType.damage(owner: participant, detail: part))
                switch result {
                    case .success(let image):
                        return image
                    case .failure:
                        return nil
                }
            },
            vehicleType: { selectedVehicleType },
            isSaveEnabled: { self.areDamagedPartsPhotosTaken(for: participant) }
        )

        viewController.output = .init(
            onFirstAppear: {
                self.showRemainingTimeBottomSheet(from: viewController)
            },
            save: {
                self.navigationController?.popViewController(animated: true)
            },
            addDamage: { completion in
                let selectedParts = self.selectedVehicleParts(for: participant).count
                guard selectedParts < Constants.maxSelectedVehiclePartsNumber else {
                    return completion(.failure(
                        .error(.error(DamagedPartPhotosViewController.DamagedPartError.reachedMaxNumberOfParts))
                    ))
                }

                switch selectedVehicleType {
                    case .car:
                        self.showDamagedPartsListViewController(
                            selectedParts: self.selectedVehicleParts(for: participant)
                        ) {
                            self.setAccidentDamagedParts(participant: participant, parts: $0, completion: completion)
                        }
                    case .other:
                        self.showCreateOtherVehicleDamagedPart {
                            self.setAccidentDamagedParts(
                                participant: participant,
                                parts: self.selectedVehicleParts(for: participant) + [ $0 ],
                                completion: completion
                            )
                        }
                }
            },
            selectVehicleType: { type in
                selectedVehicleType = type
                self.setAccidentDamagedParts(participant: participant, parts: [ ])
            },
            deleteDamage: { part, completion in
                let parts = self.selectedVehicleParts(for: participant).filter { $0 != part }
                self.setAccidentDamagedParts(
                    participant: participant,
                    parts: parts
                ) { [weak self] in
                    completion($0)
                    if case .success = $0 {
                        self?.updateCurrentDraftModel { _ in
                            self?.damagedPartsUpdatedSubscription.fire(())
                        }
                    }
                }
            },
            selectDamage: { part in
                self.showTakeDamagePhotoBottomViewController(
                    from: viewController,
                    participant: participant,
                    part: part
                )
            }
        )

        damagedPartsUpdatedSubscription.add(viewController.notify.infoUpdated).disposed(by: viewController.disposeBag)

        createAndShowNavigationController(viewController: viewController, mode: .push)
    }

    private func showDamagedPartsListViewController(
        selectedParts: [EuroProtocolVehiclePart],
        completion: @escaping ([EuroProtocolVehiclePart]) -> Void
    ) {
        let viewController = EuroProtocolMultipleChoiceListViewController()
        container?.resolve(viewController)

        viewController.input = .init(
            canDeselectSingleItem: true,
            title: NSLocalizedString("insurance_euro_protocol_damaged_parts", comment: ""),
            items: EuroProtocolVehiclePart.allCarParts.map { item in
                VehiclePartSelectable(
                    title: item.description,
                    isSelected: selectedParts.contains(where: { $0 == item })
                )
            },
            maxSelectionNumber: Constants.maxSelectedVehiclePartsNumber,
            buttonTitle: NSLocalizedString("common_save", comment: "")
        )
        viewController.output = .init(
            save: { indices in
                let parts = EuroProtocolVehiclePart.allCarParts.enumerated()
                    .filter { indices.contains($0.offset) }
                    .map { $0.element }
                completion(parts)
                self.navigationController?.popViewController(animated: true)
            },
            userInputForSelectedItemHandler: nil
        )

        createAndShowNavigationController(viewController: viewController, mode: .push)
    }

    private func showCreateOtherVehicleDamagedPart(completion: @escaping (EuroProtocolVehiclePart) -> Void) {
        let controller: OtherVehicleDamagedPartViewController = .init()
        container?.resolve(controller)
        controller.output = .init(save: {
            self.navigationController?.popViewController(animated: true)
            completion($0)
        })
        createAndShowNavigationController(viewController: controller, mode: .push)
    }

    private func showTakeDamagePhotoBottomViewController(
        from: EuroProtocolBaseViewController,
        participant: EuroProtocolParticipant,
        part: EuroProtocolVehiclePart
    ) {
        let controller: PhotoPickerBottomViewController = .init()

        controller.input = .init(
            title: {
                if case .other(let description, _) = part {
                    return description
                }
                return part.description
            },
            infoText: {
                if case .other(_, let detailDescription) = part {
                    return detailDescription ?? ""
                }
                return ""
            },
            numberOfCards: 1,
            photo: { _ in
                let result = self.euroProtocolService.getImage(
                    type: EuroProtocolPrivateImageType.damage(owner: participant, detail: part)
                )
                switch result {
                    case .success(let image):
                        return image
                    case .failure:
                        return nil
                }
            }
        )

        let processSDKPhotoCompletion: (Result<UIImage?, EuroProtocolServiceError>) -> Void = { [weak self] result in
            switch result {
                case .success:
                    self?.damagedPartsUpdatedSubscription.fire(())
                case .failure(let error):
                    from.processError(error)
            }
        }

        controller.output = .init(
            selected: { _ in
                self.euroProtocolService.protectedPhoto(
                    action: .add,
                    imageType: .damage(owner: participant, detail: part),
                    completion: processSDKPhotoCompletion
                )
            },
            delete: { _ in
                self.euroProtocolService.protectedPhoto(
                    action: .remove,
                    imageType: .damage(owner: participant, detail: part),
                    completion: processSDKPhotoCompletion
                )
            },
            close: {
                controller.dismiss(animated: true)
            },
            done: {
                controller.dismiss(animated: true)
            }
        )

        damagedPartsUpdatedSubscription
            .add(controller.notify.infoUpdated)
            .disposed(by: controller.disposeBag)

        from.showBottomSheet(contentViewController: controller)
    }

    private func showRemainingTimeBottomSheet(from: EuroProtocolBaseViewController) {
        let viewController = InfoBottomViewController()
        container?.resolve(viewController)

        let (title, description): (String, String) = {
            guard let seconds = euroProtocolService.reviewTimeLeft else {
                let title = NSLocalizedString("insurance_euro_protocol_photo_timer_initial_warning_title", comment: "")
                let descr = NSLocalizedString("insurance_euro_protocol_photo_timer_initial_warning_description", comment: "")
                return (title, descr)
            }

            let minutesLeftPhrase = String(format: NSLocalizedString("minutes_left", comment: ""), Int(seconds) / 60)
            let title = minutesLeftPhrase.capitalizingFirstLetter()
            let descr = String(
                format: NSLocalizedString(
                    "insurance_euro_protocol_photo_timer_warning_description",
                    comment: ""
                ),
                minutesLeftPhrase
            )
            return (title, descr)
        }()

        viewController.input = .init(
            title: title,
            description: description,
            primaryButtonTitle: NSLocalizedString("common_continue", comment: ""),
            secondaryButtonTitle: nil
        )
        viewController.output = .init(
            close: { viewController.dismiss(animated: true) },
            primaryAction: { viewController.dismiss(animated: true) }
        )

        from.showBottomSheet(contentViewController: viewController)
    }

    private func showAccidentInfoMainViewController(participant: EuroProtocolParticipant) {
        let viewController = AccidentInfoMainViewController()
        container?.resolve(viewController)

        var selectedCircumstances: [EuroProtocolCircumstance] = selectedCircumstanceTypes(for: participant)
        var circumstanceComment: String? = circumstanceComment(for: participant)

        var otherAccidentDescription: String? = otherDescription(for: participant)

        viewController.input = .init(
            type: participant,
            selectedCircumstances: { selectedCircumstances },
            comment: { circumstanceComment },
            otherAccidentDescription: { otherAccidentDescription }
        )
        viewController.output = .init(
            save: { completion in
                let hide = viewController.showLoadingIndicator(message: nil)
                self.setAccidentCircumstances(
                    participant: participant,
                    circumstances: selectedCircumstances,
                    description: circumstanceComment
                ) { [weak self] circumstancesResult in
                    switch circumstancesResult {
                        case .success:
                            self?.euroProtocolService.setAccidentDescription(
                                participant: participant,
                                accidentDescription: otherAccidentDescription
                            ) { [weak self] additionalDataResult in
                                hide(nil)
                                completion(additionalDataResult)
                                switch additionalDataResult {
                                    case .success:
                                        self?.navigationController?.popViewController(animated: true)
                                    case .failure:
                                        break
                                }
                            }
                        case .failure:
                            completion(circumstancesResult)
                            hide(nil)
                    }
                }
            },
            showTypes: {
                self.showAccidentTypesListViewController(
                    selectedItems: selectedCircumstances,
                    participant: participant
                ) { [weak self] in
                    selectedCircumstances = $0
                    if !selectedCircumstances.contains(.other) {
                        otherAccidentDescription = nil
                    }
                    self?.participantAccidentUpdatedSubscriptions.fire(())
                }
            },
            saveComment: {
                circumstanceComment = $0
                self.participantAccidentUpdatedSubscriptions.fire(())
            },
            saveOtherAccidentDescription: {
                otherAccidentDescription = $0
                self.participantAccidentUpdatedSubscriptions.fire(())
            }
        )

        participantAccidentUpdatedSubscriptions
            .add(viewController.notify.infoUpdated)
            .disposed(by: viewController.disposeBag)
        createAndShowNavigationController(viewController: viewController, mode: .push)
    }

    private func showAccidentTypesListViewController(
        selectedItems: [EuroProtocolCircumstance],
        participant: EuroProtocolParticipant,
        completion: @escaping ([EuroProtocolCircumstance]) -> Void
    ) {
        let viewController = EuroProtocolMultipleChoiceListViewController()
        container?.resolve(viewController)

        let items: [SelectableItem] = EuroProtocolCircumstance.allCases.map {
            AccidentTypeSelectable(
                title: $0.description,
                isSelected: selectedItems
                    .contains($0)
            )
        }
        viewController.input = .init(
            canDeselectSingleItem: true,
            title: NSLocalizedString("insurance_euro_protocol_accident_type_title", comment: ""),
            items: items,
            maxSelectionNumber: 0,
            buttonTitle: NSLocalizedString("common_save", comment: "")
        )
        viewController.output = .init(
            save: { indices in
                let types: [EuroProtocolCircumstance] = EuroProtocolCircumstance
                    .allCases
                    .enumerated()
                    .filter { indices.contains($0.offset) }
                    .map { $0.element }
                completion(types)
                self.participantAccidentUpdatedSubscriptions.fire(())
                self.navigationController?.popViewController(animated: true)
            },
            userInputForSelectedItemHandler: nil
        )

        createAndShowNavigationController(viewController: viewController, mode: .push)
    }

    private func showParticipantInfoNumberPhoto(
        for type: EuroProtocolParticipant
    ) {
        let viewController = ParticipantInfoNumberPhoto()
        container?.resolve(viewController)

        viewController.input = .init(
            loadPhoto: {
                let imageResult = self.euroProtocolService.getImage(type: EuroProtocolPrivateImageType.regMark(owner: type))
                guard case .success(let image) = imageResult else { return nil }

                return image
            },
            addPhoto: { completion in
                self.protectedPhoto(action: .add, imageType: .regMark(owner: type), completion: completion)
            },
            removePhoto: { completion in
                self.protectedPhoto(action: .remove, imageType: .regMark(owner: type)) { result in
                    completion(result.map { _ in Void() })
                }
            }
        )

        viewController.output = .init(
            finish: {
                self.navigationController?.popViewController(animated: true)
            }
        )

        createAndShowNavigationController(viewController: viewController, mode: .push)
    }

    private func showSaveBackAlert(from: ViewController) {
        let alert = UIAlertController(
            title: NSLocalizedString("insurance_euro_protocol_exit_flow_title", comment: ""),
            message: NSLocalizedString("insurance_euro_protocol_exit_flow_save_text", comment: ""),
            preferredStyle: .alert
        )

        let saveAction = UIAlertAction(title: NSLocalizedString("common_quit", comment: ""), style: .default) { [weak self] _ in
            self?.exitFlow()
        }

        let cancelAction = UIAlertAction(title: NSLocalizedString("common_cancel_button", comment: ""), style: .cancel)

        alert.addAction(saveAction)
        alert.addAction(cancelAction)

        from.present(alert, animated: true)
    }

    private func showEraseBackAlert(from: ViewController) {
        let alert = UIAlertController(
            title: NSLocalizedString("insurance_euro_protocol_exit_flow_title", comment: ""),
            message: NSLocalizedString("insurance_euro_protocol_exit_flow_erase_text", comment: ""),
            preferredStyle: .alert
        )

        let saveAction = UIAlertAction(title: NSLocalizedString("common_quit", comment: ""), style: .default) { [weak self] _ in
            self?.deleteDraftAndExit()
        }

        let cancelAction = UIAlertAction(title: NSLocalizedString("common_cancel_button", comment: ""), style: .cancel)

        alert.addAction(saveAction)
        alert.addAction(cancelAction)

        from.present(alert, animated: true)
    }

    private func showRegisteredDraftLeaveAlert(from: ViewController) {
        let alert = UIAlertController(
            title: NSLocalizedString("insurance_euro_protocol_exit_flow_title", comment: ""),
            message: NSLocalizedString("insurance_euro_protocol_draft_status_registered_leave_text", comment: ""),
            preferredStyle: .alert
        )

        let saveAction = UIAlertAction(title: NSLocalizedString("common_quit", comment: ""), style: .default) { [weak self] _ in
            self?.deleteDraftAndExit()
        }

        let cancelAction = UIAlertAction(title: NSLocalizedString("common_cancel_button", comment: ""), style: .cancel)

        alert.addAction(saveAction)
        alert.addAction(cancelAction)

        from.present(alert, animated: true)
    }

    // MARK: Helpers

    private func vehicleFirstBump(for participant: EuroProtocolParticipant) -> EuroProtocolInitialImpact? {
        switch participant {
            case .participantA:
                return self.currentDraft?.participantA.roadAccidents.initialImpact
            case .participantB:
                return self.currentDraft?.participantB.roadAccidents.initialImpact
        }
    }

    private func selectedDamageImageTypes(for participant: EuroProtocolParticipant) -> [EuroProtocolPrivateImageType] {
        switch participant {
            case .participantA:
                return self.currentDraft?.participantA.damages ?? [ ]
            case .participantB:
                return self.currentDraft?.participantB.damages ?? [ ]
        }
    }

    private func selectedVehicleParts(for participant: EuroProtocolParticipant) -> [EuroProtocolVehiclePart] {
        selectedDamageImageTypes(for: participant)
            .compactMap {
                guard case .damage(_, let part) = $0 else { return nil }
                return part
            }
            .sorted()
    }

    private func areDamagedPartsPhotosTaken(for participant: EuroProtocolParticipant) -> Bool {
        let imageTypes = selectedDamageImageTypes(for: participant)
        guard !imageTypes.isEmpty else { return false }

        for imageType in imageTypes {
            switch euroProtocolService.getImage(type: imageType) {
                case .success(let image):
                    if image == nil { return false }
                case .failure:
                    return false
            }
        }

        return true
    }

    private func vehicleType(with parts: [EuroProtocolVehiclePart]) -> DamagedPartPhotosViewController.VehicleType {
        guard !parts.isEmpty else {
            return .car
        }

        let otherPart = parts.first(where: {
            if case .other(_, _) = $0 {
                return true
            }
            return false
        })

        return otherPart != nil ? .other : .car
    }

    private func selectedCircumstanceTypes(for participant: EuroProtocolParticipant) -> [EuroProtocolCircumstance] {
        switch participant {
            case .participantA:
                return currentDraft?.participantA.roadAccidents.circumstances ?? [ ]
            case .participantB:
                return currentDraft?.participantB.roadAccidents.circumstances ?? [ ]
        }
    }

    private func otherDescription(for participant: EuroProtocolParticipant) -> String? {
        let value: String?
        switch participant {
            case .participantA:
                value = self.currentDraft?.participantA.roadAccidents.other
            case .participantB:
                value = self.currentDraft?.participantB.roadAccidents.other
        }
        return value == " " ? nil : value
    }

    private func circumstanceComment(for participant: EuroProtocolParticipant) -> String? {
        switch participant {
            case .participantA:
                return currentDraft?.participantA.roadAccidents.comments
            case .participantB:
                return currentDraft?.participantB.roadAccidents.comments
        }
    }

    private func isVehicleOwnerDataFilled(for participant: EuroProtocolParticipant) -> Bool {
        let owner: EuroProtocolOwner? = {
            switch participant {
                case .participantA:
                    return currentDraft?.participantA.owner
                case .participantB:
                    return currentDraft?.participantB.owner
            }
        }()
        guard let owner = owner else { return false }

        return !owner.isEmpty
    }

    private func isVehicleLicensePlatePhotoTaken(for participant: EuroProtocolParticipant) -> Bool {
        let photoType: EuroProtocolImageType? = {
            switch participant {
                case .participantA:
                    return currentDraft?.participantA.transport.photo
                case .participantB:
                    return currentDraft?.participantB.transport.photo
            }
        }()
        guard let photoType = photoType else {
            return false
        }

        let photoResult = self.euroProtocolService.getImage(type: photoType)
        guard case .success(let image) = photoResult else {
            return false
        }

        return image != nil
    }

    private func areAccidentCircumstancesFilled() -> Bool {
        euroProtocolService.hasDisagreements != nil
            && currentDraft?.noticeInfo.place != nil
            && currentDraft?.noticeInfo.date != nil
            && currentDraft?.noticeInfo.scheme != nil

    }

    // MARK: Service calls

    private func setOsagoPolicyInfo(
        from: ViewController,
        participantType: OSAGOCheckParticipantType,
        seriesAndNumber: SeriesAndNumberDocument,
        completion: @escaping (Result<OSAGOCheckParticipant, EuroProtocolServiceError>) -> Void
    ) {
        let hide = from.showLoadingIndicator(message: nil)
        euroProtocolService.setPolicyInfo(participant: participantType.euroProtocolParticipant, seriesAndNumber: seriesAndNumber) {
            hide(nil)
            completion($0)
        }
    }

    private func initLinkQR(
        from: ViewController,
        participant: EuroProtocolParticipantInviteInfo,
        completion: @escaping (Result<UIImage, EuroProtocolServiceError>) -> Void
    ) {
        let hide = from.showLoadingIndicator(message: nil)
        euroProtocolService.initLinkQR(add: participant) { result in
            hide(nil)
            completion(result)
        }
    }

    private func protectedPhoto(
        action: EuroProtocolPhotoAction,
        imageType: EuroProtocolPrivateImageType,
        completion: @escaping (Result<UIImage?, EuroProtocolServiceError>) -> Void
    ) {
        euroProtocolService.protectedPhoto(action: action, imageType: imageType) { result in
            completion(result)
            if case .success = result {
                self.updateCurrentDraftModel { _ in }
            }
        }
    }

    private func setAccidentDamagedParts(
        participant: EuroProtocolParticipant,
        parts: [EuroProtocolVehiclePart],
        completion: ((Result<Void, EuroProtocolServiceError>) -> Void)? = nil
    ) {
        euroProtocolService.setAccidentDamagedParts(
            participant: participant,
            parts: parts
        ) { [weak self] in
            completion?($0)
            if case .success = $0 {
                self?.updateCurrentDraftModel { _ in
                    self?.damagedPartsUpdatedSubscription.fire(())
                }
            }
        }
    }

    private func setAccidentCircumstances(
        participant: EuroProtocolParticipant,
        circumstances: [EuroProtocolCircumstance],
        description: String?,
        completion: @escaping (Result<Void, EuroProtocolServiceError>) -> Void
    ) {
        euroProtocolService.setAccidentCircumstances(
            participant: participant,
            circumstances: circumstances,
            description: description
        ) { [weak self] in
            completion($0)
            if case .success = $0 {
                self?.updateCurrentDraftModel { _ in
                    self?.participantAccidentUpdatedSubscriptions.fire(())
                }
            }
        }
    }

    private func updateCurrentDraftModel(
        completion: @escaping (Result<EuroProtocolCurrentDraftContentModel, EuroProtocolServiceError>) -> Void
    ) {
        euroProtocolService.getCurrentDraftContentModel {
            if case .success(let draft) = $0 {
                self.currentDraft = draft
            }
            completion($0)
        }
    }

    // MARK: - Test SDK methods

    private func testSDK4() {
        euroProtocolService.protectedPhoto(
            action: .add,
            imageType: .accidentScheme
        ) { result in
            switch result {
                case .success(_):
                    print("Success SDK 4")
                case .failure(let error):
                    self.alertPresenter.show(alert: ErrorNotificationAlert(error: error))
            }
        }
    }

    private func testSDK11() {
        euroProtocolService.setAccidentCoords(address: "Москва, проспект Мира, 36") { result in
            switch result {
                case .success:
                    print("Success SDK 11")
                    self.testSDK12()
                case .failure(let error):
                    self.alertPresenter.show(alert: ErrorNotificationAlert(error: error))
            }
        }
    }

    private func testSDK12() {
        euroProtocolService.setAccidentDate(Date()) { result in
            switch result {
                case .success:
                    print("Success SDK 12")
                    self.testSDK14()
                case .failure(let error):
                    self.alertPresenter.show(alert: ErrorNotificationAlert(error: error))
            }
        }
    }

    private func testSDK14() {
        euroProtocolService.setAccidentFirstHitPlace(
            participant: .participantA,
            schemeType: EuroProtocolCarScheme.pos_1
        ) { result in
            switch result {
                case .success:
                    print("Success SDK 14")
                    self.testSDK15()
                case .failure(let error):
                    self.alertPresenter.show(alert: ErrorNotificationAlert(error: error))
            }
        }
    }

    private func testSDK15() {
        euroProtocolService.setAccidentCircumstances(
            participant: .participantA,
            circumstances: [ .changingLane ],
            description: "description"
        ) { result in
            switch result {
                case .success:
                    print("Success SDK 15")
                    self.testSDK16()
                case .failure(let error):
                    self.alertPresenter.show(alert: ErrorNotificationAlert(error: error))
            }
        }
    }

    private func testSDK16() {
        euroProtocolService.setAccidentDamagedParts(
            participant: .participantA,
            parts: [ .capote ]
        ) { result in
            switch result {
                case .success:
                    print("Success SDK 16")
                    self.testSDK17()
                case .failure(let error):
                    self.alertPresenter.show(alert: ErrorNotificationAlert(error: error))
            }
        }
    }

    private func testSDK17() {
        let witness = EuroProtocolWitness(surname: "Петр", firstname: "Первый", middleName: "Сергеевич",
            address: "Санк-Петербург, прощадь главная, 1", phone: nil)
        euroProtocolService.setAccidentWitnessInfo(
            first: witness,
            second: nil
        ) { result in
            switch result {
                case .success:
                    print("Success SDK 17")
                    self.testSDK18()
                case .failure(let error):
                    self.alertPresenter.show(alert: ErrorNotificationAlert(error: error))
            }
        }
    }

    private func testSDK18() {
        euroProtocolService.createDraft(
            disagreements: false,
            validateOnly: true
        ) { result in
            switch result {
                case .success:
                    print("Success SDK 18")
                case .failure(let error):
                    switch error {
                        case .sdkError(let error):
                            print("Validation errors: \(error.validationErrors)")
                        default:
                            break
                    }
                    self.alertPresenter.show(alert: ErrorNotificationAlert(error: error))
            }
        }
    }
}
// swiftlint:enable file_length
