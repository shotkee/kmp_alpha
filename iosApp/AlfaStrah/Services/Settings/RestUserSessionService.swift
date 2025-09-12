//
//  MainUserSessionService.swift
//  AlfaStrah
//
//  Created by Eugene Ivanov on 06/02/2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

import Legacy
import WebKit

class RestUserSessionService: UserSessionService {	
    private let rest: FullRestClient
    private let secretKey: String

    var settingsService: ApplicationSettingsService
    var session: UserSession? {
        didSet {
            settingsService.session = session
            sessionSubscriptions.fire(session)
        }
    }

    private var sessionSubscriptions: Subscriptions<UserSession?> = Subscriptions()

    init(rest: FullRestClient, settingsService: ApplicationSettingsService, secretKey: String) {
        self.rest = rest
        self.secretKey = secretKey
        self.settingsService = settingsService
        session = settingsService.session
    }

    var isSessionAuthorized: Bool {
        !(session?.accessToken ?? "").isEmpty
    }

    private(set) var appAvailableStatus: AppAvailable.AvailabilityStatus?

    func deAuthorizeSession() {
        session = nil
    }

    func subscribeSession(listener: @escaping (UserSession?) -> Void) -> Subscription {
        sessionSubscriptions.add(listener)
    }

    func auth(
        login: String, password: String, type: AccountType, isDemo: SessionType,
        deviceToken: MobileDeviceToken,
        completion: @escaping (Result<Account, AlfastrahError>) -> Void
    ) {
        let (seed, hash) = getSeedAndHash(
            login,
            password,
            secretKey: secretKey,
            deviceToken: deviceToken
        )

        rest.create(
            path: "sessions/establish",
            id: nil,
            object: SignInModel(
                login: login, password: password, type: type, isDemo: isDemo,
                deviceToken: deviceToken,
                seed: seed,
                hash: hash
            ),
            headers: [:],
            requestTransformer: SignInModelTransformer(),
            responseTransformer: ResponseTransformer(transformer: AuthorizationResponseTransformer()),
            completion: mapCompletion { [weak self] result in
                guard let self = self else { return }

                switch result {
                    case .success(let response):
                        self.session = response.session
                        self.settingsService.password = password
                        self.settingsService.accountType = type
                        completion(.success(response.account))
                    case .failure(let error):
                        completion(.failure(error))
                }
            }
        )
    }
    
    func update(with session: UserSession) {
        self.session = session
    }

    func switchSession(accountType: AccountType, completion: @escaping (Result<Bool, AlfastrahError>) -> Void) {
        rest.create(
            path: "sessions/type/change",
            id: nil,
            object: accountType.rawValue,
            headers: [:],
            requestTransformer: SingleParameterTransformer(key: "type", transformer: CastTransformer<Any, Int>()),
            responseTransformer: ResponseTransformer(key: "success", transformer: CastTransformer<Any, Bool>()),
            completion: mapCompletion { [weak self] result in
                guard let self = self else { return }

                switch result {
                    case .success(let response):
                        self.settingsService.accountType = self.settingsService.userTypeForSwitch
                        completion(.success(response))
                    case .failure(let error):
                        completion(.failure(error))
                }
            }
        )
    }

    func completeSession(completion: @escaping (Result<Bool, AlfastrahError>) -> Void) {
        let idString = ""
        rest.delete(path: "sessions/\(idString)",
            id: nil,
            headers: [:],
            responseTransformer: ResponseTransformer(key: "success", transformer: CastTransformer<Any, Bool>()),
            completion: mapCompletion(completion)
        )
    }

    func sendDeviceData(
        deviceToken: String,
        completion: @escaping (Result<AppAvailable, AlfastrahError>) -> Void
    ) {
        let object = DeviceInfoRequest(
            device: "Apple",
            deviceModel: AppInfoService.deviceModel(),
            operatingSystem: .iOS,
            osVersion: AppInfoService.systemVersion(),
            appVersion: AppInfoService.applicationShortVersion,
            deviceToken: deviceToken
        )
        rest.create(
            path: "sessions/device",
            id: nil,
            object: object,
            headers: [:],
            requestTransformer: DeviceInfoRequestTransformer(),
            responseTransformer: ResponseTransformer(transformer: AppAvailableTransformer()),
            completion: mapCompletion { [weak self] result in
                guard let self = self else { return }

                switch result {
                    case .success(let response):
                        self.appAvailableStatus = response.status
                        completion(.success(response))
                    case .failure(let error):
                        completion(.failure(error))
                }
            }
        )
    }

