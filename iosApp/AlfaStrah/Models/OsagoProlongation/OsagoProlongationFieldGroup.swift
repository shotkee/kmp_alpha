//
//  OsagoProlongationFieldGroup.swift
//  AlfaStrah
//
//  Created by Nikita Omelchenko on 18.02.2021.
//  Copyright © 2021 Redmadrobot. All rights reserved.
//

// sourcery: transformer
struct OsagoProlongationFieldGroup {
    var title: String?
    var fields: [OsagoProlongationField]

    var isReady: Bool {
        fields.allSatisfy { $0.isReady }
    }
}
