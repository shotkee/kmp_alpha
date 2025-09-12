//
//  ProductsFlowActionHandler.swift
//  AlfaStrah
//
//  Created by vit on 06.03.2025.
//  Copyright © 2025 Touch Instinct. All rights reserved.
//

extension BDUI {
	class ProductsFlowActionHandler: ActionHandler<ProductsFlowActionDTO> {
		required init(
			block: ProductsFlowActionDTO
		) {
			super.init(block: block)
			
			work = { _, _, syncCompletion in
				ApplicationFlow.shared.show(item: .tabBar(.products))
				
				syncCompletion()
			}
		}
	}
}
