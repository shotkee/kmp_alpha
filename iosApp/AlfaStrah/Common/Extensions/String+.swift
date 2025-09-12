//
//  String+.swift
//  AlfaStrah
//
//  Created by Makson on 18.07.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

import Foundation
import UIKit

extension String {
    func pathExtension() -> String {
        return (self as NSString).pathExtension
    }
    
    func deletingPathExtension() -> String {
        return (self as NSString).deletingPathExtension
    }
    
    func width(withConstrainedHeight height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(
            width: .greatestFiniteMagnitude,
            height: height
        )
        
        let boundingBox = self.boundingRect(
            with: constraintRect,
            options: .usesLineFragmentOrigin,
            attributes: [NSAttributedString.Key.font: font],
            context: nil
        )

        return ceil(boundingBox.width)
    }
	
	func replacingCharacters(
		from characterSet: CharacterSet,
		with replacementString: String
	) -> String
	{
		return self
			.components(separatedBy: characterSet)
			.joined(separator: replacementString)
	}
}
