//
//  EventReportKaskoFlowActionHandler.swift
//  AlfaStrah
//
//  Created by vit on 06.03.2025.
//  Copyright © 2025 Touch Instinct. All rights reserved.
//

extension BDUI {
	class EventReportKaskoFlowActionHandler: ActionHandler<EventReportKaskoFlowActionDTO>,
											 AlertPresenterDependency,
											 InsurancesServiceDependency {
		var alertPresenter: AlertPresenter!
		var insurancesService: InsurancesService!
		
		required init(
			block: EventReportKaskoFlowActionDTO
		) {
			super.init(block: block)
			
			work = { from, _, syncCompletion in
				guard let insuranceId = block.insuranceId
				else {
					syncCompletion()
					return
				}
				
				self.showAutoEvent(for: insuranceId, from: from)
					
				syncCompletion()
			}
		}
		
		private func showAutoEvent(for insuranceId: String, from: ViewController) {
			let hide = from.showLoadingIndicator(message: NSLocalizedString("common_loading_title", comment: ""))
			insurancesService.insurance(useCache: true, id: insuranceId) { result in
				hide(nil)
				switch result {
					case .success:
						let createAutoEventFlow = CreateAutoEventFlow()
						ApplicationFlow.shared.container.resolve(createAutoEventFlow)
						createAutoEventFlow.start(with: insuranceId, from: from, draft: nil)
						
					case .failure(let error):
						ErrorHelper.show(error: error, alertPresenter: self.alertPresenter)
				}
			}
		}
	}
}
