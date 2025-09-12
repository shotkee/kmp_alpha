//
//  GaranteeLettersActionHandler.swift
//  AlfaStrah
//
//  Created by vit on 06.03.2025.
//  Copyright © 2025 Touch Instinct. All rights reserved.
//

extension BDUI {
	class GaranteeLettersActionHandler: ActionHandler<GaranteeLettersActionDTO>,
										AlertPresenterDependency,
										InsurancesServiceDependency {
		var alertPresenter: AlertPresenter!
		var insurancesService: InsurancesService!
		
		required init(
			block: GaranteeLettersActionDTO
		) {
			super.init(block: block)
			
			work = { from, _, syncCompletion in
				guard let insuranceId = block.insuranceId
				else {
					syncCompletion()
					return
				}
				
				self.insurancesService.insurance(useCache: true, id: insuranceId) { [weak from] result in
					guard let from
					else {
						syncCompletion()
						return
					}

					switch result {
						case .success(let insurance):
							let guaranteeLettersFlow = GuaranteeLettersFlow(rootController: from)
							ApplicationFlow.shared.container.resolve(guaranteeLettersFlow)

							guaranteeLettersFlow.createGuaranteeLetters(
								insurance: insurance,
								from: from
							) { result in
								switch result {
									case .success(let guaranteLEttersController):
										from.navigationController?.pushViewController(guaranteLEttersController, animated: true)
									case .failure:
										break
								}

								syncCompletion()
							}

						case .failure(let error):
							ErrorHelper.show(error: error, alertPresenter: self.alertPresenter)

							syncCompletion()
					}
				}
			}
		}
	}
}
