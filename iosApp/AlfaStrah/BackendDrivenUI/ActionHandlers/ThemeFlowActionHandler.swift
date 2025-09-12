//
//  ThemeFlowActionHandler.swift
//  AlfaStrah
//
//  Created by vit on 06.03.2025.
//  Copyright © 2025 Touch Instinct. All rights reserved.
//

extension BDUI {
	class ThemeFlowActionHandler: ActionHandler<ThemeFlowActionDTO> {
		required init(
			block: ThemeFlowActionDTO
		) {
			super.init(block: block)
			
			work = { from, _, syncCompletion in
				self.switchTheme(from: from)
				
				syncCompletion()
			}
		}
		
		private func switchTheme(from: ViewController) {
			ApplicationFlow.shared.profileFlow.showApplicationTheme(from: from)
		}
	}
}
