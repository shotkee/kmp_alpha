//
//  Car
//  AlfaStrah
//
//  Created by Станислав Старжевский on 11.12.2017.
//  Copyright © 2017 RedMadRobot. All rights reserved.
//

import Foundation

// sourcery: transformer
struct Vehicle: Entity {
    // sourcery: transformer.name = "reg_number"
    var registrationNumber: String?

    var power: String?

    var vin: String?

    // sourcery: transformer.name = "issue_year", transformer = "DateTransformer<Any>(format: "yyyy", locale: AppLocale.currentLocale)"
    var yearOfIssue: Date?

    // sourcery: transformer.name = "cert_seria"
    var registrationCertificateSeries: String?

    // sourcery: transformer.name = "cert_number"
    var registrationCertificateNumber: String?

    // sourcery: transformer.name = key_count, transformer = "NumberStringTransformer<Any, Int>()"
    var keyCount: Int?

    // sourcery: transformer.name = "passport_seria"
    var passportSeries: String?

    // sourcery: transformer.name = "passport_number"
    var passportNumber: String?
}
/*
 reg_number
 String
 Гос. номер


 power
 String
 Мощность двигателя

 vin    String    VIN

 issue_year    Int    Год выпуска

 cert_seria    String    Серия свидетельства о регистрации

 cert_number    String    Номер свидетельства о регистрации

 key_count    Int    Количество комплектов ключей

 passport_seria    String    Серия паспорта ТС

 passport_number    String    Номер паспорта ТС

 */
