//
//  RsaEuroProtocolService
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 29.03.2021.
//  Copyright © 2021 Redmadrobot. All rights reserved.
//

import Legacy
import RSASDK
import WebKit

// swiftlint:disable file_length

class RsaEuroProtocolService: EuroProtocolService {
    private enum Constatns {
        static let authErrorMaxRetryCount: Int = 3
        static let secureGuidMaxRetryCount: Int = 1
    }
    private var permissionsStatusUpdateSubscriptions: Subscriptions<EuroProtocolServicePermissionsStatus> = Subscriptions()
    private(set) var permissionsStatus: EuroProtocolServicePermissionsStatus = .unknown

    private let rest: FullRestClient
    private let mobileGuidService: MobileGuidService
    private let accountService: AccountService
    private let logger: TaggedLogger?
    private let geoLocationService: GeoLocationService
    private let isProd: Bool
    private let applicationSettingsService: ApplicationSettingsService
    
    init(
        rest: FullRestClient,
        mobileGuidService: MobileGuidService,
        accountService: AccountService,
        geoLocationService: GeoLocationService,
        logger: TaggedLogger?,
        isProd: Bool,
        applicationSettingsService: ApplicationSettingsService
    ) {
        self.rest = rest
        self.mobileGuidService = mobileGuidService
        self.accountService = accountService
        self.geoLocationService = geoLocationService
        self.logger = logger
        self.isProd = isProd
        self.applicationSettingsService = applicationSettingsService
    }

    func subscribeForPermissionsStatusUpdates(listener: @escaping (EuroProtocolServicePermissionsStatus) -> Void) -> Subscription {
        requestPermissions()
        return permissionsStatusUpdateSubscriptions.add(listener)
    }

    private func notifyPermissionsStatus() {
        permissionsStatusUpdateSubscriptions.fire(permissionsStatus)
    }

    private var locationSubscription: Subscription?

    func requestPermissions() {
        locationSubscription = geoLocationService.subscribeForAvailability { [weak self] availability in
            guard let self = self else { return }

            switch availability {
                case .allowedAlways, .allowedWhenInUse:
                    // 2 - Ask camera access permisson
                    Permissions.camera { granted in
                        if granted {
                            // 3 - Ask photo library add only permisson
                            Permissions.photoLibrary(for: .addOnly) { granted in
                                if granted {
                                    self.permissionsStatus = .permissionsGranted
                                    self.notifyPermissionsStatus()
                                } else {
                                    self.permissionsStatus = .photoStoragePermissionRequired
                                    self.notifyPermissionsStatus()
                                }
                            }
                        } else {
                            self.permissionsStatus = .cameraAccessRequired
                            self.notifyPermissionsStatus()
                        }
                    }
                case .denied, .notDetermined, .restricted:
                    self.permissionsStatus = .locationPermissionRequired
                    self.notifyPermissionsStatus()
            }
        }

        // 1 - Ask geolocation permisson
        geoLocationService.requestAvailability(always: true)
    }
    // MARK: - Secure GUID (SDK auth data)

    private var sdkAuthInfo: RSASDK.AuthInfo? {
        guard let sdkToken = esiaData?.sdkAccessToken, let auth = sdkAuthCredentials else { return nil }

        return RSASDK.AuthInfo(secureGuid: auth.sdkAuthData.secureGuid, token: sdkToken)
    }

    struct SdkAuthCredentials {
        let mobileGiud: String
        let sdkAuthData: SdkAuthData
    }

    private var sdkAuthCredentials: SdkAuthCredentials?

    private func updateSdkAuthCredentials(completion: @escaping (Result<Void, EuroProtocolServiceError>) -> Void) {
        func getSdkAuthData(mobileGuid: String, completion: @escaping (Result<Void, EuroProtocolServiceError>) -> Void) {
            getSecureGuid(retryNumber: 0, mobileGuid: mobileGuid) { result in
                switch result {
                    case .success(let sdkAuthData):
                        self.sdkAuthCredentials = SdkAuthCredentials(mobileGiud: mobileGuid, sdkAuthData: sdkAuthData)
                        completion(.success(()))
                    case .failure(let error):
                        completion(.failure(error))
                }
            }
        }

        if let mobileGuid = mobileGuidService.mobileGuid {
            getSdkAuthData(mobileGuid: mobileGuid, completion: completion)
        } else {
            mobileGuidService.updateMobileGuid { result in
                switch result {
                    case .success(let mobileGuid):
                        getSdkAuthData(mobileGuid: mobileGuid, completion: completion)
                    case .failure(let error):
                        completion(.failure(EuroProtocolServiceError.error(error)))
                }
            }
        }
    }

