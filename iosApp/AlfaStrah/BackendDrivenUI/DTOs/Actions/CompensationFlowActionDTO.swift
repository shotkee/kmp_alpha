//
//  CompensationFlowActionDTO.swift
//  AlfaStrah
//
//  Created by vit on 03.03.2025.
//  Copyright © 2025 Touch Instinct. All rights reserved.
//

extension BDUI {
	class CompensationFlowActionDTO: ActionDTO {
		enum Key: String {
			case insuranceId = "insuranceId"
		}
		
		let insuranceId: String?
		
		required init(body: [String: Any]) {
			if let insuranceId = body[Key.insuranceId] as? Int {
				self.insuranceId = String(insuranceId)
			} else {
				self.insuranceId = nil
			}
			
			super.init(body: body)
		}
	}
}
