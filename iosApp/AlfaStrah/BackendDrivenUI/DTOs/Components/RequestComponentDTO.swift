//
//  RequestComponentDTO.swift
//  AlfaStrah
//
//  Created by vit on 19.04.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

extension BDUI {
	class RequestComponentDTO: ComponentDTO {
		enum Key: String {
			case method = "method"
			case postBody = "postBody"
			case url = "url"
			case headers = "headers"
		}
		
		let method: Method?
		let url: URL?
		let postBody: String?
		let headers: [HeaderComponentDTO]?
		
		required init(body: [String: Any]) {
			self.method = Method(rawValue: body[Key.method] as? String ?? "")
			self.url = URL(string: body[Key.url] as? String ?? "")
			self.postBody = body[Key.postBody] as? String
			self.headers = Self.instantinate(Key.headers, body)
			
			super.init(body: body)
		}
	}
	
	class HeaderComponentDTO: ComponentDTO {
		enum Key: String {
			case value = "value"
			case header = "header"
		}
		
		let value: String?
		let header: String?
		
		required init(body: [String: Any]) {
			self.value = body[Key.value] as? String
			self.header = body[Key.header] as? String
			
			super.init(body: body)
		}
	}
}
