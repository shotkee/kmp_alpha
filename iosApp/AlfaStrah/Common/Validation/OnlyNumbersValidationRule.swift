//
//  NumberContainsOnlyValidationRule.swift
//  AlfaStrah
//
//  Created by Nikita Omelchenko on 29.01.2021.
//  Copyright © 2021 Redmadrobot. All rights reserved.
//

class OnlyNumbersValidationRule: ValidationRule {
    func validate(_ value: String) -> Result<Void, ValidationError> {
        let isValid = CharacterSet.decimalDigits.isSuperset(of: CharacterSet(charactersIn: value))

        return isValid ? .success(()) : .failure(ValidationError.numbersOnly)
    }
}
