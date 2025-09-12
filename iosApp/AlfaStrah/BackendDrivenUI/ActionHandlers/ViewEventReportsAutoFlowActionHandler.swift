//
//  ViewEventReportsAutoFlowActionHandler.swift
//  AlfaStrah
//
//  Created by vit on 06.03.2025.
//  Copyright © 2025 Touch Instinct. All rights reserved.
//

extension BDUI {
	class ViewEventReportsAutoFlowActionHandler: ActionHandler<ViewEventReportsAutoFlowActionDTO>,
												 AlertPresenterDependency,
												 InsurancesServiceDependency {
		var alertPresenter: AlertPresenter!
		var insurancesService: InsurancesService!
		
		required init(
			block: ViewEventReportsAutoFlowActionDTO
		) {
			super.init(block: block)
			
			work = { from, _, syncCompletion in
				self.showAutoEvents(from: from)

				syncCompletion()
			}
		}
		
		private func showAutoEvents(from: ViewController) {
			insurancesService.insurances(useCache: true) { result in
				switch result {
					case .success(let shortInsurances):
						if let category = shortInsurances.insuranceGroupList.flatMap({ $0.insuranceGroupCategoryList })
							.first(where: { $0.insuranceCategory.type == .auto }) {
							let eventFlow = InsuranceEventFlow(rootController: from)
							ApplicationFlow.shared.container.resolve(eventFlow)
							eventFlow.showActiveEvents(for: category, from: from)
						} else {
							ErrorHelper.show(error: AlfastrahError.unknownError, alertPresenter: self.alertPresenter)
						}
						
					case .failure(let error):
						ErrorHelper.show(error: error, alertPresenter: self.alertPresenter)
						
				}
			}
		}
	}
}
