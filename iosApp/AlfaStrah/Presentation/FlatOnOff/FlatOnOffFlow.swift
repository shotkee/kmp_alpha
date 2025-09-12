//
//  FlatOnOffFlow.swift
//  AlfaStrah
//
//  Created by Peter Tretyakov on 30.03.2020.
//  Copyright © 2020 Redmadrobot. All rights reserved.
//

class FlatOnOffFlow: BaseFlow, FlatOnOffServiceDependency, InsurancesServiceDependency {
    var flatOnOffService: FlatOnOffService!
    var insurancesService: InsurancesService!

    private let storyboard: UIStoryboard = .init(name: "FlatOnOff", bundle: nil)

    enum Mode {
        case activations
        case activate
        case buyDays
    }

    func start(mode: Mode, insurance: Insurance) {
        switch mode {
            case .activations:
                showActivations(insurance: insurance)
            case .activate:
                showActivateScreen(insurance: insurance)
            case .buyDays:
                showBuyDays(insuranceId: insurance.id)
        }
    }

    private func showActivations(insurance: Insurance) {
        let viewController: FlatOnOffProtectionsViewController = storyboard.instantiate()
        container?.resolve(viewController)
        viewController.input = .init(
            protections: { completion in
                self.flatOnOffService.activations(insuranceId: insurance.id, completion: completion)
            }
        )
        viewController.output = .init(
            showPolicy: openURL,
            activate: {
                self.showActivateScreen(insurance: insurance)
            }
        )
        createAndShowNavigationController(viewController: viewController, mode: .push)
    }

    private func showActivateScreen(insurance: Insurance) {
        let viewController: FlatOnOffActivateViewController = storyboard.instantiate()
        container?.resolve(viewController)
        viewController.input = .init(
            balance: { completion in
                self.flatOnOffService.balance(insuranceId: insurance.id, completion: completion)
            }
        )
        viewController.output = .init(
            openCalendar: { range, completion in
                self.showCalendar(initialRange: range, completion: completion)
            },
            proceed: { start, finish, completion in
                self.flatOnOffService.activate(insuranceId: insurance.id, start: start, finish: finish) { result in
                    switch result {
                        case .success(let calculation):
                            self.showActivateFinalTermsScreen(insurance: insurance, calculation: calculation)
                            completion(.success(Void()))
                        case .failure(let error):
                            completion(.failure(error))
                    }
                }
            },
            buyDays: {
                self.showBuyDays(insuranceId: insurance.id)
            },
            about: {
                self.flatOnOffService.landingURL { result in
                    guard let url = result.value else { return }

                    self.openURL(url)
                }
            },
            buyPolicy: { [unowned viewController] in
                self.buyNewInsurance(insurance.id, from: viewController)
            },
            openChat: {
                ApplicationFlow.shared.show(item: .tabBar(.chat))
            }
        )
        createAndShowNavigationController(viewController: viewController, mode: .push)
    }

    private func showActivateFinalTermsScreen(insurance: Insurance, calculation: FlatOnOffProtectionCalculation) {
        let viewController: FlatOnOffActivateFinalViewController = storyboard.instantiate()
        container?.resolve(viewController)
        viewController.input = .init(insurance: insurance, calculation: calculation)
        viewController.output = .init(
            activate: { completion in
                self.flatOnOffService.confirmActivation(
                    insuranceId: insurance.id,
                    protectionId: calculation.id
                ) { [unowned viewController ] result in
                    switch result {
                        case .success(let confirmation):
                            self.showActivationSuccessScreen(confirmation: confirmation, viewController: viewController)
                            completion(.success(Void()))
                        case .failure(let error):
                            completion(.failure(error))
                    }
                }
            }
        )
        createAndShowNavigationController(viewController: viewController, mode: .push)
    }

    private func showActivationSuccessScreen(confirmation: FlatOnOffConfirmActivationResponse, viewController: UIViewController) {
        let operationView = OperationStatusView()
        operationView.notify.updateState(
            .info(.init(
					title: confirmation.title,
					description: confirmation.message,
					icon: .Icons.tick.resized(newWidth: 54)?.withRenderingMode(.alwaysTemplate)
			))
        )
        operationView.notify.buttonConfiguration([
            .init(
                title: NSLocalizedString("common_done_button", comment: ""),
                isPrimary: true,
                action: {
                    self.navigationController?.popToRootViewController(animated: true)
                }
            )
        ])
        viewController.view.addSubview(operationView)
        NSLayoutConstraint.activate(NSLayoutConstraint.fill(view: operationView, in: viewController.view))
    }

