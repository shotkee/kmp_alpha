//
//  AlertActionHandler.swift
//  AlfaStrah
//
//  Created by vit on 06.03.2025.
//  Copyright © 2025 Touch Instinct. All rights reserved.
//

extension BDUI {
	class AlertActionHandler: ActionHandler<AlertActionDTO> {
		required init(
			block: AlertActionDTO
		) {
			super.init(block: block)
			
			work = { from, _, syncCompletion in
				guard let alert = block.alert
				else {
					syncCompletion()
					return
				}
				
				self.showAlert(alert, from: from, completion: { action in
					self.flow?.handleAction(
						action,
						on: from,
						isModal: self.isModal ?? false,
						syncCompletion: nil
					)
				})
			
				syncCompletion()
			}
		}
		
		private func showAlert(
			_ alert: AlertComponentDTO,
			from: ViewController,
			completion: @escaping (ActionDTO) -> Void
		) {
			let actionSheet = UIAlertController(
				title: alert.title,
				message: alert.description,
				preferredStyle: .alert
			)
			
			if let buttons = alert.buttons {
				buttons.forEach { alertButton in
					actionSheet.addAction(
						UIAlertAction(
							title: alertButton.title,
							style: {
								switch $0.style {
									case .`default`, .none:
										return .default
										
									case .destructive:
										return .destructive
										
									case .cancel:
										return .cancel
										
								}
							} (alertButton),
							handler: { _ in
								guard let action = alertButton.action
								else { return }
								
								completion(action)
							}
						)
					)
				}
			}
			
			from.present(
				actionSheet,
				animated: true
			)
		}
	}
}
