//
//  IntegerPartLengthValidationRule.swift
//  AlfaStrah
//
//  Created by vit on 28.02.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

class IntegerPartLengthValidationRule: ValidationRule {
    private let maxChars: Int
    
    init(maxChars: Int) {
        self.maxChars = maxChars
    }
    
    func validate(_ value: String) -> Result<Void, ValidationError> {
        guard !value.isEmpty
        else { return .failure(ValidationError.length(count: maxChars)) }
        
        let parts = value.replacingOccurrences(of: ",", with: ".").split(separator: ".")

        guard let integerPartLength = parts.first?.count
        else { return .failure(ValidationError.length(count: maxChars)) }
        
        return integerPartLength <= maxChars ? .success(()) : .failure(ValidationError.length(count: maxChars))
    }
}
