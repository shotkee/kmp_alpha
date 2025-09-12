//
//  RealmInsuranceParticipant
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 11/02/2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

import Foundation

class RealmInsuranceParticipant: RealmEntity {
    @objc dynamic var fullName: String = ""
    @objc dynamic var firstName: String?
    @objc dynamic var lastName: String?
    @objc dynamic var patronymic: String?
    @objc dynamic var birthDate: Date?
    @objc dynamic var sex: String?
    @objc dynamic var contactInformation: String?
    @objc dynamic var fullAddress: String?
}
