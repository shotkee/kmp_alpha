//
//  FranchiseFlowActionHandler.swift
//  AlfaStrah
//
//  Created by vit on 06.03.2025.
//  Copyright © 2025 Touch Instinct. All rights reserved.
//

extension BDUI {
	class FranchiseFlowActionHandler: ActionHandler<FranchiseFlowActionDTO>,
									  AlertPresenterDependency,
									  InsurancesServiceDependency {
		var alertPresenter: AlertPresenter!
		var insurancesService: InsurancesService!
		
		required init(
			block: FranchiseFlowActionDTO
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
		
					self.showFranchiseTransition(insurance: insurance, from: from)
					
					syncCompletion()
				}
				
				syncCompletion()
			}
		}
		
		private func showFranchiseTransition(insurance: Insurance, from: UIViewController) {
			let franchiseTransitionFlow = FranchiseTransitionFlow(rootController: from)
			ApplicationFlow.shared.container.resolve(franchiseTransitionFlow)
			franchiseTransitionFlow.showFranchiseTransitionScreen(insuranceId: insurance.id)
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
	}
	
}
