//
//  NotSameValidationRule.swift
//  AlfaStrah
//
//  Created by Nikita Omelchenko on 26.02.2021.
//  Copyright © 2021 Redmadrobot. All rights reserved.
//

class NotSameValidationRule: ValidationRule {
    private let oldValues: [String]

    init(_ oldValues: String...) {
        self.oldValues = oldValues
    }

    func validate(_ value: String) -> Result<Void, ValidationError> {
        let isValid = !oldValues.contains(value)

        return isValid ? .success(()) : .failure(ValidationError.notSame)
    }
}
