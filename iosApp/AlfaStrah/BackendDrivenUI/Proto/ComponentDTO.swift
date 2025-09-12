//
//  ComponentDTO.swift
//  AlfaStrah
//
//  Created by vit on 16.04.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

// swiftlint:disable all

import Legacy

extension BDUI {
	class ComponentDTO: ComponentInitializable {
		enum Key: String {
			case `type` = "type"
		}
		
		let type: BackendComponentType
		
		required init(
			body: [String: Any]
		) {
			self.type = BackendComponentType(rawValue: body[Key.type] as? String ?? "") ?? .none
		}
		
		init(type: BackendComponentType) {
			self.type = type
		}
		
		static func instantinate<T>(
			_ key: any RawRepresentable<String>,
			_ body: [String: Any]?
		) -> T? where T: ComponentInitializable  {
			guard let body
			else { return nil }
			
			if key.rawValue.isEmpty {
				return Self.mapData(from: body)
			} else {
				if let componentBody = body[key] as? [String: Any] {
					return Self.mapData(from: componentBody)
				} else {
					return nil
				}
			}
		}
		
		static func instantinate<T>(
			_ body: [String: Any]?
		) -> T? where T: ComponentInitializable  {
			guard let body
			else { return nil }
			
			return T.init(body: body)
		}
		
		static func mapData<T>(
			from body: [String: Any]
		) -> T? where T: ComponentInitializable {
			if let targetDTO = Self.mapData(body: body) as? T {
				return targetDTO
			} else {
				return T.init(body: body)
			}
		}

		static func mapData(body: [String: Any]) -> ComponentDTO? {
			if	let typeRaw = body[ComponentDTO.Key.type] as? String,
				let type = BackendComponentType(rawValue: typeRaw) {
					
				if let classType = BDUI.Mapper.widgetEntries[type]?.dtoType
					?? BDUI.Mapper.headerEntries[type]?.dtoType
					?? BDUI.Mapper.footerEntries[type]?.dtoType {
					return classType.init(body: body)
				}
				
				if let classType = BDUI.Mapper.actionEntries[type]?.dtoType {
					return classType.init(body: body)
				}
			}
			
			return nil
		}
		
		static func instantinate<T>(
			_ key: any RawRepresentable<String>,
			_ body: [String: Any]
		) -> [T] where T: ComponentInitializable {
			if let array = body[key.rawValue] as? [Any] {
				return array.compactMap {
					if let elementBody = $0 as? [String: Any] {
						return Self.mapData(from: elementBody)
					}
					return nil
				}
			}

			return []
		}
	}
}
