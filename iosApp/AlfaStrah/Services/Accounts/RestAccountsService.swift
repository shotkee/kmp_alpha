//
//  RestAccountService.swift
//  AlfaStrah
//
//  Created by Амир Нуриев on 2/5/19.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

import Legacy

final class RestAccountService: AccountService {
    private let rest: FullRestClient
    private let secretKey: String

    private let sessionService: UserSessionService
    private let applicationSettingsService: ApplicationSettingsService

    private var userAccount: Account? {
        didSet {
            guard userAccount != oldValue else { return }

            accountSubscriptions.fire(userAccount)
        }
    }
    
    private var isGetAccountRequestInProgress = false
    
    private var accountSubscriptions: Subscriptions<Account?> = Subscriptions()
    func subscribeForAccountUpdates(listener: @escaping (Account?) -> Void) -> Subscription {
        accountSubscriptions.add(listener)
    }

    var isAuthorized: Bool {
        sessionService.isSessionAuthorized
    }

    var isDemo: Bool {
        return applicationSettingsService.userAuthType == .demo
    }
    
    var hasMedicalFileStorage: Bool {
        guard let userAccount = userAccount
        else { return false }
        
        return userAccount.additions.contains(.medicalFileStorage)
    }
    
    var isUserAccountDataLoaded: Bool {
        userAccount != nil
    }
    
    private var cancellable: CancellableNetworkTaskContainer?

    init(
        rest: FullRestClient,
        secretKey: String,
        sessionService: UserSessionService,
        applicationSettingsService: ApplicationSettingsService
    ) {
        self.rest = rest
        self.secretKey = secretKey
        self.sessionService = sessionService
        self.applicationSettingsService = applicationSettingsService
    }

    func register(
        account: Account,
        insuranceNumber: String,
        deviceToken: MobileDeviceToken,
        agreedToPersonalDataPolicy: Bool,
        completion: @escaping (Result<RegisterAccountResponse, AlfastrahError>) -> Void
    ) {
        let accountType = applicationSettingsService.accountType

        let (seed, hash) = getSeedAndHash(
            account.phone.plain,
            account.email,
            secretKey: secretKey,
            deviceToken: deviceToken
        )

        rest.create(
            path: "/accounts/register",
            id: nil,
            object: RegisterAccountRequest(
                firstName: account.firstName,
                lastName: account.lastName,
                phoneNumber: account.phone.plain,
                birthDateISO: account.birthDate,
                insuranceNumber: insuranceNumber,
                email: account.email,
                patronymic: account.patronymic,
                type: accountType,
                deviceToken: deviceToken,
                seed: seed,
                hash: hash,
                agreedToPersonalDataPolicy: agreedToPersonalDataPolicy
            ),
            headers: [:],
            requestTransformer: RegisterAccountRequestTransformer(),
            responseTransformer: ResponseTransformer(
                transformer: RegisterAccountResponseTransformer()
            ),
            completion: mapCompletion(completion)
        )
    }

    func confirmCode(
        _ code: String,
        accountId: String,
        completion: @escaping (Result<String, AlfastrahError>) -> Void
    ) {
        rest.create(
            path: "/accounts/\(accountId)/confirm",
            id: nil,
            object: [ "code": code ],
            headers: [:],
            requestTransformer: DictionaryTransformer(
                keyTransformer: CastTransformer<AnyHashable, String>(),
                valueTransformer: CastTransformer<Any, String>()
            ),
            responseTransformer: ResponseTransformer(
                key: "password",
                transformer: CastTransformer<Any, String>()
            ),
            completion: mapCompletion(completion)
        )
    }

    // Creating pass. old_password - code from Verification SMS response
    func updatePassword(
        _ password: String,
        oldPassword: String,
        accountId: String,
        completion: @escaping (Result<SetPasswordResponse, AlfastrahError>) -> Void
    ) {
        rest.partialUpdate(
            path: "/accounts/\(accountId)/password",
            id: nil,
            object: SetPasswordRequest(
                oldPassword: oldPassword,
                password: password
            ),
            headers: [:],
            requestTransformer: SetPasswordRequestTransformer(),
            responseTransformer: ResponseTransformer(transformer: SetPasswordResponseTransformer()),
            completion: mapCompletion { [weak self] result in
                guard let self = self else { return }

                switch result {
                    case .success(let response):
                        self.userAccount = response.account
                        completion(.success(response))
                    case .failure(let error):
                        completion(.failure(error))
                }
            }
        )
    }