    func isValidSession(completion: @escaping (Result<Bool, AlfastrahError>) -> Void) {
        let idString = ""
        rest.read(
            path: "sessions/\(idString)",
            id: nil,
            parameters: [:],
            headers: [:],
            responseTransformer: ResponseTransformer(key: "success", transformer: CastTransformer<Any, Bool>()),
            completion: mapCompletion(completion)
        )
    }

    func getAppStoreLink(completion: @escaping (Result<String, AlfastrahError>) -> Void) {
        rest.read(
            path: "/appstore",
            id: nil,
            parameters: [:],
            headers: [:],
            responseTransformer: ResponseTransformer(key: "link", transformer: CastTransformer<Any, String>()),
            completion: mapCompletion { result in
                switch result {
                    case .success(let response):
                        completion(.success(response))
                    case .failure(let error ):
                        completion(.failure(error))
                }
            }
        )
    }

    // MARK: - Updatable

    func updateService(isUserAuthorized: Bool, completion: @escaping (Result<Void, ServiceUpdateError>) -> Void) {
        completion(.failure(.notImplemented))
    }

    func performActionAfterAppIsReady(isUserAuthorized: Bool, completion: @escaping (Result<Void, ServiceUpdateError>) -> Void) {
        completion(.failure(.notImplemented))
    }

    func erase(logout: Bool) {
        if logout {
            deAuthorizeSession()
            settingsService.userAuthType = .notDefined
            settingsService.haveAskedAboutTouchId = false
            settingsService.login = nil
            settingsService.password = nil
            settingsService.pin = nil
			settingsService.loginAttempts = 0
            
            removeCookies()
        }
    }
    
    // MARK: - Delete browsing data on logout
    func removeCookies() {
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)

        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(
                    ofTypes: record.dataTypes,
                    for: [record]
                ) {}
            }
        }
    }
	
	func authWithSMSCode(
		phoneNumber: String,
		completion: @escaping (Result<AuthSmsCode, AlfastrahError>) -> Void
	)
	{
		rest.create(
			path: "/api/login/phone",
			id: nil,
			object: [
				"phone_number": phoneNumber,
			],
			headers: [:],
			requestTransformer: DictionaryTransformer(
				keyTransformer: CastTransformer<AnyHashable, String>(),
				valueTransformer: CastTransformer<Any, Any>()
			),
			responseTransformer: ResponseTransformer(transformer: AuthSmsCodeTransformer()),
			completion: mapCompletion(completion)
		)
	}
	
	func confirmSMSCode(
		phone: String,
		code: String,
		completion: @escaping (Result<Account, AlfastrahError>) -> Void
	)
	{
		rest.create(
			path: "/api/login/phone/confirm",
			id: nil,
			object: [
				"phone_number": phone,
				"code": code
			],
			headers: [:],
			requestTransformer: DictionaryTransformer(
				keyTransformer: CastTransformer<AnyHashable, String>(),
				valueTransformer: CastTransformer<Any, String>()
			),
			responseTransformer: ResponseTransformer(transformer: AuthorizationResponseTransformer()),
			completion: mapCompletion { [weak self] result in
				guard let self = self else { return }

				switch result {
					case .success(let response):
						self.session = response.session
						completion(.success(response.account))
					case .failure(let error):
						completion(.failure(error))
				}
			}
		)
	}
	
	func resendSMSCode(
		phoneNumber: String,
		completion: @escaping (Result<AuthSmsCode, AlfastrahError>) -> Void
	)
	{
		rest.create(
			path: "/api/login/phone",
			id: nil,
			object: [
				"phone_number": phoneNumber,
			],
			headers: [:],
			requestTransformer: DictionaryTransformer(
				keyTransformer: CastTransformer<AnyHashable, String>(),
				valueTransformer: CastTransformer<Any, Any>()
			),
			responseTransformer: ResponseTransformer(transformer: AuthSmsCodeTransformer()),
			completion: mapCompletion(completion)
		)
	}
}
