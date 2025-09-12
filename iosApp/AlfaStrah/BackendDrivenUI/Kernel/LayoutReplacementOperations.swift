//
//  LayoutOperations.swift
//  AlfaStrah
//
//  Created by vit on 19.02.2025.
//  Copyright © 2025 Touch Instinct. All rights reserved.
//

import Legacy
import UIKit
import OrderedCollections

extension BDUI {
	struct LayoutReplacementOperations {
		typealias LayoutBody = [String: Any]
		typealias ScreenId = String
		typealias LayoutId = String
		typealias TagFilter = String
		typealias FilterCallback = (_ screenId: String, _ layoutId: String, _ tag: String?) -> Void
		
		// swiftlint:disable:next large_tuple
		typealias ParametersTuple = (
			containerView: UIView?,
			horizontalInset: CGFloat,
			filterCallback: FilterCallback?,
			layoutParsedDictionary: LayoutBody?,
			willShownByTag: TagFilter?,
			eventHandler: ((EventsDTO) -> Void)?
		)
		
		typealias LayoutEntry = OrderedDictionary<LayoutId, ParametersTuple>
		
		static var layoutEntries: [ScreenId: LayoutEntry] = [:]
		
		static var currentFilteredLayoutId: String?
		
		struct Constants {
			// this id for all layout replace entries where screendId is nil
			static let currentReplacementsKey = "currentReplacementsKey"
		}
		
		static func printLayoutData(with logger: TaggedLogger?, tag: String = "") {
			logger?.debug("\(tag) ------------------------------ LAYOUT DATA ------------------------------")
			for key in Self.layoutEntries.keys {
				Self.printLayoutData(with: logger, tag, for: key)
			}
		}
		
		static func printLayoutData(with logger: TaggedLogger?, _ tag: String = "", for screenId: String) {
			logger?.debug("\(tag)\tscreen id \(screenId)")
			if let items = Self.layoutEntries[screenId] {
				for item in items {
					logger?.debug("\(tag)\t\t\(item.key) - \(item.value.layoutParsedDictionary?["type"])")
				}
			}
		}
	}
}
