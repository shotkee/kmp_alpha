//
//  EsiaPassport
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 31.05.2021.
//  Copyright © 2021 Redmadrobot. All rights reserved.
//

// sourcery: transformer
struct EsiaPassport {
    var isRussian: Bool

    var isVerified: Bool

    var series: String

    var number: String

    // sourcery: transformer = "DateTransformer<Any>(format: "yyyy-MM-dd", locale: AppLocale.currentLocale)"
    var issueDate: Date

    var issuedBy: String
}
