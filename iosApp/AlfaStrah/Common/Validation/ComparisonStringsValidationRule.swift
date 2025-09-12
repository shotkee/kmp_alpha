//
//  ComparisonStringsValidationRule.swift
//  AlfaStrah
//
//  Created by Makson on 28.08.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

import Foundation

class ComparisonStringsValidationRule: ValidationRule {
    private var oldString: String
    
    init(oldString: String){
        self.oldString = oldString
    }
    
    func validate(_ value: String) -> Result<Void, ValidationError> {
        value != oldString ? .success(()) : .failure(ValidationError.notSame)
    }
}
