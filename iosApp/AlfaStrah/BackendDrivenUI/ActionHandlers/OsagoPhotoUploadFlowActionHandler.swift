//
//  OsagoPhotoUploadFlowActionHandler.swift
//  AlfaStrah
//
//  Created by vit on 06.03.2025.
//  Copyright © 2025 Touch Instinct. All rights reserved.
//

import SDWebImage

extension BDUI {
	class OsagoPhotoUploadFlowActionHandler: ActionHandler<OsagoPhotoUploadFlowActionDTO>,
											 AlertPresenterDependency,
											 BackendDrivenServiceDependency {
		var alertPresenter: AlertPresenter!
		var backendDrivenService: BackendDrivenService!
		
		required init(
			block: OsagoPhotoUploadFlowActionDTO
		) {
			super.init(block: block)
			
			work = { from, replaceFormData, syncCompletion in
				guard let picker = block.picker
				else {
					syncCompletion()
					return
				}
				
				let flow = OsagoPhotoUploadFlow()
				ApplicationFlow.shared.container.resolve(flow)
								
				flow.showAutoEventPhotosSheet(picker: picker, from: from) { fileIds in
					replaceFormData(fileIds)
				}
				
				syncCompletion()
			}
		}
	}
}
