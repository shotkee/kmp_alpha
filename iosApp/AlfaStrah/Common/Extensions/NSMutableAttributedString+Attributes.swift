//
//  NSMutableAttributedString+Attributes.swift
//  AlfaStrah
//
//  Created by vit on 30.01.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

import Foundation

extension NSMutableAttributedString {
    func applyBold(_ value: String) {
        guard let valueRange = self.string.range(of: value, options: .caseInsensitive)
        else { return }

        let nsValueRange = NSRange(valueRange, in: self.string)

        self.enumerateAttribute(.font, in: nsValueRange) { value, range, _ in
            if let font = value as? UIFont {
                let size = font.fontDescriptor.pointSize
                
                var attributes = font.fontDescriptor.fontAttributes
				
                var traits = (attributes[.traits] as? [UIFontDescriptor.TraitKey: Any]) ?? [:]
                
				traits[.weight] = UIFont.Weight.bold
                attributes[.name] = nil
                attributes[.traits] = traits
                
                let descriptor = UIFontDescriptor(fontAttributes: attributes)
                
                self.addAttributes([.font: UIFont(descriptor: descriptor, size: size)], range: range)
            }
        }
    }
	
	func applyingBold(_ value: String) -> NSMutableAttributedString {
		let newString = NSMutableAttributedString(string: self.string)
		
		guard let valueRange = self.string.range(of: value, options: .caseInsensitive)
		else { return self }

		let nsValueRange = NSRange(valueRange, in: self.string)
		
		let symbolicTraits: UIFontDescriptor.SymbolicTraits = [.traitBold]
				
		self.enumerateAttribute(.font, in: nsValueRange) { value, range, _ in
			if var font = value as? UIFont {
				if let modifiedFontDescriptor = font.fontDescriptor.withSymbolicTraits(symbolicTraits) {
					font = UIFont(descriptor: modifiedFontDescriptor, size: font.pointSize)
					newString.addAttribute(.font, value: font, range: range)
				}
			}
		}
		
		return newString
	}
	    
    func apply(color: UIColor, to value: String) -> NSMutableAttributedString {
        guard let valueRange = self.string.range(of: value, options: .caseInsensitive)
        else { return self }

        let nsValueRange = NSRange(valueRange, in: self.string)
        
        self.addAttribute(.foregroundColor, value: color, range: nsValueRange)
        
        return self
    }
}
