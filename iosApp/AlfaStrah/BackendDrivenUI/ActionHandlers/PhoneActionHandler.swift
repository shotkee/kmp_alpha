//
//  PhoneActionHandler.swift
//  AlfaStrah
//
//  Created by vit on 06.03.2025.
//  Copyright © 2025 Touch Instinct. All rights reserved.
//

extension BDUI {
	class PhoneActionHandler: ActionHandler<PhoneActionDTO> {
		required init(
			block: PhoneActionDTO
		) {
			super.init(block: block)
			
			work = { from, _, syncCompletion in
				guard let phone = block.phone
				else {
					syncCompletion()
					return
				}
				
				self.showCallNumberActionSheet(phone: phone, viewController: from)
				
				syncCompletion()
			}
		}
		
		private func showCallNumberActionSheet(
			phone: PhoneComponentDTO,
			viewController: ViewController
		) {
			guard let humanReadable = phone.humanReadable,
				  let plain = phone.plain
			else { return }
			
			let actionSheet = UIAlertController(
				title: humanReadable,
				message: nil,
				preferredStyle: .actionSheet
			)
			
			if phone.canMakeCall ?? false == true {
				let callNumberAction = UIAlertAction(
					title: NSLocalizedString("common_call", comment: ""),
					style: .default
				) { _ in
					
					guard let url = URL(string: "telprompt://" + plain)
					else { return }
					
					UIApplication.shared.open(url, completionHandler: nil)
				}
				actionSheet.addAction(callNumberAction)
			}
			
			if phone.canCopyValue ?? false == true {
				let copyNumberAction = UIAlertAction(
					title: NSLocalizedString("common_copy", comment: ""),
					style: .default,
					handler: { _ in
						UIPasteboard.general.string = plain
					}
				)
				
				actionSheet.addAction(copyNumberAction)
			}
			
			let cancel = UIAlertAction(
				title: NSLocalizedString(
					"common_cancel_button",
					comment: ""
				),
				style: .cancel,
				handler: nil
			)
			
			actionSheet.addAction(cancel)
			
			viewController.present(
				actionSheet,
				animated: true
			)
		}
	}
}
