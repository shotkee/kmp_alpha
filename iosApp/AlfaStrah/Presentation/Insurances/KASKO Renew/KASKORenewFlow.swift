//
//  KASKORenewFlow
//  AlfaStrah
//
//  Created by Stanislav Starzhevskiy on 16.10.17.
//  Copyright © 2017 RedMadRobot. All rights reserved.
//

import UIKit
import Legacy

class KASKORenewFlow: BaseFlow, InsurancesServiceDependency {
    private enum Storyboards {
        static let insuranceRenewal = UIStoryboard(name: "KASKORenewInsuranceFlow", bundle: nil)
    }

    var insurancesService: InsurancesService!

    deinit {
        logger?.debug("")
    }

    func start(
        insurance: Insurance,
        renewalType: InsuranceShort.RenewType?
    )
    {
        if let renewalType = renewalType
        {
            renewInsurance(
                insurance: insurance,
                renewalType: renewalType
            )
        }
        else
        {
            getRenewalType(
                insuranceID: insurance.id,
                completion: { result in
                    switch result {
                        case.success(let renewalType):
                            self.renewInsurance(
                                insurance: insurance,
                                renewalType: renewalType
                            )

                        case .failure(let error):
                            self.errorEncountered(error)
                    }
                }
            )
        }
    }

    private func renewInsurance(
        insurance: Insurance,
        renewalType: InsuranceShort.RenewType?
    ) {
        if renewalType == .url {
            renewInsuranceViaWebPage(
                insurance: insurance
            )
        } else {
            renewInsuranceViaNativeScreen(
                insurance: insurance
            )
        }
    }

    private func getRenewalType(
        insuranceID: String,
        completion: @escaping (Result<InsuranceShort.RenewType?, AlfastrahError>) -> Void
    )
    {
        let hide = fromViewController.showLoadingIndicator(
            message: NSLocalizedString("common_loading_title", comment: "")
        )

        insurancesService.insurances(useCache: true) { result in
            hide(nil)

            switch result {
                case .success(let response):
                    let insurance = response.insuranceGroupList
                        .flatMap { $0.insuranceGroupCategoryList }
                        .flatMap { $0.insuranceList }
                        .first(where: { $0.id == insuranceID })
                    completion(.success(insurance?.renewType))

                case .failure(let error):
                    completion(.failure(error))
            }
        }
    }

    private func renewInsuranceViaWebPage(
        insurance: Insurance
    )
    {
        let hide = fromViewController.showLoadingIndicator(
            message: NSLocalizedString("common_loading_title", comment: "")
        )

        insurancesService.insuranceRenewUrl(
            insuranceID: insurance.id
        ) { result in
            hide(nil)

            switch result {
                case .success(let renewURL):
                    self.openWebPage(url: renewURL)

                case .failure(let error):
                    self.errorEncountered(error)
            }
        }
    }

    private func renewInsuranceViaNativeScreen(insurance: Insurance)
    {
        guard
            let category = insurancesService.cachedInsuranceCategories().first(where: { $0.productIds.contains(insurance.productId) })
        else {
            fatalError("Incorrect Configuration!")
        }

        let renewCtrl = kaskoRenewInfoViewController()
        renewCtrl.set(
            proceedToPayment: proceedToPayment,
            errorEncountered: errorEncountered
        )
        renewCtrl.set(insurance: insurance, category: category)
        renewCtrl.addCloseButton { self.close() }
        createAndShowNavigationController(viewController: renewCtrl, mode: .modal)
    }

    private func kaskoRenewInfoViewController() -> KASKORenewInfoViewController {
        guard let controller = Storyboards.insuranceRenewal.instantiateInitialViewController() as? KASKORenewInfoViewController else {
            fatalError("Initial view controller should be KASKORenewInfoViewController")
        }
        container?.resolve(controller)

        controller.output = .init(
            linkTap: { [weak controller] url in
                guard let controller = controller else { return }

                SafariViewController.open(url, from: controller)
            }
        )
        return controller
    }

    private func proceedToPayment(url: URL) {
        guard let controller = SafariViewController.viewController(for: url) else { return }

        fromViewController.dismiss(animated: false) {
            self.fromViewController.present(controller, animated: true)
        }
    }

    private func openWebPage(url: URL)
    {
        SafariViewController.open(url, from: fromViewController)
    }

    private func errorEncountered(_ error: Error?) {
        fromViewController.dismiss(animated: true) {
            guard let controller = self.fromViewController.navigationController?.topViewController as? ViewController else { return }

            controller.processError(error)
        }
    }
}
