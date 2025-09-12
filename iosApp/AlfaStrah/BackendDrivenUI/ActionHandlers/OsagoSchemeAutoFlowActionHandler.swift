//
//  OsagoSchemeAutoFlowActionHandler.swift
//  AlfaStrah
//
//  Created by vit on 06.03.2025.
//  Copyright © 2025 Touch Instinct. All rights reserved.
//

extension BDUI {
	class OsagoSchemeAutoFlowActionHandler: ActionHandler<OsagoSchemeAutoFlowActionDTO> {
		required init(
			block: OsagoSchemeAutoFlowActionDTO
		) {
			super.init(block: block)
			
			work = { from, replaceFormData, syncCompletion in
				guard let picker = block.picker
				else {
					syncCompletion()
					return
				}
				
				self.showAutoEventDamagedPartsSheet(
					picker: picker,
					from: from
				) { [ weak from ] ids in
					guard let from
					else { return }
										
					replaceFormData(ids)
				}
				
				syncCompletion()
			}
		}
		
		// MARK: - Osago Auto Event
		private func showAutoEventDamagedPartsSheet(
			picker: OsagoSchemeAutoPickerComponentDTO?,
			from: ViewController,
			completion: @escaping ([Int]) -> Void
		) {
			let viewController = AutoEventDetailsPickerViewController()
			ApplicationFlow.shared.container.resolve(viewController)
			
			viewController.input = .init(
				picker: picker
			)
			
			viewController.output = .init(
				partsSelected: { [weak viewController] selectedParts in
					let partsIds = selectedParts.compactMap { $0.id }
					
					viewController?.dismiss(animated: true) {
						completion(partsIds)
					}
				}
			)
			
			let navigationController = RMRNavigationController(rootViewController: viewController)
			navigationController.strongDelegate = RMRNavigationControllerDelegate()
			
			viewController.addCloseButton(position: .right) { [weak viewController] in
				viewController?.dismiss(animated: true)
			}
			
			from.present(
				navigationController,
				animated: true
			)
		}
	}
}
