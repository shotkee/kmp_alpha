//
//  InsuranceParticipant
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 23/08/2018.
//  Copyright © 2018 RedMadRobot. All rights reserved.
//

import Foundation

// sourcery: transformer
struct InsuranceParticipant: Entity {
    // sourcery: transformer.name = "full_name"
    let fullName: String

    // sourcery: transformer.name = "first_name"
    var firstName: String?

    // sourcery: transformer.name = "last_name"
    var lastName: String?

    var patronymic: String?

    // sourcery: transformer.name = "birth_date_iso"
    // sourcery: transformer = "DateTransformer<Any>(format: "yyyy-MM-dd", locale: AppLocale.currentLocale)"
    var birthDate: Date?

    // sourcery: transformer.name = "birth_date"
    // sourcery: transformer = "TimestampTransformer<Any>(scale: 1)"
    var birthDateNonISO: Date?

    var sex: String?

    // sourcery: transformer.name = "contact_information"
    var contactInformation: String?

    // sourcery: transformer.name = "full_address"
    var fullAddress: String?
}
