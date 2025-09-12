//
//  OsagoProlongationEditInfo.swift
//  AlfaStrah
//
//  Created by Nikita Omelchenko on 18.02.2021.
//  Copyright © 2021 Redmadrobot. All rights reserved.
//

// sourcery: transformer
struct OsagoProlongationEditInfo {
    var description: String
    var participants: [OsagoProlongationParticipant]

    var isReady: Bool {
        participants.allSatisfy { $0.isReady }
    }
}
