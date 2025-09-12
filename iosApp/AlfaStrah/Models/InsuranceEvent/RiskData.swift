//
//  RiskData
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 24/05/2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

// sourcery: transformer
struct RiskData: Equatable {
    // sourcery: transformer = IdTransformer<Any>()
    var id: String

    // sourcery: transformer.name = "type"
    var kind: RiskData.RiskDataKind

    var title: String?

    // sourcery: transformer.name = "title_options"
    var titleOptions: String?

    // sourcery: transformer.name = "is_required"
    var requiredStatus: RiskData.RequiredStatus

    // sourcery: transformer.name = "risk_data_option_list"
    var options: [RiskDataOption]?

    // sourcery: transformer.name = "available_symbols"
    var validSymbols: [String]?

    // sourcery: transformer.name = "max_length"
    var maxSymbolsLength: Int?

    // sourcery: enumTransformer
    enum RiskDataKind: Int {
        // sourcery: defaultCase
        case text = 0
        case radio = 1
        case checkbox = 2
        case decimalSelect = 3
        // дата в формате DD.MM.YYYY
        case date = 4
        // время в формате HH:MM
        case time = 5
        case decimal = 6
    }

    // sourcery: enumTransformer
    enum RequiredStatus: Int {
        // sourcery: defaultCase
        case optional = 0
        case required = 1

        var isRequired: Bool {
            self == .required
        }
    }
}
