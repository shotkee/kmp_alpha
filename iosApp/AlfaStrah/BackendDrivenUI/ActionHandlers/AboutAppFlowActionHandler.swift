//
//  AboutAppFlowActionHandler.swift
//  AlfaStrah
//
//  Created by vit on 06.03.2025.
//  Copyright © 2025 Touch Instinct. All rights reserved.
//

extension BDUI {
	class AboutAppFlowActionHandler: ActionHandler<AboutAppFlowActionDTO> {
		required init(
			block: AboutAppFlowActionDTO
		) {
			super.init(block: block)
			
			work = { _, _, syncCompletion in
				self.aboutApp()
					
				syncCompletion()
			}
		}
		
		private func aboutApp() {
			ApplicationFlow.shared.profileFlow.showAbout()
		}
	}
}
