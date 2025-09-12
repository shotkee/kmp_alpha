//
//  OfficesFlowActionHandler.swift
//  AlfaStrah
//
//  Created by vit on 06.03.2025.
//  Copyright © 2025 Touch Instinct. All rights reserved.
//

extension BDUI {
	class OfficesFlowActionHandler: ActionHandler<OfficesFlowActionDTO> {
		required init(
			block: OfficesFlowActionDTO
		) {
			super.init(block: block)
			
			work = { from, _, syncCompletion in
				self.showOffices(from: from)
				
				syncCompletion()
			}
		}
		
		private func showOffices(from: ViewController) {
			let officesFlow = OfficesFlow()
			ApplicationFlow.shared.container.resolve(officesFlow)
			officesFlow.start(from: from)
		}
	}
}
