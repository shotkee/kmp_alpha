//
//  MainPageToNativeRenderActionHandler.swift
//  AlfaStrah
//
//  Created by vit on 06.03.2025.
//  Copyright © 2025 Touch Instinct. All rights reserved.
//

extension BDUI {
	class MainPageToNativeRenderActionHandler: ActionHandler<MainPageToNativeRenderActionDTO>,
											   ApplicationSettingsServiceDependency {
		var applicationSettingsService: ApplicationSettingsService!

		required init(
			block: MainPageToNativeRenderActionDTO
		) {
			super.init(block: block)
			
			work = { _, _, syncCompletion in
				self.applicationSettingsService.isNativeRender = .yes
				ApplicationFlow.shared.reloadHomeTab(withNativeRender: true)
				
				syncCompletion()
			}
		}
	}
}
