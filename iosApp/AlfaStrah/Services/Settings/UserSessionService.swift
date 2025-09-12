//
//  UserSessionService.swift
//  AlfaStrah
//
//  Created by Eugene Ivanov on 31/01/2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

import Legacy

protocol UserSessionService: Updatable {
    func auth(
        login: String, password: String, type: AccountType, isDemo: SessionType,
        deviceToken: MobileDeviceToken,
        completion: @escaping (Result<Account, AlfastrahError>) -> Void
    )
    func subscribeSession(listener: @escaping (UserSession?) -> Void) -> Subscription
    func switchSession(accountType: AccountType, completion: @escaping (Result<Bool, AlfastrahError>) -> Void)
    func completeSession(completion: @escaping (Result<Bool, AlfastrahError>) -> Void)
    func isValidSession(completion: @escaping (Result<Bool, AlfastrahError>) -> Void)
    func sendDeviceData(
        deviceToken: String,
        completion: @escaping (Result<AppAvailable, AlfastrahError>) -> Void
    )
    func deAuthorizeSession()
    var isSessionAuthorized: Bool { get }
    var session: UserSession? { get set }
    var appAvailableStatus: AppAvailable.AvailabilityStatus? { get }
    func getAppStoreLink(completion: @escaping (Result<String, AlfastrahError>) -> Void)
    
    func update(with session: UserSession)
    func removeCookies()
	func authWithSMSCode(phoneNumber: String, completion: @escaping (Result<AuthSmsCode, AlfastrahError>) -> Void)
	func confirmSMSCode(phone: String, code: String, completion: @escaping (Result<Account, AlfastrahError>) -> Void)
	func resendSMSCode(phoneNumber: String, completion: @escaping (Result<AuthSmsCode, AlfastrahError>) -> Void)
}

// sourcery: enumTransformer
@objc enum SessionType: Int {
    // sourcery: defaultCase
    case normal = 0
    case demo = 1
}

// sourcery: enumTransformer
@objc enum AccountType: Int {
    // sourcery: defaultCase
    case alfaStrah = 0
    case alfaLife = 1
}

// sourcery: enumTransformer
@objc enum AuthType: Int {
    // sourcery: defaultCase
    case notDefined = 0
    case full = 1
    case auto = 2
    case pin = 3
    case biometric = 4
    case demo = 5
}
