//
//  EuroProtocolDraftStatus+Icon.swift
//  AlfaStrah
//
//  Created by Shukhrat Sagatov on 10.09.2021.
//  Copyright © 2021 Redmadrobot. All rights reserved.
//

extension EuroProtocolDraftStatus {
    var icon: UIImage? {
        switch self {
            case .waitingForOtherSign, .waitingForMySign, .noInviteCode, .signed, .waiting, .draftNotConfigured,
                    .draftNotFound, .myDraftNotFound, .draftSaved, .sentToRegistrate:
                return UIImage(named: "icon-clock")
            case .rejected, .rejectedAgain, .timeout, .sendingServerError, .myDraftRejected, .partyDraftRejected:
                return UIImage(named: "icon-close")
            case .registered:
                return UIImage(named: "icon-checkmark-black")
        }
    }
}
