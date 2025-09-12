//
//  LayoutReplaceAsyncActionDTO.swift
//  AlfaStrah
//
//  Created by vit on 03.03.2025.
//  Copyright © 2025 Touch Instinct. All rights reserved.
//

extension BDUI {
	class LayoutReplaceAsyncActionDTO: ActionDTO {
		enum Key: String {
			case content = "content"
			case layoutId = "layoutId"
			case screenId = "screenId"
		}
		
		let request: RequestComponentDTO?
		let screenId: String?
		let layoutId: String?

		required init(body: [String: Any]) {
			if let content = body[Key.content] as? [String: Any] {
				self.screenId = body[Key.screenId] as? String
				self.layoutId = body[Key.layoutId] as? String
				self.request = RequestComponentDTO(body: content)
			} else {
				self.request = nil
				self.screenId = nil
				self.layoutId = nil
			}
			
			super.init(body: body)
		}
	}
}
