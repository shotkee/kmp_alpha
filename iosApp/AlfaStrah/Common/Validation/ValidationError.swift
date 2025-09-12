//
//  ValidationError.swift
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 26.10.2020.
//  Copyright © 2020 Redmadrobot. All rights reserved.
//

enum ValidationError: Error {
    case required
    case length(count: Int)
    case lengthMinMax(min: Int, max: Int)
    case numbersOnly
    case notSame
    case cyrillicOnly
    case wrongFormat
    case emailByDataDetector
    case regexp
    
    public var localizedDescription: String? {
        switch self {
            case .length, .numbersOnly, .notSame, .cyrillicOnly, .wrongFormat,
                    .lengthMinMax, .regexp:
                return nil
            case .required:
                return NSLocalizedString("required_validation_error_description", comment: "")
            case .emailByDataDetector:
                return NSLocalizedString("email_validation_error_description", comment: "")
        }
    }
}
