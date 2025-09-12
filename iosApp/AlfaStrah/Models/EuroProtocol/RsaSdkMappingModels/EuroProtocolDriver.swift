//
//  EuroProtocolDriver.swift
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 16.06.2021.
//  Copyright © 2021 Redmadrobot. All rights reserved.
//

import RSASDK

struct EuroProtocolDriver: AlfaFromRsaConvertableType {
    var address: String?
    var phone: String?
    var document: String?

    var isEmpty: Bool {
        address == nil || phone == nil || document == nil
    }

    static func convert(from sdkType: RSASDK.Driver) -> EuroProtocolDriver {
        EuroProtocolDriver(address: sdkType.address, phone: sdkType.phone, document: sdkType.document)
    }
}
