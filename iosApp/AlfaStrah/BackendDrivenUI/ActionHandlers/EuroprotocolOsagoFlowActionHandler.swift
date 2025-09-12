//
//  EuroprotocolOsagoFlowActionHandler.swift
//  AlfaStrah
//
//  Created by vit on 06.03.2025.
//  Copyright © 2025 Touch Instinct. All rights reserved.
//

extension BDUI {
	class EuroprotocolOsagoFlowActionHandler: ActionHandler<EuroprotocolOsagoFlowActionDTO>,
											  AlertPresenterDependency,
											  EventReportServiceDependency,
											  InsurancesServiceDependency {
		var alertPresenter: AlertPresenter!
		var eventReportService: EventReportService!
		var insurancesService: InsurancesService!
		
		required init(
			block: EuroprotocolOsagoFlowActionDTO
		) {
			super.init(block: block)
			
			work = { from, _, syncCompletion in
				guard let insuranceId = block.insuranceId
				else {
					syncCompletion()
					return
				}
				
				self.showEuroProtocol(for: insuranceId, from: from)
					
				syncCompletion()
			}
		}
		
		private func showEuroProtocol(for insuranceId: String, from: ViewController) {
			insurancesService.insurance(useCache: true, id: insuranceId) { result in
				switch result {
					case .success(let insurance):
						let createAutoEventFlow = CreateAutoEventFlow()
						ApplicationFlow.shared.container.resolve(createAutoEventFlow)
						
						let draftKind = self.eventReportService
							.autoEventDrafts()
							.first { $0.insuranceId == insuranceId }
							.map(InsuranceEventFlow.DraftKind.autoDraft)
						
						if case .autoDraft(let draft) = draftKind {
							createAutoEventFlow.showEuroProtocol(with: insuranceId, from: from, draft: draft, isModal: true)
						} else {
							createAutoEventFlow.showEuroProtocol(with: insuranceId, from: from, draft: nil, isModal: true)
						}
						
					case .failure(let error):
						ErrorHelper.show(error: error, alertPresenter: self.alertPresenter)
				}
			}
		}
	}
}
