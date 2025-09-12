//
//  EmailHelper.swift
//  AlfaStrah
//
//  Created by Амир Нуриев on 2/20/19.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

enum EmailHelper {
    static func isValidEmail(_ value: String) -> Bool {
        let email = value.trimmingCharacters(in: .whitespacesAndNewlines)
        let components = email.components(separatedBy: "@")
        let isValid =
            components.count >= 2 &&
            !components[0].isEmpty &&
            !components[components.count - 1].isEmpty &&
            components[components.count - 1].contains(".") &&
            components[components.count - 1].split(separator: ".").count % 2 >= 0
        return isValid
    }
}
