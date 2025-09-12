//
//  ActivateProductFlow.swift
//  AlfaStrah
//
//  Created by Amir Nuriev on 4/19/19.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

import UIKit
import Legacy

class ActivateProductFlow: AccountServiceDependency, AlertPresenterDependency, LoggerDependency, InsurancesServiceDependency {
    private enum Constants {
        static let steps: [String] = [
            String(describing: OwnershipViewController.self),
            String(describing: DealersListViewController.self),
            String(describing: ActivateInsuranceInfoViewController.self),
            String(describing: InsurerInfoViewController.self)
        ]
        static func stepNumber(viewController: AnyClass) -> Int? {
            if let index = steps.firstIndex(of: String(describing: viewController.self)) {
                return Int(index) + 1
            }
            return nil
        }
    }

    var accountService: AccountService!
    var alertPresenter: AlertPresenter!
    var logger: TaggedLogger?
    var insurancesService: InsurancesService!
    private weak var initialViewController: UINavigationController?

    private let disposeBag: DisposeBag = DisposeBag()
    private let storyboard: UIStoryboard = UIStoryboard(name: "ActivateProduct", bundle: nil)
    private var insuranceInfo: InsuranceActivateInsuranceInfo?
    private var ownershipType: OwnershipType?
    private var dealerId: String?
    private var dealers: [InsuranceDealer] = []
    private var insurerInfo: InsuranceParticipant?

    deinit {
        logger?.debug("")
    }

    func startModally(from controller: UIViewController) {
        let navigationController = RMRNavigationController()
        navigationController.strongDelegate = RMRNavigationControllerDelegate()
        initialViewController = navigationController
        let ownershipVC = createOwnershipViewController()
        ownershipVC.addCloseButton { [weak ownershipVC] in
            ownershipVC?.presentingViewController?.dismiss(animated: true)
        }
        initialViewController?.setViewControllers([ ownershipVC ], animated: false)
        guard let initialViewController = initialViewController else { return }

        controller.present(initialViewController, animated: true)
    }

    private func createOwnershipViewController() -> ViewController {
        guard let indexOfStep = Constants.stepNumber(viewController: OwnershipViewController.self) else {
            fatalError("Inconsistent Configuration!")
        }

        let viewController: OwnershipViewController = storyboard.instantiate()
        viewController.input = .init(
            stepsCount: Constants.steps.count,
            currentStepIndex: indexOfStep
        )
        viewController.output = .init(
            dealers: { ownershipType in
                self.ownershipType = ownershipType
                self.showDealers(ownershipType)
            }
        )
        return viewController
    }

    private func showDealers(_ ownershipType: OwnershipType) {
        guard let indexOfStep = Constants.stepNumber(viewController: DealersListViewController.self) else {
            fatalError("Inconsistent Configuration!")
        }

        let viewController: DealersListViewController = storyboard.instantiate()
        viewController.input = .init(
            stepsCount: Constants.steps.count,
            currentStepIndex: indexOfStep,
            getDealers: { [weak viewController] completion in
                let hide = viewController?.showLoadingIndicator(message: nil)
                self.insurancesService.insuranceProductDealers(ownershipType: ownershipType) { result in
                    hide?(nil)
                    switch result {
                        case .success(let dealers):
                            self.dealers = dealers
                            completion(dealers)
                        case .failure(let error):
                            ErrorHelper.show(error: error, alertPresenter: self.alertPresenter)
                    }
                }
            }
        )
        viewController.output = .init(
            showDealerWithId: { dealerId in
                self.dealerId = dealerId
                self.showDealer()
            }
        )
        initialViewController?.pushViewController(viewController, animated: true)
    }

