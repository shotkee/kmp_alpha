//
//  OsagoSchemeAutoFlowActionDTO.swift
//  AlfaStrah
//
//  Created by vit on 03.03.2025.
//  Copyright © 2025 Touch Instinct. All rights reserved.
//

extension BDUI {
	class OsagoSchemeAutoFlowActionDTO: ActionDTO {
		let picker: OsagoSchemeAutoPickerComponentDTO?
		
		required init(body: [String: Any]) {
			self.picker = Self.instantinate(body)
			
			super.init(body: body)
		}
	}
}
