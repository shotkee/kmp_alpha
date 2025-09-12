//
//  Dictionary+.swift
//  AlfaStrah
//
//  Created by vit on 18.06.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

extension Dictionary {
	func mapKeyAndValuesRecursive<K: Hashable, V>(
		transformKey: (Key) -> K,
		transformValue: (Value) -> V
	) -> [K: V] {
		return Dictionary<K, V>(
			uniqueKeysWithValues: map { (key, value) in
				var mappedDictionaryValue: V?
				
				if let valueDictionary = value as? Dictionary {
					mappedDictionaryValue = valueDictionary.mapKeyAndValuesRecursive(
						transformKey: transformKey,
						transformValue: transformValue
					) as? V
				}
				return (
					transformKey(key),
					mappedDictionaryValue ?? transformValue(value)
				)
			}
		)
	}
}

extension Dictionary {
	mutating func moveData(fromKey: Key, toKey: Key) {
		if let entry = removeValue(forKey: fromKey) {
			self[toKey] = entry
		}
	}
}

extension Dictionary {
	subscript<T: RawRepresentable>(key: T) -> Value? where T.RawValue == Key {
		get {
			return self[key.rawValue]
		}

		set {
			self[key.rawValue] = newValue
		}
	}
}
