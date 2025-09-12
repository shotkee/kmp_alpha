//
//  OsagoPhotoUploadPickerComponentDTO.swift
//  AlfaStrah
//
//  Created by vit on 17.12.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

extension BDUI {
	class OsagoPhotoUploadPickerComponentDTO: ComponentDTO {
		enum Key: String {
			case countMin = "countMin"
			case input = "input"
			case firstScreen = "firstScreen"
			case uploadScreen = "uploadScreen"
			case uploadUrl = "uploadUrl"
			case countMax = "countMax"
			case canSelectFromSavedPhotos = "canSelectFromSavedPhotos"
		}
		
		let countMin: Int?
		let countMax: Int?
		
		let input: [InputEntryOsagoUploadPickerComponentDTO]?
		
		let firstScreen: FirstScreenOsagoUploadPickerComponentDTO?
		let uploadScreen: UploadScreenOsagoUploadPickerComponentDTO?
		
		let uploadUrl: URL?
		
		let canSelectFromSavedPhotos: Bool
		
		required init(body: [String: Any]) {
			self.countMin = body[Key.countMin] as? Int
			self.countMax = body[Key.countMax] as? Int
			
			self.input = Self.instantinate(Key.input, body)
			
			self.firstScreen = Self.instantinate(Key.firstScreen, body)
			self.uploadScreen = Self.instantinate(Key.uploadScreen, body)
			
			self.uploadUrl = URL(string: body[Key.uploadUrl] as? String ?? "")
			
			self.canSelectFromSavedPhotos = body[Key.canSelectFromSavedPhotos] as? Bool ?? false
			
			super.init(body: body)
		}
	}
}
