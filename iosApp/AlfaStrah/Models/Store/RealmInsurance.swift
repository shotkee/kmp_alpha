//
//  RealmInsurance
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 11/02/2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

import Foundation
import RealmSwift

class RealmInsurance: RealmEntity {
    @objc dynamic var id: String = ""
    @objc dynamic var title: String = ""
    @objc dynamic var contractNumber: String = ""
    @objc dynamic var startDate: Date = Date()
    @objc dynamic var endDate: Date = Date()
    @objc dynamic var objectDescription: String?
    @objc dynamic var insurancePremium: String?
    let ownerParticipants: List<RealmInsuranceParticipant> = .init()
    let insurerParticipants: List<RealmInsuranceParticipant> = .init()
    let insuredParticipants: List<RealmInsuranceParticipant> = .init()
    let benefitParticipants: List<RealmInsuranceParticipant> = .init()
    let drivers: List<RealmInsuranceParticipant> = .init()
    @objc dynamic var vehicle: RealmVehicle?
    let tripSegments: List<RealmTripSegment> = .init()
    @objc dynamic var productId: String = ""
    @objc dynamic var renewAvailable: Bool = false
    @objc dynamic var renewUrl: String?
    dynamic var osagoRenewStatus: RealmProperty<Int?> = .init()
    @objc dynamic var renewInsuranceId: String?
    let fieldGroupList: List<RealmInfoFieldGroup> = .init()
    @objc dynamic var insuredObjectTitle: String = ""
    @objc dynamic var emergencyPhone: RealmPhone?
    let sosActivities: List<Int> = .init()
    let clinicIds: List<String> = .init()
    @objc dynamic var accessClinicPhone: Bool = false
    @objc dynamic var type: Int = 0
    @objc dynamic var archiveDate: Date = Date()
    @objc dynamic var pdfURL: String?
    @objc dynamic var helpURL: String?
    @objc dynamic var helpType: String?
    @objc dynamic var passbookAvailable: Bool = false
    @objc dynamic var passbookAvailableOnline: Bool = false
    @objc dynamic var insuranceIdOuter: String?
    @objc dynamic var mobileDeeplinkID: String?
    @objc dynamic var telemedicine: Bool = false
    @objc dynamic var isInsurer: Bool = false
    let isChild: RealmProperty<Bool?> = .init()
    @objc dynamic var company: String?
    @objc dynamic var kidsDoctorPhone: RealmPhone?
    let bills: List<RealmInsuranceBill> = .init()
    @objc dynamic var shouldShowBills: Bool = false
    @objc dynamic var hasUnpaidBills: Bool = false
    @objc dynamic var shouldShowGuaranteeLetters: Bool = false
    @objc dynamic var isFranchiseTransitionAvailable: Bool = false
    let servicesList: List<String> = .init()
    
    override static func primaryKey() -> String? {
        "id"
    }
}
