//
//  ClinicsFlowActionDTO.swift
//  AlfaStrah
//
//  Created by vit on 03.03.2025.
//  Copyright © 2025 Touch Instinct. All rights reserved.
//

extension BDUI {
	class ClinicsFlowActionDTO: ActionDTO {
		enum Key: String {
			case insuranceId = "insuranceId"
			case preselectedClinicFilter = "preselectedClinicFilter"
		}
		
		let insuranceId: String?
		let filterId: String?
		
		required init(body: [String: Any]) {
			if let insuranceId = body[Key.insuranceId] as? Int {
				self.insuranceId = String(insuranceId)
			} else {
				self.insuranceId = nil
			}
			
			if let insuranceId = body[Key.preselectedClinicFilter] as? Int {
				self.filterId = String(insuranceId)
			} else {
				self.filterId = nil
			}
			
			super.init(body: body)
		}
	}
}
