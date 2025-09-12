//
//  AppSettingsFlowActionHandler.swift
//  AlfaStrah
//
//  Created by vit on 06.03.2025.
//  Copyright © 2025 Touch Instinct. All rights reserved.
//

extension BDUI {
	class AppSettingsFlowActionHandler: ActionHandler<AppSettingsFlowActionDTO> {
		required init(
			block: AppSettingsFlowActionDTO
		) {
			super.init(block: block)
			
			work = { _, _, syncCompletion in
				self.appSettings()
			
				syncCompletion()
			}
		}
		
		private func appSettings() {
			ApplicationFlow.shared.profileFlow.showSettings()
		}
	}
}
