//
//  CurrencyValidationRule.swift
//  AlfaStrah
//
//  Created by vit on 27.02.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

class CurrencyValidationRule: ValidationRule {
    func validate(_ value: String) -> Result<Void, ValidationError> {
        let isNumerical = CharacterSet.decimalDigits.isSuperset(of: CharacterSet(charactersIn: value))
        
        return hasCurrencyFormat(value) || isNumerical ? .success(()) : .failure(ValidationError.wrongFormat)
    }
    
    private func hasCurrencyFormat(_ text: String) -> Bool {
        let pattern = "((?:\\d+[\\.\\,]\\d{1,2})?)$"
        
        guard let regex = try? NSRegularExpression(pattern: pattern)
        else { return false }
        
        let range = NSRange(location: 0, length: text.count)
        
        guard let match = regex.firstMatch(in: text, options: [], range: range)
        else { return false }
        
        return match.range.length != 0
    }
}
