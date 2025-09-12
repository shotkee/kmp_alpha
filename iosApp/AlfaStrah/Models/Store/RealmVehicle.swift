//
//  RealmVehicle
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 11/02/2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

import Foundation

class RealmVehicle: RealmEntity {
    @objc dynamic var registrationNumber: String?
    @objc dynamic var power: String?
    @objc dynamic var vin: String?
    @objc dynamic var yearOfIssue: Date?
    @objc dynamic var registrationCertificateSeries: String?
    @objc dynamic var registrationCertificateNumber: String?
    @objc dynamic var keyCount: Int = 0
    @objc dynamic var passportSeries: String?
    @objc dynamic var passportNumber: String?
}
