//
//  DraftCalculationsActionHandler.swift
//  AlfaStrah
//
//  Created by vit on 06.03.2025.
//  Copyright © 2025 Touch Instinct. All rights reserved.
//

extension BDUI {
	class DraftCalculationsActionHandler: ActionHandler<DraftCalculationsActionDTO> {
		required init(
			block: DraftCalculationsActionDTO
		) {
			super.init(block: block)
			
			work = { from, _, syncCompletion in
				let draftFlow = DraftsCalculationsFlow(rootController: from)
				ApplicationFlow.shared.container.resolve(draftFlow)
				draftFlow.start()
				
				syncCompletion()
			}
		}
	}
}
