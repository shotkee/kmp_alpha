//
//  NothingActionHandler.swift
//  AlfaStrah
//
//  Created by vit on 06.03.2025.
//  Copyright © 2025 Touch Instinct. All rights reserved.
//

extension BDUI {
	class NothingActionHandler: ActionHandler<NothingActionDTO> {
		required init(
			block: NothingActionDTO
		) {
			super.init(block: block)
			
			work = { from, _, syncCompletion in
				syncCompletion()
			}
		}
	}
}
