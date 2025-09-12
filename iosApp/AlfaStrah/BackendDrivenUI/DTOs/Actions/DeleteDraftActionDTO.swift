//
//  DeleteDraftActionDTO.swift
//  AlfaStrah
//
//  Created by vit on 03.03.2025.
//  Copyright © 2025 Touch Instinct. All rights reserved.
//

extension BDUI {
	class DeleteDraftActionDTO: ActionDTO {
		enum Key: String {
			case draftId = "draftId"
		}
		
		let id: Int?
		
		required init(body: [String: Any]) {
			self.id = body[Key.draftId] as? Int
			
			super.init(body: body)
		}
	}
}
