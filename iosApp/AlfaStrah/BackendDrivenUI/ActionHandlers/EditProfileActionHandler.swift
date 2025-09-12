//
//  EditProfileActionHandler.swift
//  AlfaStrah
//
//  Created by vit on 06.03.2025.
//  Copyright © 2025 Touch Instinct. All rights reserved.
//

extension BDUI {
	class EditProfileActionHandler: ActionHandler<EditProfileActionDTO> {
		required init(
			block: EditProfileActionDTO
		) {
			super.init(block: block)
			
			work = { from, _, syncCompletion in
				self.editProfile(from: from)
					
				syncCompletion()
			}
		}
		
		private func editProfile(from: ViewController) {
			ApplicationFlow.shared.profileFlow.showAccountInfo(from: from)
		}
	}
}
