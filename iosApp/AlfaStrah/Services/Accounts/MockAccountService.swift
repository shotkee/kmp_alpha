//
//  MockAccountService.swift
//  AlfaStrah
//
//  Created by Амир Нуриев on 2/8/19.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

import Legacy

class MockAccountService: AccountService {
    lazy var userAccount: Account? = Constants.mockAccount
    private let accountService: AccountService

    var isAuthorized: Bool {
        accountService.isAuthorized
    }
    
    var isUserAccountDataLoaded: Bool {
        true
    }

    init(accountService: AccountService) {
        self.accountService = accountService
    }

    private var accountSubscriptions: Subscriptions<Account?> = Subscriptions()
    func subscribeForAccountUpdates(listener: @escaping (Account?) -> Void) -> Subscription {
        accountSubscriptions.add(listener)
    }

    var isDemo: Bool {
        accountService.isDemo
    }
    
    var hasMedicalFileStorage: Bool {
        guard let userAccount = userAccount
        else { return false }
        
        return userAccount.additions.contains(.medicalFileStorage)
    }

    private var password: String = "password"

    func register(
        account: Account,
        insuranceNumber: String,
        deviceToken: MobileDeviceToken,
        agreedToPersonalDataPolicy: Bool,
        completion: @escaping (Result<RegisterAccountResponse, AlfastrahError>) -> Void
    ) {
        userAccount = account
        completion(.success(
            RegisterAccountResponse(
                account: account,
                maskedPhoneNumber: Constants.phone.plain,
                otpVerificationResendTimeInterval: 59
            )
        ))
    }

    func confirmCode(_ code: String, accountId: String, completion: @escaping (Result<String, AlfastrahError>) -> Void) {
        completion(.success(password))
    }

    func updatePassword(_ password: String, oldPassword: String, accountId: String,
            completion: @escaping (Result<SetPasswordResponse, AlfastrahError>) -> Void) {
        self.password = password
        completion(.success(SetPasswordResponse(success: true, account: userAccount ?? Constants.mockAccount, message: "")))
    }

    func resetPassword(email: String, phone: String, completion: @escaping (Result<ResetPasswordResponse, AlfastrahError>) -> Void) {
        let account = userAccount ?? Constants.mockAccount
        completion(.success(
            ResetPasswordResponse(
                accountId: account.id,
                phone: account.phone,
                otpVerificationResendTimeInterval: 59,
				passRecoveryFlow: .regular
            )
        ))
    }

    func updateAccount(
        _ account: Account,
        newAccountData: Account,
        completion: @escaping (Result<UpdateAccountResponse, AlfastrahError>) -> Void
    ) {
        let updateAccountResponse = UpdateAccountResponse(account: newAccountData, otpVerificationResendTimeInterval: 59)
        userAccount = newAccountData
        completion(.success(updateAccountResponse))
    }

    func getAccount(useCache: Bool, _ completion: @escaping (Result<Account, AlfastrahError>) -> Void) {
        guard isAuthorized else {
            completion(.failure(.network(.auth(error: nil))))
            return
        }

        if userAccount == nil {
            userAccount = Constants.mockAccount
        }

        completion(.success(Constants.mockAccount))
    }

    func resendSms(accountId: String, completion: @escaping (Result<ResendSmsResponse, AlfastrahError>) -> Void) {
        let response = ResendSmsResponse(
            phone: userAccount?.phone ?? Constants.phone,
            otpVerificationResendTimeInterval: 59
        )
        
        completion(.success(response))
    }

    func verifyPassword(_ password: String, accountId: String, completion: @escaping (Result<Bool, AlfastrahError>) -> Void) {
        if accountId == userAccount?.id && password == self.password {
            completion(.success(true))
        } else {
            completion(.failure(.network(.badUrl)))
        }
    }
	
	func checkBirthday(
		accountId: String,
		birthday: Date,
		email: String,
		completion: @escaping (Result<CheckBirthdayResponse, AlfastrahError>) -> Void
	) {
		completion(
			.success(
				.init(
					accountId: userAccount?.id ?? Constants.mockAccount.id,
					phone: userAccount?.phone ?? Constants.phone,
					email: userAccount?.email ?? Constants.mockAccount.email,
					smsCodeVerificationResendTimeInterval: 40,
					emailCodeVerificationResendTimeInterval: 40
				)
			)
		)
	}

    func clearUserAccount() {
        userAccount = nil
    }

    func verifyPhone(code: String, completion: @escaping (Result<Bool, AlfastrahError>) -> Void) {
        completion(.failure(.network(.badUrl)))
    }

    func verifyEmail(code: String, completion: @escaping (Result<Bool, AlfastrahError>) -> Void) {
        completion(.failure(.network(.badUrl)))
    }
	
	func resendPartnerSmsCode(
		accountId: String,
		completion: @escaping (Result<ResendPartnerSmsCodeResponse, AlfastrahError>) -> Void
	) {
		completion(.success(ResendPartnerSmsCodeResponse(phone: userAccount?.phone ?? Constants.phone, smsCodePartnerResendTimeInterval: 40)))
	}
	
	func resendPartnerEmailCode(
		accountId: String,
		completion: @escaping (Result<ResendPartnerEmailCodeResponse, AlfastrahError>) -> Void
	) {
		completion(.success(ResendPartnerEmailCodeResponse(email: userAccount?.email ?? Constants.mockAccount.email, emailCodePartnerResendTimeInterval: 40)))
	}
	
	func checkPartnerCodes(
		accountId: String,
		emailCode: String,
		smsCode: String,
		completion: @escaping (Result<CheckPartnerCodesResponse, AlfastrahError>) -> Void
	) {
		completion(.success(CheckPartnerCodesResponse(password: "1111")))
	}

    func resendPhoneVerificationCode(_ completion: @escaping (Result<Phone, AlfastrahError>) -> Void) {
        let phone = userAccount?.phone ?? Constants.phone
        completion(.success(phone))
    }

    func resendVerificationEmail(_ completion: @escaping (Result<String, AlfastrahError>) -> Void) {
        completion(.success(Constants.mockAccount.email))
    }
    
    // MARK: - Constants
    private enum Constants {
        static let mockAccount = Account(
			id: "0000000001", firstName: "User", lastName: "McUserface", patronymic: "James", phone: phone,
            birthDate: .distantPast, email: "user@mcuserface.com", unconfirmedPhone: phone,
			unconfirmedEmail: "user@mcuserface.com", isDemo: .normal, additions: [.medicalFileStorage],
			profileBanners: []
		)
        static let phone = Phone(plain: "71234567890", humanReadable: "+7 (123) 456-78-90")
    }

    // MARK: - Updatable

    func updateService(isUserAuthorized: Bool, completion: @escaping (Result<Void, ServiceUpdateError>) -> Void) {
        guard isUserAuthorized
        else { return completion(.failure(.authNeeded)) }

        getAccount(useCache: true, mapUpdateCompletion(completion))
    }
    
    func performActionAfterAppIsReady(isUserAuthorized: Bool, completion: @escaping (Result<Void, ServiceUpdateError>) -> Void) {
        completion(.failure(.notImplemented))
    }

    func erase(logout: Bool) {
        if logout {
            userAccount = nil
        }
    }
    
    func passwordRequirements(_ completion: @escaping (Result<[NewPasswordRequirement], AlfastrahError>) -> Void) {
        completion(.failure(.api(.init(httpCode: 999, internalCode: 0, title: "Not implemented", message: "Not implemented"))))
    }
}
