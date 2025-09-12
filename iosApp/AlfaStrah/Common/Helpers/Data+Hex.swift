//
//  Data+Hex.swift
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 05/09/2018.
//  Copyright © 2018 RedMadRobot. All rights reserved.
//

import Foundation

extension Data {
    var hexadecimal: String {
        let string = reduce("") { result, byte in
            result + String(format: "%02x", byte)
        }
        return string
    }
}
