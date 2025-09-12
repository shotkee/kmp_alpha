//
//  NSMutableAttributedString+Replace.swift
//  AlfaStrah
//
//  Created by Peter Tretyakov on 03.04.2020.
//  Copyright © 2020 Redmadrobot. All rights reserved.
//

import UIKit

extension NSMutableAttributedString {
    func replace(_ string: String, with attributedString: NSAttributedString) {
        let range = (self.string as NSString).range(of: string)

        // Guard for preventing localization errors.
        // If there is no desired string in NSMutableAttributedString,
        // string will be replaced by double exclamation mark (\u{203C}\u{FE0F}) with red text color.
        switch environment {
            case .appStore:
                break
            case .testAdHoc, .stageAdHoc, .prodAdHoc, .test, .stage, .prod:
                guard range.location != NSNotFound else {
                    let exclamation = "\u{203C}\u{FE0F}"
                    let alarm = "\(exclamation) \(string) is absent \(exclamation)"
                    let attributedAlarm = NSAttributedString(string: alarm, attributes: [ .foregroundColor: UIColor.red ])
                    insert(attributedAlarm, at: 0)
                    return
                }
        }

        replaceCharacters(in: range, with: attributedString)
    }
}
