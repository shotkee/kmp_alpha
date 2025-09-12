//
//  ScreenEntry.swift
//  AlfaStrah
//
//  Created by vit on 19.02.2025.
//  Copyright © 2025 Touch Instinct. All rights reserved.
//

import UIKit

extension BDUI {
	struct ScreenEntry: Equatable {
		var screenId: String
		weak var viewController: UIViewController?
		
		var postData: [FormDataEntryComponentDTO]?
		
		var renderSubscriptions: [() -> Void] = []
		
		static func == (lhs: ScreenEntry, rhs: ScreenEntry) -> Bool {
			return lhs.screenId == rhs.screenId
		}
		
		mutating func subscribeForRender(listener: @escaping () -> Void){
			renderSubscriptions.append(listener)
		}
		
		mutating func startRenderSubscriptions() {
			guard !renderSubscriptions.isEmpty
			else { return }
			
			for subscription in renderSubscriptions {
				subscription()
			}
			
			renderSubscriptions.removeAll()
		}
	}
}
