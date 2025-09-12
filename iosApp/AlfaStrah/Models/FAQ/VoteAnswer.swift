//
//  VoteAnswer.swift
//  AlfaStrah
//
//  Created by mac on 03.11.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

import Foundation

// sourcery: transformer
struct VoteAnswer {
    // sourcery: enumTransformer, enumTransformer.type = "String"
    enum Answer {
        // sourcery: enumTransformer.value = "yes"
        case positive
        // sourcery: enumTransformer.value = "no"
        case negative
    }

    // sourcery: transformer.name = "question_id"
    let questionId: Int

    // sourcery: transformer.name = "is_usefull"
    let answer: Answer
}
