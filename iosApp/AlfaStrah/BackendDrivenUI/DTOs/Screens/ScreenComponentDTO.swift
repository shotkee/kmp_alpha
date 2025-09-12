//
//  ScreenComponentDTO.swift
//  AlfaStrah
//
//  Created by vit on 16.04.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

extension BDUI {
	class ScreenComponentDTO: ComponentDTO {
		enum Key: String {
			case backgroundColor = "backgroundColor"
			case header = "header"
			case screenId = "screenId"
			case showType = "showType"
			case footer = "bottom"
			case layout = "layout"
			case pullToRefresh = "pullToRefresh"
			case events = "events"
		}
		
		enum ShowType: String {
			case vertical = "Vertical"
			case horizontal = "Horizontal"
			case modal = "Modal"
		}
		
		let backgroundColor: ThemedValueComponentDTO?
		var screenId: String?
		let showType: ShowType?
		let pullToRefresh: RequestComponentDTO?
		
		let header: HeaderDTO?
		let layout: WidgetDTO?
		let footer: FooterDTO?
		let events: EventsDTO?
		
		required init(body: [String: Any]) {
			self.backgroundColor = Self.instantinate(Key.backgroundColor, body)
			self.screenId = body[Key.screenId] as? String ?? UUID().uuidString
			self.showType = ShowType(rawValue: body[Key.showType] as? String ?? "")
			
			self.events = Self.instantinate(Key.events, body)
			
			self.pullToRefresh = Self.instantinate(Key.pullToRefresh, body)
			
			self.header = Self.instantinate(Key.header, body)
			self.layout = Self.instantinate(Key.layout, body)
			self.footer = Self.instantinate(Key.footer, body)
			
			super.init(body: body)
			
			if let screenId {
				LayoutReplacementOperations.layoutEntries.moveData(
					fromKey: LayoutReplacementOperations.Constants.currentReplacementsKey,
					toKey: screenId
				)
				
				print("layout replace - created - screenId \(screenId)")
			}
			
			print("screen basic layout changes - created - screenId \(screenId)")
		}
	}
}
