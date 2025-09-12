//
//  ChangeSessionTypeFlowActionDTO.swift
//  AlfaStrah
//
//  Created by vit on 03.03.2025.
//  Copyright © 2025 Touch Instinct. All rights reserved.
//

extension BDUI {
	class ChangeSessionTypeFlowActionDTO: ActionDTO {
		enum Key: String {
			case accountType = "sessionType"
		}
		
		let accountType: AccountType?
		
		required init(body: [String: Any]) {
			if let accountTypeRaw = body[Key.accountType] as? Int,
			   let accountType = AccountType(rawValue: accountTypeRaw) {
				self.accountType = accountType
			} else {
				self.accountType = nil
			}
			
			super.init(body: body)
		}
	}
}
