//
//  BillFlowActionDTO.swift
//  AlfaStrah
//
//  Created by vit on 03.03.2025.
//  Copyright © 2025 Touch Instinct. All rights reserved.
//

extension BDUI {
	class BillFlowActionDTO: ActionDTO {
		enum Key: String {
			case insuranceId = "insuranceId"
			case billId = "billId"
		}
		
		let insuranceId: String?
		let billId: Int?
		
		required init(body: [String: Any]) {
			if let insuranceId = body[Key.insuranceId] as? Int {
				self.insuranceId = String(insuranceId)
			} else {
				self.insuranceId = nil
			}
			
			if let billId = body[Key.billId] as? Int {
				self.billId = billId
			} else {
				self.billId = nil
			}
			
			super.init(body: body)
		}
	}
}
