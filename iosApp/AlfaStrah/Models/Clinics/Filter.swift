//
//  Filter.swift
//  AlfaStrah
//
//  Created by Makson on 22.10.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

import Foundation

// sourcery: transformer
struct ClinicFilter
{
	// sourcery: enumTransformer, enumTransformer.type = "String"
	enum RenderType: String {
		// sourcery: enumTransformer.value = "checkbox"
		case checkbox = "checkbox"
		// sourcery: enumTransformer.value = "specialities"
		case specialities = "specialities"
	}
	
	// sourcery: transformer.name = "title"
	let title: String
	
	// sourcery: transformer.name = "icon"
	let icon: ThemedValue
	
	// sourcery: transformer.name = "information"
	let information: [ClinicFilterInformation]
	
	// sourcery: transformer.name = "values"
	let values: [String]
	
	// sourcery: transformer.name = "render_type"
	let renderType: RenderType
}

// sourcery: transformer
struct ClinicFilterInformation
{
	// sourcery: transformer.name = "title"
	let title: String
	
	// sourcery: transformer.name = "description"
	let description: String
}
