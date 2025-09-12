//
//  RealmQuestionCategory.swift
//  AlfaStrah
//
//  Created by Eugene Ivanov on 27/05/2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

import RealmSwift

class RealmQuestionCategory: RealmEntity {
    @objc dynamic var id: String = ""
    @objc dynamic var title: String = ""
    let questionGroupList: List<RealmQuestionGroup> = .init()
}

class RealmQuestionGroup: RealmEntity {
    @objc dynamic var title: String = ""
    let questionList: List<RealmQuestion> = .init()
}
