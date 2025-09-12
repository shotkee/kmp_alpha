//
//  TelemedFlowActionHandler.swift
//  AlfaStrah
//
//  Created by vit on 06.03.2025.
//  Copyright © 2025 Touch Instinct. All rights reserved.
//

extension BDUI {
	class TelemedFlowActionHandler: ActionHandler<TelemedFlowActionDTO>,
									AlertPresenterDependency,
									InsurancesServiceDependency {
		var alertPresenter: AlertPresenter!
		var insurancesService: InsurancesService!
		
		required init(
			block: TelemedFlowActionDTO
		) {
			super.init(block: block)
			
			work = { from, _, syncCompletion in
				guard let insuranceId = block.insuranceId
				else {
					syncCompletion()
					return
				}
				
				self.insurance(by: insuranceId, from: from) { insurance in
					self.showTelemedicineInfo(insurance: insurance, from: from)
					
					syncCompletion()
				}
			}
		}
		
		private func showTelemedicineInfo(insurance: Insurance, from: ViewController) {
			let viewController: TelemedicineInfoViewController =  UIStoryboard(name: "Insurances", bundle: nil).instantiate()
			ApplicationFlow.shared.container.resolve(viewController)
			// swiftlint:disable:next trailing_closure
			viewController.output = TelemedicineInfoViewController.Output(
				telemedicine: { [weak viewController] in
					guard let controller = viewController else { return }
					
					self.showTelemedicine(insurance: insurance, from: controller)
				}
			)
			from.navigationController?.pushViewController(viewController, animated: true)
		}
		
		private func showTelemedicine(insurance: Insurance, from controller: ViewController) {
			let hide = controller.showLoadingIndicator(message: NSLocalizedString("common_loading_title", comment: ""))
			
			insurancesService.telemedicineUrl(insuranceId: insurance.id) { result in
				hide(nil)
				switch result {
					case .success(let url):
						UIApplication.shared.open(url, options: [:], completionHandler: nil)
					case .failure(let error):
						ErrorHelper.show(error: error, alertPresenter: controller.alertPresenter)
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
	}
}
