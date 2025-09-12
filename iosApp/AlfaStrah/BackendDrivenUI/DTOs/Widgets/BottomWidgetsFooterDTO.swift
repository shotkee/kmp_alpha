//
//  BottomWidgetsFooterDTO.swift
//  AlfaStrah
//
//  Created by vit on 16.04.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

extension BDUI {
	class BottomWidgetsFooterDTO: FooterDTO {
		enum Key: String {
			case content = "content"
			case renderType = "renderType"
		}
		
		enum RenderType: String {
			case pinnedDown = "PinnedDown"
		}
		
		let renderType: RenderType?
		let content: [ButtonWidgetDTO]?
		
		required init(body: [String: Any]) {
			self.renderType = RenderType(rawValue: body[Key.renderType] as? String ?? "")
			self.content = Self.instantinate(Key.content, body)
			
			super.init(body: body)
		}
	}
}
