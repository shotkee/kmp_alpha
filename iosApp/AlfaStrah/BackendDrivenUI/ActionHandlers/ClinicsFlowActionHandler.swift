//
//  ClinicsFlowActionHandler.swift
//  AlfaStrah
//
//  Created by vit on 06.03.2025.
//  Copyright © 2025 Touch Instinct. All rights reserved.
//

extension BDUI {
	class ClinicsFlowActionHandler: ActionHandler<ClinicsFlowActionDTO>,
									AlertPresenterDependency,
									InsurancesServiceDependency {
		var alertPresenter: AlertPresenter!
		var insurancesService: InsurancesService!
		
		required init(
			block: ClinicsFlowActionDTO
		) {
			super.init(block: block)
			
			work = { from, _, syncCompletion in
				guard let insuranceId = block.insuranceId
				else {
					syncCompletion()
					return
				}
				
				let flow = ClinicAppointmentFlow(rootController: from)
				ApplicationFlow.shared.container.resolve(flow)
				
				if let filterId = block.filterId {
					self.insurancesService.insurance(useCache: true, id: insuranceId) { [weak from] result in
						guard let from
						else {
							syncCompletion()
							return
						}
						
						switch result {
							case .success(let insurance):
								flow.showClinicsWithFilterId(filterId, for: insurance, mode: .push)
								
							case .failure(let error):
								ErrorHelper.show(error: error, alertPresenter: self.alertPresenter)
								
						}
						syncCompletion()
					}
					
				} else {
					flow.start(insuranceId: insuranceId, mode: .push)
					syncCompletion()
				}
			}
		}
	}
}
