//
//  CollapseLayoutDTO.swift
//  AlfaStrah
//
//  Created by vit on 18.07.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

extension BDUI {
	class CollapseLayoutDTO: LayoutDTO {
		enum Key: String {
			case content = "content"
			case header = "header"
			case showType = "showType"
			case button = "button"
		}
		
		enum ShowType: String {
			case visible = "Visible"
			case invisible = "Invisible"
		}
		
		let themedHeader: ThemedTextComponentDTO?
		let collapseButton: CollapseButtonComponentDTO?
		let showType: ShowType?
		
		let content: [WidgetDTO]?
		
		required init(body: [String: Any]) {
			self.themedHeader = Self.instantinate(Key.header, body)
			self.collapseButton = Self.instantinate(Key.button, body)
			self.showType = ShowType(rawValue: body[Key.showType] as? String ?? "")
			self.content = Self.instantinate(Key.content, body)
			
			super.init(body: body)
		}
	}
	
	class CollapseButtonComponentDTO: ComponentDTO {
		enum Key: String {
			case iconColor = "iconColor"
			case backgroundColor = "backgroundColor"
		}
		
		let themedIconColor: ThemedValueComponentDTO?
		let themedBackgroundColor: ThemedValueComponentDTO?
		
		required init(body: [String: Any]) {
			self.themedIconColor = Self.instantinate(Key.iconColor, body)
			self.themedBackgroundColor = Self.instantinate(Key.backgroundColor, body)
			
			super.init(body: body)
		}
	}
}
