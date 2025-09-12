//
//  EventReportNsFlowActionDTO.swift
//  AlfaStrah
//
//  Created by vit on 03.03.2025.
//  Copyright © 2025 Touch Instinct. All rights reserved.
//

extension BDUI {
	class EventReportNsFlowActionDTO: ActionDTO {
		enum Key: String {
			case insuranceId = "insuranceId"
			case name = "name"
		}
		
		let insuranceId: String?
		let recipientName: String?
		
		required init(body: [String: Any]) {
			if let insuranceId = body[Key.insuranceId] as? Int {
				self.insuranceId = String(insuranceId)
			} else {
				self.insuranceId = nil
			}
			
			self.recipientName = body[Key.name] as? String
			
			super.init(body: body)
		}
	}
}
