//
//  QuestionsFlowActionHandler.swift
//  AlfaStrah
//
//  Created by vit on 06.03.2025.
//  Copyright © 2025 Touch Instinct. All rights reserved.
//

extension BDUI {
	class QuestionsFlowActionHandler: ActionHandler<QuestionsFlowActionDTO> {
		required init(
			block: QuestionsFlowActionDTO
		) {
			super.init(block: block)
			
			work = { from, _, syncCompletion in
				self.openFaq()
				
				syncCompletion()
			}
		}
		
		private func openFaq() {
			guard let controller = self.flow?.initialViewController.topViewController as? ViewController
			else { return }
			
			let flow = QAFlow(rootController: controller)
			ApplicationFlow.shared.container.resolve(flow)
			flow.startModaly()
		}
	}
}
