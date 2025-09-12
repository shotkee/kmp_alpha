//
//  FranchiseTransitionFlow.swift
//  AlfaStrah
//
//  Created by Vyacheslav Shakaev on 07.07.2022.
//  Copyright © 2022 Touch Instinct. All rights reserved.
//

import UIKit
import Legacy

class FranchiseTransitionFlow: BaseFlow, FranchiseTransitionServiceDependency
{
    var franchiseTransitionService: FranchiseTransitionService!

    private let storyboard = UIStoryboard(name: "FranchiseTransition", bundle: nil)

    func showFranchiseTransitionScreen(insuranceId: String)
    {
        let hide = fromViewController.showLoadingIndicator(message: nil)

        franchiseTransitionService.franchiseTransitionData(
            insuranceId: insuranceId
        ) { result in
            hide(nil)

            switch result {
                case .success(let franchiseTransitionData):
                    self.showFranchiseTransitionScreen(
                        for: insuranceId,
                        with: franchiseTransitionData
                    )

                case .failure(let error):
                    self.showError(error)
            }
        }
    }

    private func showFranchiseTransitionScreen(
        for insuranceId: String,
        with franchiseTransitionData: FranchiseTransitionData
    )
    {
        let viewController: FranchiseTransitionViewController = storyboard.instantiate()
        container?.resolve(viewController)

        viewController.input = .init(
            data: franchiseTransitionData
        )
        
        viewController.output = .init(
            changeProgram: { [weak viewController] checkedPersonIds in
                guard let controller = viewController
                else { return }

                self.changeProgram(
                    insuranceId: insuranceId,
                    checkedPersonIds: checkedPersonIds,
                    on: controller
                )
            },
            showProgramTermsPdf: { [weak self] in
                guard let self = self
                else { return }
                
                let url = self.franchiseTransitionService.getUrlForChangeProgramTermsPdf(
                    insuranceId: insuranceId
                )
                
                WebViewer.openDocument(
                    url,
                    withAuthorization: true,
                    from: viewController
                )
            },
            showInsuranceProgramPdf: { [weak self] personId in
                guard let self = self
                else { return }
                
                let url = self.franchiseTransitionService.getUrlForInsuranceProgramPdf(
                    insuranceId: insuranceId,
                    personId: String(personId)
                )
                
                WebViewer.openDocument(
                    url,
                    withAuthorization: true,
                    from: viewController
                )
            },
            showClinicsListPdf: { [weak self] personId in
                guard let self = self
                else { return }

                let url = self.franchiseTransitionService.getUrlForClinicsListPdf(
                    insuranceId: insuranceId,
                    personId: String(personId)
                )
                
                WebViewer.openDocument(
                    url,
                    withAuthorization: true,
                    from: viewController
                )
            }
        )

        createAndShowNavigationController(
            viewController: viewController,
            mode: .push
        )
    }

    private func openProgramTermsPdf(url: URL)
    {
        guard let navigationController = navigationController else { return }

        WebViewer.openDocument(url, from: navigationController)
    }

    private func changeProgram(
        insuranceId: String,
        checkedPersonIds: [Int],
        on viewController: UIViewController
    )
    {
        let hide = viewController.showLoadingIndicator(message: nil)

        franchiseTransitionService.changeProgram(
            insuranceId: insuranceId,
            personIds: checkedPersonIds
        ) { [weak viewController] result in
            hide(nil)

            guard let controller = viewController else {
                return
            }

            switch result {
                case .success(let franchiseTransitionResult):
                    self.showFranchiseTransitionResult(
                        persons: franchiseTransitionResult.persons,
                        successful: franchiseTransitionResult.isSuccessful,
                        resultMessage: franchiseTransitionResult.message,
                        from: controller
                    )

                case .failure(let error):
                    self.showError(error)
            }
        }
    }

    private func showFranchiseTransitionResult(
        persons: [FranchiseTransitionResultInsuredPerson],
        successful: Bool,
        resultMessage: String?,
        from viewController: UIViewController
    )
    {
        guard let navigationController = viewController.navigationController
        else { return }
        
        let resultViewController: FranchiseTransitionResultViewController = storyboard.instantiate()

        container?.resolve(resultViewController)
        
        resultViewController.title = NSLocalizedString("change_insurance_program_screen_title", comment: "")
        
        resultViewController.input = .init(
            persons: persons,
            isFranchiseTransitionSuccessful: successful,
            resultMessage: resultMessage,
            doneButtonTap: { [weak navigationController] in
                guard let navigationController = navigationController
                else { return }
                
                let insuranceVC = navigationController.viewControllers
                    .first(where: { $0 is InsuranceViewController })
                if let insuranceVC = insuranceVC {
                    navigationController.popToViewController(
                        insuranceVC,
                        animated: true
                    )
                } else {
                    ApplicationFlow.shared.show(item: .tabBar(.home))
                }
            }
        )
        
        navigationController.pushViewController(resultViewController, animated: true)
    }
}
