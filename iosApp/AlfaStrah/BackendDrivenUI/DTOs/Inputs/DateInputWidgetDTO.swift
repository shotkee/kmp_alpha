//
//  DateInputWidgetDTO.swift
//  AlfaStrah
//
//  Created by vit on 22.11.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

extension BDUI {
	class DateInputWidgetDTO: TextInputWidgetDTO {
		enum Key: String {
			case dateTo = "dateTo"
			case dateDefault = "dateDefault"
			case dateFrom = "dateFrom"
		}
		
		let dateTo: Date?
		let dateDefault: Date?
		let dateFrom: Date?
		
		required init(body: [String: Any]) {
			self.dateTo = Self.date(from: body[Key.dateTo] as? String)
			self.dateFrom = Self.date(from: body[Key.dateFrom] as? String)
			self.dateDefault = Self.date(from: body[Key.dateDefault] as? String)
			
			super.init(body: body)
		}
		
		private static let dateFormat = "yyyy-MM-dd"
		private static let dateFormatter: DateFormatter = {
			let formatter = DateFormatter()
			formatter.dateFormat = dateFormat
			formatter.timeZone = TimeZone(abbreviation: "UTC")
			return formatter
		}()
		
		private static func date(from string: String?) -> Date? {
			guard let string
			else { return nil }
			
			return dateFormatter.date(from: string)
		}
	}
}
