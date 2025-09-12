//
//  LayoutBDUI.swift
//  AlfaStrah
//
//  Created by vit on 18.07.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

import OrderedCollections

extension BDUI {
	class LayoutDTO: WidgetDTO {
		enum Key: String {
			case layoutId = "layoutId"
			case tags = "tags"
		}
		
		let layoutId: String?
		let tags: [String]?
		
		required init(body: [String: Any]) {
			self.layoutId = body[Key.layoutId] as? String
			self.tags = body[Key.tags] as? [String]
			
			super.init(body: body)
			
			let currentReplacementsKey = LayoutReplacementOperations.Constants.currentReplacementsKey
			
			if let layoutId {
				if LayoutReplacementOperations.layoutEntries[currentReplacementsKey] != nil {
#if DEBUG
					print("layout replace create new layout \(layoutId)")
#endif
					
					LayoutReplacementOperations.layoutEntries[currentReplacementsKey]?[layoutId] = (
						containerView: nil,
						horizontalInset: 0,
						filterCallback: nil,
						layoutParsedDictionary: body,
						willShownByTag: nil,
						eventHandler: nil
					)
				} else {
#if DEBUG
					print("layout replace create new layout \(layoutId)")
#endif
					
					let newLayoutEntry: OrderedDictionary<LayoutReplacementOperations.LayoutId, LayoutReplacementOperations.ParametersTuple> = [
						layoutId: (
							containerView: nil,
							horizontalInset: 0,
							filterCallback: nil,
							layoutParsedDictionary: body,
							willShownByTag: nil,
							eventHandler: nil
						)
					]
					
					LayoutReplacementOperations.layoutEntries[LayoutReplacementOperations.Constants.currentReplacementsKey] = newLayoutEntry
				}
			}
		}
	}
}
