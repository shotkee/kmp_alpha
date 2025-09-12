//
//  MedicalFileStorageFlowActionDTO.swift
//  AlfaStrah
//
//  Created by vit on 03.03.2025.
//  Copyright © 2025 Touch Instinct. All rights reserved.
//

extension BDUI {
	class InstructionFlowActionDTO: ActionDTO {
		enum Key: String {
			case insuranceId = "insuranceId"
			case categoryId = "categoryId"
		}
		
		let insuranceId: String?
		let categoryId: String?
		
		required init(body: [String: Any]) {
			if let insuranceId = body[Key.insuranceId] as? Int {
				self.insuranceId = String(insuranceId)
			} else {
				self.insuranceId = nil
			}
			
			if let categoryId = body[Key.categoryId] as? Int {
				self.categoryId = String(categoryId)
			} else {
				self.categoryId = nil
			}
			
			super.init(body: body)
		}
	}
}
