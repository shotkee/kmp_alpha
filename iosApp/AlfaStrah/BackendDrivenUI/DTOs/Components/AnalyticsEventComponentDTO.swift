//
//  AnalyticsEventBackendComponent.swift
//  AlfaStrah
//
//  Created by Makson on 31.07.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

import Foundation

extension BDUI {
	class AnalyticsEventComponentDTO: ComponentDTO {
		enum Key: String {
			case eventDetails = "eventDetails"
			case eventName = "eventName"
			case profileDetails = "profileDetails"
		}
		
		let eventDetails: [AnalyticsDetailComponentDTO]?
		let eventName: String?
		let profileDetails: [AnalyticsDetailComponentDTO]?
		
		required init(body: [String: Any]) {
			self.eventDetails = Self.instantinate(Key.eventDetails, body)
			self.eventName = body[Key.eventName] as? String
			self.profileDetails = Self.instantinate(Key.profileDetails, body)
			
			super.init(body: body)
		}
	}
	
	class AnalyticsDetailComponentDTO: ComponentDTO {
		enum Key: String {
			case title = "title"
			case value = "value"
		}
		
		let title: String?
		let value: String?
		
		required init(body: [String: Any])
		{
			self.title = body[Key.title] as? String
			self.value = body[Key.value] as? String
			
			super.init(body: body)
		}
	}
}
