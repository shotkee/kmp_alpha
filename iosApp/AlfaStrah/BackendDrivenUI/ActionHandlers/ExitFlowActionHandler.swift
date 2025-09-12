//
//  ExitFlowActionHandler.swift
//  AlfaStrah
//
//  Created by vit on 06.03.2025.
//  Copyright © 2025 Touch Instinct. All rights reserved.
//

extension BDUI {
	class ExitFlowActionHandler: ActionHandler<ExitFlowActionDTO> {
		required init(
			block: ExitFlowActionDTO
		) {
			super.init(block: block)
			
			work = { from, _, syncCompletion in
				self.userLogout(from: from)
			
				syncCompletion()
			}
		}
		
		private func userLogout(from: ViewController) {
			ApplicationFlow.shared.profileFlow.showLogout(from: from) {
				BDUI.CommonActionHandlers.shared.reset()
			}
		}
	}
}