    private func getSecureGuid(
        retryNumber: Int,
        mobileGuid: String,
        completion: @escaping (Result<SdkAuthData, EuroProtocolServiceError>) -> Void
    ) {
        rest.create(
            path: "api/security/secure_guid",
            id: nil,
            object: [ "mobile_guid": "\(mobileGuid)" ],
            headers: [:],
            requestTransformer: DictionaryTransformer(
                keyTransformer: CastTransformer<AnyHashable, String>(),
                valueTransformer: CastTransformer<Any, String>()
            ),
            responseTransformer: ResponseTransformer(transformer: SdkAuthDataTransformer()),
            completion: mapCompletion { [unowned self] result in
                switch result {
                    case .success(let sdkAuthData):
                        completion(.success(sdkAuthData))
                    case .failure(let error):
                        // В случае если этот метод вызывает ошибку, следует запросить его с другим mobile_guid
                        if retryNumber < Constatns.authErrorMaxRetryCount {
                            self.mobileGuidService.updateMobileGuid { result in
                                switch result {
                                    case .success(let mobileGuid):
                                        self.getSecureGuid(retryNumber: retryNumber + 1, mobileGuid: mobileGuid, completion: completion)
                                    case .failure(let error):
                                        completion(.failure(EuroProtocolServiceError.error(error)))
                                }
                            }
                        } else {
                            completion(.failure(EuroProtocolServiceError.error(error)))
                        }
                }
            }
        )
    }

    // MARK: - Esia Link and sdk token

    var esiaUser: EsiaUser? {
        esiaData?.user
    }

    func getEsiaLinkInfo(completion: @escaping (Result<EsiaLinkInfo, EuroProtocolServiceError>) -> Void) {
        rest.read(
            path: "api/esia/link",
            id: nil,
            parameters: [:],
            headers: [:],
            responseTransformer: ResponseTransformer(transformer: EsiaLinkInfoTransformer()),
            completion: mapCompletion { result in
                switch result {
                    case .success(let data):
                        completion(.success(data))
                    case .failure(let error):
                        completion(.failure(EuroProtocolServiceError.error(error)))
                }
            }
        )
    }

    private var esiaData: EsiaUserData?

    func getEsiaUser(tokenScs: String, completion: @escaping (Result<EsiaUserData, EuroProtocolServiceError>) -> Void) {
        rest.create(
            path: "api/esia/profile",
            id: nil,
            object: [ "esia_refresh_token": "\(tokenScs)" ],
            headers: [:],
            requestTransformer: DictionaryTransformer(
                keyTransformer: CastTransformer<AnyHashable, String>(),
                valueTransformer: CastTransformer<Any, String>()
            ),
            responseTransformer: ResponseTransformer(transformer: EsiaUserDataTransformer()),
            completion: mapCompletion { result in
                switch result {
                    case .success(let data):
                        self.esiaData = data
                        completion(.success(data))
                    case .failure(let error):
                        completion(.failure(EuroProtocolServiceError.error(error)))
                }
            }
        )
    }

    // MARK: - Alfastrah

    func reportCreatedOsagoEvent(
        insurance: SeriesAndNumberDocument,
        aisNumber: String,
        completion: @escaping (Result<String, EuroProtocolServiceError>) -> Void
    ) {
        var object = [
            "contract_seria": insurance.series,
            "contract_number": insurance.number,
            "glonass_number": aisNumber
        ]

        if let claimDate = applicationSettingsService.euroProtocolClaimDate {
            let formatter = DateFormatter()
            formatter.timeZone = TimeZone.current
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            
            object["claim_date"] = formatter.string(from: claimDate)
            
            // ISO 8601 time zone format
            formatter.dateFormat = "ZZZZZ"
            object["timezone"] = formatter.string(from: claimDate)
        }
        
        rest.create(
            path: "api/insurances/osagosdk/event_report/create",
            id: nil,
            object: object,
            headers: [:],
            requestTransformer: DictionaryTransformer(
                keyTransformer: CastTransformer<AnyHashable, String>(),
                valueTransformer: CastTransformer<Any, String>()
            ),
            responseTransformer: ResponseTransformer(key: "event_report_id", transformer: CastTransformer<Any, String>()),
            completion: mapCompletion { result in
                switch result {
                    case .success(let reportId):
                        completion(.success(reportId))
                    case .failure(let error):
                        completion(.failure(EuroProtocolServiceError.error(error)))
                }
            }
        )
    }

    // MARK: - Cleanup

    func clearCachedData() {
        sdkAuthCredentials = nil
        esiaData = nil
        hasDisagreements = nil
        aisIdentifier = nil
        aisAlfaRegistrationId = nil
        participantBInviteModel = ParticipantBInviteModel()
        clearWebCookies()
    }

    private func clearWebCookies() {
        DispatchQueue.main.async {
            let cookieStore = WKWebsiteDataStore.default().httpCookieStore
            cookieStore.getAllCookies { cookies in
                cookies.forEach { cookieStore.delete($0) }
            }
        }
    }

    // MARK: - RSA SDK