    private func showDealer() {
        guard let indexOfStep = Constants.stepNumber(viewController: ActivateInsuranceInfoViewController.self) else {
            fatalError("Inconsistent Configuration!")
        }

        let viewController: ActivateInsuranceInfoViewController = storyboard.instantiate()
        viewController.input = .init(
            stepsCount: Constants.steps.count,
            currentStepIndex: indexOfStep,
            minimumDate: AppLocale.calendar.date(byAdding: .year, value: -29, to: Date()) ?? Date()
        )
        viewController.output = .init(
            showPrices: { completion in
                self.showPrices(completion: completion)
            },
            continueWithInsuranceInfo: { insuranceInfo in
                self.insuranceInfo = insuranceInfo
                self.showInsurerInfo()
            }
        )
        initialViewController?.pushViewController(viewController, animated: true)
    }

    private func showPrices(completion: @escaping (Money) -> Void) {
        let viewController: InsurancePricesViewController = storyboard.instantiate()
        viewController.input = .init(
            prices: { [weak viewController] completion in
                guard let dealerId = self.dealerId else { return }

                let hide = viewController?.showLoadingIndicator(message: nil)
                self.insurancesService.insuranceProductDealerPrices(dealerId: dealerId) { result in
                    hide?(nil)
                    switch result {
                        case .success(let prices):
                            completion(prices)
                        case .failure(let error):
                            ErrorHelper.show(error: error, alertPresenter: self.alertPresenter)
                    }
                }
            }
        )
        viewController.output = .init(
            selectPrice: { [weak viewController] money in
                viewController?.navigationController?.popViewController(animated: true)
                completion(money)
            }
        )
        initialViewController?.pushViewController(viewController, animated: true)
    }

    private func showInsurerInfo() {
        guard let indexOfStep = Constants.stepNumber(viewController: InsurerInfoViewController.self) else {
            fatalError("Inconsistent Configuration!")
        }
        
        guard accountService.isAuthorized
        else { return }
                
        guard let initialViewController = initialViewController
        else { return }

        let hide = initialViewController.showLoadingIndicator(
            message: NSLocalizedString("common_loading_title",
            comment: "")
        )
        accountService.getAccount(useCache: true) { [weak initialViewController] result in
            hide(nil)
            guard let initialViewController = initialViewController
            else { return }
               
            switch result {
               case .success(let userAccount):
                    let viewController: InsurerInfoViewController = self.storyboard.instantiate()
                    viewController.input = .init(
                        stepsCount: Constants.steps.count,
                        currentStepIndex: indexOfStep,
                        minimumDate: AppLocale.calendar.date(byAdding: .year, value: -100, to: Date()) ?? Date(),
                        account: userAccount
                    )
                    viewController.output = .init(
                        continueWithInsurerInfo: { insurerInfo in
                            guard
                                let insuranceInfo = self.insuranceInfo,
                                let ownershipType = self.ownershipType,
                                let dealer = self.dealers.first(where: { $0.id == self.dealerId })
                            else {
                                return
                            }

                            self.insurerInfo = insurerInfo
                            let hide = viewController.showLoadingIndicator(message: nil)
                            self.insurancesService.activateBoxProduct(
                                InsuranceActivateRequest(
                                    price: insuranceInfo.price,
                                    number: insuranceInfo.insuranceNumber,
                                    purchaseDate: insuranceInfo.purchaseDate,
                                    purchaseLocation: dealer.title,
                                    ownershipType: ownershipType,
                                    insurer: insurerInfo
                                )
                            ) { result in
                                hide(nil)
                                switch result {
                                    case .success(let response):
                                        if response.success {
                                            let alert = BasicNotificationAlert(
                                                text: response.message ?? NSLocalizedString("common_success", comment: "")
                                            )
                                            self.alertPresenter.show(alert: alert)
                                            self.initialViewController?.presentingViewController?.dismiss(animated: true)
                                        } else {
                                            ErrorHelper.show(error: nil, text: response.message, alertPresenter: self.alertPresenter)
                                        }
                                    case .failure(let error):
                                        ErrorHelper.show(error: error, alertPresenter: self.alertPresenter)
                                }
                            }
                        }
                    )
                    initialViewController.pushViewController(viewController, animated: true)
               case .failure(let error):
                    ErrorHelper.show(error: error, alertPresenter: self.alertPresenter)
            }
        }
    }
}
