//
//  VzrOnOffFlow.swift
//  AlfaStrah
//
//  Created by Amir Nuriev on 10/16/19.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

import UIKit
import Legacy

class VzrOnOffFlow: BaseFlow, VzrOnOffServiceDependency, InsurancesServiceDependency {
    enum StartOption {
        case buyDays
        case startTrip
        case tripHistory
        case purchaseHistory
    }

    var vzrOnOffService: VzrOnOffService!
    var insurancesService: InsurancesService!

    private let storyboard: UIStoryboard = .init(name: "VzrOnOffFlow", bundle: nil)

    func start(option: StartOption, insuranceId: String) {
        switch option {
            case .buyDays:
                showDayPackages(insuranceId: insuranceId)
            case .startTrip:
                showStartTripStepOne(insuranceId: insuranceId)
            case .tripHistory:
                showTripHistory(insuranceId: insuranceId)
            case .purchaseHistory:
                showPurchaseHistory(insuranceId: insuranceId)
        }
    }

    private func showDayPackages(insuranceId: String) {
        let controller: VzrOnOffDaysPackagesViewController = storyboard.instantiate()
        container?.resolve(controller)
        controller.input = .init(
            packages: { completion in
                self.vzrOnOffService.timePackages(insuranceId: insuranceId, completion: completion)
            }
        )
        controller.output = .init(
            selectPackage: { package in
                self.showAgreement(insuranceId: insuranceId, package: package)
            }
        )
        createAndShowNavigationController(viewController: controller, mode: .push)
    }

    private func showAgreement(insuranceId: String, package: VzrOnOffPurchaseItem) {
        let controller: VzrOnOffAgreementViewController = storyboard.instantiate()
        container?.resolve(controller)
        controller.input = .init(package: package)
        controller.output = .init(
            purchasePackage: { [weak controller] in
                guard let controller = controller else { return }

                let hide = controller.showLoadingIndicator(message: nil)
                self.vzrOnOffService.purchaseLink(
                    insuranceId: insuranceId,
                    purchaseItemId: package.id
                ) { result in
                        hide {}
                        switch result {
                            case .success(let url):
                                guard let url = URL(string: url) else { return }

                                self.showPurchasePackage(url: url, package: package, insuranceId: insuranceId)
                            case .failure(let error):
                                ErrorHelper.show(error: error, alertPresenter: self.alertPresenter)
                        }
                }
            }
        )
        controller.addCloseButton {
            self.close()
        }
        createAndShowNavigationController(viewController: controller, mode: .push)
    }

    private func showPurchaseHistory(insuranceId: String) {
        let controller: VzrOnOffPurchaseHistoryViewController = storyboard.instantiate()
        container?.resolve(controller)
        controller.input = .init(
            history: { completion in
                self.vzrOnOffService.purchaseHistory(insuranceId: insuranceId, completion: completion)
            }
        )
        controller.output = .init(
            showFilters: showYearFilters,
            buyPackages: {
                self.showDayPackages(insuranceId: insuranceId)
            }
        )
        createAndShowNavigationController(viewController: controller, mode: .push)
    }

    private func showYearFilters(_ years: [Int], completion: @escaping (Int) -> Void) {
        let controller: VzrOnOffYearsFilterViewController = storyboard.instantiate()
        container?.resolve(controller)
        controller.input = .init(years: years)
        controller.output = .init(
            selectYear: { year in
                self.navigationController?.popViewController(animated: true)
                completion(year)
            }
        )
        createAndShowNavigationController(viewController: controller, mode: .push)
    }

    private func showPurchasePackage(url: URL, package: VzrOnOffPurchaseItem, insuranceId: String) {
        let controller = PurchaseTimeWebViewController()
        container?.resolve(controller)
        controller.input = .init(url: url)
        controller.output = .init(
            showOperationStatus: { success in
                self.showOperationStatus(success: success, package: package, insuranceId: insuranceId)
            }
        )
        controller.addCloseButton { [unowned controller] in
            controller.presentingViewController?.dismiss(animated: true)
            self.navigationController?.popToRootViewController(animated: true)
        }
        createAndShowNavigationController(viewController: controller, mode: .modal)
    }

