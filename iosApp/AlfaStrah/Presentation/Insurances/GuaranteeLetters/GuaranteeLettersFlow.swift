//
//  GuaranteeLettersFlow.swift
//  AlfaStrah
//
//  Created by Vyacheslav Shakaev on 08.04.2022.
//  Copyright © 2022 Touch Instinct. All rights reserved.
//

import UIKit
import Legacy

class GuaranteeLettersFlow: BaseFlow,
							GuaranteeLettersServiceDependency,
							InsurancesServiceDependency {
    var guaranteeLettersService: GuaranteeLettersService!
	var insurancesService: InsurancesService!

    private let storyboard = UIStoryboard(name: "GuaranteeLetters", bundle: nil)

    func showGuaranteeLetters(insurance: Insurance, from: ViewController) {
        let hide = from.showLoadingIndicator(message: nil)
        guaranteeLettersService.guaranteeLetters(insuranceId: insurance.id) { result in
            hide(nil)
            switch result {
                case .success(let guaranteeLetters):
                    let guaranteeLettersViewController = self.createGuaranteeLettersViewController(
                        for: insurance,
                        with: guaranteeLetters,
                        from: from
                    )
                    
                    self.createAndShowNavigationController(
                        viewController: guaranteeLettersViewController,
                        mode: .push
                    )
                case .failure(let error):
                    ErrorHelper.show(error: error, alertPresenter: self.alertPresenter)
            }
        }
    }
	
	func createGuaranteeLetters(
		insurance: Insurance,
		from: ViewController,
		completion: @escaping (Result<ViewController, AlfastrahError>) -> Void
	) {
		let hide = from.showLoadingIndicator(message: nil)
		
		guaranteeLettersService.guaranteeLetters(insuranceId: insurance.id) { result in
			hide(nil)
			switch result {
				case .success(let guaranteeLetters):
					let guaranteeLettersViewController = self.createGuaranteeLettersViewController(
						for: insurance,
						with: guaranteeLetters,
						from: from
					)
					
					completion(.success(guaranteeLettersViewController))
					
				case .failure(let error):
					completion(.failure(error))
					
					ErrorHelper.show(error: error, alertPresenter: self.alertPresenter)
			}
		}
	}
    
    private func createGuaranteeLettersViewController(
        for insurance: Insurance,
        with guaranteeLeters: [GuaranteeLetter],
        from: ViewController
    ) -> GuaranteeLettersViewController {
        let viewController: GuaranteeLettersViewController = storyboard.instantiate()
        container?.resolve(viewController)
        
        viewController.input = .init(
            insurance: insurance,
            guaranteeLetters: guaranteeLeters
        )

        viewController.output = .init(
            downloadGuaranteeLetter: { [weak viewController] guaranteeLetterUrl in
                guard let controller = viewController else { return }

                WebViewer.openDocument(guaranteeLetterUrl, from: controller)
            },
            requestGuaranteeLetter: { [weak from] in
                from?.dismiss(
                    animated: true,
                    completion: {
                        ApplicationFlow.shared.switchTab(to: .chat)
                    }
                )
				
				if let analyticsData = analyticsData(
					from: self.insurancesService.cachedShortInsurances(forced: true),
					for: insurance.id
				) {
					self.analytics.track(
						navigationSource: AnalyticsParam.NavigationSource.dmsDetails,
						insuranceId: insurance.id,
						event: AnalyticsEvent.Dms.guaranteeLetters,
						userProfileProperties: analyticsData.analyticsUserProfileProperties
					)
				}
            },
            showFiltersScreen: { [weak viewController] in
                guard let presentingVC = viewController else { return }

                self.presentFiltersScreen(
                    from: presentingVC,
                    initialFilters: presentingVC.activeFilters,
                    applyFilters: { [weak viewController] filters in
                        viewController?.applyFilters(filters)
                    }
                )
            }
        )
        
        return viewController
    }

    private func presentFiltersScreen(
        from presentingVC: UIViewController,
        initialFilters: [GuaranteeLetter.Status],
        applyFilters: @escaping ([GuaranteeLetter.Status]) -> Void
    ) {
        let viewController: GuaranteeLetterFiltersViewController = storyboard.instantiate()
        viewController.addCloseButton { [weak viewController] in
            viewController?.dismiss(animated: true, completion: nil)
        }

        viewController.input = .init(
            activeFilters: initialFilters
        )
        viewController.output = .init(
            resetFilters: { [weak viewController] in
                applyFilters([])
                viewController?.dismiss(animated: true, completion: nil)
            },
            applyFilters: { [weak viewController] filters in
                applyFilters(filters)
                viewController?.dismiss(animated: true, completion: nil)
            }
        )

        createAndShowNavigationController(
            viewController: viewController,
            mode: .modal
        )
    }
}
