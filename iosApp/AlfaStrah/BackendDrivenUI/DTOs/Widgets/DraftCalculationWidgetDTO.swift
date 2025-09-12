//
//  DraftCalculationWidgetDTO.swift
//  AlfaStrah
//
//  Created by vit on 15.08.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

extension BDUI {
	class DraftCalculationWidgetDTO: WidgetDTO {
		enum Key: String {
			case calculationNumber = "calculationNumber"
			case calculationTitle = "calculationTitle"
			case dividerColor = "dividerColor"
			case contextMenu = "contextMenu"
			case bottomLines = "bottomLines"
			case parameterList = "parameterList"
			case price = "price"
			case button = "button"
		}
		
		let calculationNumberThemedText: ThemedTextComponentDTO?
		let calculationThemedTitle: ThemedTextComponentDTO?
		let dividerThemedColor: ThemedValueComponentDTO?
		let contextMenu: ContextMenuComponentDTO?
		let bottomLines: [ThemedTextComponentDTO]?
		let parameterList: [ParameterBackendComponent]?
		let priceThemedText: ThemedTextComponentDTO?
		let widgetDto: WidgetDTO?
		
		required init(body: [String: Any]) {
			self.calculationThemedTitle = Self.instantinate(Key.calculationTitle, body)
			self.calculationNumberThemedText = Self.instantinate(Key.calculationNumber, body)
			self.dividerThemedColor = Self.instantinate(Key.dividerColor, body)
			self.contextMenu = Self.instantinate(Key.contextMenu, body)
			self.bottomLines = Self.instantinate(Key.bottomLines, body)
			self.parameterList = Self.instantinate(Key.parameterList, body)
			self.priceThemedText = Self.instantinate(Key.price, body)
			self.widgetDto = Self.instantinate(Key.button, body)
			
			super.init(body: body)
		}
	}
	
	class ContextMenuComponentDTO: ComponentDTO {
		enum Key: String {
			case icon = "icon"
			case backgroundColor = "backgroundColor"
			case dividersColor = "dividersColor"
			case items = "items"
		}
		
		let themedIcon: ThemedValueComponentDTO?
		let themedBackgroundColor: ThemedValueComponentDTO?
		let separatorColor: ThemedValueComponentDTO?
		let items: [ContextMenuItemBackendComponent]?
		
		required init(body: [String: Any]) {
			self.themedIcon = Self.instantinate(Key.icon, body)
			self.themedBackgroundColor = Self.instantinate(Key.backgroundColor, body)
			self.separatorColor = Self.instantinate(Key.dividersColor, body)
			self.items = Self.instantinate(Key.items, body)
			
			super.init(body: body)
		}
	}
	
	class ContextMenuItemBackendComponent: ComponentDTO {
		enum Key: String {
			case icon = "icon"
			case text = "text"
			case events = "events"
		}
		
		let themedIcon: ThemedValueComponentDTO?
		let themedText: ThemedTextComponentDTO?
		
		let events: EventsDTO?
		
		required init(body: [String: Any]) {
			self.themedIcon = Self.instantinate(Key.icon, body)
			self.themedText = Self.instantinate(Key.text, body)
			
			self.events = Self.instantinate(Key.events, body)
			
			super.init(body: body)
		}
	}
	
	class ParameterBackendComponent: ComponentDTO {
		enum Key: String {
			case title = "title"
			case value = "value"
		}
		
		let themedTitle: ThemedTextComponentDTO?
		let themedValue: ThemedTextComponentDTO?
		
		required init(body: [String: Any]) {
			self.themedTitle = Self.instantinate(Key.title, body)
			self.themedValue = Self.instantinate(Key.value, body)
			
			super.init(body: body)
		}
	}
}
