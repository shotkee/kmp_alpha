//
//  MultipleActionsActionHandler.swift
//  AlfaStrah
//
//  Created by vit on 06.03.2025.
//  Copyright © 2025 Touch Instinct. All rights reserved.
//

extension BDUI {
	class MultipleActionsActionHandler: ActionHandler<MultipleActionsActionDTO>,
										AlertPresenterDependency {
		var alertPresenter: AlertPresenter!
		
		required init(
			block: MultipleActionsActionDTO
		) {
			super.init(block: block)
			
			work = { from, _, syncCompletion in
				guard let actions = block.actions
				else {
					syncCompletion()
					return
				}
				
				/// recursevly handle actions
				for (index, action) in actions.enumerated() {
					if let mode = action.mode {
						switch action.type {
							case .actionLayoutReplaceAsync, .actionLayoutReplace, .actionLayoutFilter:
								break
								
							default:
								BDUI.ActionExecutionSynchronization.proceed(
									priority: index,
									with: mode,
									actionName: action.name ?? "undefined",
									action: { syncCompletion in
										if let topViewController = BDUI.ScreensHierarchyIndexing.activeTab?.topBackendScreenEntry?.viewController as? ViewController {
											self.flow?.handleAction(
												action,
												on: topViewController,
												isModal: self.isModal ?? false,
												syncCompletion: syncCompletion
											)
										} else {
											ErrorHelper.show(error: AlfastrahError.unknownError, alertPresenter: self.alertPresenter)
										}
									}
								)
						}
						
					}
					
					switch action.type {
						case .actionLayoutReplaceAsync, .actionLayoutReplace, .actionLayoutFilter:
							break
							
						default:
							if index == actions.endIndex - 1 {
								BDUI.ActionExecutionSynchronization.startActions {
									syncCompletion()
								}
							}
					}
				}
			}
		}
	}
}