    private func showOperationStatus(success: Bool, package: VzrOnOffPurchaseItem, insuranceId: String) {
        let controller: ViewController = .init()
        container?.resolve(controller)
        let operationStatusView: OperationStatusView = .init()
        controller.view.addSubview(operationStatusView)
        NSLayoutConstraint.activate(NSLayoutConstraint.fill(view: operationStatusView, in: controller.view))
        controller.navigationItem.hidesBackButton = success
        controller.navigationController?.interactivePopGestureRecognizer?.isEnabled = !success
        let title: String
        let description: String
        let state: OperationStatusView.State
        var buttons: [OperationStatusView.ButtonConfiguration] = []
        if success {
            title = NSLocalizedString("vzr_on_off_purchase_time_status_success", comment: "")
            let format = NSLocalizedString(
                "vzr_on_off_purchase_time_status_success_description", comment: "")
            let daysString = AppLocale.days(from: package.days) ?? ""
            let currencyString = AppLocale.price(from: NSNumber(value: package.currencyPrice), currencyCode: package.currency)
            description = String(format: format, daysString, currencyString)
            state = .info(.init(
					title: title,
					description: description,
					icon: .Icons.tick.resized(newWidth: 54)?.withRenderingMode(.alwaysTemplate)
			))
            buttons = [
                .init(
                    title: NSLocalizedString("common_to_main_screen", comment: ""),
                    isPrimary: false,
                    action: {
                        ApplicationFlow.shared.show(item: .tabBar(.home))
                    }
                ),
                .init(
                    title: NSLocalizedString("common_done_button", comment: ""),
                    isPrimary: true,
                    action: {
                        self.navigationController?.popToRootViewController(animated: true)
                    }
                )
            ]
        } else {
            title = NSLocalizedString("vzr_on_off_purchase_time_status_failure", comment: "")
            description = NSLocalizedString("vzr_on_off_purchase_time_status_failure_description", comment: "")
            state = .info(.init(title: title, description: description, icon: UIImage(named: "icon-common-failure")))
            buttons = [
                .init(
                    title: NSLocalizedString("vzr_on_off_purchase_time_retry_payment", comment: ""),
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

    private func showStartTripStepOne(insuranceId: String) {
        let controller: VzrOnOffStartTripStepOneViewController = storyboard.instantiate()
        container?.resolve(controller)
        controller.input = .init(
            dashboard: { completion in
                self.vzrOnOffService.dashboard(insuranceId: insuranceId, completion: completion)
            },
            insurance: { completion in
                self.insurancesService.insurance(useCache: true, id: insuranceId, completion: completion)
            }
        )
        controller.output = .init(
            selectTripPeriod: { [weak self] initialRange, completion in
                self?.showCalendar(initialRange: initialRange, completion: completion)
            },
            proceed: { tripPeriod in
                self.showFinalTerms(insuranceId: insuranceId, startDate: tripPeriod.startDate, endDate: tripPeriod.endDate,
                    tripDaysCount: tripPeriod.duration)
            },
            buyDays: {
                self.showDayPackages(insuranceId: insuranceId)
            },
            buyPolicy: { [weak controller] in
                guard let controller = controller else { return }

                self.buyNewInsurance(insuranceId, from: controller)
            },
            about: {
                self.showAbout(insuranceId: insuranceId)
            }
        )
        createAndShowNavigationController(viewController: controller, mode: .push)
    }

    private func showCalendar(initialRange: DateRange? = nil, completion: @escaping (DateRange) -> Void) {
        let controller: RangeCalendarViewController = storyboard.instantiate()
        container?.resolve(controller)
        controller.input = .init(inputPickedRange: initialRange, startingDate: Date(), calendarInterval: nil, pickedRangeLengthMin: 2,
            pickedRangeLengthMax: nil, theme: .themeDefault)
        controller.output = .init(selectedRange: { [weak self] dateRange in
            completion(dateRange)
            self?.close()
        })
        controller.addCloseButton {
            self.close()
        }
        createAndShowNavigationController(viewController: controller, mode: .modal)
    }

    private func showTripHistory(insuranceId: String) {
        let controller: VzrOnOffTripHistoryViewController = storyboard.instantiate()
        container?.resolve(controller)
        controller.input = .init(
            history: { completion in
                self.vzrOnOffService.tripsHistory(insuranceId: insuranceId, completion: completion)
            }
        )
        controller.output = .init(
            startNewTrip: { self.showStartTripStepOne(insuranceId: insuranceId) },
            showFilters: showYearFilters
        )
        createAndShowNavigationController(viewController: controller, mode: .push)
    }

    private func showAbout(insuranceId: String) {
        let controller: VzrOnOffAboutViewController = storyboard.instantiate()
        container?.resolve(controller)
        controller.input = .init(landingUrl: vzrOnOffService.landingUrl)
        controller.output = .init(
            details: showProgramLanding(_:),
            buyPolicy: { [weak controller] in
                guard let controller = controller else { return }

                self.buyNewInsurance(insuranceId, from: controller)
            }
        )
        controller.addCloseButton {
            self.close()
        }
        createAndShowNavigationController(viewController: controller, mode: .modal)
    }

    private func showFinalTerms(insuranceId: String, startDate: Date, endDate: Date, tripDaysCount: Int) {
        let controller: VzrOnOffFinalTermsViewController = storyboard.instantiate()
        container?.resolve(controller)
        controller.input = .init(
            insuredPersonName: { completion in
                self.insurancesService.insurance(useCache: true, id: insuranceId) { result in
                    switch result {
                        case .success(let insurance):
                            completion(.success(insurance.insuredObjectTitle))
                        case .failure(let error):
                            completion(.failure(error))
                    }
                }
            },
            programTerms: { completion in
                self.vzrOnOffService.programTerms(insuranceId: insuranceId, completion: completion)
            },
            tripDaysCount: tripDaysCount,
            startDate: startDate,
            endDate: endDate
        )
        controller.output = .init(
            activate: {
                self.showActivateTrip(insuranceId: insuranceId, startDate: startDate, endDate: endDate)
            }
        )
        createAndShowNavigationController(viewController: controller, mode: .push)
    }

    private func showActivateTrip(insuranceId: String, startDate: Date, endDate: Date) {
        let controller: ViewController = .init()
        container?.resolve(controller)
        let operationStatusView: OperationStatusView = .init()
        controller.view.addSubview(operationStatusView)
        NSLayoutConstraint.activate(NSLayoutConstraint.fill(view: operationStatusView, in: controller.view))
        operationStatusView.notify.updateState(
            .loading(.init(title: NSLocalizedString("vzr_activate_trip_loading_text", comment: ""), description: nil, icon: nil))
        )
        controller.navigationItem.hidesBackButton = true
        controller.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        func activate() {
            vzrOnOffService.activateTrip(
                insuranceId: insuranceId,
                startDate: startDate,
                endDate: endDate
            ) { [unowned controller] result in
                switch result {
                    case .success(let response):
                        controller.navigationItem.hidesBackButton = true
                        controller.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
                        operationStatusView.notify.updateState(
                            .info(
                                .init(
                                    title: NSLocalizedString("vzr_activate_trip_success_title", comment: ""),
                                    description: response.message,
                                    icon: .Icons.tick.resized(newWidth: 54)?.withRenderingMode(.alwaysTemplate)
                                )
                            )
                        )
                        operationStatusView.notify.buttonConfiguration(
                            [
                                .init(
                                    title: NSLocalizedString("common_view_insurance", comment: ""),
                                    isPrimary: false,
                                    action: { [unowned controller] in
                                        self.viewInsurancePolicy(insuranceId, from: controller)
                                    }
                                ),
                                .init(
                                    title: NSLocalizedString("common_done_button", comment: ""),
                                    isPrimary: true,
                                    action: {
                                        self.navigationController?.popToRootViewController(animated: true)
                                    }
                                )
                            ]
                        )
                    case .failure(let error):
                        controller.navigationItem.hidesBackButton = false
                        controller.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
                        operationStatusView.notify.updateState(
                            .info(
                                .init(
                                    title: NSLocalizedString("vzr_activate_trip_failure_title", comment: ""),
                                    description: error.displayValue ?? NSLocalizedString("common_error_unknown_error", comment: ""),
                                    icon: UIImage(named: "icon_common_data_error")
                                )
                            )
                        )
                        operationStatusView.notify.buttonConfiguration(
                            [
                                .init(
                                    title: NSLocalizedString("common_to_main_screen", comment: ""),
                                    isPrimary: false,
                                    action: {
                                        ApplicationFlow.shared.show(item: .tabBar(.home))
                                    }
                                ),
                                error.apiErrorKind == .noInternetConnection
                                    ? .init(
                                        title: NSLocalizedString("common_retry", comment: ""),
                                        isPrimary: true,
                                        action: activate
                                    )
                                    : .init(
                                        title: NSLocalizedString("common_write_to_chat", comment: ""),
                                        isPrimary: true,
                                        action: { ApplicationFlow.shared.show(item: .tabBar(.chat)) }
                                    )
                            ]
                        )
                }
            }
        }
        activate()
        createAndShowNavigationController(viewController: controller, mode: .push)
    }

    private func viewInsurancePolicy(_ insuranceId: String, from viewController: ViewController) {
        let hide = viewController.showLoadingIndicator(message: nil)
        insurancesService.insurance(useCache: true, id: insuranceId) { [unowned viewController] result in
            hide {}
            switch result {
                case .success(let insurance):
                    guard let url = insurance.pdfURL else { return }

                    WebViewer.openDocument(url, showShareButton: false, from: viewController)
                case .failure(let error):
                    ErrorHelper.show(error: error, alertPresenter: self.alertPresenter)
            }
        }
    }

    private func showProgramLanding(_ url: URL) {
        SafariViewController.open(url, from: topModalController)
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
}
