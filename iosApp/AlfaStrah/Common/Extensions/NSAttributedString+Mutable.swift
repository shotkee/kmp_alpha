//
//  NSAttributedString+Mutable.swift
//  AlfaStrah
//
//  Created by Peter Tretyakov on 03.04.2020.
//  Copyright © 2020 Redmadrobot. All rights reserved.
//

import Foundation

extension NSAttributedString {
    var mutable: NSMutableAttributedString {
        NSMutableAttributedString(attributedString: self)
    }
}