    var hasDisagreements: Bool? {
        get {
            switch applicationSettingsService.hasDisagreements {
                case .yes:
                    return true
                case .no:
                    return false
                case .none:
                    return nil
            }
        }
        set {
            switch newValue {
                case Optional.some(true):
                    applicationSettingsService.hasDisagreements = .yes
                case Optional.some(false):
                    applicationSettingsService.hasDisagreements = .no
                case nil:
                    applicationSettingsService.hasDisagreements = .none
            }
        }
    }

    var participantBInviteModel: ParticipantBInviteModel {
        get {
            ParticipantBInviteModel(
                firstName: applicationSettingsService.euroProtocolInviteBFirstName,
                lastName: applicationSettingsService.euroProtocolInviteBLastName,
                middleName: applicationSettingsService.euroProtocolInviteBMiddleName,
                birthDate: applicationSettingsService.euroProtocolInviteBBirthDate,
                imageQRCode: applicationSettingsService.euroProtocolInviteBQRCode
            )
        }
        set {
            applicationSettingsService.euroProtocolInviteBFirstName = newValue.firstName
            applicationSettingsService.euroProtocolInviteBLastName = newValue.lastName
            applicationSettingsService.euroProtocolInviteBMiddleName = newValue.middleName
            applicationSettingsService.euroProtocolInviteBBirthDate = newValue.birthDate
            applicationSettingsService.euroProtocolInviteBQRCode = newValue.imageQRCode
        }
    }

    var aisIdentifier: String? {
        get { applicationSettingsService.aisIdentifier }
        set { applicationSettingsService.aisIdentifier = newValue }
    }

    var aisAlfaRegistrationId: String? {
        get { applicationSettingsService.aisAlfaRegistrationIdentifier }
        set { applicationSettingsService.aisAlfaRegistrationIdentifier = newValue }
    }

    func checkActiveSessionPresent() -> Bool {
        // Call SDK 23 with empty auth data. If there is an active session SDK will response with RSASDK.Success
        // This is a temporary solution. Waiting for SDK proper method.
        let response = RSASDK.getCurrentContent(authInfo: .init(secureGuid: "", token: ""))
        switch response {
            case RSASDK.Error.noActiveSession:
                return false
            default:
                return true
        }
    }

    var reviewTimeLeft: TimeInterval? {
        RSASDK.reviewTimeLeft
    }

    /// SDK_1 (initSDK) Инициализация SDK
    func startSdk(completion: @escaping (Result<Void, EuroProtocolServiceError>) -> Void) {
        func environment(_ isProd: Bool) -> RSASDK.ServerEnvironment
        {
            return isProd
                ? .init(
                    glonas: .prod,
                    esia: .prod
                )
                : .init(
                    glonas: .test,
                    esia: .test
                )
        }
        
        self.logger?.debug("SDK_1 (initSDK) Инициализация SDK")
        func authSdk(completion: @escaping (Result<Void, EuroProtocolServiceError>) -> Void) {
            guard
                let authCredentials = sdkAuthCredentials,
                let sdkAuthInfo = sdkAuthInfo
            else { return completion(.failure(.sdkAuthInfoMissing)) }

            RSASDK.initSDK(
                mobileGuid: authCredentials.mobileGiud,
                icLogin: authCredentials.sdkAuthData.login,
                icPassword: authCredentials.sdkAuthData.password,
                environment: environment(isProd),
                authInfo: sdkAuthInfo,
                completion: mapSdkCompletion(completion) { _ in completion(.success(())) }
            )

        }

        updateSdkAuthCredentials { result in
            switch result {
                case .success:
                    authSdk(completion: completion)
                case .failure(let error):
                    completion(.failure(error))
            }
        }
    }

    /// SDK_2 (finalizeSDK) Завершение работы SDK
    func stopSdk(completion: @escaping (Result<Void, EuroProtocolServiceError>) -> Void) {
        authRetryableSdkRequest(
            request: { completion in
                self.logger?.debug("SDK_2 (finalizeSDK) Завершение работы SDK")

                RSASDK.finalizeSDK(
                    authInfo: self.sdkAuthInfo ?? .init(secureGuid: "", token: ""),
                    completion: self.mapSdkCompletion(completion) { _ in
                        self.clearCachedData()
                        completion(.success(()))
                    }
                )
            },
            completion: completion
        )
    }

    /// SDK_4 (setProtectedPhoto) Защищенная фотография
    func protectedPhoto(
        action: EuroProtocolPhotoAction,
        imageType: EuroProtocolPrivateImageType,
        completion: @escaping (Result<UIImage?, EuroProtocolServiceError>) -> Void
    ) {
        authRetryableSdkRequest(
            request: { completion in
                self.logger?.debug("SDK_4 (setProtectedPhoto) Защищенная фотография")
                guard let sdkAuthInfo = self.sdkAuthInfo else { return completion(.failure(.sdkAuthInfoMissing)) }

                RSASDK.setProtectedPhoto(
                    action: action.sdkType,
                    document: imageType.sdkType,
                    cameraOverlay: nil,
                    authInfo: sdkAuthInfo,
                    completion: self.mapSdkCompletion(completion) { sdkSuccess in
                        switch sdkSuccess {
                            case .success:
                                completion(.success(nil))
                            case .image(let image):
                                completion(.success(image))
                            default:
                                completion(.failure(.successResponseParsingError))
                        }
                    }
                )
            },
            completion: completion
        )
    }

