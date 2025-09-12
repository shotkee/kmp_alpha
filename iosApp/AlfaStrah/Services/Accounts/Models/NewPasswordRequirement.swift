//
//  NewPasswordRequirement.swift
//  AlfaStrah
//
//  Created by vit on 18.09.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

// sourcery: transformer
struct NewPasswordRequirement {
    // sourcery: enumTransformer, enumTransformer.type = "String"
    enum RegexpExecutionContext {
        // sourcery: enumTransformer.value = "always"
        case showAlways
        // sourcery: enumTransformer.value = "positive"
        case satisfiedIfPositiveResult
        // sourcery: enumTransformer.value = "negative"
        case satisfiedIfNegativeResult
    }
    // sourcery: transformer.name = "title"
    let title: String
    // sourcery: transformer.name = "regexp"
    let regularExpressionString: String?
    // sourcery: transformer.name = "visible"
    let visibilityCondition: RegexpExecutionContext
}
