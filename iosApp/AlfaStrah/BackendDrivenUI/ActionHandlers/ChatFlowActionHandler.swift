//
//  ChatFlowActionHandler.swift
//  AlfaStrah
//
//  Created by vit on 06.03.2025.
//  Copyright © 2025 Touch Instinct. All rights reserved.
//

extension BDUI {
	class ChatFlowActionHandler: ActionHandler<ChatFlowActionDTO> {
		required init(
			block: ChatFlowActionDTO
		) {
			super.init(block: block)
			
			work = { from, _, syncCompletion in
				self.openChatFullscreen(from: from)
				
				syncCompletion()
			}
		}
		
		private func openChatFullscreen(from: ViewController) {
			let chatFlow = ChatFlow()
			ApplicationFlow.shared.container.resolve(chatFlow)
			chatFlow.show(from: from, mode: .fullscreen)
		}
	}
}
