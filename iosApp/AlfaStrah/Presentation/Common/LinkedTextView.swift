//
//  LinkedTextView.swift
//  AlfaStrah
//
//  Created by vit on 05.09.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

import UIKit

class LinkedTextView: UITextView, UITextViewDelegate {
    private var links: [ LinkArea ] = []

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        setup()
    }

    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        
        setup()
    }
    
    private func setup() {
        delegate = self
        isEditable = false
        isSelectable = true
        isScrollEnabled = false
		
		backgroundColor = .clear
    }
    
    func set(
        text: String,
        userInteractionWithTextEnabled: Bool = true,
        links: [ LinkArea ],
        textAttributes: [NSAttributedString.Key: Any] = Style.TextAttributes.grayInfoText,
		linkColor: UIColor = .Text.textAccent,
		isUnderlined: Bool = true
    ) {
        self.links = links
        
        let mutableString = (text <~ textAttributes).mutable
        
		self.tintColor = linkColor
            
        for link in links {
            let rangeOfLink = NSString(string: mutableString.string).range(of: link.text)
            
            guard rangeOfLink.location != NSNotFound
            else { continue }
            
            var attributes: [NSAttributedString.Key: Any] = [:]
            
            attributes[.link] = link.absoluteString
            
            if isUnderlined {
                attributes[.underlineStyle] = NSUnderlineStyle.single.rawValue
            }
            
            mutableString.addAttributes(
                attributes,
                range: rangeOfLink
            )
        }

        attributedText = mutableString
        
        isUserInteractionEnabled = userInteractionWithTextEnabled
    }
    
    // MARK: - UITextViewDelegate
    func textView(
        _ textView: UITextView,
        shouldInteractWith url: URL,
        in characterRange: NSRange,
        interaction: UITextItemInteraction
    ) -> Bool {
        let link = links.first { $0.absoluteString == url.absoluteString }
        link?.tapHandler(url)
        return false
    }
}
