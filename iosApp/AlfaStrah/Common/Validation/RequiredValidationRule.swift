//
//  RequiredValidationRule.swift
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 26.10.2020.
//  Copyright © 2020 Redmadrobot. All rights reserved.
//

class RequiredValidationRule: ValidationRule {
    func validate(_ value: String) -> Result<Void, ValidationError> {
        let value = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return !value.isEmpty
            ? .success(())
            : .failure(ValidationError.required)
    }
}
