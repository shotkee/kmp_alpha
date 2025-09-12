//
//  HelpBlocksFlowActionDTO.swift
//  AlfaStrah
//
//  Created by vit on 03.03.2025.
//  Copyright © 2025 Touch Instinct. All rights reserved.
//

extension BDUI {
	class HelpBlocksFlowActionDTO: ActionDTO {
		enum Key: String {
			case insuranceId = "insuranceId"
			case fileUrl = "fileUrl"
		}
		
		let insuranceId: String?
		let url: URL?
		
		required init(body: [String: Any]) {
			if let indsuranceId = body[Key.insuranceId] as? Int {
				self.insuranceId = String(indsuranceId)
			} else {
				self.insuranceId = nil
			}
			
			if let urlPath = body[Key.fileUrl] as? String {
				self.url = URL(string: urlPath)
			} else {
				self.url = nil
			}
			
			super.init(body: body)
		}
	}
}
