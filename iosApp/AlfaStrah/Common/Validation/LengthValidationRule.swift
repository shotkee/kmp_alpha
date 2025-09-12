//
//  CardNumberValidationRule.swift
//  AlfaStrah
//
//  Created by Nikita Omelchenko on 28.01.2021.
//  Copyright © 2021 Redmadrobot. All rights reserved.
//

class LengthValidationRule: ValidationRule {
    private let minChars: Int
    private let maxChars: Int

    init(countChars: Int) {
        self.minChars = countChars
        self.maxChars = countChars
    }
    
    init(minChars: Int = 0, maxChars: Int) {
        self.minChars = minChars
        self.maxChars = maxChars
    }
    
    func validate(_ value: String) -> Result<Void, ValidationError> {
        let isValid = value.count >= minChars && value.count <= maxChars

        return isValid ? .success(()) : .failure(ValidationError.length(count: maxChars))
    }
}