    private func showCalendar(initialRange: DateRange?, completion: @escaping (DateRange) -> Void) {
        let storyboard = UIStoryboard(name: "VzrOnOffFlow", bundle: nil)
        let viewController: RangeCalendarViewController = storyboard.instantiate()
        container?.resolve(viewController)
        viewController.input = .init(
            inputPickedRange: initialRange,
            startingDate: Date(),
            calendarInterval: nil,
            pickedRangeLengthMin: 1,
            pickedRangeLengthMax: nil,
            theme: .themeDefault
        )
        viewController.output = .init(
            selectedRange: { [weak self] dateRange in
                self?.close()
                completion(dateRange)
            }
        )
        viewController.addCloseButton {
            self.close()
        }
        createAndShowNavigationController(viewController: viewController, mode: .modal)
    }

    private func buyNewInsurance(_ insuranceId: String, from controller: ViewController) {
        insurancesService.insurance(useCache: true, id: insuranceId) { [unowned controller] result in
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

    private func showBuyDays(insuranceId: String) {
        let viewController: FlatOnOffBuyDaysViewController = storyboard.instantiate()
        container?.resolve(viewController)
        viewController.input = .init(
            packages: { completion in
                self.flatOnOffService.packages(insuranceId: insuranceId, completion: completion)
            }
        )
        viewController.output = .init(
            selectPackage: { package in
                self.showAgreement(package: package, insuranceId: insuranceId)
            }
        )
        createAndShowNavigationController(viewController: viewController, mode: .push)
    }

    private func showAgreement(package: FlatOnOffPurchaseItem, insuranceId: String) {
        let viewController: FlatOnOffAgreementViewController = storyboard.instantiate()
        container?.resolve(viewController)
        viewController.input = .init(package: package)
        viewController.output = .init(
            purchasePackage: { [weak viewController] in
                guard let viewController = viewController else { return }

                let hide = viewController.showLoadingIndicator(message: nil)
                self.flatOnOffService.purchaseUrl(insuranceId: insuranceId, packageId: package.id) { [weak viewController] result in
                    hide {}

                    switch result {
                        case .success(let url):
                            self.showPurchasePackage(url: url, package: package)
                        case .failure(let error):
                            viewController?.processError(error)
                    }
                }

            }
        )
        createAndShowNavigationController(viewController: viewController, mode: .push)
    }

    private func showPurchasePackage(url: URL, package: FlatOnOffPurchaseItem) {
        let controller = PurchaseTimeWebViewController()
        container?.resolve(controller)
        controller.input = .init(url: url)
        controller.output = .init(
            showOperationStatus: { success in
                self.showOperationStatus(success: success, package: package)
            }
        )
        controller.addCloseButton { [unowned controller] in
            controller.presentingViewController?.dismiss(animated: true)
        }
        createAndShowNavigationController(viewController: controller, mode: .modal)
    }

    private func showOperationStatus(success: Bool, package: FlatOnOffPurchaseItem) {
        let controller: ViewController = .init()
        container?.resolve(controller)
        let operationStatusView: OperationStatusView = .init()
        controller.view.addSubview(operationStatusView)
        NSLayoutConstraint.activate(NSLayoutConstraint.fill(view: operationStatusView, in: controller.view))
        controller.navigationItem.hidesBackButton = true
        controller.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        let title: String
        let description: String
        let state: OperationStatusView.State
        var buttons: [OperationStatusView.ButtonConfiguration] = []
        if success {
            title = NSLocalizedString("flat_on_off_purchase_time_status_success", comment: "")
            description = package.successText
            state = .info(.init(
				title: title,
				description: description,
				icon: .Icons.tick.resized(newWidth: 54)?.withRenderingMode(.alwaysTemplate)
			))
            buttons = [
                .init(
                    title: NSLocalizedString("common_done_button", comment: ""),
                    isPrimary: true,
                    action: {
                        self.navigationController?.popToRootViewController(animated: true)
                    }
                )
            ]
        } else {
            title = NSLocalizedString("flat_on_off_purchase_time_status_failure", comment: "")
            description = NSLocalizedString("flat_on_off_purchase_time_status_failure_description", comment: "")
            state = .info(.init(title: title, description: description, icon: UIImage(named: "icon-common-failure")))
            buttons = [
                .init(
                    title: NSLocalizedString("flat_on_off_purchase_time_retry_payment", comment: ""),
                    isPrimary: true,
                    action: {
                        self.navigationController?.popViewController(animated: true)
                    }
                )
            ]
        }
        operationStatusView.notify.updateState(state)
        operationStatusView.notify.buttonConfiguration(buttons)
        createAndShowNavigationController(viewController: controller, mode: .push)
    }

    private func openURL(_ url: URL) {
        guard let navigationController = navigationController else { return }
        
        SafariViewController.open(url, from: navigationController)
    }
}
