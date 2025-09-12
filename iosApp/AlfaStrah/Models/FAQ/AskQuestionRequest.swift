//
//  AskQuestionModel.swift
//  AlfaStrah
//
//  Created by Eugene Ivanov on 22/05/2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

// sourcery: transformer
struct AskQuestionRequest {
    // sourcery: transformer.name = "question_text"
    let text: String
    let phone: String

    let destination: String?
    // sourcery: transformer.name = "question_id"
    let questionId: Int?
}
