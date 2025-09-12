//
//  TimeInputWidgetDTO.swift
//  AlfaStrah
//
//  Created by vit on 22.11.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

extension BDUI {
	class TimeInputWidgetDTO: TextInputWidgetDTO {
		enum Key: String {
			case timeTo = "dateTo"
			case timeDefault = "dateDefault"
			case timeFrom = "dateFrom"
		}
		
		let timeTo: Date?
		let timeDefault: Date?
		let timeFrom: Date?
		
		required init(body: [String: Any]) {
			self.timeTo = Self.time(from: body[Key.timeTo] as? String)
			self.timeFrom = Self.time(from: body[Key.timeFrom] as? String)
			self.timeDefault = Self.time(from: body[Key.timeDefault] as? String)
			
			super.init(body: body)
		}
		
		private static let dateFormat = "HH:mm"
		private static let timeFormatter: DateFormatter = {
			let formatter = DateFormatter()
			formatter.dateFormat = dateFormat
			formatter.timeZone = TimeZone(abbreviation: "UTC")
			return formatter
		}()
		
		private static func time(from string: String?) -> Date? {
			guard let string
			else { return nil }
			
			return timeFormatter.date(from: string)
		}
	}
}
