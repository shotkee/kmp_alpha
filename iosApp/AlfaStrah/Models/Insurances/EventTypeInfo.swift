//
//  EventTypeInfo
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 15/12/2018.
//  Copyright © 2018 Redmadrobot. All rights reserved.
//

// sourcery: transformer
struct EventTypeInfo {
    // sourcery: transformer = IdTransformer<Any>()
    var id: String

    var title: String

    var type: EventTypeInfo.Kind

    var value: String?

    // sourcery: transformer.name = "available_value_list"
    var availableValues: [String]?

    // sourcery: transformer.name = "is_mandatory"
    var isMandatory: Bool

    // sourcery: transformer.name = "default_value"
    var defaultValue: String?

    // sourcery: transformer.name = "value_list"
    var values: [String]?

    var placeholder: String?

    // sourcery: enumTransformer
    enum Kind: Int {
        // sourcery: defaultCase
        case string = 1
        case list = 2
        case date = 3
        case header = 4
        case stringList = 5
    }
}
