//
//  QuestionCategory.swift
//  AlfaStrah
//
//  Created by Eugene Ivanov on 22/05/2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

// sourcery: transformer
struct QuestionCategory: Entity {
    // sourcery: transformer = IdTransformer<Any>()
    let id: String
    let title: String
    // sourcery: transformer.name = "question_group_list"
    var questionGroupList: [QuestionGroup]
}

// sourcery: transformer
struct QuestionGroup: Entity {
    let title: String
    // sourcery: transformer.name = "question_list"
    let questionList: [Question]
}
