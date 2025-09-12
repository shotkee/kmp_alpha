//
//  FindInsuranceFlowActionHadler.swift
//  AlfaStrah
//
//  Created by vit on 06.03.2025.
//  Copyright © 2025 Touch Instinct. All rights reserved.
//

extension BDUI {
	class FindInsuranceFlowActionHadler: ActionHandler<FindInsuranceFlowActionDTO> {
		required init(
			block: FindInsuranceFlowActionDTO
		) {
			super.init(block: block)
			
			work = { from, _, syncCompletion in
				self.searchInsuranceModal(from: from)
				syncCompletion()
			}
		}
		
		private func searchInsuranceModal(from: UIViewController) {
			let storyboard = UIStoryboard(name: "InsuranceSearchRequest", bundle: nil)
			let viewController: CreateInsuranceSearchRequestViewController = storyboard.instantiateInitial()
			ApplicationFlow.shared.container.resolve(viewController)
			
			viewController.addCloseButton { [weak viewController] in
				viewController?.dismiss(animated: true, completion: nil)
			}
			
			let navigationController = RMRNavigationController(rootViewController: viewController)
			navigationController.strongDelegate = RMRNavigationControllerDelegate()
			
			from.present(navigationController, animated: true, completion: nil)
		}
	}
}
