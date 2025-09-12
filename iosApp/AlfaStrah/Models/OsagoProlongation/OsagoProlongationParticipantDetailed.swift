//
//  OsagoProlongationParticipantDetailed.swift
//  AlfaStrah
//
//  Created by Nikita Omelchenko on 18.02.2021.
//  Copyright © 2021 Redmadrobot. All rights reserved.
//

// sourcery: transformer
struct OsagoProlongationParticipantDetailed {
    var description: String

    // sourcery: transformer.name = "field_groups"
    var fieldGroups: [OsagoProlongationFieldGroup]

    var isReady: Bool {
        fieldGroups.allSatisfy { $0.isReady }
    }
}
