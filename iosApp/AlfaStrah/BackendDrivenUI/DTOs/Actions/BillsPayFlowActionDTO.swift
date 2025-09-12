//
//  BillsPayFlowActionDTO.swift
//  AlfaStrah
//
//  Created by vit on 03.03.2025.
//  Copyright © 2025 Touch Instinct. All rights reserved.
//

extension BDUI {
	class BillsPayFlowActionDTO: ActionDTO {
		enum Key: String {
			case insuranceId = "insuranceId"
			case billIds = "billsId"
		}
		
		let insuranceId: String?
		let billIds: [Int]?
		
		required init(body: [String: Any]) {
			if let insuranceId = body[Key.insuranceId] as? Int {
				self.insuranceId = String(insuranceId)
			} else {
				self.insuranceId = nil
			}
			
			if let billIds = body[Key.billIds] as? [Int] {
				self.billIds = billIds
			} else {
				self.billIds = nil
			}
			
			super.init(body: body)
		}
	}
}
