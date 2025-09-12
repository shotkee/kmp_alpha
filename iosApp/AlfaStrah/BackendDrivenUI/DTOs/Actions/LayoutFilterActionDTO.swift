//
//  LayoutFilterActionDTO.swift
//  AlfaStrah
//
//  Created by vit on 03.03.2025.
//  Copyright © 2025 Touch Instinct. All rights reserved.
//

extension BDUI {
	class LayoutFilterActionDTO: ActionDTO {
		enum Key: String {
			case tag = "tag"
			case screenId = "screenId"
			case layoutId = "layoutId"
		}
		
		let screenId: String?
		let layoutId: String?
		let tag: String?
		
		required init(body: [String: Any]) {
			self.screenId = body[Key.screenId] as? String
			self.layoutId = body[Key.layoutId] as? String
			self.tag = body[Key.tag] as? String
			
			super.init(body: body)
		}
	}
}
