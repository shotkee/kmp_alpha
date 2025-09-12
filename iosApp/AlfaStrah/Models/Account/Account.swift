//
//  Account.swift
//  AlfaStrah
//
//  Created by Eugene Ivanov on 31/01/2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

// sourcery: transformer
class Account: Equatable {
    // sourcery: enumTransformer
    enum Mode: Int {
        // sourcery: defaultCase
        case normal = 0
        case demo = 1
    }
    
    // sourcery: enumTransformer
    enum AdditionAvailabilty: String {
        case medicalFileStorage = "medicalfilestorage"
    }

    // sourcery: transformer = IdTransformer<Any>()
    var id: String
    // sourcery: transformer.name = "first_name"
    var firstName: String
    // sourcery: transformer.name = "last_name"
    var lastName: String
    // sourcery: transformer.name = "patronymic"
    var patronymic: String?
    // sourcery: transformer.name = "phone"
    var phone: Phone
    // sourcery: transformer.name = "birth_date", transformer = "TimestampTransformer<Any>(scale: 1)"
    var birthDate: Date
    // sourcery: transformer.name = "email"
    var email: String
    // sourcery: transformer.name = "unconfirmed_phone"
    var unconfirmedPhone: Phone?
    // sourcery: transformer.name = "unconfirmed_email"
    var unconfirmedEmail: String?
    // sourcery: transformer.name = "is_demo"
    var isDemo: Account.Mode
    // sourcery: transformer.name = "additions"
    let additions: [AdditionAvailabilty]
	// sourcery: transformer.name = "profile_banners"
	let profileBanners: [Bonus]

    var planePhone: String {
        phone.plain
    }
    var humanReadable: String {
        phone.humanReadable
    }

    init(
        id: String,
        firstName: String,
        lastName: String,
        patronymic: String?,
        phone: Phone,
        birthDate: Date,
        email: String,
        unconfirmedPhone: Phone?,
        unconfirmedEmail: String?,
        isDemo: Mode,
        additions: [AdditionAvailabilty],
		profileBanners: [Bonus]
    ) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.patronymic = patronymic
        self.phone = phone
        self.birthDate = birthDate
        self.email = email
        self.unconfirmedPhone = unconfirmedPhone
        self.unconfirmedEmail = unconfirmedEmail
        self.isDemo = isDemo
        self.additions = additions
		self.profileBanners = profileBanners
    }

    var fullName: String {
        [ lastName, firstName, patronymic ?? "" ].filter { !$0.isEmpty }.joined(separator: " ")
    }

    static func == (lhs: Account, rhs: Account) -> Bool {
        lhs.id == rhs.id
        && lhs.fullName == rhs.fullName
        && lhs.phone == rhs.phone
        && lhs.birthDate == rhs.birthDate
        && lhs.email == rhs.email
        && lhs.unconfirmedPhone == rhs.unconfirmedPhone
        && lhs.unconfirmedEmail == rhs.unconfirmedEmail
        && lhs.isDemo == rhs.isDemo
        && lhs.additions == rhs.additions
    }
}
