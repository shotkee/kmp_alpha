//
//  ParticipantBInviteModel.swift
//  AlfaStrah
//
//  Created by Stanislav Rachenko on 28.07.2021.
//  Copyright © 2021 Redmadrobot. All rights reserved.
//

import Foundation

struct ParticipantBInviteModel {
    var firstName: String?
    var lastName: String?
    var middleName: String?
    var birthDate: Date?
    var imageQRCode: UIImage?

    var fullName: String? {
        if firstName != nil || lastName != nil || middleName != nil {
            return [ firstName ?? "", lastName ?? "", middleName ?? "" ].joined(separator: " ")
        } else {
            return nil
        }
    }

    var isInvited: Bool {
        firstName != nil && lastName != nil && birthDate != nil && imageQRCode != nil
    }
}
