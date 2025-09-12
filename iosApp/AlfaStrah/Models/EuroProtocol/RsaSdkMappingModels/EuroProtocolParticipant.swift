//
//  EuroProtocolParticipant.swift
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 16.06.2021.
//  Copyright © 2021 Redmadrobot. All rights reserved.
//

import RSASDK

enum EuroProtocolParticipant: RsaSdkConvertableType {
    case participantA
    case participantB

    var sdkType: RSASDK.ParticipantType {
        switch self {
            case .participantA:
                return .A
            case .participantB:
                return .B
        }
    }

    static func convert(from sdkType: RSASDK.ParticipantType) -> EuroProtocolParticipant {
        switch sdkType {
            case .A:
                return .participantA
            case .B:
                return .participantB
            @unknown default:
                fatalError("Unknown type")
        }
    }
}
