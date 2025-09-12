//
//  ActionHandlerFlow+.swift
//  AlfaStrah
//
//  Created by vit on 05.03.2025.
//  Copyright © 2025 Touch Instinct. All rights reserved.
//

extension BDUI.ActionHandlerFlow {
	static func buildAction<T: BDUI.Action>(
		_ action: BDUI.ActionDTO,
		for _: T.Type
	) -> NSObject? {
		guard let obj = action as? T.A
		else { return nil }
		
		let blockAction = T.init(
			block: obj
		)
		
		return blockAction
	}
	
	static func selectActionHandler(
		for action: BDUI.ActionDTO,
		in flow: BDUI.ActionHandlerFlow,
		isModal: Bool
	) -> BDUI.Handler.CompletionCallback? {
		guard let actionType = BDUI.Mapper.actionEntries[action.type]?.handler
		else { return nil }
		
		if let actionHandler = Self.buildAction(action, for: actionType) as? BDUI.Handler {
			ApplicationFlow.shared.container.resolve(actionHandler)
			actionHandler.flow = flow
			actionHandler.isModal = isModal
			
			return actionHandler.work
		}
		
		return nil
	}
}
