//
//  MedicalCardFileEntriesGroup.swift
//  AlfaStrah
//
//  Created by Makson on 19.06.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

import Foundation

struct MedicalCardFileEntriesGroup {
    enum Kind {
        case processing
        case successful(Date)
        case search
    }
    let kind: Kind
    var fileEntries: [MedicalCardFileEntry]
}
