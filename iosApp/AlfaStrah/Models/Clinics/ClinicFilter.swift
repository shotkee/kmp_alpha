//
//  ClinicFilter.swift
//  AlfaStrah
//
//  Created by Makson on 22.10.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

import Foundation

extension Clinic
{
	// sourcery: transformer
	struct ClinicFilter
	{
		// sourcery: transformer.name = "title"
		let title: String
		
		// sourcery: transformer.name = "values"
		let values: [String]
	}
}
