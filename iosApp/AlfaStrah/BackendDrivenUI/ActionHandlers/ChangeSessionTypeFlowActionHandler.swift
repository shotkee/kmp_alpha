//
//  ChangeSessionTypeFlowActionHandler.swift
//  AlfaStrah
//
//  Created by vit on 06.03.2025.
//  Copyright © 2025 Touch Instinct. All rights reserved.
//

extension BDUI {
	class ChangeSessionTypeFlowActionHandler: ActionHandler<ChangeSessionTypeFlowActionDTO>,
											  ApplicationSettingsServiceDependency {
		var applicationSettingsService: ApplicationSettingsService!
		
		required init(
			block: ChangeSessionTypeFlowActionDTO
		) {
			super.init(block: block)
			
			work = { from, _, syncCompletion in
				guard let accountType = block.accountType
				else {
					syncCompletion()
					return
				}
				
				self.switchAccountType(to: accountType, from: from) {
					syncCompletion()
				}
			}
		}
		
		private func switchAccountType(to accountType: AccountType, from: ViewController, completion: @escaping () -> Void) {
			let resultAccountType: AccountType
			
			switch accountType {
				case .alfaLife:
					resultAccountType = .alfaStrah
				case .alfaStrah:
					resultAccountType = .alfaLife
			}
			
			self.applicationSettingsService.accountType = resultAccountType
			
			ApplicationFlow.shared.profileFlow.changeAccountType(
				withIndicator: false,
				from: from,
				completion
			)
		}
	}
}
