//
//  ActionExecution.swift
//  AlfaStrah
//
//  Created by vit on 19.02.2025.
//  Copyright © 2025 Touch Instinct. All rights reserved.
//

extension BDUI {
	struct ActionExecutionSynchronization {
		typealias OperationEntry = (
			mode: ActionDTO.ActionMode,
			priority: Int, name: String?,
			action: (_ completion: (() -> Void)?) -> Void
		)
		
		static var operations: [OperationEntry] = []
		
		static func startActions(_ completion: (() -> Void)? = nil) {
			var sortedByPriorityOperations = operations.sorted { $0.priority > $1.priority }
			
			let completionHandler = { (_ currentActionCompletion: @escaping () -> Void) -> Void in
				DispatchQueue.main.async {
					let operation = sortedByPriorityOperations.popLast()
					
					if sortedByPriorityOperations.isEmpty {
						operations.removeAll()
					}
					
					switch operation?.mode {
						case .async, .none:
							operation?.action(nil)
							currentActionCompletion()
							if operations.isEmpty {
								completion?()
							}
						case .sync:
							operation?.action {
								currentActionCompletion()
								if operations.isEmpty {
									completion?()
								}
							}
					}
				}
			}
			
			func recursive() {
				completionHandler {
					if !Self.operations.isEmpty {
						recursive()
					}
				}
			}
			
			recursive()
		}
		
		static func proceed(
			priority: Int? = nil,
			with mode: ActionDTO.ActionMode,
			actionName: String,
			action: @escaping (_ completion: (() -> Void)?) -> Void
		) {
			guard let priority
			else {
				action(nil)
				return
			}
			
			operations.append((mode, priority, actionName, action))
		}
	}
}