    /// SDK_5 (setFreePhoto) Незащищенная фотография
    func freePhoto(
        index: Int,
        action: EuroProtocolPhotoAction,
        completion: @escaping (Result<UIImage?, EuroProtocolServiceError>) -> Void
    ) {
        authRetryableSdkRequest(
            request: { completion in
                self.logger?.debug("SDK_5 (setFreePhoto) Незащищенная фотография")
                guard let sdkAuthInfo = self.sdkAuthInfo else { return completion(.failure(.sdkAuthInfoMissing)) }

                RSASDK.setFreePhoto(
                    action: action.sdkType,
                    document: .place(id: index),
                    cameraOverlay: nil,
                    authInfo: sdkAuthInfo,
                    completion: self.mapSdkCompletion(completion) { sdkSuccess in
                        switch sdkSuccess {
                            case .success:
                                completion(.success(nil))
                            case .image(let image):
                                completion(.success(image))
                            default:
                                completion(.failure(.successResponseParsingError))
                        }
                    }
                )
            },
            completion: completion
        )
    }

    /// SDK_6 (setPolicyInfo) Добавление полиса
    func setPolicyInfo(
        participant: EuroProtocolParticipant,
        seriesAndNumber: SeriesAndNumberDocument,
        completion: @escaping (Result<OSAGOCheckParticipant, EuroProtocolServiceError>) -> Void
    ) {
        authRetryableSdkRequest(
            request: { completion in
                self.logger?.debug("SDK_6 (setPolicyInfo) Добавление полиса")
                guard let sdkAuthInfo = self.sdkAuthInfo else { return completion(.failure(.sdkAuthInfoMissing)) }

                RSASDK.setPolicyInfo(
                    participant: participant.sdkType,
                    type: .osago(series: seriesAndNumber.series, number: seriesAndNumber.number),
                    showQR: false,
                    authInfo: sdkAuthInfo,
                    completion: self.mapSdkCompletion(completion) { sdkSuccess in
                        switch sdkSuccess {
                            case .policy(let info, _):
                                let osagoInfo = OSAGOPolicyInfo(
                                    companyName: info.insurer,
                                    seriesAndNumber: .init(series: info.series, number: info.number),
                                    startDate: info.beginDate,
                                    endDate: info.endDate
                                )
                                let vehicleInfo = OSAGOAutoInfo(
                                    brand: info.mark,
                                    model: info.model,
                                    vin: info.vin,
                                    licensePlate: info.licensePlate
                                )
                                let participant = OSAGOCheckParticipant(policyInfo: osagoInfo, autoInfo: vehicleInfo)
                                completion(.success(participant))
                            default:
                                completion(.failure(.successResponseParsingError))
                        }
                    }
                )
            },
            completion: completion
        )
    }

    /// SDK_7 (setDriverInfo) Передача данных водителя
    func setDriverInfo(info: DriverDocuments, completion: @escaping (Result<String, EuroProtocolServiceError>) -> Void) {
        guard let esiaUser = esiaUser else { return completion(.failure(.sdkAuthInfoMissing)) }
        
        accountService.getAccount(useCache: true) { [weak self] result in
            guard let self = self
            else { return }
            
            switch result {
                case .success(let userAccount):
                    let driver = RSASDK.DriverPersonalInfo(
                        lastname: esiaUser.lastName,
                        firstname: esiaUser.firstName,
                        middlename: esiaUser.middleName,
                        birthdate: esiaUser.birthDate,
                        address: info.address,
                        phone: info.phone,
                        email: esiaUser.email ?? userAccount.email
                    )

                    let document = RSASDK.PassportESIA(
                        isRussian: esiaUser.passport.isRussian,
                        isVerified: esiaUser.passport.isVerified,
                        series: esiaUser.passport.series,
                        number: esiaUser.passport.number,
                        issueDate: esiaUser.passport.issueDate
                    )

                    let categories = info.categoryDriverLicense.map { $0.sdkType }

                    let license = RSASDK.License(
                        series: info.driverLicense.series,
                        number: info.driverLicense.number,
                        categories: categories,
                        issueDate: info.startDateDriverLicense,
                        expiryDate: info.endDateDriverLicense
                    )

                    self.authRetryableSdkRequest(
                        request: { completion in
                            self.logger?.debug("SDK_7 (setDriverInfo) Пsередача данных водителя")
                            guard let sdkAuthInfo = self.sdkAuthInfo else { return completion(.failure(.sdkAuthInfoMissing)) }

                            RSASDK.setDriverInfo(
                                esiaSubjId: esiaUser.esiaId,
                                info: driver,
                                document: document,
                                license: license,
                                authInfo: sdkAuthInfo,
                                completion: self.mapSdkCompletion(completion) { sdkSuccess in
                                    print(sdkSuccess)
                                    switch sdkSuccess {
                                        case .userID(let id):
                                            completion(.success(id))
                                        default:
                                            completion(.failure(.successResponseParsingError))
                                    }
                                }
                            )
                        },
                        completion: completion
                    )
                case .failure(let error):
                    return completion(.failure(.error(error)))
            }
        }
    }

