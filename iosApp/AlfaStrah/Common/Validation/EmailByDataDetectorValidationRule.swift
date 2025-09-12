//
//  EmailByDataDetectorValidationRule.swift
//  AlfaStrah
//
//  Created by vit on 31.08.2023.
//  Copyright © 2023 Touch Instinct. All rights reserved.
//

class EmailByDataDetectorValidationRule: ValidationRule {
    private static let dataDetector: NSDataDetector? = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
    
    func validate(_ value: String) -> Result<Void, ValidationError> {
        guard let dataDetector = Self.dataDetector
        else { return .success(()) } // backend validate data
        
        let length = value.count
        let matches = dataDetector.matches(in: value, range: NSRange(location: 0, length: length))
        
        if let emailMatch = matches[safe: 0],
           emailMatch.range.length == length,
           emailMatch.url?.scheme == "mailto" {
            return .success(())
        }
        
        return .failure(ValidationError.emailByDataDetector)
    }
}
