//
//  InsuranceRender.swift
//  AlfaStrah
//
//  Created by vit on 02.07.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

import Foundation

// sourcery: transformer
struct InsuranceRender: Entity {
	// sourcery: transformer.name = "method"
	let method: Method
	// sourcery: transformer.name = "postBody"
	let postBody: String?
	// sourcery: transformer.name = "type"
	let type: BackendComponentType
	// sourcery: transformer.name = "url", transformer = "UrlTransformer<Any>()"
	let url: URL?
	// sourcery: transformer.name = "headers"
	let headers: [InsuranceRenderHeader]
}

// sourcery: transformer
struct InsuranceRenderHeader: Entity {
	// sourcery: transformer.name = "value"
	let value: String
	// sourcery: transformer.name = "header"
	let name: String
}
