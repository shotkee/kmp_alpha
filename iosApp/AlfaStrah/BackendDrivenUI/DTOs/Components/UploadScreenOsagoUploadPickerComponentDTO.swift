//
//  UploadScreenOsagoUploadPickerComponentDTO.swift
//  AlfaStrah
//
//  Created by vit on 21.02.2025.
//  Copyright © 2025 Touch Instinct. All rights reserved.
//

extension BDUI {
	class UploadScreenOsagoUploadPickerComponentDTO: ComponentDTO {
		enum Key: String {
			case title = "title"
			case information = "information"
		}
		
		let title: ThemedSizedTextComponentDTO?
		let information: WidgetDTO?
		
		required init(body: [String: Any]) {
			self.title = Self.instantinate(Key.title, body)
			self.information = Self.instantinate(Key.information, body)
			
			super.init(body: body)
		}
	}
}
