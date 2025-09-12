//
//  EuroProtocolWitness.swift
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 16.06.2021.
//  Copyright © 2021 Redmadrobot. All rights reserved.
//

import RSASDK

struct EuroProtocolWitness: RsaSdkConvertableType {
    let surname: String
    let firstname: String
    let middleName: String?
    let address: String
    let phone: String?

    var sdkType: RSASDK.Witness {
        RSASDK.Witness(
            surname: surname,
            firstname: firstname,
            middleName: middleName,
            address: address,
            phone: phone
        )
    }

    static func convert(from sdkType: RSASDK.Witness) -> EuroProtocolWitness {
        EuroProtocolWitness(surname: sdkType.surname, firstname: sdkType.firstname,
            middleName: sdkType.middleName, address: sdkType.address, phone: sdkType.phone)
    }
}

enum EuroProtocolWitnessKind: RsaSdkConvertableType {
    case first
    case second

    var sdkType: RSASDK.WitnessType {
        switch self {
            case .first:
                return .first
            case .second:
                return .second
        }
    }

    static func convert(from sdkType: RSASDK.WitnessType) -> EuroProtocolWitnessKind {
        switch sdkType {
            case .first:
                return .first
            case .second:
                return .second
            @unknown default:
                fatalError("Unknown type")
        }
    }
}
