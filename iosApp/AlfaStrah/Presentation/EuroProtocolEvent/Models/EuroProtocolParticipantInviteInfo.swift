//
//  EuroProtocolParticipantInviteInfo.swift
//  AlfaStrah
//
//  Created by Shukhrat Sagatov on 11.08.2021.
//  Copyright © 2021 Redmadrobot. All rights reserved.
//

struct EuroProtocolParticipantInviteInfo {
    var firstName: String
    var lastName: String
    var middleName: String?
    var birthday: Date

    init(firstName: String, lastName: String, middleName: String?, birthday: Date) {
        self.firstName = firstName
        self.lastName = lastName
        // middle name needs to be nil if not present
        self.middleName = middleName == "" ? nil : middleName
        self.birthday = birthday
    }

    var name: String {
        [ lastName, firstName, middleName ?? "" ].joined(separator: " ")
    }
}
