//
//  EmailValidationRule.swift
//  AlfaStrah
//
//  Created by vit on 23.01.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

class EmailValidationRule: ValidationRule {
    func validate(_ value: String) -> Result<Void, ValidationError> {
        return emailHasWrongFormat(value) ? .success(()) : .failure(ValidationError.wrongFormat)
    }
    
    private func emailHasWrongFormat(_ text: String) -> Bool {
        if text.isEmpty {
            return false
        }

        return EmailHelper.isValidEmail(text)
    }
}
