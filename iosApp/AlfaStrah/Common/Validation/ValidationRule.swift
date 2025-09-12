//
//  ValidationRule.swift
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 26.10.2020.
//  Copyright © 2020 Redmadrobot. All rights reserved.
//

protocol ValidationRule {
    func validate(_ value: String) -> Result<Void, ValidationError>
}
