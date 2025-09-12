//
//  InteractiveSupportQuestion.swift
//  AlfaStrah
//
//  Created by vit on 18.10.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

import Foundation

// sourcery: transformer
struct InteractiveSupportQuestion {
    // sourcery: transformer.name = "question_id"
    let id: Int
    // sourcery: transformer.name = "title"
    let title: String
    // sourcery: transformer.name = "answers"
    let answers: [InteractiveSupportAnswer]
}

// sourcery: transformer
struct InteractiveSupportQuestionsResponse {
    // sourcery: transformer.name = "questions"
    let questions: [InteractiveSupportQuestion]
    // sourcery: transformer.name = "first_question_id"
    let firstQuestionId: Int
}

// sourcery: transformer
struct InteractiveSupportAnswer {
    // sourcery: enumTransformer, enumTransformer.type = "String"
    enum NextStepType: String {
        // sourcery: enumTransformer.value = "step"
        case nextStep = "step"
        // sourcery: enumTransformer.value = "result"
        case result = "result"
    }
    
    // sourcery: transformer.name = "title"
    let title: String
    // sourcery: transformer.name = "next_step_type"
    let nextStepType: NextStepType
    // sourcery: transformer.name = "next_question_id"
    let nextQuestionId: Int?
    // sourcery: transformer.name = "result_key"
    let key: String?
}
