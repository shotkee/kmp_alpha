//
//  LoyaltyFlowActionHandler.swift
//  AlfaStrah
//
//  Created by vit on 06.03.2025.
//  Copyright © 2025 Touch Instinct. All rights reserved.
//

extension BDUI {
	class LoyaltyFlowActionHandler: ActionHandler<LoyaltyFlowActionDTO> {
		required init(
			block: LoyaltyFlowActionDTO
		) {
			super.init(block: block)
			
			work = { _, _, syncCompletion in
				ApplicationFlow.shared.show(item: .alfaPoints)

				syncCompletion()
			}
		}
	}
}
