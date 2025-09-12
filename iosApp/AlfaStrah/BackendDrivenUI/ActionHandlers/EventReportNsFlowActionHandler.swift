//
//  EventReportNsFlowActionHandler.swift
//  AlfaStrah
//
//  Created by vit on 06.03.2025.
//  Copyright © 2025 Touch Instinct. All rights reserved.
//

extension BDUI {
	class EventReportNsFlowActionHandler: ActionHandler<EventReportNsFlowActionDTO>,
										  AlertPresenterDependency,
										  InsurancesServiceDependency {
		var alertPresenter: AlertPresenter!
		var insurancesService: InsurancesService!
		
		required init(
			block: EventReportNsFlowActionDTO
		) {
			super.init(block: block)
			
			work = { from, _, syncCompletion in
				guard let insuranceId = block.insuranceId
				else {
					syncCompletion()
					return
				}

				self.showAccidentEventReport(for: insuranceId, from: from)
					
				syncCompletion()
			}
		}
		
		private func showAccidentEventReport(for insuranceId: String, from: ViewController) {
			insurancesService.insurance(useCache: true, id: insuranceId) { result in
				switch result {
					case .success(let insurance):
						let accidentFlow = AccidentEventFlow(rootController: from)
						ApplicationFlow.shared.container.resolve(accidentFlow)
						
						accidentFlow.start(
							insuranceId: insuranceId,
							flowMode: AccidentEventFlow.FlowMode.createNewEvent,
							showMode: ViewControllerShowMode.push
						)
						
					case .failure(let error):
						ErrorHelper.show(error: error, alertPresenter: self.alertPresenter)
						
				}
			}
		}
	}
}
