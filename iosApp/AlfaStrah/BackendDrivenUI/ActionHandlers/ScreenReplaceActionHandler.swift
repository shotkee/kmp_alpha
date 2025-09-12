//
//  ScreenReplaceActionHandler.swift
//  AlfaStrah
//
//  Created by vit on 06.03.2025.
//  Copyright © 2025 Touch Instinct. All rights reserved.
//

import Legacy

extension BDUI {
	class ScreenReplaceActionHandler: ActionHandler<ScreenReplaceActionDTO>,
									  LoggerDependency {
		var logger: TaggedLogger?
		
		required init(
			block: ScreenReplaceActionDTO
		) {
			super.init(block: block)
			
			work = { from, _, syncCompletion in
				guard let screenId = block.screenId,
					  let screen = block.screen
				else {
					syncCompletion()
					return
				}
				
				syncCompletion()
					
				BDUI.CommonActionHandlers.shared.replace(
					screen: screen,
					forScreenId: screenId,
					logger: self.logger
				)
			}
		}
	}
}
