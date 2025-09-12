//
//  TextRoutines.swift
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 24/07/2018.
//  Copyright © 2018 RedMadRobot. All rights reserved.
//

import UIKit

enum TextHelper {
    static func maximize(
        textView: UITextView,
        heightConstraint: NSLayoutConstraint,
        minHeight: CGFloat,
        maxHeight: CGFloat,
        animation: () -> Void
    ) {
        let size = textView.sizeThatFits(CGSize(width: textView.frame.width, height: maxHeight))
        let height = min(max(size.height, minHeight), maxHeight)

        let updateOffset = {
            if size.height > height {
                if textView.selectedRange.location == textView.text.utf16.count {
                    textView.setContentOffset(CGPoint(x: 0, y: size.height - height), animated: true)
                }
            } else if size.height == height {
                textView.setContentOffset(.zero, animated: true)
            }
        }

        let heightChanged = abs(heightConstraint.constant - height) > 0.1
        if heightChanged {
            heightConstraint.constant = height
            animation()
        }
        updateOffset()
    }

    static func html(from string: String) -> NSAttributedString {
        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue as NSNumber
        ]
        let attributedString = string.data(using: .utf8)
            .flatMap { try? NSAttributedString(data: $0, options: options, documentAttributes: nil) }
            ?? NSAttributedString(string: string)
        return attributedString
    }

    static func isAlmostNumeric(_ characters: [Character]?) -> Bool {
        if let characters = characters {
            return numeric.isSubset(of: characters) && characters.count < numeric.count * 2
        } else {
            return false
        }
    }

    static let numeric: Set<Character> = [ "1", "2", "3", "4", "5", "6", "7", "8", "9", "0" ]
}
