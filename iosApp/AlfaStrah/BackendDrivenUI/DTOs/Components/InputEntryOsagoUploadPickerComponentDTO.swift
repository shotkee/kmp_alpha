//
//  InputEntryOsagoUploadPickerComponentDTO.swift
//  AlfaStrah
//
//  Created by vit on 21.02.2025.
//  Copyright © 2025 Touch Instinct. All rights reserved.
//

extension BDUI {
	class InputEntryOsagoUploadPickerComponentDTO: ComponentDTO {
		enum Key: String {
			case id = "id"
			case url = "url"
		}
		
		let id: String?
		let url: URL?
		
		required init(body: [String: Any]) {
			self.id = body[Key.id] as? String
			self.url = URL(string: body[Key.url] as? String ?? "")
			
			super.init(body: body)
		}
	}
}