    func resetPassword(
        email: String,
        phone: String,
        completion: @escaping (Result<ResetPasswordResponse, AlfastrahError>) -> Void
    ) {
        rest.create(
            path: "/accounts/reset",
            id: nil,
            object: ResetPasswordRequest(email: email, phoneNumber: phone),
            headers: [:],
            requestTransformer: ResetPasswordRequestTransformer(),
            responseTransformer: ResponseTransformer(transformer: ResetPasswordResponseTransformer()),
            completion: mapCompletion(completion)
        )
    }

    func updateAccount(
        _ account: Account,
        newAccountData: Account,
        completion: @escaping (Result<UpdateAccountResponse, AlfastrahError>) -> Void
    ) {
        rest.update(
            path: "/accounts",
            id: nil,
            object: [ "account": newAccountData ],
            headers: [:],
            requestTransformer: DictionaryTransformer(
                keyTransformer: CastTransformer<AnyHashable, String>(),
                valueTransformer: AccountTransformer()
            ),
            responseTransformer: ResponseTransformer(transformer: UpdateAccountResponseTransformer()),
            completion: mapCompletion { [weak self] result in
                guard let self = self else { return }

                switch result {
                    case .success(let updateAccountResponse):
                        self.userAccount = updateAccountResponse.account
                        completion(.success(updateAccountResponse))
                    case .failure(let error):
                        completion(.failure(error))
                }
            }
        )
    }
    
    func getAccount(useCache: Bool, _ completion: @escaping (Result<Account, AlfastrahError>) -> Void) {
        if let userAccount = userAccount, useCache {
            completion(.success(userAccount))
        } else {
            guard isAuthorized else {
                completion(.failure(.network(.auth(error: nil))))
                return
            }
            
            if !isGetAccountRequestInProgress {
                isGetAccountRequestInProgress = true
                self.cancellable = CancellableNetworkTaskContainer()
                let task = rest.read(
                    path: "/accounts/self",
                    id: nil,
                    parameters: [:],
                    headers: [:],
                    responseTransformer: ResponseTransformer(
                        key: "account",
                        transformer: AccountTransformer()
                    ),
                    completion: mapCompletion { [weak self] result in
                        self?.isGetAccountRequestInProgress = false
                        guard let self = self
                        else { return }

                        switch result {
                            case .success(let account):
                                self.userAccount = account
                                completion(.success(account))
                            case .failure(let error):
                                completion(.failure(error))
                        }
                    }
                )
                cancellable?.addCancellables([ task ])
            }
        }
    }

    func resendSms(
        accountId: String,
        completion: @escaping (Result<ResendSmsResponse, AlfastrahError>) -> Void
    ) {
        rest.create(
            path: "/accounts/\(accountId)/confirm/resend_sms",
            id: nil,
            object: [ "account_id": accountId ],
            headers: [:],
            requestTransformer: DictionaryTransformer(
                keyTransformer: CastTransformer<AnyHashable, String>(),
                valueTransformer: CastTransformer<Any, String>()
            ),
            responseTransformer: ResponseTransformer(transformer: ResendSmsResponseTransformer()),
            completion: mapCompletion(completion)
        )
    }

    func verifyPassword(
        _ password: String,
        accountId: String,
        completion: @escaping (Result<Bool, AlfastrahError>) -> Void
    ) {
        rest.create(
            path: "/accounts/\(accountId)/password",
            id: nil,
            object: [ "password": password ],
            headers: [:],
            requestTransformer: DictionaryTransformer(
                keyTransformer: CastTransformer<AnyHashable, String>(),
                valueTransformer: CastTransformer<Any, String>()
            ),
            responseTransformer: ResponseTransformer(
                key: "valid",
                transformer: CastTransformer<Any, Bool>()
            ),
            completion: mapCompletion(completion)
        )
    }

    func verifyPhone(
        code: String,
        completion: @escaping (Result<Bool, AlfastrahError>) -> Void
    ) {
        rest.create(
            path: "/accounts/phone/verify",
            id: nil,
            object: [ "code": code ],
            headers: [:],
            requestTransformer: DictionaryTransformer(
                keyTransformer: CastTransformer<AnyHashable, String>(),
                valueTransformer: CastTransformer<Any, String>()
            ),
            responseTransformer: ResponseTransformer(
                key: "success",
                transformer: CastTransformer<Any, Bool>()
            ),
            completion: mapCompletion(completion)
        )
    }

