//
//  BillsFlowActionHandler.swift
//  AlfaStrah
//
//  Created by vit on 07.03.2025.
//  Copyright © 2025 Touch Instinct. All rights reserved.
//

extension BDUI {
	class BillsFlowActionHandler: ActionHandler<BillsFlowActionDTO>,
								  AlertPresenterDependency,
								  InsurancesServiceDependency {
		var alertPresenter: AlertPresenter!
		var insurancesService: InsurancesService!
		
		required init(
			block: BillsFlowActionDTO
		) {
			super.init(block: block)
			
			work = { from, _, syncCompletion in
				guard let insuranceId = block.insuranceId
				else {
					syncCompletion()
					return
				}
				
				self.insurance(by: insuranceId, from: from) { [weak from] insurance in
					guard let from
					else { return }
					
					self.showInsuranceBills(insurance: insurance, from: from)
					
					syncCompletion()
				}
			}
		}
		
		private func insurance(
			by insuranceId: String,
			from: ViewController,
			completion: @escaping (Insurance) -> Void
		) {
			let hide = from.showLoadingIndicator(message: NSLocalizedString("common_loading_title", comment: ""))
			insurancesService.insurance(useCache: true, id: insuranceId) { result in
				hide(nil)
				switch result {
					case .success(let insurance):
						completion(insurance)
					case .failure(let error):
						ErrorHelper.show(error: error, alertPresenter: self.alertPresenter)
				}
			}
		}
		
		private func showInsuranceBills(insurance: Insurance, from: ViewController) {
			let insuranceBillsFlow = InsuranceBillsFlow(rootController: from)
			ApplicationFlow.shared.container.resolve(insuranceBillsFlow)
			insuranceBillsFlow.showBills(insurance: insurance, from: from)
		}
	}
}
