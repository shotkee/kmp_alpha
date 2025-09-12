//
//  QuestionFlowActionDTO.swift
//  AlfaStrah
//
//  Created by vit on 03.03.2025.
//  Copyright © 2025 Touch Instinct. All rights reserved.
//

extension BDUI {
	class QuestionFlowActionDTO: ActionDTO {
		enum Key: String {
			case questionId = "questionId"
		}
		
		let questionId: Int?
		
		required init(body: [String: Any]) {
			self.questionId = body[Key.questionId] as? Int
			
			super.init(body: body)
		}
	}
}
