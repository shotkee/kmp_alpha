//
//  NavigateBackToActionHandler.swift
//  AlfaStrah
//
//  Created by vit on 06.03.2025.
//  Copyright © 2025 Touch Instinct. All rights reserved.
//

extension BDUI {
	class NavigateBackToActionHandler: ActionHandler<NavigateBackToActionDTO> {
		required init(
			block: NavigateBackToActionDTO
		) {
			super.init(block: block)
			
			work = { from, _, syncCompletion in
				if let screenId = block.screenId {
					BDUI.CommonActionHandlers.shared.navigateBack(to: screenId) {
						syncCompletion()
					}
					
				} else {
					// NB: For sync naviagation-back operations only - we can be sure that the operation has completed synchronously
					// only when the current viewController has been disposed
					
					if let bduiViewController = from as? ScreenBasicViewController {
						bduiViewController.destructCallback = {
							syncCompletion()
						}
					}
					
					if self.isModal ?? false {
						from.dismiss(animated: true) {
							syncCompletion()
						}
					} else {
						if let navigationController = from.navigationController {
							if navigationController.viewControllers.count == 1 {
								from.dismiss(animated: true) {
									syncCompletion()
								}
							} else {
								navigationController.popViewController(animated: true)
								syncCompletion()
							}
						}
					}
				}
			}
		}
	}
}
