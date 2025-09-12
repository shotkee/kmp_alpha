//
//  RegexpValidationRule.swift
//  AlfaStrah
//
//  Created by vit on 19.09.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

class RegexpValidationRule: ValidationRule {
    var isReverse = false
    
    let regexp: String
    
    init(regexp: String, isReverse: Bool = false) {
        var regexp = regexp
        
        regexp.removeFirst()
        regexp.removeLast()
        
        self.regexp = regexp
    }
    
    func validate(_ value: String) -> Result<Void, ValidationError> {
        guard let regex = try? NSRegularExpression(pattern: regexp)
        else { return  .failure(ValidationError.regexp) }
        
        let length = value.count
        let matches = regex.matches(in: value, range: NSRange(location: 0, length: length))
        
        return matches.isEmpty != isReverse ? .failure(ValidationError.regexp) : .success(())
    }
}
