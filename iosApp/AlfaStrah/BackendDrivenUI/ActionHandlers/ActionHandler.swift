//
//  ActionHandler.swift
//  AlfaStrah
//
//  Created by vit on 05.03.2025.
//  Copyright © 2025 Touch Instinct. All rights reserved.
//

import Legacy

extension BDUI {
	class ActionHandler<A: ActionDTO>: Handler, ActionInitializable {
		let block: A
				
		required init(
			block: A
		) {
			self.block = block
			
			super.init()
		}
	}
	
	class Handler: NSObject {
		typealias FormData = Any
		typealias CompletionCallback = (
			_ from: ViewController,
			_ replaceFormData: @escaping (FormData?) -> Void,
			_ syncCompletion: @escaping () -> Void
		) -> Void
		
		let disposeBag: DisposeBag = DisposeBag()
		
		var isModal: Bool?
		var flow: ActionHandlerFlow?
		var formDataPatchKey: String?
		
		var work: (CompletionCallback)?
	}
}
