//
//  WebViewEventComponentDTO.swift
//  AlfaStrah
//
//  Created by vit on 16.04.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

extension BDUI {
	class WebViewEventComponentDTO: ComponentDTO {
		enum Key: String {
			case method = "method"
			case postBody = "postBody"
			case url = "url"
			case publicUrl = "publicUrl"
			case openType = "openType"
			case headers = "headers"
		}
		
		enum HandleType: String {
			case webView = "webview"
		}
		
		let method: Method?
		let url: URL?
		let postBody: String?
		let openType: HandleType?
		let publicUrl: URL?
		let headers: [HeaderComponentDTO]?
		
		required init(body: [String: Any]) {
			self.method = Method(rawValue: body[Key.method] as? String ?? "")
			self.url = URL(string: body[Key.url] as? String ?? "")
			self.postBody = body[Key.postBody] as? String
			self.openType = HandleType(rawValue: body[Key.openType] as? String ?? "")
			self.publicUrl = URL(string: body[Key.publicUrl] as? String ?? "")
			self.headers = Self.instantinate(Key.headers, body)
			
			super.init(body: body)
		}
	}
}
