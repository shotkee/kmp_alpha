//
//  BottomLayoutFooterDTO.swift
//  AlfaStrah
//
//  Created by vit on 11.09.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

extension BDUI {
	class BottomLayoutFooterDTO: FooterDTO {
		enum Key: String {
			case layout = "layout"
			case renderType = "renderType"
		}
		
		enum RenderType: String {
			case pinnedDown = "PinnedDown"
		}
		
		let layout: WidgetDTO?
		let renderType: RenderType?
		
		required init(body: [String: Any]) {
			self.layout = Self.instantinate(Key.layout, body)
			self.renderType = RenderType(rawValue: body[Key.renderType] as? String ?? "")
			
			super.init(body: body)
		}
	}
}