    /// SDK_8 (initLinkQR) Генерация QR-Code приглашения второго участника
    func initLinkQR(
        add participant: EuroProtocolParticipantInviteInfo,
        completion: @escaping (Result<UIImage, EuroProtocolServiceError>) -> Void
    ) {
        authRetryableSdkRequest(
            request: { completion in
                self.logger?.debug("SDK_8 (initLinkQR) Генерация QR-Code приглашения второго участника")
                guard let sdkAuthInfo = self.sdkAuthInfo else { return completion(.failure(.sdkAuthInfoMissing)) }

                RSASDK.initLinkQR(
                    deviceType: .oneDevice(
                        user: (
                            fullName: (
                                surname: participant.lastName,
                                firstname: participant.firstName,
                                middlename: participant.middleName
                            ),
                            birthday: participant.birthday
                        ),
                        showURL: false
                    ),
                    authInfo: sdkAuthInfo,
                    completion: self.mapSdkCompletion(completion) { sdkSuccess in
                        switch sdkSuccess {
                            case .success, .inviteURL:
                                // When succeeded, SDK implementation calls completion three times:
                                // once with .image result that contains actual QR code, with .inviteURL
                                // and another time with .success that has no use
                                break
                            case .image(let image):
                                self.applicationSettingsService.euroProtocolInviteBQRCode = image
                                completion(.success(image))
                            default:
                                completion(.failure(.successResponseParsingError))
                        }
                    }
                )
            },
            completion: completion
        )
    }

    /// SDK_11 (setAccidentCoords) Сохранение координат места ДТП
    func setAccidentCoords(address: String, completion: @escaping (Result<Void, EuroProtocolServiceError>) -> Void) {
        authRetryableSdkRequest(
            request: { completion in
                self.logger?.debug("SDK_11 (setAccidentCoords) Сохранение координат места ДТП")
                guard let sdkAuthInfo = self.sdkAuthInfo else { return completion(.failure(.sdkAuthInfoMissing)) }

                RSASDK.setAccidentCoords(
                    address: address,
                    authInfo: sdkAuthInfo,
                    completion: self.mapSdkCompletion(completion) { _ in
                        completion(.success(()))
                    }
                )
            },
            completion: completion
        )
    }

    /// SDK_12 (setAccidentTime) Передача даты и времени ДТП
    func setAccidentDate(_ date: Date, completion: @escaping (Result<Void, EuroProtocolServiceError>) -> Void) {
        authRetryableSdkRequest(
            request: { completion in
                self.logger?.debug("SDK_12 (setAccidentTime) Передача даты и времени ДТП")
                guard let sdkAuthInfo = self.sdkAuthInfo else { return completion(.failure(.sdkAuthInfoMissing)) }

                RSASDK.setAccidentTime(
                    date: date,
                    authInfo: sdkAuthInfo,
                    completion: self.mapSdkCompletion(completion) { _ in
                        completion(.success(()))
                    }
                )
            },
            completion: completion
        )
    }

    /// SDK_14 (setAccidentFirstHit) Передача места первоначального удара в ТС участника
    func setAccidentFirstHitPlace(
        participant: EuroProtocolParticipant,
        schemeType: EuroProtocolFirstBumpScheme,
        completion: @escaping (Result<Void, EuroProtocolServiceError>) -> Void
    ) {
        authRetryableSdkRequest(
            request: { completion in
                self.logger?.debug("SDK_14 (setAccidentFirstHit) Передача места первоначального удара в ТС участника")
                guard let sdkAuthInfo = self.sdkAuthInfo else { return completion(.failure(.sdkAuthInfoMissing)) }

                RSASDK.setAccidentFirstHit(
                    participant: participant.sdkType,
                    schemeType: schemeType.sdkFirstBumpType,
                    authInfo: sdkAuthInfo,
                    completion: self.mapSdkCompletion(completion) { _ in
                        completion(.success(()))
                    }
                )
            },
            completion: completion
        )
    }

