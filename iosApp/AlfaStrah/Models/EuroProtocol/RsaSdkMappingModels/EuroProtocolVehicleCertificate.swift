//
//  EuroProtocolVehicleCertificate.swift
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 16.06.2021.
//  Copyright © 2021 Redmadrobot. All rights reserved.
//

import RSASDK

struct EuroProtocolVehicleCertificate: AlfaFromRsaConvertableType {
    var series: String?
    var number: String?

    var isEmpty: Bool {
        series == nil || number == nil
    }

    static func convert(from sdkType: RSASDK.VehicleCertificate) -> EuroProtocolVehicleCertificate {
        EuroProtocolVehicleCertificate(series: sdkType.series, number: sdkType.number)
    }
}
