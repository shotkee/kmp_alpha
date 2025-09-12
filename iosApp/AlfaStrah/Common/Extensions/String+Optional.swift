//
//  String+Optional.swift
//  AlfaStrah
//
//  Created by Makson on 05.08.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

extension Optional where Wrapped == String {
	var isEmptyOrNil: Bool {
		return self?.isEmpty ?? true
	}
}
