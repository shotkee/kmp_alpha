//
//  LayoutReplaceActionHandler.swift
//  AlfaStrah
//
//  Created by vit on 06.03.2025.
//  Copyright © 2025 Touch Instinct. All rights reserved.
//

extension BDUI {
	class LayoutReplaceActionHandler: ActionHandler<LayoutReplaceActionDTO> {
		required init(
			block: LayoutReplaceActionDTO
		) {
			super.init(block: block)
			
			work = { _, _, syncCompletion in
				syncCompletion()
			}
		}
	}
}
