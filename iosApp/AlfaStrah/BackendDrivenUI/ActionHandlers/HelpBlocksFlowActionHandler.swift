//
//  HelpBlocksFlowActionHandler.swift
//  AlfaStrah
//
//  Created by vit on 06.03.2025.
//  Copyright © 2025 Touch Instinct. All rights reserved.
//

extension BDUI {
	class HelpBlocksFlowActionHandler: ActionHandler<HelpBlocksFlowActionDTO>,
									   AlertPresenterDependency,
									   InsurancesServiceDependency {
		var alertPresenter: AlertPresenter!
		var insurancesService: InsurancesService!
		
		required init(
			block: HelpBlocksFlowActionDTO
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
					else {
						syncCompletion()
						return
					}
			
					self.showInsuranceProgram(insurance: insurance, from: from, insuranceHelpUrl: self.block.url)
				}
				
				syncCompletion()
			}
		}
		
		private func showInsuranceProgram(insurance: Insurance, from: UIViewController, insuranceHelpUrl: URL? = nil) {
			let insuranceProgramFlow = InsuranceProgramFlow(rootController: from)
			ApplicationFlow.shared.container.resolve(insuranceProgramFlow)
			insuranceProgramFlow.show(
				insuranceId: insurance.id,
				insuranceHelpType: insurance.helpType,
				insuranceHelpUrl: {
					if let url = insuranceHelpUrl {
						return url
					}
					return insurance.helpURL
				}()
			)
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
