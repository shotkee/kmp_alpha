//
//  OsagoPhotoUploadFlowActionDTO.swift
//  AlfaStrah
//
//  Created by vit on 03.03.2025.
//  Copyright © 2025 Touch Instinct. All rights reserved.
//

extension BDUI {
	class OsagoPhotoUploadFlowActionDTO: ActionDTO {
		let picker: OsagoPhotoUploadPickerComponentDTO?
		
		required init(body: [String: Any]) {
			self.picker = Self.instantinate(body)
			
			super.init(body: body)
		}
	}
}
