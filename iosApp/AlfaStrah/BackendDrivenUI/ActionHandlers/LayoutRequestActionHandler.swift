//
//  LayoutRequestActionHandler.swift
//  AlfaStrah
//
//  Created by vit on 06.03.2025.
//  Copyright © 2025 Touch Instinct. All rights reserved.
//

extension BDUI {
	class LayoutRequestActionHandler: ActionHandler<LayoutRequestActionDTO> {
		required init(
			block: LayoutRequestActionDTO
		) {
			super.init(block: block)
			
			work = { from, _, syncCompletion in
				// TODO: - BDUI.ViewBuilder : consumeLayoutActions method
				/*
				 When the time comes to refactor the layout actions
				 that are currently embedded in the LayoutBDUI build routine
				 it is necessary to move the corresponding code of action here.
				*/
				
				syncCompletion()
			}
		}
	}
}
