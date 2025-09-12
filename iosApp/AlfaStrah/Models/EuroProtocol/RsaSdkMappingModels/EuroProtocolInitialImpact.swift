//
//  EuroProtocolInitialImpact.swift
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 16.06.2021.
//  Copyright © 2021 Redmadrobot. All rights reserved.
//

import RSASDK

struct EuroProtocolInitialImpact: AlfaFromRsaConvertableType {
    var vechicleType: EuroProtocolVehicleType
    var sector: String

    static func convert(from sdkType: RSASDK.InitialImpact) -> EuroProtocolInitialImpact {
        EuroProtocolInitialImpact(vechicleType: EuroProtocolVehicleType.convert(from: sdkType.typeTS), sector: sdkType.sector)
    }
}
