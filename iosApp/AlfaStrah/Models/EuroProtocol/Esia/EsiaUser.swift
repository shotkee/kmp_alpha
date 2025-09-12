//
//  EsiaUser
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 31.05.2021.
//  Copyright © 2021 Redmadrobot. All rights reserved.
//

// sourcery: transformer
struct EsiaUser {
    // sourcery: transformer = IdTransformer<Any>(), transformer.name = "oid"
    var esiaId: String

    var firstName: String

    var lastName: String

    var middleName: String?
    // sourcery: transformer = "DateTransformer<Any>(format: "yyyy-MM-dd", locale: AppLocale.currentLocale)"
    var birthDate: Date

    var address: String?

    var passport: EsiaPassport

    var drivingLicense: EsiaDriverLicense?

    var mobile: String?

    var email: String?

    var fullName: String {
        [ lastName, firstName, middleName].compactMap { $0 }.joined(separator: " ")
    }
}
