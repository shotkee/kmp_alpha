//
//  InsuranceFlowActionHandler.swift
//  AlfaStrah
//
//  Created by vit on 06.03.2025.
//  Copyright © 2025 Touch Instinct. All rights reserved.
//

extension BDUI {
	class InsuranceFlowActionHandler: ActionHandler<InsuranceFlowActionDTO>,
									  AlertPresenterDependency,
									  InsurancesServiceDependency {
		var alertPresenter: AlertPresenter!
		var insurancesService: InsurancesService!
		
		required init(
			block: InsuranceFlowActionDTO
		) {
			super.init(block: block)
			
			work = { from, _, syncCompletion in
				guard let insuranceId = block.insuranceId
				else {
					syncCompletion()
					return
				}
				
				self.showInsurance(with: insuranceId, from: from)

				syncCompletion()
			}
		}
		
		private func showInsurance(with id: String, from: ViewController) {
			let flow = InsurancesFlow()
			ApplicationFlow.shared.container.resolve(flow)
			
			let hide = from.showLoadingIndicator(
				message: NSLocalizedString("common_load", comment: "")
			)
			
			insurancesService.insurance(useCache: true, id: id) { result in
				hide(nil)
				switch result {
					case .success(let insurance):
						flow.showInsurance(id: id, from: from, isModal: true, kind: insurance.type)
					case .failure(let error):
						ErrorHelper.show(error: error, alertPresenter: self.alertPresenter)
				}
			}
		}
	}
}
