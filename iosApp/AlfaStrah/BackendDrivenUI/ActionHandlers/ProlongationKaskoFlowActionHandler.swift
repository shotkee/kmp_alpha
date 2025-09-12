//
//  ProlongationKaskoFlowActionHandler.swift
//  AlfaStrah
//
//  Created by vit on 06.03.2025.
//  Copyright © 2025 Touch Instinct. All rights reserved.
//

extension BDUI {
	class ProlongationKaskoFlowActionHandler: ActionHandler<ProlongationKaskoFlowActionDTO>,
											  AlertPresenterDependency,
											  InsurancesServiceDependency {
		var alertPresenter: AlertPresenter!
		var insurancesService: InsurancesService!
		
		required init(
			block: ProlongationKaskoFlowActionDTO
		) {
			super.init(block: block)
			
			work = { from, _, syncCompletion in
				guard let insuranceId = block.insuranceId
				else {
					syncCompletion()
					return
				}
				
				self.prolongForInsurance(with: insuranceId, from: from)
				
				syncCompletion()
			}
		}
		
		private func prolongForInsurance(with insuranceId: String, from: ViewController) {
			guard let insuranceShort = self.insurancesService.cachedShortInsurance(by: insuranceId)
			else { return }
			
			let flow = InsurancesFlow()
			ApplicationFlow.shared.container.resolve(flow)
			
			flow.showRenew(
				insuranceId: insuranceShort.id,
				renewalType: insuranceShort.renewType,
				from: from
			)
		}
	}
}
