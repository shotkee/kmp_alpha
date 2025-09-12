//
//  Stack.swift
//  AlfaStrah
//
//  Created by vit on 08.08.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

public struct Stack<Element: Equatable> {
	var storage: [Element] = []
	public init() { }
	
	public mutating func push(_ element: Element) {
		storage.append(element)
	}
	
	@discardableResult
	public mutating func pop() -> Element? {
		return storage.popLast()
	}
	
	public func peek() -> Element? {
		return storage.last
	}
	
	public var isEmpty: Bool {
		return storage.isEmpty
	}
	
	public func exist(_ element: Element) -> Bool {
		return storage.contains(where: { $0 == element })
	}
	
	@discardableResult
	public mutating func pop(to: Element) -> Element? {
		var index = storage.count - 1
		
		while storage[index] != to {
			guard index != 0
			else { break }
			
			self.pop()
			
			index -= 1
		}
		
		return storage.isEmpty ? nil : storage.last
	}
}
