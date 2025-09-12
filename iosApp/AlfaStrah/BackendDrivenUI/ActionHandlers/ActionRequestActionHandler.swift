//
//  ActionRequestActionHandler.swift
//  AlfaStrah
//
//  Created by vit on 06.03.2025.
//  Copyright © 2025 Touch Instinct. All rights reserved.
//

extension BDUI {
	class ActionRequestActionHandler: ActionHandler<ActionRequestActionDTO> {
		required init(
			block: ActionRequestActionDTO
		) {
			super.init(block: block)
			
			work = { from, _, syncCompletion in
				guard let request = block.request
				else {
					syncCompletion()
					return
				}
				
				BDUI.CommonActionHandlers.shared.handleActionRequest(
					block,
					request,
					handleEvent: { eventSelector in
						self.flow?.handleBackendEvents(
							eventSelector,
							on: from,
							with: nil,
							isModal: self.isModal ?? false,
							syncCompletion: syncCompletion
						)
					}
				)
				
				// NB! sync action request will only complete when the nested action completes
			}
		}
	}
}
