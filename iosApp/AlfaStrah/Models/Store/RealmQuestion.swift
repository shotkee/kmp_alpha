//
//  RealmQuestion.swift
//  AlfaStrah
//
//  Created by Eugene Ivanov on 27/05/2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

import RealmSwift

class RealmQuestion: RealmEntity {
    @objc dynamic var id: String = ""
    @objc dynamic var questionText: String = ""
    @objc dynamic var answerHtml: String = ""
    @objc dynamic var isFrequent: Bool = false
    @objc dynamic var lastModified: Date = Date()
}
