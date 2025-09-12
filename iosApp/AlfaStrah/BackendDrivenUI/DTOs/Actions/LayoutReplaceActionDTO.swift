//
//  LayoutReplaceActionDTO.swift
//  AlfaStrah
//
//  Created by vit on 03.03.2025.
//  Copyright © 2025 Touch Instinct. All rights reserved.
//

extension BDUI {
	class LayoutReplaceActionDTO: ActionDTO {
		enum Key: String {
			case screenId = "screenId"
			case layoutId = "layoutId"
			case content = "content"
		}
		
		let screenId: String?
		let layoutId: String?
		let layout: (() -> LayoutDTO?)?
		
		required init(body: [String: Any]) {
			if let content = body[Key.content] as? [String: Any] {
				self.layout = {
					return BDUI.ComponentDTO.mapData(from: content)
				}
				
				self.screenId = body[Key.screenId] as? String
				self.layoutId = body[Key.layoutId] as? String
			} else {
				self.screenId = nil
				self.layoutId = nil
				self.layout = nil
			}
			
			super.init(body: body)
		}
	}
}
