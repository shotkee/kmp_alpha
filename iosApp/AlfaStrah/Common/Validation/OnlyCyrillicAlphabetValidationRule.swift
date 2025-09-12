//
//  OnlyCyrillicAlphabetValidationRule.swift
//  AlfaStrah
//
//  Created by Vitaly Shkinev on 28.11.2022.
//  Copyright © 2022 Touch Instinct. All rights reserved.
//

class OnlyCyrillicAlphabetValidationRule: ValidationRule {
    func validate(_ value: String) -> Result<Void, ValidationError> {
        return hasOnlyCyrillicCharacters(value) ? .success(()) : .failure(ValidationError.cyrillicOnly)
    }
    
    private func hasOnlyCyrillicCharacters(_ text: String) -> Bool {
        if text.isEmpty {
            return false
        }
        
        let cyrillicSymbols = "абвгдежзийклмнопрстуфхцчшщьюяАБВГДЕЖЗИЙКЛМНОПРСТУФХЦЧШЩЬЮЯ"

        for symbol in text {
            if !cyrillicSymbols.contains(symbol) && symbol.isLetter {
                return false
            }
        }
        return true
    }
}
