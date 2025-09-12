//
//  UITextInput+.swift
//  AlfaStrah
//
//  Created by Makson on 06.08.2024.
//  Copyright © 2024 Touch Instinct. All rights reserved.
//

extension UITextInput
{
	var selectedRange: NSRange?
	{
		guard let range = self.selectedTextRange else { return nil }

		let location = offset(from: beginningOfDocument, to: range.start)
		let length = offset(from: range.start, to: range.end)

		return NSRange(location: location, length: length)
	}
}
