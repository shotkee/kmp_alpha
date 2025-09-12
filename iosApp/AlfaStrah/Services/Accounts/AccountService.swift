//
//  AccountService.swift
//  AlfaStrah
//
//  Created by Амир Нуриев on 2/1/19.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

import Legacy

protocol AccountService: Updatable {
    var isAuthorized: Bool { get }
    var isDemo: Bool { get }
    var isUserAccountDataLoaded: Bool { get }
    var hasMedicalFileStorage: Bool { get }

    func subscribeForAccountUpdates(listener: @escaping (Account?) -> Void) -> Subscription

    func register(
        account: Account,
        insuranceNumber: String,
        deviceToken: MobileDeviceToken,
        agreedToPersonalDataPolicy: Bool,
        completion: @escaping (Result<RegisterAccountResponse, AlfastrahError>) -> Void
    )

    func confirmCode(
        _ code: String,
        accountId: String,
        completion: @escaping (Result<String, AlfastrahError>) -> Void
    )

    func updatePassword(
        _ password: String,
        oldPassword: String,
        accountId: String,
        completion: @escaping (Result<SetPasswordResponse, AlfastrahError>) -> Void
    )

    func resetPassword(
        email: String,
        phone: String,
        completion: @escaping (Result<ResetPasswordResponse, AlfastrahError>) -> Void
    )

    func updateAccount(
        _ account: Account,
        newAccountData: Account,
        completion: @escaping (Result<UpdateAccountResponse, AlfastrahError>) -> Void
    )

    func getAccount(useCache: Bool, _ completion: @escaping (Result<Account, AlfastrahError>) -> Void)
    
    func resendSms(
        accountId: String,
        completion: @escaping (Result<ResendSmsResponse, AlfastrahError>) -> Void
    )

    func verifyPassword(
        _ password: String,
        accountId: String,
        completion: @escaping (Result<Bool, AlfastrahError>) -> Void
    )

    func verifyPhone(
        code: String,
        completion: @escaping (Result<Bool, AlfastrahError>) -> Void
    )

    func verifyEmail(
        code: String,
        completion: @escaping (Result<Bool, AlfastrahError>) -> Void
    )
	
	func checkBirthday(
		accountId: String,
		birthday: Date,
		email: String,
		completion: @escaping (Result<CheckBirthdayResponse, AlfastrahError>) -> Void
	)
	
	func resendPartnerSmsCode(
		accountId: String,
		completion: @escaping (Result<ResendPartnerSmsCodeResponse, AlfastrahError>) -> Void
	)
	
	func resendPartnerEmailCode(
		accountId: String,
		completion: @escaping (Result<ResendPartnerEmailCodeResponse, AlfastrahError>) -> Void
	)
	
	func checkPartnerCodes(
		accountId: String,
		emailCode: String,
		smsCode: String,
		completion: @escaping (Result<CheckPartnerCodesResponse, AlfastrahError>) -> Void
	)

    func resendPhoneVerificationCode(_ completion: @escaping (Result<Phone, AlfastrahError>) -> Void)

    func resendVerificationEmail(_ completion: @escaping (Result<String, AlfastrahError>) -> Void)
    
    func passwordRequirements(_ completion: @escaping (Result<[NewPasswordRequirement], AlfastrahError>) -> Void)
}
