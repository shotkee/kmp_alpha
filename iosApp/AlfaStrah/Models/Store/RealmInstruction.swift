//
//  RealmInstruction.swift
//  AlfaStrah
//
//  Created by Evgeny Ivanov on 12/04/2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

import RealmSwift

class RealmInstruction: RealmEntity {
    @objc dynamic var id: String = ""
    @objc dynamic var title: String = ""
    @objc dynamic var fullDescription: String = ""
    @objc dynamic var shortDescription: String = ""
    @objc dynamic var lastModified: Date = Date()
    @objc dynamic var insuranceCategoryId: String = ""
    let steps: List<RealmInstructionStep> = .init()
}

class RealmInstructionStep: RealmEntity {
    @objc dynamic var sortNumber: Int = 0
    @objc dynamic var title: String = ""
    @objc dynamic var fullDescription: String = ""
}