    /// SDK_15 (setAccidentCircumstances) Передача кода обстоятельства ДТП
    func setAccidentCircumstances(
        participant: EuroProtocolParticipant,
        circumstances: [EuroProtocolCircumstance],
        description: String?,
        completion: @escaping (Result<Void, EuroProtocolServiceError>) -> Void
    ) {
        authRetryableSdkRequest(
            request: { completion in
                self.logger?.debug("SDK_15 (setAccidentCircumstances) Передача кода обстоятельства ДТП")
                guard let sdkAuthInfo = self.sdkAuthInfo else { return completion(.failure(.sdkAuthInfoMissing)) }

                RSASDK.setAccidentCircumstances(
                    participant: participant.sdkType,
                    types: circumstances.map { $0.sdkType },
                    description: participant == .participantA ? (description ?? "") : "Данные заполняются на ЕПГУ",
                    authInfo: sdkAuthInfo,
                    completion: self.mapSdkCompletion(completion) { _ in
                        completion(.success(()))
                    }
                )
            },
            completion: completion
        )
    }

    /// SDK_16 (setAccidentDamagedParts) Передача списка поврежденных деталей ТС
    func setAccidentDamagedParts(
        participant: EuroProtocolParticipant,
        parts: [EuroProtocolVehiclePart],
        completion: @escaping (Result<Void, EuroProtocolServiceError>) -> Void
    ) {
        authRetryableSdkRequest(
            request: { completion in
                self.logger?.debug("SDK_16 (setAccidentDamagedParts) Передача списка поврежденных деталей ТС")
                guard let sdkAuthInfo = self.sdkAuthInfo else { return completion(.failure(.sdkAuthInfoMissing)) }

                RSASDK.setAccidentDamagedParts(
                    participant: participant.sdkType,
                    types: parts.map { $0.sdkType },
                    authInfo: sdkAuthInfo,
                    completion: self.mapSdkCompletion(completion) { _ in
                        completion(.success(()))
                    }
                )
            },
            completion: completion
        )
    }

    /// SDK_17 (setAccidentWitnessInfo) Передача данных свидетелей ДТП
    func setAccidentWitnessInfo(
        first: EuroProtocolWitness?,
        second: EuroProtocolWitness?,
        completion: @escaping (Result<Void, EuroProtocolServiceError>) -> Void
    ) {
        authRetryableSdkRequest(
            request: { completion in
                self.logger?.debug("SDK_17 (setAccidentWitnessInfo) Передача данных свидетелей ДТП")
                guard let sdkAuthInfo = self.sdkAuthInfo else { return completion(.failure(.sdkAuthInfoMissing)) }

                RSASDK.setAccidentWitnessInfo(
                    first: first?.sdkType,
                    second: second?.sdkType,
                    authInfo: sdkAuthInfo,
                    completion: self.mapSdkCompletion(completion) { _ in
                        completion(.success(()))
                    }
                )
            },
            completion: completion
        )
    }

    /// SDK_18 (createDraft) Создание черновика извещения о ДТП в ЕПГУ
    func createDraft(
        disagreements: Bool,
        validateOnly: Bool,
        completion: @escaping (Result<Void, EuroProtocolServiceError>) -> Void
    ) {
        authRetryableSdkRequest(
            request: { completion in
                self.logger?.debug("SDK_18 (createDraft) Создание черновика извещения о ДТП в ЕПГУ")
                guard let sdkAuthInfo = self.sdkAuthInfo else { return completion(.failure(.sdkAuthInfoMissing)) }

                RSASDK.createDraft(
                    disagreements: disagreements,
                    create: !validateOnly,
                    authInfo: sdkAuthInfo,
                    completion: self.mapSdkCompletion(completion) { _ in
                        completion(.success(()))
                    }
                )
            },
            completion: completion
        )
    }

    /// SDK_19 (acceptDraft) Подписание черновика извещения о ДТП
    func acceptDraft(completion: @escaping (Result<Void, EuroProtocolServiceError>) -> Void) {
        authRetryableSdkRequest(
            request: { completion in
                self.logger?.debug("SDK_19 (acceptDraft) Подписание черновика извещения о ДТП")
                guard let sdkAuthInfo = self.sdkAuthInfo else { return completion(.failure(.sdkAuthInfoMissing)) }

                RSASDK.acceptDraft(
                    authInfo: sdkAuthInfo,
                    completion: self.mapSdkCompletion(completion) { [weak self] _ in
                        guard let self = self
                        else { return }
                        
                        // save date for osago event draft report
                        self.applicationSettingsService.euroProtocolClaimDate = Date()
                        completion(.success(()))
                    }
                )
            },
            completion: completion
        )
    }

    /// SDK_20 (declineDraft) Отклонение черновика извещения
    func declineDraft(completion: @escaping (Result<Void, EuroProtocolServiceError>) -> Void) {
        authRetryableSdkRequest(
            request: { completion in
                self.logger?.debug("SDK_20 (declineDraft) Отклонение черновика извещения")
                guard let sdkAuthInfo = self.sdkAuthInfo else { return completion(.failure(.sdkAuthInfoMissing)) }

                RSASDK.declineDraft(
                    authInfo: sdkAuthInfo,
                    completion: self.mapSdkCompletion(completion) { _ in
                        completion(.success(()))
                    }
                )
            },
            completion: completion
        )
    }

