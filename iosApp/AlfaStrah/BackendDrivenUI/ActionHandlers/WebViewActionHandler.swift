//
//  WebViewActionHandler.swift
//  AlfaStrah
//
//  Created by vit on 06.03.2025.
//  Copyright © 2025 Touch Instinct. All rights reserved.
//

extension BDUI {
	class WebViewActionHandler: ActionHandler<WebViewActionDTO> {
		required init(
			block: WebViewActionDTO
		) {
			super.init(block: block)
			
			work = { from, _, syncCompletion in
				guard let event = block.event,
					  let url = event.url
				else {
					syncCompletion()
					return
				}
				
				WebViewer.openDocument(
					url,
					withAuthorization: false,	// NB! Not use default headers from global authorizer
					showShareButton: event.publicUrl != nil ? true : false,
					urlShareable: event.publicUrl,
					from: from,
					customHeaders: event.headers
				)
				
				syncCompletion()
			}
		}
	}
}
