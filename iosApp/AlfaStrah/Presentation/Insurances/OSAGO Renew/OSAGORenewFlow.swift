//
//  OSAGORenewFlow
//  AlfaStrah
//
//  Created by Stanislav Starzhevskiy on 08.11.2017.
//  Copyright © 2017 RedMadRobot. All rights reserved.
//

import UIKit
import Legacy

class OSAGORenewFlow: BaseFlow,
                      InsurancesServiceDependency,
                      OsagoProlongationServiceDependency,
                      GeocodeServiceDependency,
                      PolicyServiceDependency {
    var insurancesService: InsurancesService!
    var osagoProlongationService: OsagoProlongationService!
    var geocodeService: GeocodeService!
    var policyService: PolicyService!

    private let disposeBag: DisposeBag = DisposeBag()
    private var insuranceId: String!

    private lazy var infoUpdatedSubscriptions: Subscriptions<Void> = Subscriptions()
    private lazy var updateStatusSubscriptions: Subscriptions<Void> = Subscriptions()

    func start(insuranceId: String) {
        guard let fromViewController = fromViewController as? ViewController else { return }

        self.insuranceId = insuranceId
        let hide = fromViewController.showLoadingIndicator(message: NSLocalizedString("common_loading_title", comment: ""))

        osagoProlongationService.insurancesOsagoProlongationCalcRequest(insuranceId: insuranceId) { result in
            hide {}
            switch result {
                case .success(let osagoProlongation):
                    self.showFlowInitialScreen(state: osagoProlongation.info, showMode: .modal)
                case .failure(let error):
                    self.show(error: error)
                    self.close()
            }
        }.disposed(by: disposeBag)
    }

    private func showFlowInitialScreen(state: OsagoProlongation.OsagoProlongationInfo, showMode: ViewControllerShowMode) {
        var initialViewController: ViewController?

        switch state {
            case .unsupported:
                self.close()
            case .inProcessed:
                initialViewController = self.renewInProgressScreen()
            case .success(let info):
                initialViewController = self.osagoRenewInfoController(info: info)
            case .failure(let errorInfo):
                initialViewController = self.failureScreen(errorInfo: errorInfo)
            case .error(let errorInfo, let editInfo):
                initialViewController = self.errorScreen(errorInfo: errorInfo, editInfo: editInfo)
        }

        guard let viewController = initialViewController else { return }

        viewController.addCloseButton { [weak viewController] in
            viewController?.dismiss(animated: true, completion: nil)
        }
        self.createAndShowNavigationController(viewController: viewController, mode: showMode, asInitial: true)
    }

    private func renewInProgressScreen() -> ViewController {
        let viewController = OSAGORenewInProgressViewController()

        viewController.input = .init(
            renewStatus: { [weak viewController] startTimerCompletion in
                guard let controller = viewController else { return }

                self.osagoProlongationService.insurancesOsagoProlongationCalcRequest(insuranceId: self.insuranceId) { result in
                    switch result {
                        case .success(let osagoProlongation):
                            switch osagoProlongation.info {
                                case .inProcessed:
                                    startTimerCompletion(true)
                                case .unsupported, .error, .failure, .success:
                                    self.showFlowInitialScreen(state: osagoProlongation.info, showMode: .push)
                            }
                        case .failure:
                            startTimerCompletion(true)
                    }
                }.disposed(by: controller.disposeBag)
            }
        )

        return viewController
    }

    private func osagoRenewInfoController(info: OsagoProlongationCalculateInfo) -> ViewController {
        let viewController = OSAGORenewPolicyInfoViewController()

        viewController.input = .init(
            userInfo: info,
            getOsagoProlongationUrls: { [weak viewController] completion in
                guard let controller = viewController else { return }

                self.getOsagoProlongationUrls(from: controller, completion: completion)
            },
            getPersonalDataUsageTermsUrl: { [weak viewController] completion in
                guard let controller = viewController else { return }

                self.getPersonalDataUsageTermsUrl(from: controller, completion: completion)
            }
        )

        viewController.output = .init(
            renew: { [weak viewController] userAgreedToPrivacyPolicy in
                guard let controller = viewController else { return }

                self.paymentInsurance(
                    from: controller,
                    agreedToPersonalDataPolicy: userAgreedToPrivacyPolicy
                )
            },
            linkTap: { [weak viewController] url in
                guard let controller = viewController else { return }

                SafariViewController.open(url, from: controller)
            }
        )

        return viewController
    }

    private func osagoErrorInfoViewController(viewModel: OSAGORenewViewModel) {
        let viewController = OSAGOErrorInfoViewController()

        viewController.input = .init(viewModel: viewModel)
        viewController.output = .init(
            editParticipantTap: { data in
                self.osagoParticipantInfoViewController(participant: data, viewModel: viewModel)
            },
            prolongationTap: { [weak viewController] in
                guard let fromController = viewController else { return }

                let changeRequestModel = viewModel.changeRequestModel(insuranceId: self.insuranceId)
                let hide = fromController.showLoadingIndicator(message: NSLocalizedString("common_loading_title", comment: ""))
                self.osagoProlongationService.insurancesOsagoProlongationChangeRequest(changeRequest: changeRequestModel) { result in
                    hide {}
                    switch result {
                        case .success:
                            self.showFlowInitialScreen(state: .inProcessed, showMode: .push)
                        case .failure(let error):
                            self.show(error: error)
                    }
                }
            }
        )

        infoUpdatedSubscriptions.add(viewController.notify.infoUpdated).disposed(by: viewController.disposeBag)
        createAndShowNavigationController(viewController: viewController, mode: .push)
    }

    private func osagoParticipantInfoViewController(
        participant: OsagoProlongationParticipant,
        viewModel: OSAGORenewViewModel
    ) {
        let viewController = OSAGOParticipantInfoViewController()

        viewController.input = .init(participant: participant, viewModel: viewModel)
        viewController.output = .init(
            saveParticipantTap: { editedParticipant in
                if let participantIndex = viewModel.editedInfo.participants.firstIndex(where: { $0 == editedParticipant }) {
                    viewModel.editedInfo.participants[participantIndex] = editedParticipant
                }
                self.infoUpdatedSubscriptions.fire(())
                self.navigationController?.popViewController(animated: true)
            },
            enterAddress: geocodeService.searchLocation,
            buyPolicy: { from in
                self.buyNewInsurance(from: from)
            }
        )

        self.createAndShowNavigationController(viewController: viewController, mode: .push)
    }

    private func failureScreen(errorInfo: OsagoProlongationErrorInfo) -> ViewController {
        let viewController = OSAGORenewErrorViewController()

        viewController.set(
            icon: "icon-kasko-on-off-purchase-failure",
            title: errorInfo.title,
            subTitle: errorInfo.message,
            buttonStyle: .oneButton(
                mainTitle: NSLocalizedString("insurance_new_buy", comment: "")
            )
        )

        viewController.output = .init(
            minorButtonHandler: nil,
            mainButtonHandler: {
                self.buyNewInsurance(from: viewController)
            }
        )

        return viewController
    }

    private func errorScreen(
        errorInfo: OsagoProlongationErrorInfo,
        editInfo: OsagoProlongationEditInfo
    ) -> ViewController {
        let viewController = OSAGORenewErrorViewController()

        viewController.set(
            icon: "icon-kasko-on-off-purchase-failure",
            title: errorInfo.title,
            subTitle: errorInfo.message,
            errorsInfo: errorInfo.errorsArray,
            buttonStyle: .twoButtons(
                mainTitle: NSLocalizedString("insurance_make_changes", comment: ""),
                minorTitle: NSLocalizedString("insurance_new_buy", comment: "")
            )
        )

        viewController.output = .init(
            minorButtonHandler: { [weak viewController] in
                guard let viewController = viewController else { return }

                self.buyNewInsurance(from: viewController)
            },
            mainButtonHandler: {
                self.osagoErrorInfoViewController(viewModel: .init(info: editInfo))
            }
        )

       return viewController
    }

    private func paymentInsurance(
        from controller: ViewController,
        agreedToPersonalDataPolicy: Bool
    ) {
        let hide = controller.showLoadingIndicator(message: NSLocalizedString("common_loading_title", comment: ""))

        osagoProlongationService.insurancesOsagoProlongationDeeplinkRequest(
            insuranceId: insuranceId,
            agreedToPersonalDataPolicy: agreedToPersonalDataPolicy
        ) { [weak controller] result in
            hide {}
            guard let controller = controller else { return }

            switch result {
                case .success(let deepLink):
                    SafariViewController.open(deepLink.url, from: controller)
                case .failure(let error):
                    ErrorHelper.show(error: error, alertPresenter: self.alertPresenter)
            }
        }
    }

    private func buyNewInsurance(from controller: ViewController) {
        insurancesService.insurance(useCache: true, id: insuranceId) { [weak controller] result in
            guard let controller = controller else { return }

            switch result {
                case .success(let insurance):
                    self.insurancesService.insuranceFromPreviousPurchaseDeeplinkUrl(productId: insurance.productId) { result in
                        switch result {
                            case .success(let url):
                                SafariViewController.open(url, from: controller)
                            case .failure(let error):
                                ErrorHelper.show(error: error, alertPresenter: self.alertPresenter)
                        }
                    }
                case .failure(let error):
                    ErrorHelper.show(error: error, alertPresenter: self.alertPresenter)
            }
        }
    }

    private func getOsagoProlongationUrls(
        from: ViewController,
        completion: @escaping (OsagoProlongationURLs) -> Void
    ) {
        let cancellable = CancellableNetworkTaskContainer()
        let hide = from.showLoadingIndicator(message: nil, cancellable: cancellable)

        let networkTask = osagoProlongationService.insurancesOsagoProlongationProgramRequest(insuranceID: insuranceId) { result in
            hide(nil)
            switch result {
                case .success(let urls):
                    completion(urls)

                case .failure(let error):
                    self.show(error: error)
                    self.close()
            }
        }

        cancellable.addCancellables([ networkTask ])
    }

    private func getPersonalDataUsageTermsUrl(
        from: ViewController,
        completion: @escaping (PersonalDataUsageAndPrivacyPolicyURLs) -> Void
    ) {
        let hide = from.showLoadingIndicator(message: nil)

        self.policyService.getPersonalDataUsageTermsUrl(on: .osagoProlongation) { [weak self] result in
            hide(nil)

            switch result {
                case.success(let data):
                    completion(data)

                case .failure(let error):
                    self?.show(error: error)
                    self?.close()
            }
        }
    }

    // MARK: - Error handle

    private func show(error: Error) {
        ErrorHelper.show(error: error, alertPresenter: alertPresenter)
    }
}
