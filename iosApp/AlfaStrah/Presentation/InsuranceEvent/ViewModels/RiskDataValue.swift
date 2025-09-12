//
//  RiskDataValue.swift
//  AlfaStrah
//
//  Created by Igor Pokrovsky on 19/01/2018.
//  Copyright © 2018 RedMadRobot. All rights reserved.
//

struct RiskDataValue {
    enum Value {
        case text(String)
        case radio(optionId: String)
        case checkbox(value: Bool)
        case decimalSelect(value: String, optionId: String)
        case date(String)
        case time(String)
        case decimal(String)
    }

    var riskDataId: String
    var value: Value
}
