//
//  VirtualAssistantFlowActionHandler.swift
//  AlfaStrah
//
//  Created by vit on 06.03.2025.
//  Copyright © 2025 Touch Instinct. All rights reserved.
//

extension BDUI {
	class VirtualAssistantFlowActionHandler: ActionHandler<VirtualAssistantFlowActionDTO>,
											 AlertPresenterDependency,
											 InsurancesServiceDependency,
											 InteractiveSupportServiceDependency {
		var alertPresenter: AlertPresenter!
		var insurancesService: InsurancesService!
		var interactiveSupportService: InteractiveSupportService!
		
		required init(
			block: VirtualAssistantFlowActionDTO
		) {
			super.init(block: block)
			
			work = { from, _, syncCompletion in
				guard let insuranceId = block.insuranceId
				else {
					syncCompletion()
					return
				}
				
				let hide = from.showLoadingIndicator(message: NSLocalizedString("common_loading_title", comment: ""))
				self.insurancesService.insurances(useCache: true) { result in
					switch result {
						case .success(let response):
							let insuranceShort = response.insuranceGroupList
								.flatMap { $0.insuranceGroupCategoryList }
								.flatMap { $0.insuranceList }
								.filter { $0.id == insuranceId }.first
							
							if let insuranceShort {
								self.showInteractiveSupport(insurance: insuranceShort, from: from) {
									hide(nil)
								}
							}
							
						case .failure(let error):
							hide(nil)
							ErrorHelper.show(error: error, alertPresenter: self.alertPresenter)
							
					}
					
					syncCompletion()
				}
			}
		}
		
		private func showInteractiveSupport(insurance: InsuranceShort, from: ViewController, completion: @escaping () -> Void) {
			interactiveSupportService.onboarding(insuranceIds: [insurance.id]) { result in
				completion()
				switch result {
					case .success(let data):
						guard let onboardingDataForInsurance = data.first(where: { String($0.insuranceId) == insurance.id })
						else { return }
						
						let interactiveSupportFlow = InteractiveSupportFlow(rootController: from)
						ApplicationFlow.shared.container.resolve(interactiveSupportFlow)
						
						interactiveSupportFlow.start(
							for: insurance,
							with: onboardingDataForInsurance,
							flowStartScreenPresentationType: .fullScreen
						)
					case .failure(let error):
						ErrorHelper.show(error: error, alertPresenter: self.alertPresenter)
				}
			}
		}
	}
}
