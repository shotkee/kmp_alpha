//
//  RMRAuthPhoneHelper.swift
//  AlfaStrah
//
//  Created by Olga Vorona on 12/11/15.
//  Copyright © 2015 RedMadRobot. All rights reserved.
//

import Foundation

extension NSString {
    // Возвращает номер телефона, у которого цифры закрыты кроме offset сначала и конца
    // +7 (900) 000-00-00 ->  +7 (9**) ***-**-00
    @objc func maskedPhoneString(_ offset: NSInteger) -> String {
        var maskedPhone = ""
        let numbersArray = "0123456789"
        let phoneString = self as String

        var startOffset = offset
        let characters = phoneString
        for (index, char) in characters.enumerated() {
            var newChar = char
            if numbersArray.contains(char) {
                if startOffset > 0 {
                    startOffset -= 1
                } else if characters.count - index > offset {
                    newChar = "*"
                }
            }
            maskedPhone.append(newChar)
        }

        return maskedPhone
    }
}
