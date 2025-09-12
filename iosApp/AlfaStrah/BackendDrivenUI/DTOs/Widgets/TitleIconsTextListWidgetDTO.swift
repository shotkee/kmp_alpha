//
//  TitleIconsTextListWidgetDTO.swift
//  AlfaStrah
//
//  Created by vit on 12.02.2025.
//  Copyright © 2025 Touch Instinct. All rights reserved.
//

extension BDUI {
	class TitleIconsTextListWidgetDTO: WidgetDTO {
		enum Key: String {
			case leftIcon = "leftIcon"
			case rightIcon = "rightIcon"
			case title = "title"
			case image = "image"
			case topContentItems = "topContentItems"
			case bottomContentItems = "bottomContentItems"
		}
		
		let leftIcon: ThemedValueComponentDTO?
		let rightIcon: InlineWidgetButtonComponentDTO?
		let title: ThemedSizedTextComponentDTO?
		let image: ThemedValueComponentDTO?
		let topItems: [TitleIconsTextListItemComponentDTO]?
		let bottomItems: [TitleIconsTextListItemComponentDTO]?
		
		required init(body: [String: Any]) {
			self.leftIcon = Self.instantinate(Key.leftIcon, body)
			self.rightIcon = Self.instantinate(Key.rightIcon, body)
			self.title = Self.instantinate(Key.title, body)
			self.image = Self.instantinate(Key.image, body)
			self.topItems = Self.instantinate(Key.topContentItems, body)
			self.bottomItems = Self.instantinate(Key.bottomContentItems, body)
			
			super.init(body: body)
		}
	}
	
	class  TitleIconsTextListItemComponentDTO: ComponentDTO {
		enum Key: String {
			case header = "header"
			case value = "value"
			case width = "width"
		}
		
		let header: ThemedSizedTextComponentDTO?
		let value: СopyableThemedTextComponentDTO?
		let width: CGFloat
		
		required init(body: [String: Any]) {
			self.header = Self.instantinate(Key.header, body)
			self.value = Self.instantinate(Key.value, body)
			self.width = body[Key.width] as? CGFloat ?? 1
			
			super.init(body: body)
		}
	}
}
