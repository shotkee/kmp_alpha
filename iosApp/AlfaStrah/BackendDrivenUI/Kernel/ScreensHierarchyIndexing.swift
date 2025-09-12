//
//  ScreensHierarchyIndexing.swift
//  AlfaStrah
//
//  Created by vit on 20.02.2025.
//  Copyright © 2025 Touch Instinct. All rights reserved.
//

extension BDUI {
	struct ScreensHierarchyIndexing {
		// MARK: - Screens hierarchy
		class TabStack {
			var topBackendScreenScreenId: String? {
				topBackendScreenEntry?.screenId
			}
			
			var topBackendScreenEntry: ScreenEntry? {
				get {
					screensEntriesStack.peek()
				}
				
				set {
					if let newValue {
						screensEntriesStack.storage[
							screensEntriesStack.storage.index(
								before: screensEntriesStack.storage.endIndex
							)
						] = newValue
					}
				}
			}
			
			var screensEntriesStack = Stack<ScreenEntry>() {
				didSet {
					ScreensHierarchyIndexing.printScreenStack()
				}
			}
		}
		
		static var floatingTab: TabStack?
		static var tabs: [TabStack] = []
		
		static var activeTabIndex: Int = 0 {
			didSet {
				Self.printScreenStack()
			}
		}
		
		static var activeTab: TabStack? {
			if activeTabIndex < 0 {
				return floatingTab
			}
			
			if activeTabIndex >= 0 {
				return tabs[safe: activeTabIndex]
			}
			
			return nil
		}
		
		static func setActiveTab(_ index: Int) {
			Self.activeTabIndex = index
		}
		
		static func initTabIfNeeded(_ tabIndex: Int) {
			guard tabs.count - 1 < tabIndex
			else { return } // no need to initialize
			
			for _ in (tabs.count - 1)..<tabIndex {
				tabs.append(TabStack())
			}
		}
		
		static func printScreenStack() {
			guard let activeTab
			else { return }
			
			print("screens stack -------------")
			
			for entry in activeTab.screensEntriesStack.storage {
				print("screens stack \(entry.screenId)")
			}
		}
	}
}
