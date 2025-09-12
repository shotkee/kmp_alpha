//
//  Question.swift
//  AlfaStrah
//
//  Created by Eugene Ivanov on 22/05/2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

// sourcery: transformer
struct Question: Entity {
    // sourcery: transformer = IdTransformer<Any>()
    let id: String
    // sourcery: transformer.name = "is_frequent"
    let isFrequent: Bool
    // sourcery: transformer.name = "question_text"
    let questionText: String

    // sourcery: transformer.name = "answer_full"
    let answerHtml: String

    // sourcery: transformer.name = "last_modified", transformer = "TimestampTransformer<Any>(scale: 1)"
    var lastModified: Date
}