    // SDK_21 (sendNotice) Фиксация извещения АИС ОСАГО
    func sendNotice(completion: @escaping (Result<String, EuroProtocolServiceError>) -> Void) {
        authRetryableSdkRequest(
            request: { completion in
                self.logger?.debug("SDK_21 (sendNotice) Фиксация извещения АИС ОСАГО")
                guard let sdkAuthInfo = self.sdkAuthInfo else { return completion(.failure(.sdkAuthInfoMissing)) }

                RSASDK.sendNotice(
                    authInfo: sdkAuthInfo,
                    completion: self.mapSdkCompletion(completion) { sdkSuccess in
                        switch sdkSuccess {
                            case .noticeRegistered(let number):
                                completion(.success(String(number)))
                            default:
                                completion(.failure(.successResponseParsingError))
                        }
                    }
                )
            },
            completion: completion
        )
    }

    /// SDK_22 (setOwner) Передача данных владельца ТС
    func setOwner(
        participant: EuroProtocolParticipant,
        owner: EuroProtocolOwner,
        completion: @escaping (Result<Void, EuroProtocolServiceError>) -> Void
    ) {
        authRetryableSdkRequest(
            request: { completion in

                self.logger?.debug("SDK_22 (setOwner) Передача данных владельца ТС")
                guard let sdkAuthInfo = self.sdkAuthInfo else { return completion(.failure(.sdkAuthInfoMissing)) }

                guard let sdkTypeOwner = owner.sdkType else {
                    self.logger?.debug("Can't call SDK_22: not sufficient data")
                    return
                }

                RSASDK.setOwner(
                    participant: participant.sdkType,
                    owner: sdkTypeOwner,
                    authInfo: sdkAuthInfo,
                    completion: self.mapSdkCompletion(completion) { _ in
                        completion(.success(()))
                    }
                )
            },
            completion: completion
        )
    }

    /// SDK_23 (getCurrentContent) Чтение полей черновика
    func getCurrentDraftContentModel(
        completion: @escaping (Result<EuroProtocolCurrentDraftContentModel, EuroProtocolServiceError>) -> Void
    ) {
        authRetryableSdkRequest(
            request: { completion in
                self.logger?.debug("SDK_23 (getCurrentContent) Чтение полей черновика")
                guard let sdkAuthInfo = self.sdkAuthInfo else { return completion(.failure(.sdkAuthInfoMissing)) }

                let sdkResponse = RSASDK.getCurrentContent(authInfo: sdkAuthInfo)

                let handler = self.mapSdkCompletion(completion) { sdkSuccess in
                    let result: Result<EuroProtocolCurrentDraftContentModel, EuroProtocolServiceError> = {
                        switch sdkSuccess {
                            case .currentDraftContent(let sdkDraftModel):
                                return .success(EuroProtocolCurrentDraftContentModel.convert(from: sdkDraftModel))
                            default:
                                return .failure(.successResponseParsingError)
                        }
                    }()
                    completion(result)
                }

                handler(sdkResponse)
            },
            completion: completion
        )
    }

    /// SDK_24 (getDraftStatus) Чтение статуса черновика ЕПГУ
    func getDraftStatus(
        completion: @escaping (Result<EuroProtocolDraftStatus, EuroProtocolServiceError>) -> Void
    ) {
        authRetryableSdkRequest(
            request: { completion in
                self.logger?.debug("SDK_24 (getDraftStatus) Чтение статуса черновика ЕПГУ")
                guard let sdkAuthInfo = self.sdkAuthInfo else { return completion(.failure(.sdkAuthInfoMissing)) }

                RSASDK.getDraftStatus(
                    authInfo: sdkAuthInfo,
                    completion: self.mapSdkCompletion(completion) { sdkSuccess in
                        switch sdkSuccess {
                            case .draftStatus(let status):
                                completion(.success(.convert(from: status)))
                            default:
                                completion(.failure(.successResponseParsingError))
                        }
                    }
                )
            },
            completion: completion
        )
    }

    /// SDK_25 (getDraftContent) Чтение полей черновика ЕПГУ
    func getDraftContent(completion: @escaping (Result<Void, EuroProtocolServiceError>) -> Void) {
        authRetryableSdkRequest(
            request: { completion in
                self.logger?.debug("SDK_25 (getDraftContent) Чтение полей черновика ЕПГУ")
                guard let sdkAuthInfo = self.sdkAuthInfo else { return completion(.failure(.sdkAuthInfoMissing)) }

                RSASDK.getDraftContent(
                    authInfo: sdkAuthInfo,
                    completion: self.mapSdkCompletion(completion) { sdkSuccess in
                        switch sdkSuccess {
                            case .draftContent(_, _):
                                completion(.success(()))
                            default:
                                completion(.failure(.successResponseParsingError))
                        }
                    }
                )
            },
            completion: completion
        )
    }

