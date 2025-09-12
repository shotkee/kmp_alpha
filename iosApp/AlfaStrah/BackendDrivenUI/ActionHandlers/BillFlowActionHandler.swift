//
//  BillFlowActionHandler.swift
//  AlfaStrah
//
//  Created by vit on 05.03.2025.
//  Copyright © 2025 Touch Instinct. All rights reserved.
//

extension BDUI {
	class BillFlowActionHandler: ActionHandler<BillFlowActionDTO> {
		required init(
			block: BillFlowActionDTO
		) {
			super.init(block: block)
			
			work = { from, _, syncCompletion in
				guard  let insuranceId = self.block.insuranceId,
				   let billId = self.block.billId
				else {
					syncCompletion()
					return
				}
				
				ApplicationFlow.shared.show(item: .insuranceBill(insuranceId, billId))
				syncCompletion()
			}
		}
	}
}
