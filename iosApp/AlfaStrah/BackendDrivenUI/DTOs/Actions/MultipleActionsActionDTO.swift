//
//  MultipleActionsActionDTO.swift
//  AlfaStrah
//
//  Created by vit on 03.03.2025.
//  Copyright © 2025 Touch Instinct. All rights reserved.
//

extension BDUI {
	class MultipleActionsActionDTO: ActionDTO {
		enum Key: String {
			case actions = "actions"
			case action = "action"
			case mode = "mode"
		}
		
		let actions: [ActionDTO]?
		
		required init(body: [String: Any]) {
			if let actionBodiesArray = body[Key.actions] as? [Any] {
				let actions: [ActionDTO] = actionBodiesArray.compactMap {
					if let item = $0 as? [String: Any] {
						let mode = ActionMode(rawValue: item[Key.mode] as? String ?? "sync") ?? .sync

						if let actionRaw = item[Key.action] as? [String: Any] {
							if let action: BDUI.ActionDTO = BDUI.ComponentDTO.mapData(from: actionRaw) {
								action.mode = mode
								
								return action
							}
						}
					}
					return nil
				}
				
				self.actions = actions
			} else {
				self.actions = nil
			}
			
			super.init(body: body)
		}
	}
}
