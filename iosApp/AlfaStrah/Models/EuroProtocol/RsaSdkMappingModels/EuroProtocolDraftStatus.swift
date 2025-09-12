//
//  EuroProtocolDraftStatus.swift
//  AlfaStrah
//
//  Created by Shukhrat Sagatov on 07.09.2021.
//  Copyright © 2021 Redmadrobot. All rights reserved.
//

import RSASDK

enum EuroProtocolDraftStatus: AlfaFromRsaConvertableType {
    case noInviteCode
    case draftNotConfigured
    case myDraftNotFound
    case myDraftRejected
    case partyDraftRejected
    case draftNotFound
    case draftSaved
    case signed
    case waitingForMySign
    case waitingForOtherSign
    case rejected
    case rejectedAgain
    case waiting
    case sentToRegistrate
    case registered(status: String?)
    case timeout
    case sendingServerError

    static func convert(from sdkType: RSASDK.DraftStatus) -> EuroProtocolDraftStatus {
        switch sdkType {
            case .noInviteCode:
                return .noInviteCode
            case .draftNotConfigured:
                return .draftNotConfigured
            case .myDraftNotFound:
                return .myDraftNotFound
            case .myDraftRejected:
                return .myDraftRejected
            case .partyDraftRejected:
                return .partyDraftRejected
            case .draftNotFound:
                return .draftNotFound
            case .draftSaved:
                return .draftSaved
            case .signed:
                return .signed
            case .waitingForMySign:
                return .waitingForMySign
            case .waitingForOtherSign:
                return .waitingForOtherSign
            case .rejected:
                return .rejected
            case .rejectedAgain:
                return .rejectedAgain
            case .waiting:
                return .waiting
            case .sentToRegistrate:
                return .sentToRegistrate
            case .registered(let status):
                return .registered(status: status)
            case .timeout:
                return .timeout
            case .sendingServerError:
                return .sendingServerError
            @unknown default:
                fatalError("Unknown type")
        }
    }

    var description: String {
        switch self {
            case .waitingForMySign:
                return NSLocalizedString("insurance_euro_protocol_notice_status_waiting_for_my_sign", comment: "")
            case .waitingForOtherSign:
                return NSLocalizedString("insurance_euro_protocol_notice_status_waiting_for_other_sign", comment: "")
            case .rejected:
                return NSLocalizedString("insurance_euro_protocol_notice_status_rejected", comment: "")
            case .rejectedAgain:
                return NSLocalizedString("insurance_euro_protocol_notice_status_rejected_again", comment: "")
            case .sentToRegistrate:
                return NSLocalizedString("insurance_euro_protocol_notice_status_sent_to_registrate", comment: "")
            case .registered:
                return NSLocalizedString("insurance_euro_protocol_notice_status_registered", comment: "")
            case .timeout:
                return NSLocalizedString("insurance_euro_protocol_notice_status_timeout", comment: "")
            case .sendingServerError:
                return NSLocalizedString("insurance_euro_protocol_notice_status_sending_server_error", comment: "")
            default:
                return String(describing: self)
        }
    }
}
