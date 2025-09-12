//
//  EsiaDriverLicense
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 31.05.2021.
//  Copyright © 2021 Redmadrobot. All rights reserved.
//

// sourcery: transformer
struct EsiaDriverLicense {
    // sourcery: enumTransformer
    enum Kind: String {
        case rus = "RF_DRIVING_LICENSE"
        // sourcery: defaultCase
        case unknown = "date"
    }

    // sourcery: transformer.name = "type"
    var kind: EsiaDriverLicense.Kind

    var series: String

    var number: String

    // sourcery: transformer = "DateTransformer<Any>(format: "yyyy-MM-dd", locale: AppLocale.currentLocale)"
    var issueDate: Date

    // sourcery: transformer = "DateTransformer<Any>(format: "yyyy-MM-dd", locale: AppLocale.currentLocale)"
    var expiryDate: Date
}
