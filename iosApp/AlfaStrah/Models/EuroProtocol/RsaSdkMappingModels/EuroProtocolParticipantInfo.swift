//
//  EuroProtocolParticipantInfo.swift
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 16.06.2021.
//  Copyright © 2021 Redmadrobot. All rights reserved.
//

import RSASDK

struct EuroProtocolParticipantInfo: AlfaFromRsaConvertableType {
    var transport: EuroProtocolTransport
    var owner: EuroProtocolOwner
    var policy: EuroProtocolInsurancePolicy
    var license: EuroProtocolLicense?
    var driver: EuroProtocolDriver?
    var roadAccidents: EuroProtocolRoadAccidents
    var damages: [EuroProtocolPrivateImageType]
    var damageInsured: Bool

    var isEmpty: Bool {
        transport.isEmpty || owner.isEmpty || policy.isEmpty || (license?.isEmpty ?? true) ||
            (driver?.isEmpty ?? true) || roadAccidents.isEmpty || damages.isEmpty
    }

    static func convert(from sdkType: RSASDK.CurrentDraftContentModel.ParticipantInfo) -> EuroProtocolParticipantInfo {
        EuroProtocolParticipantInfo(
            transport: EuroProtocolTransport.convert(from: sdkType.transport),
            owner: EuroProtocolOwner.convert(from: sdkType.owner),
            policy: EuroProtocolInsurancePolicy.convert(from: sdkType.policy),
            license: sdkType.license.map { EuroProtocolLicense.convert(from: $0) },
            driver: sdkType.driver.map { EuroProtocolDriver.convert(from: $0) },
            roadAccidents: EuroProtocolRoadAccidents.convert(from: sdkType.roadAccidents),
            damages: sdkType.damages.map { EuroProtocolPrivateImageType.convert(from: $0) },
            damageInsured: sdkType.damageInsured
        )
    }
}