    func verifyEmail(
        code: String,
        completion: @escaping (Result<Bool, AlfastrahError>) -> Void
    ) {
        rest.create(
            path: "/accounts/email/verify",
            id: nil,
            object: [ "code": code ],
            headers: [:],
            requestTransformer: DictionaryTransformer(
                keyTransformer: CastTransformer<AnyHashable, String>(),
                valueTransformer: CastTransformer<Any, String>()
            ),
            responseTransformer: ResponseTransformer(
                key: "success",
                transformer: CastTransformer<Any, Bool>()
            ),
            completion: mapCompletion(completion)
        )
    }
	
	func checkBirthday(
		accountId: String,
		birthday: Date,
		email: String,
		completion: @escaping (Result<CheckBirthdayResponse, AlfastrahError>) -> Void
	) {
		rest.create(
			path: "/api/partner_password_recovery/check_birthday",
			id: nil,
			object: CheckBirthdayRequest(accountId: accountId, birthDate: birthday, email: email),
			headers: [:],
			requestTransformer: CheckBirthdayRequestTransformer(),
			responseTransformer: ResponseTransformer(
				transformer: CheckBirthdayResponseTransformer()
			),
			completion: mapCompletion(completion)
		)
	}
	
	func resendPartnerSmsCode(
		accountId: String,
		completion: @escaping (Result<ResendPartnerSmsCodeResponse, AlfastrahError>) -> Void
	) {
		rest.create(
			path: "/api/partner_password_recovery/resend_phone",
			id: nil,
			object: [ "account_id": accountId ],
			headers: [:],
			requestTransformer: DictionaryTransformer(
				keyTransformer: CastTransformer<AnyHashable, String>(),
				valueTransformer: CastTransformer<Any, String>()
			),
			responseTransformer: ResponseTransformer(
				transformer: ResendPartnerSmsCodeResponseTransformer()
			),
			completion: mapCompletion(completion)
		)
	}
	
	func resendPartnerEmailCode(
		accountId: String,
		completion: @escaping (Result<ResendPartnerEmailCodeResponse, AlfastrahError>) -> Void
	) {
		rest.create(
			path: "/api/partner_password_recovery/resend_email",
			id: nil,
			object: [ "account_id": accountId ],
			headers: [:],
			requestTransformer: DictionaryTransformer(
				keyTransformer: CastTransformer<AnyHashable, String>(),
				valueTransformer: CastTransformer<Any, String>()
			),
			responseTransformer: ResponseTransformer(
				transformer: ResendPartnerEmailCodeResponseTransformer()
			),
			completion: mapCompletion(completion)
		)
	}
	
	func checkPartnerCodes(
		accountId: String,
		emailCode: String,
		smsCode: String,
		completion: @escaping (Result<CheckPartnerCodesResponse, AlfastrahError>) -> Void
	) {
		rest.create(
			path: "/api/partner_password_recovery/codes_confirm",
			id: nil,
			object: CheckPatnerCodesRequest(accountId: accountId, phoneCode: smsCode, emailCode: emailCode),
			headers: [:],
			requestTransformer: CheckPatnerCodesRequestTransformer(),
			responseTransformer: ResponseTransformer(
				transformer: CheckPartnerCodesResponseTransformer()
			),
			completion: mapCompletion(completion)
		)
	}

    func resendPhoneVerificationCode(_ completion: @escaping (Result<Phone, AlfastrahError>) -> Void) {
        rest.create(
            path: "/accounts/phone/verify/resend_sms",
            id: nil,
            object: nil,
            headers: [:],
            requestTransformer: VoidTransformer(),
            responseTransformer: ResponseTransformer(
                key: "phone",
                transformer: PhoneTransformer()
            ),
            completion: mapCompletion(completion)
        )
    }

    func resendVerificationEmail(_ completion: @escaping (Result<String, AlfastrahError>) -> Void) {
        rest.create(
            path: "/accounts/email/verify/resend",
            id: nil,
            object: nil,
            headers: [:],
            requestTransformer: VoidTransformer(),
            responseTransformer: ResponseTransformer(key: "email", transformer: CastTransformer<Any, String>()),
            completion: mapCompletion(completion)
        )
    }

    func passwordRequirements(_ completion: @escaping (Result<[NewPasswordRequirement], AlfastrahError>) -> Void) {
        rest.read(
            path: "/api/user/password/requirement",
            id: nil,
            parameters: [:],
            headers: [:],
            responseTransformer: ResponseTransformer(
                key: "requirement_list",
                transformer: ArrayTransformer(transformer: NewPasswordRequirementTransformer())
            ),
            completion: mapCompletion(completion)
        )
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
            cancellable?.cancel()
            userAccount = nil
        }
    }
}