    /// SDK_26 (getImage) Получение изображения по номеру документа
    func getImage(type: EuroProtocolImageType) -> Result<UIImage?, EuroProtocolServiceError> {
        self.logger?.debug("SDK_26 (getImage) Получение изображения по номеру документа")
        guard let sdkAuthInfo = sdkAuthInfo else { return .failure(.sdkAuthInfoMissing) }

        let image = RSASDK.getImage(document: type.sdkDocumentType, authInfo: sdkAuthInfo)

        return .success(image)
    }

    /// SDK_29 (setAdditionalData) Метод отправки дополнительной информации по ДТП
    func setAccidentDescription(
        participant: EuroProtocolParticipant,
        accidentDescription: String?,
        completion: @escaping (Result<Void, EuroProtocolServiceError>) -> Void
    ) {
        authRetryableSdkRequest(
            request: { completion in
                self.logger?.debug("SDK_29 (setAdditionalData) Метод отправки дополнительной информации по ДТП")
                guard let sdkAuthInfo = self.sdkAuthInfo else { return completion(.failure(.sdkAuthInfoMissing)) }

                RSASDK.setAdditionalData(
                    participant: participant.sdkType,
                    vehicleCertificate: nil,
                    driverOwnership: nil,
                    policyDamageInsured: nil,
                    // When sending nil to SDK_29 will clean the field in SDK, remove the nil-coalescing operator
                    accidentDescription: accidentDescription ?? " ",
                    authInfo: sdkAuthInfo,
                    completion: self.mapSdkCompletion(completion) { _ in
                        completion(.success(()))
                    }
                )
            },
            completion: completion
        )
    }

    // MARK: - Helpers

    private func mapSdkCompletion<T>(
        _ completion: @escaping (Result<T, EuroProtocolServiceError>) -> Void,
        successHandler: @escaping (RSASDK.Success) -> Void
    ) -> (RSAResponse) -> Void {
        let result: (RSAResponse) -> Void = { response in
            DispatchQueue.main.async {
                switch response {
                    case let sdkSuccess as RSASDK.Success:
                        self.logger?.debug("SDK Success Response: \(response), \(response.code), \(response.description)")
                        successHandler(sdkSuccess)
                    case let error as RSASDK.Error:
                        self.logger?.debug("SDK Error Response: \(response), \(response.code), \(response.description)")
                        let sdkError = RsaSdkError.convert(from: error)
                        completion(.failure(.sdkError(sdkError)))
                    case let errors as [RSASDK.ValidationError]:
                        self.logger?.debug("SDK Validation Errors Response: \(response), \(response.code), \(response.description)")
                        let sdkError = RsaSdkError.validationErrors(code: response.code, description: response.description,
                            errors: errors.map { RsaSdkValidationError.convert(from: $0) })
                        completion(.failure(.sdkError(sdkError)))
                    default:
                        self.logger?.debug("SDK Unknown Response: \(response), \(response.code), \(response.description)")
                        let sdkError = RsaSdkError.unknownError(code: response.code, description: response.description)
                        completion(.failure(.sdkError(sdkError)))
                }
            }
        }

        return result
    }

    private func authRetryableSdkRequest<T>(
        retryNumber: Int = 0,
        request: @escaping (@escaping (Result<T, EuroProtocolServiceError>) -> Void) -> Void,
        completion: @escaping (Result<T, EuroProtocolServiceError>) -> Void
    ) {
        let result: (Result<T, EuroProtocolServiceError>) -> Void = { [unowned self] response in
            self.logger?.debug("SDK auth retry number = \(retryNumber)")
            switch response {
                case .failure(.sdkError(.secureGuidExpired)):
                    guard retryNumber < Constatns.authErrorMaxRetryCount else {
                        return completion(.failure(.sdkAuthInfoMissing))
                    }
                    self.updateSdkAuthCredentials { result in
                        switch result {
                            case .success: // Retry sdk request after secure giud refresh
                                self.authRetryableSdkRequest(
                                    retryNumber: retryNumber + 1,
                                    request: request,
                                    completion: completion
                                )
                            case .failure(let error): // Throw up error
                                completion(.failure(error))
                        }
                    }

                case .failure(.sdkError(.esiaTokenExpired)):
                    guard let tokenScs = self.esiaData?.tokenScs, retryNumber < Constatns.authErrorMaxRetryCount else {
                        return completion(.failure(.sdkAuthInfoMissing))
                    }

                    self.getEsiaUser(tokenScs: tokenScs) { result in
                        switch result {
                            case .success: // Retry sdk request after esia token refresh
                                self.authRetryableSdkRequest(
                                    retryNumber: retryNumber + 1,
                                    request: request,
                                    completion: completion
                                )
                            case .failure(let error): // Throw up error
                                completion(.failure(error))
                        }
                    }
                default: // Don't retry request
                    completion(response)
            }
        }

        request(result)
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
            stopSdk { _ in }
        }
    }
}
