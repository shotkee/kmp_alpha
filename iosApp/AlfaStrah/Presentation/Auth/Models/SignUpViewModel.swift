//
//  SignUpViewModel.swift
//  AlfaStrah
//
//  Created by Evgeny Ivanov on 10/02/2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

class SignUpViewModel {
    var firstName = ""
    var lastName = ""
    var birthDate: Date?
    var mail = ""
    var phoneObject: Phone?
    var policyHTML = ""
    var havePatronymic = true
    var agreedToPersonalDataPolicy = false

    // Optional
    var insuranceNumber = ""
    var patronymic = ""

    func isValid() -> Bool {
        guard
            !firstName.isEmpty,
            !lastName.isEmpty,
            EmailHelper.isValidEmail(mail),
            phoneObject != nil,
            birthDate != nil,
            (patronymic.isEmpty != havePatronymic),
            agreedToPersonalDataPolicy
        else { return false }

        return true
    }

    func toAccount() -> Account? {
        guard
            !firstName.isEmpty,
            !lastName.isEmpty,
            !mail.isEmpty,
            let phone = phoneObject,
            let birhDate = birthDate
        else { return nil }

        return Account(
            id: "",
            firstName: firstName,
            lastName: lastName,
            patronymic: patronymic,
            phone: phone,
            birthDate: birhDate,
            email: mail,
            unconfirmedPhone: nil,
            unconfirmedEmail: nil,
            isDemo: .normal,
            additions: [],
			profileBanners: []
        )
    }
}
