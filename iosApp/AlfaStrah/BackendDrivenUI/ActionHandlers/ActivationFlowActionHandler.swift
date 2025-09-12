//
//  ActivationFlowActionHandler.swift
//  AlfaStrah
//
//  Created by vit on 06.03.2025.
//  Copyright © 2025 Touch Instinct. All rights reserved.
//

extension BDUI {
	class ActivationFlowActionHandler: ActionHandler<ActivationFlowActionDTO> {
		required init(
			block: ActivationFlowActionDTO
		) {
			super.init(block: block)
			
			work = { from, _, syncCompletion in
				self.openActivateInsurance(from: from)

				syncCompletion()
			}
		}
		
		private func openActivateInsurance(from: ViewController) {
			let flow = ActivateProductFlow()
			ApplicationFlow.shared.container.resolve(flow)
			flow.startModally(from: from)
		}
	}
}
