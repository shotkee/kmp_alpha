//
//  RemontNeighboursRenewFlow.swift
//  AlfaStrah
//
//  Created by Amir Nuriev on 6/11/19.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

import UIKit
import Legacy

class RemontNeighboursRenewFlow: DependencyContainerDependency, InsurancesServiceDependency, LoggerDependency, AlertPresenterDependency {
    private let storyboard = UIStoryboard(name: "RemontNeighboursRenewInsuranceFlow", bundle: nil)

    private weak var initialViewController: UINavigationController?
    private var insurance: Insurance?
    var container: DependencyInjectionContainer?
    var alertPresenter: AlertPresenter!
    var insurancesService: InsurancesService!
    var logger: TaggedLogger?

    deinit {
        logger?.debug("")
    }

    func start(
        from controller: UIViewController,
        insurance: Insurance,
        showMode: ViewControllerShowMode = .push
    ) {
        guard let category = insurancesService.cachedInsuranceCategories()
            .first(where: { $0.productIds.contains(insurance.productId) })
        else { return }
        
        self.insurance = insurance
        let renewCtrl = renewInfoViewController()
        renewCtrl.set(
            proceedToPayment: { url in
                self.proceedToPayment(url: url)
            },
            errorEncountered: { [weak renewCtrl] error in
                guard let renewCtrl = renewCtrl else { return }

                let unavailableController = self.renewUnavailableController()
                let navigationController = RMRNavigationController(rootViewController: unavailableController)
                navigationController.strongDelegate = RMRNavigationControllerDelegate()
                unavailableController.addCloseButton {
                    self.initialViewController?.popViewController(animated: false)
                    unavailableController.presentingViewController?.dismiss(animated: true)
                }
                renewCtrl.present(navigationController, animated: true) {
                    ErrorHelper.show(error: error, alertPresenter: self.alertPresenter)
                }
                ErrorHelper.show(error: error, alertPresenter: self.alertPresenter)
            }
        )
        renewCtrl.set(insurance: insurance, category: category)
        
        initialViewController = controller.navigationController
        switch showMode {
            case .push:
                initialViewController?.pushViewController(renewCtrl, animated: true)
            case .modal:
                initialViewController?.present(renewCtrl, animated: true)
        }
    }

    private func renewInfoViewController() -> RemontNeighboursRenewViewController {
        let controller: RemontNeighboursRenewViewController = storyboard.instantiate()
        container?.resolve(controller)
        return controller
    }

    private func renewUnavailableController() -> RemontNeighboursRenewUnavailableViewController {
        let controller: RemontNeighboursRenewUnavailableViewController = storyboard.instantiate()
        container?.resolve(controller)
        controller.output = .init(
            call: {
                guard let insurance = self.insurance else { return }

                PhoneHelper.handlePhone(
                    plain: insurance.emergencyPhone.plain,
                    humanReadable: insurance.emergencyPhone.humanReadable
                )
            },
            chat: {
                ApplicationFlow.shared.show(item: .tabBar(.chat))
            },
            prolong: {
                ApplicationFlow.shared.show(item: .tabBar(.chat))
            },
            toMainScreen: {
                ApplicationFlow.shared.show(item: .tabBar(.home))
            }
        )
        return controller
    }

    private func proceedToPayment(url: URL) {
        guard let controller = SafariViewController.viewController(for: url) else { return }

        initialViewController?.present(controller, animated: true) {
            self.initialViewController?.popViewController(animated: false)
        }
    }
}
