//
//  OrderedDictionary+.swift
//  AlfaStrah
//
//  Created by vit on 22.10.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

import OrderedCollections

extension OrderedDictionary {
	mutating func moveData(fromKey: Key, toKey: Key) {
		if let entry = removeValue(forKey: fromKey) {
			self[toKey] = entry
		}
	}
}
