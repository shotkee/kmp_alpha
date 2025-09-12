//
//  NotificationsListActionHandler.swift
//  AlfaStrah
//
//  Created by vit on 06.03.2025.
//  Copyright © 2025 Touch Instinct. All rights reserved.
//

extension BDUI {
	class NotificationsListActionHandler: ActionHandler<NotificationsListActionDTO>,
										  AccountServiceDependency {
		var accountService: AccountService!
		
		required init(
			block: NotificationsListActionDTO
		) {
			super.init(block: block)
			
			work = { _, _, syncCompletion in
				self.showNotificationsScreen()
					
				syncCompletion()
			}
		}
		
		private func showNotificationsScreen() {
			guard let controller = self.flow?.initialViewController.topViewController
			else { return }
			
			guard !accountService.isDemo else {
				DemoAlertHelper().showDemoAlert(from: controller)
				return
			}
			
			let flow = NotificationsFlow(rootController: controller)
			ApplicationFlow.shared.container.resolve(flow)
			flow.showList(mode: .modal)
		}
	}
}
