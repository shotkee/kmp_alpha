//
//  InteractiveSupportQuestionnaireResult.swift
//  AlfaStrah
//
//  Created by vit on 02.11.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

import Foundation
import Legacy

// sourcery: transformer
struct InteractiveSupportQuestionnaireResult {
    // sourcery: enumTransformer, enumTransformer.type = "String"
    enum ActionType: String {
        // sourcery: enumTransformer.value = "screen"
        case showScreen = "screen"
        // sourcery: enumTransformer.value = "callback"
        case phoneCall = "callback"
    }
    
    // sourcery: transformer.name = "type"
    let type: ActionType
    // sourcery: transformer.name = "phone"
    let phone: Phone?
    // sourcery: transformer.name = "detailed_content"
    let content: [InteractiveSupportQuestionnaireResultContent]?
    // sourcery: transformer.name = "button"
    let button: BackendButton?
}

// sourcery: transformer
struct InteractiveSupportQuestionnaireResultContent {
    // sourcery: enumTransformer, enumTransformer.type = "String"
    enum InternalContentType: String {
        // sourcery: enumTransformer.value = "title"
        case title = "title"
        // sourcery: enumTransformer.value = "image"
        case image = "image"
        // sourcery: enumTransformer.value = "answers"
        case answers = "answers"
        // sourcery: enumTransformer.value = "steps"
        case steps = "steps"
    }
    
    // sourcery: transformer.name = "type"
    let internalContentType: InternalContentType
    
    // sourcery: transformer.name = "data"
    let additionalParameters: [String: Any]?
    
    // sourcery: transformer
    struct Answer {
		// sourcery: transformer.name = "title"
        let title: String
		// sourcery: transformer.name = "value"
        let value: String
    }
    
    // sourcery: transformer
    struct Step {
		// sourcery: transformer.name = "image", transformer = "UrlTransformer<Any>()"
        let image: URL
		// sourcery: transformer.name = "image_themed"
		let imageThemed: ThemedValue?
		// sourcery: transformer.name = "text"
        let text: String
    }
    
    enum ContentType {
        case text(String)
        case image(url: URL)
        case answers([Answer])
        case steps([Step])
    }
    
    var contentType: ContentType? {
        struct ParameterKey {
            static let text = "text"
            static let image = "image"
            static let answers = "user_answers"
            static let steps = "steps"
        }
        
        guard let additionalParameters = additionalParameters
        else { return nil }
        
        switch internalContentType {
            case .title:
                guard let text = additionalParameters[ParameterKey.text] as? String
                else { return nil }
                return .text(text)
            case .image:
                guard let path = additionalParameters[ParameterKey.image] as? String,
                      let url = URL(string: path)
                else { return nil }
                
                return .image(url: url)
            case .answers:
                guard let answersToTransform = additionalParameters[ParameterKey.answers]
                else { return nil }
                
                let transformer = ArrayTransformer<Any, InteractiveSupportQuestionnaireResultContentAnswerTransformer>(
                    transformer: InteractiveSupportQuestionnaireResultContentAnswerTransformer()
                )
                
                if let value = transformer.transform(source: answersToTransform).value {
                    return .answers(value)
                }
                
                return nil
                
            case .steps:
                guard let answersToTransform = additionalParameters[ParameterKey.steps]
                else { return nil }
                
                let transformer = ArrayTransformer<Any, InteractiveSupportQuestionnaireResultContentStepTransformer>(
                    transformer: InteractiveSupportQuestionnaireResultContentStepTransformer()
                )
                
                if let value = transformer.transform(source: answersToTransform).value {
                    return .steps(value)
                }
                
                return nil
        }
    }
}
