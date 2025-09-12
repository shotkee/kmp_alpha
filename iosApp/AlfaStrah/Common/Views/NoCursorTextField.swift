//
//  NoCursorTextField.swift
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 23/05/2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

import UIKit

class NoCursorTextField: UITextField {
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        false
    }

    override func selectionRects(for range: UITextRange) -> [UITextSelectionRect] {
        []
    }

    override func caretRect(for position: UITextPosition) -> CGRect {
        .zero
    }
}
